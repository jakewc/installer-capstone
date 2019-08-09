--
-- ENABLER DATABASE INSTALLATION SCRIPT
--
-- This script is responsible for TABLE creation and update, and is used for both
-- new and upgrade installations. Stored procedures are created by LOAD.SQL
--
-- $Header: /Enabler/Data Model/DBU 4.0/enabler.sql 100   27/04/18 5:00p Adrians $
--
-- README:
-- 1.   Table SQL operations always have two sections:
--      a. CREATE - aLL fields must be created here (including all fields in the UPDATE section)
--      b. UPDATE - table updates/upgrades derived from DBUxxx.SQL
-- 2.   Temporary Helper store procedures should be 
--		a. created at the top of this script; and
--		b. dropped at the end of this script after all the table installation is completed.
--
-- 

print '------------------------------------------------------------'
print 'ENABLER DATABASE SCHEMA...'
print CONVERT(varchar,getdate(), 121)
go

-- ------------------------------------------------------------
-- Changes based on Microsoft best practice recommendations

print ''
print 'CONFIGURING DATABASE ENGINE'
print 'Ensuring Enabler database Auto_Close option is turned off'
GO

ALTER DATABASE EnablerDB SET AUTO_CLOSE OFF WITH NO_WAIT
GO

print 'Ensuring auto shrink off for EnablerDB'
GO

ALTER DATABASE EnablerDB SET AUTO_SHRINK OFF WITH NO_WAIT
GO

DECLARE @Version AS INT
SET @Version = ( SELECT @@microsoftversion / 0x01000000 )
IF @Version >= 9.0
BEGIN
	-- SQL 2005 or Newer
	print 'Setting Page verify to checksum for EnablerDB'
	exec('ALTER DATABASE enablerdb SET PAGE_VERIFY CHECKSUM')
END 
GO

-- ------------------------------------------------------------
    
print ''
print 'Creating stored procedure: upgrade_decimal_column'
go


create procedure upgrade_decimal_column
    @the_table        varchar(100),
    @the_column       varchar(100),
    @new_width        smallint,
    @new_decimals     smallint
as

declare 
    @current_width    smallint,
    @current_decimals smallint,
    @the_conditions   varchar(100)

begin
   -- make sure the table and column exist before we do anything
   if exists ( select column_name from INFORMATION_SCHEMA.COLUMNS where 
              table_name = @the_table and column_name = @the_column and data_type = 'decimal' )
   begin
      select @current_width = ( select numeric_precision 
                                from INFORMATION_SCHEMA.COLUMNS 
                                where table_name = @the_table 
                                and column_name = @the_column )

      select @current_decimals = ( select numeric_scale from INFORMATION_SCHEMA.COLUMNS 
                                   where table_name = @the_table 
                                   and column_name = @the_column )

      -- figure out whether the column current allows nulls, if not, then make sure we apply
      -- 'not null' as a condition of the updated field.  From experimentation it seems that
      -- the default value is preserved, so we don't need to check that and reapply it.
      select @the_conditions   = ( select is_nullable 
                                   from INFORMATION_SCHEMA.COLUMNS 
                                   where table_name = @the_table 
                                   and column_name = @the_column )
      if @the_conditions = 'No' 
         select @the_conditions = 'not null'
      else
         select @the_conditions = ''

     -- see if any update to the field is required
     if ( @new_width > @current_width or @new_decimals > @current_decimals ) 
     begin
            print ' Updating decimal column: Table "' + @the_table + '" Column "' + @the_column + '"'
            declare @SQLStatement varchar(512)
            select @SQLStatement = 'alter table ' + @the_table + ' alter column ' + @the_column + 
                   ' decimal(' + CONVERT(VARCHAR,@new_width) + ',' + CONVERT(VARCHAR,@new_decimals) + ') ' + 
                   @the_conditions
            -- print @SQLStatement
            exec ( @SQLStatement )
     end
      else
      begin
         print ' Checking decimal column: Table "' + @the_table + '" Column "' + @the_column + 
              '" no update (' + CONVERT(VARCHAR, @current_width) + ',' + 
              CONVERT(VARCHAR, @current_decimals ) + ')'
      end
   end
   else
   begin
      print 'ERROR: upgrade_decimal_column could not find column "' + @the_column + '" in Table "' + @the_table + '"'
   end
end
go

-- procedure to simplify the removal of column constraints
CREATE PROCEDURE Drop_Constraints
	@table_name      varchar(100),
	@column_name     varchar(100),
	@constraint_type char(10)
AS
DECLARE
	@constraint_name nvarchar(100),
	@sql             nvarchar(2000)
BEGIN
	if @constraint_type = 'F' 
	select @constraint_name = ( select so.name 
	                              from sysobjects so
	                             inner join sysforeignkeys sf on so.id = sf.constid
	                             inner join syscolumns sc on sf.fkeyid = sc.id and sf.fkey = sc.colid
	                             where so.xtype = 'F'
	                               and OBJECT_NAME( parent_obj ) = @table_name
	                               and sc.name = @column_name  )
	else
	if @constraint_type = 'D'								   
	select @constraint_name = ( select dobj.name as def_name
	                              from syscolumns col 
	                              left outer join sysobjects dobj 
	                                on dobj.id = col.cdefault and dobj.type = 'D' 
	                             where col.id = object_id( @table_name ) 
	                               and dobj.name is not null
	                               and col.name = @column_name )
	else
		print ' ERROR: Unknown constraint type ' + @constraint_type

	if @constraint_name is null
	begin
		print ' Constraint type ' + @constraint_type + ' not matched'
	end
	else
	begin
		print ' Deleting ' + @constraint_type + ' constraint: ' + @constraint_name
		SET @sql = N'ALTER TABLE '+@table_name+' DROP CONSTRAINT ' + @constraint_name
		EXEC sp_executesql @sql
	end
END
go

--------------------------------------------------------------------------------
-- CREATING TABLES

print ''
print 'CREATING OR UPGRADING TABLES'
print ''

print 'Table: Protocol_Type'
go
IF NOT EXISTS(SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
              WHERE TABLE_NAME = 'Protocol_Type')
BEGIN
   print ' Created'
   CREATE TABLE Protocol_Type (
                Protocol_Type_ID     smallint NOT NULL,
                Protocol_Type_Name   char(20) NOT NULL,
                PRIMARY KEY (Protocol_Type_ID)
 )
END
go
 

print 'Table: Prompts'
go
IF NOT EXISTS(select table_name from information_schema.tables 
              WHERE TABLE_NAME = 'Prompts')
BEGIN
 print ' Created'
 CREATE TABLE Prompts (
        Prompt_ID            int NOT NULL,
        Prompt_Attribute     int NOT NULL,
        Prompt_Desc          nchar(40) NULL,
        Prompt_Rate          int NOT NULL,
        Prompt_Data          nchar(1000),
        PRIMARY KEY (Prompt_ID)
 )
END
ELSE
BEGIN
   IF NOT EXISTS(SELECT Column_Name FROM information_schema.columns 
                 WHERE Table_Name = 'Prompts'
                 AND Column_Name = 'Prompt_Data')
   BEGIN
      Print' Adding column: Prompt_Data'
      ALTER TABLE Prompts ADD Prompt_Data nvarchar(1000) NULL
   END

   IF EXISTS(select Column_Name from information_schema.columns 
          WHERE Table_Name = 'Prompts'
          AND Column_Name = 'Prompt_Desc')
   BEGIN
      Print ' Adding column: Prompt_Desc'
      ALTER TABLE Prompts ALTER COLUMN Prompt_Desc nchar(40) NULL
   END

  IF EXISTS(SELECT Column_Name FROM information_schema.columns
             WHERE Table_Name = 'Prompts' 
             AND Column_Name = 'prompt_text')
  BEGIN
      Print ' Removing column: Prompt_Text'
      ALTER TABLE Prompts DROP COLUMN Prompt_Text
  END

END
go


print 'Table: Tag'
go
IF NOT EXISTS(SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
   WHERE TABLE_NAME = 'Tag')
BEGIN
   PRINT ' Created'
   CREATE TABLE Tag (
      Tag_ID            int NOT NULL,
      Tag_Number        smallint NOT NULL DEFAULT 1,
      Tag_Data          nvarchar(32) NOT NULL DEFAULT ' ',
      Tag_Description   nvarchar(40) NULL,
      Tag_Disabled      int NOT NULL DEFAULT 0,
      Date_Scanned      DateTime NULL, 
      Date_Expiration   DateTime NULL, 
      PRIMARY KEY (Tag_ID)
      )
END	
ELSE
BEGIN
	-- If the Tag table already exists, then check the Tag Number column 
	IF NOT EXISTS(SELECT Table_Name FROM information_schema.columns 
	               WHERE Table_Name = 'Tag' AND column_Name = 'Tag_Number')
	BEGIN
		Print 'Adding column: Tag_Number'
		ALTER TABLE Tag ADD Tag_Number smallint NOT NULL DEFAULT 1
	END

	-- If the Tag table already exists, then check the Tag Disabled columns 	
	IF NOT EXISTS(SELECT table_name FROM information_schema.columns 
	               WHERE table_name = 'Tag' AND column_Name = 'Tag_Disabled')
	BEGIN
		Print 'Adding column: Tag_Disabled, Data_Expiration'
		ALTER TABLE Tag ADD Tag_Disabled       int NOT NULL DEFAULT 0
		ALTER TABLE Tag ADD Date_Expiration    DateTime NULL 
	END	
END
GO


print 'Table: Attendant'
go
IF NOT EXISTS(select table_name from information_schema.tables 
          WHERE TABLE_NAME = 'Attendant')
BEGIN
 print ' Created'
 CREATE TABLE Attendant (
        Attendant_ID              int NOT NULL,
        Attendant_Name            nchar(30) NOT NULL DEFAULT ' ',
        Attendant_Logon_ID        nchar(10) NOT NULL DEFAULT ' ',
        Attendant_Number          smallint NOT NULL DEFAULT 1,
        Attendant_Password        nchar(10) NOT NULL DEFAULT ' ',
        Attendant_Disabled        int NOT NULL DEFAULT 0,
        Attendant_Blocked_Reason  int NOT NULL DEFAULT 0,
        Warning_Level             decimal(12,4) NOT NULL DEFAULT 0.0,
        Alarm_Level               decimal(12,4) NOT NULL DEFAULT 0.0,
        Deleted                   smallint NOT NULL DEFAULT 0,
        Attendant_Tag_ID          int NULL DEFAULT NULL,
        Attendant_Tag_Active      bit NOT NULL DEFAULT 0,
        PRIMARY KEY (Attendant_ID),
        FOREIGN KEY (Attendant_Tag_ID) REFERENCES Tag(Tag_ID) 
 )
END
ELSE
BEGIN
   -- DBU 336
   IF NOT EXISTS(SELECT Table_Name FROM information_schema.columns 
          WHERE Table_Name = 'Attendant'
          AND Column_Name = 'Attendant_Disabled')
   BEGIN
      Print ' Adding columns: Attendant_Disabled, Attendant_Block_Reason, Warning_Level, Alarm_Level'
      ALTER TABLE Attendant ADD 
         Attendant_Disabled        int NOT NULL DEFAULT 0,
         Attendant_Blocked_Reason  int NOT NULL DEFAULT 0,
         Warning_Level             decimal(12,4) NOT NULL DEFAULT 0.0,
         Alarm_Level               decimal(12,4) NOT NULL DEFAULT 0.0
   END

   -- DBU 405
   IF NOT EXISTS(SELECT * FROM information_schema.columns WHERE table_name = 'Attendant' AND column_name = 'Deleted')
   BEGIN
      Print ' Adding column: Deleted'
      ALTER TABLE Attendant ADD Deleted smallint NOT NULL DEFAULT 0
   END

   -- DBU 407
   IF NOT EXISTS(SELECT * FROM information_schema.columns WHERE table_name = 'Attendant' AND column_name = 'Attendant_Tag_ID')
   BEGIN
      Print ' Adding columns: Attendant_Tag_ID, Attendant_Tag_Active'
      ALTER TABLE Attendant ADD Attendant_Tag_ID 	int NULL DEFAULT NULL
      ALTER TABLE Attendant ADD Attendant_Tag_Active 	bit NOT NULL DEFAULT 0

      ALTER TABLE Attendant ADD FOREIGN KEY (Attendant_Tag_ID) REFERENCES Tag(Tag_ID)
   END

End
GO
 

print 'Table: Attendant_Period'
go
IF NOT EXISTS(SELECT Table_Name FROM information_schema.tables 
              WHERE Table_Name = 'Attendant_Period')
BEGIN 
   print ' Created'
   CREATE TABLE Attendant_Period (
        Att_Period_ID        int NOT NULL,
        Attendant_ID         int NOT NULL,
        Att_Period_State     smallint NOT NULL DEFAULT 1,
        Att_Period_Open_DT   datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
        Att_Period_Close_DT  datetime NULL,
        Att_Period_Number    int NOT NULL DEFAULT 1,
        Att_Logged_On        int NOT NULL DEFAULT 0,
        PRIMARY KEY NONCLUSTERED (Att_Period_ID), 
        FOREIGN KEY (Attendant_ID) REFERENCES Attendant
 )
END
ELSE
BEGIN
   IF NOT EXISTS(SELECT NULL FROM INFORMATION_SCHEMA.COLUMNS 
                 WHERE Column_Name = 'Att_Logged_On' 
                 AND Table_Name = 'Attendant_Period')
   BEGIN
      Print' Adding columns: Att_Logged_On'
      ALTER TABLE Attendant_Period ADD Att_Logged_On int NOT NULL DEFAULT 0
   END
END
go



print 'Index: X1E1Attendant_Period on Attendant_Period.Attendant_Period_State'
IF NOT EXISTS (SELECT Name FROM sysindexes WHERE Name = 'XIE1Attendant_Period') 
BEGIN
  print ' Created'
  CREATE INDEX XIE1Attendant_Period ON Attendant_Period
  (
     Att_Period_State 
  )
END
go

 
print 'Index: XIE2Attendant_Period on Attendant_Period.Att_Period_Open_DT'
IF NOT EXISTS (SELECT Name FROM sysindexes WHERE Name = 'XIE2Attendant_Period') 
BEGIN
  print ' Created'
  CREATE INDEX XIE2Attendant_Period ON Attendant_Period
  (
     Att_Period_Open_DT
  )
END
go
 

print 'Index: XIE3Attendant_Period on Attendant_Period.Att_Period_Close_DT'
IF NOT EXISTS (SELECT Name FROM sysindexes WHERE Name = 'XIE3Attendant_Period') 
BEGIN
  print ' Created'
  CREATE INDEX XIE3Attendant_Period ON Attendant_Period
  (
     Att_Period_Close_DT
  )
END
go



print 'Table: Device_Type'
go
IF NOT EXISTS(SELECT Table_Name FROM information_schema.tables 
              WHERE Table_Name = 'Device_type')
BEGIN
   print ' Created'
   CREATE TABLE Device_type (
          Device_Type          int NOT NULL,
          Device_Name          nchar(30) NOT NULL DEFAULT ' ',
          Device_Description   nvarchar(80) NULL,
          PRIMARY KEY (Device_Type)
   )
END
go

 
print 'Table: Event_Type'
go
IF NOT EXISTS(SELECT Table_Name FROM information_schema.tables 
              WHERE Table_Name = 'Event_type')
BEGIN
   print 'Creating table: Event_Type'
   CREATE TABLE Event_type (
        Event_Type           int NOT NULL,
        Event_name           nchar(30) NOT NULL DEFAULT ' ',
        Device_Type          int NOT NULL,
        Event_description    nvarchar(80) NULL,
        Log_event            smallint NOT NULL DEFAULT 0.0,
        Display_event        smallint NOT NULL DEFAULT 0.0,
        Event_level          smallint NOT NULL DEFAULT 1,
        PRIMARY KEY (Event_Type, Device_Type), 
        FOREIGN KEY (Device_Type)
                              REFERENCES Device_type
)
END
go


 
print 'Table: Price_Profile'
go
IF NOT EXISTS(SELECT Table_Name FROM information_schema.tables 
              WHERE Table_Name = 'Price_Profile')
BEGIN 
 print 'Creating table: Price_Profile'
 CREATE TABLE Price_Profile (
        Price_Profile_ID     int NOT NULL,
        Price_Profile_Name   nchar(30) NOT NULL DEFAULT ' ',
        Scheduled_ST         datetime NOT NULL DEFAULT getdate(),
        Parent_Grade_ID      int NOT NULL,
        Deleted              smallint NOT NULL DEFAULT 0,
        PRIMARY KEY (Price_Profile_ID)
 )
END
ELSE
BEGIN
-- Parent grade id should not be null (now that we have delete tagging).
-- Can not be made into a foreign key as this causes issues with the table adapters
-- in c# and how it loads up the grade rows and parent grade id's
	IF(SELECT IS_NULLABLE FROM information_schema.columns 
	   WHERE TABLE_NAME = 'Price_Profile' AND COLUMN_NAME = 'Parent_Grade_ID') = 'YES'
	BEGIN
	  PRINT ' Modifying table: Price_Profile modifying Parent_Grade_ID to NOT NULL'
	  ALTER TABLE Price_Profile ALTER COLUMN Parent_Grade_ID INT NOT NULL
	END
	
-- We may want to add a column to denote a past, current, next and future profile.
-- this field would be set by sp_checkprices and used by the web pages to ensure that the webpages
-- is displaying what the pump server intends to do.
END
go

-- make sure its nullable, so we can add the first record when we have no grades configure
ALTER TABLE Price_Profile ALTER COLUMN parent_grade_id int NULL
go

print 'Table: Price_profile'
go
IF NOT EXISTS(SELECT column_name FROM INFORMATION_SCHEMA.columns
               WHERE Table_Name = 'price_profile' AND column_name = 'Deleted')
   BEGIN
      print ' Adding column: deleted'
      ALTER TABLE price_profile ADD Deleted smallint NOT NULL DEFAULT 0
   END 
go

print 'Table: Volume_Unit'
go
IF NOT EXISTS(SELECT Table_Name FROM INFORMATION_SCHEMA.TABLES
              WHERE Table_Name = 'Volume_Unit')
BEGIN
 print ' Created'
 CREATE TABLE Volume_Unit (
        Volume_Unit_ID             smallint NOT NULL,
        Volume_Unit_Name           nchar(20) NOT NULL DEFAULT ' ',
        Volume_Short_Name          nchar(5) NOT NULL DEFAULT ' ',        
        PRIMARY KEY (Volume_Unit_ID)
        
 )
END
go


print 'Table: Grades'
go
IF NOT EXISTS(SELECT Table_Name FROM INFORMATION_SCHEMA.TABLES
              WHERE Table_Name = 'Grades')
BEGIN
 print ' Created'
 CREATE TABLE Grades (
        Grade_ID             int NOT NULL,
        Grade_Name           nchar(20) NOT NULL DEFAULT ' ',
        Grade_Number         int NOT NULL DEFAULT 0,
        Price_Profile_ID     int NOT NULL,
        Grade_Description    nvarchar(80) NULL,
        Allocation_Limit     decimal(11,4) NOT NULL DEFAULT 0.0,
        Alloc_Limit_Type     smallint NOT NULL DEFAULT 0.0,
        Oil_Company_Code     char(19) NULL DEFAULT ' ',
        Tax_Link             int NULL,
        Group_Link           int NULL,
        Delivery_Timeout     smallint NOT NULL DEFAULT 0.0,
        Price_Pole_Segment   smallint NOT NULL DEFAULT 0.0,
        Grade_Type           smallint NOT NULL DEFAULT 1,
        Grade1_ID            int NULL DEFAULT NULL,
        Grade2_ID            int NULL DEFAULT NULL,
        Blend_Ratio          decimal(8,4) NULL DEFAULT 0.0,
        Min_Price            decimal(12,4) NOT NULL DEFAULT 0,
        Max_Price            decimal(12,4) NOT NULL DEFAULT 0,
        Loss_Tolerance       decimal(6,4) NOT NULL DEFAULT 0.50,
        Gain_Tolerance       decimal(6,4) NOT NULL DEFAULT 0.25,
        Is_Enabled           bit          not null default 1,
        Deleted              smallint NOT NULL DEFAULT 0,
        Volume_Unit_ID	     smallint,
        PRIMARY KEY (Grade_ID), 
        FOREIGN KEY (Price_Profile_ID) REFERENCES Price_Profile,
        FOREIGN KEY (Volume_Unit_ID) REFERENCES Volume_Unit
 )
END
ELSE
BEGIN

   IF NOT EXISTS(SELECT column_name FROM INFORMATION_SCHEMA.columns
                  WHERE TABLE_NAME = 'grades' AND column_name = 'Deleted')
   BEGIN
      print ' Adding column: deleted'
      ALTER TABLE Grades ADD Deleted smallint NOT NULL DEFAULT 0
   END 

   -- DBU 330
   IF NOT EXISTS(SELECT column_name FROM INFORMATION_SCHEMA.columns
   WHERE TABLE_NAME = 'grades' AND column_name = 'Grade_number')
   BEGIN
      print ' Adding column: Grade_Number'
      ALTER TABLE Grades ADD Grade_Number int NOT NULL DEFAULT 0
   END 

   -- DBU 348
   If NOT EXISTS (SELECT column_Name From INFORMATION_SCHEMA.COLUMNS where column_name = 'Min_Price' 
        AND TABLE_NAME = 'Grades' ) 
   BEGIN
     print ' Adding column: Min_Price, Max_Price'
     ALTER TABLE Grades ADD
       Min_Price        decimal(12,4) NOT NULL DEFAULT 0,
       Max_Price        decimal(12,4) NOT NULL DEFAULT 0
   END

  -- DBU 349
   IF NOT EXISTS ( SELECT Column_Name From INFORMATION_SCHEMA.COLUMNS 
        where column_name = 'Loss_Tolerance' 
        AND TABLE_NAME = 'Grades' )
   BEGIN
      print ' Adding column: Loss_Tolerance, Gain_Tolerance'
      ALTER TABLE Grades ADD
        Loss_Tolerance        decimal(6,4) NOT NULL DEFAULT 0.50,
        Gain_Tolerance        decimal(6,4) NOT NULL DEFAULT 0.25
   END

   -- DBU 320
   EXEC upgrade_decimal_column 'grades', 'allocation_limit',  11, 4
   EXEC upgrade_decimal_column 'grades', 'blend_ratio',        8, 4
   
   -- DBU 401
	IF NOT EXISTS (SELECT * FROM information_schema.columns WHERE Column_Name = 'Is_Enabled' AND Table_Name = 'Grades')
	BEGIN
		print ' Adding column Is_Enabled'
		ALTER TABLE Grades ADD Is_Enabled bit NOT NULL DEFAULT 1
	END

   -- DBU 402
   IF NOT EXISTS(SELECT column_name FROM INFORMATION_SCHEMA.columns
    WHERE TABLE_NAME = 'Grades' AND column_name = 'Volume_Unit_ID')
    BEGIN
      print ' Adding column: Volume_Unit_ID'
      ALTER TABLE Grades ADD Volume_Unit_ID smallint FOREIGN KEY (Volume_Unit_ID) REFERENCES Volume_Unit
   END 

   IF (SELECT character_maximum_length 
       FROM information_schema.columns 
       WHERE TABLE_NAME = 'grades'
       AND Column_name =  'grade_name') < 20 
   BEGIN
      Print ' Updating table: Grades  Setting Grade_Name column to 20 char'
      ALTER TABLE Grades ALTER COLUMN Grade_Name nchar(20) NOT NULL
   END
END
go

print 'Checking Grades.Grade_Number is populated with valid data'
-- cannot do this in the clause above because the deleted field may not exist when that is run
IF ( SELECT MIN(Grade_Number) FROM Grades WHERE Deleted = 0 ) = 0 
BEGIN
	Print' Updating data: Grades  Setting Grade_Number values'
   
	DECLARE @GradeNumber AS INT
	SET @GradeNumber = ( SELECT MAX(grade_number) FROM GRADES WHERE deleted = 0 )
	  	  
	UPDATE Grades 
	   SET Grade_Number = @GradeNumber,
	       @GradeNumber = @GradeNumber + 1
	 WHERE Grade_Number = 0 
	   AND Deleted = 0
END
go

PRINT 'Checking for grade number duplicates'
go

DECLARE @ID Int, @Number Int, @LastNumber Int, @NewNumber Int
DECLARE Number_Cursor CURSOR FAST_FORWARD FOR SELECT Grade_ID, Grade_Number FROM Grades WHERE Deleted = 0 ORDER BY Grade_Number, Grade_ID    
OPEN Number_Cursor
SET @LastNumber = -1
FETCH NEXT FROM Number_Cursor INTO @ID, @Number
WHILE @@Fetch_status = 0
BEGIN

    IF @Number = @LastNumber
    BEGIN
    
        -- First attempt to set the grade number as the next in sequence based on the Grade ID
        SET @NewNumber = (SELECT MAX(Grade_Number) + 1 FROM Grades WHERE Grade_ID < @ID AND Deleted = 0)
        
        IF NOT @NewNumber IS NULL
        BEGIN
            IF EXISTS (SELECT Grade_Number FROM Grades WHERE Deleted = 0 AND Grade_Number = @NewNumber )
            BEGIN
                -- Fail safe, use max grade number + 1 
                SET @NewNumber = (SELECT MAX(Grade_Number) + 1 FROM Grades WHERE Deleted = 0)
            END 
        END 
        
        PRINT 'Updating Grade_ID ' + CONVERT(varchar(10),@ID) + ' number from ' + CONVERT(varchar(10),@Number) + ' to ' + CONVERT(varchar(10),@NewNumber)
        UPDATE Grades SET Grade_Number = @NewNumber WHERE Grade_ID = @ID
    END
    
    SET @LastNumber = @Number

    FETCH NEXT FROM Number_Cursor INTO @ID, @Number
END
DEALLOCATE Number_Cursor
go

print 'Table: Pump_Protocol'
go
IF NOT EXISTS(SELECT table_name 
              FROM information_schema.tables 
              WHERE TABLE_NAME = 'Pump_protocol')
BEGIN
    Print ' Created'
    CREATE TABLE Pump_Protocol (
        Protocol_ID          int          NOT NULL,
        Protocol_Name        char(30)     NOT NULL DEFAULT ' ',
        Protocol_Type_ID     smallint     NULL,
        Protocol_Desc        varchar(80)  NOT NULL,
        Driver_Class_ID      char(38)     NOT NULL,
        Inter_Poll_Delay     smallint     NOT NULL DEFAULT 0.0,
        Poll_Type            smallint     NOT NULL DEFAULT 1,
        Line_Control         tinyint      NOT NULL DEFAULT 0.0,
        Baud_Divisor_latch   smallint     NULL DEFAULT 0.0,
        Outboard_Protocol    int          NOT NULL DEFAULT 0,
		Extended_Port_settings varchar(100) NULL DEFAULT '',
        PRIMARY KEY (Protocol_ID),  
        FOREIGN KEY (Protocol_Type_ID) REFERENCES Protocol_Type
    )
 END
 ELSE
 BEGIN
    -- DBU 300
    IF NOT EXISTS(select column_name 
                  from information_schema.columns 
                  WHERE TABLE_NAME = 'Pump_protocol'
                  AND COLUMN_NAME = 'Protocol_Type_ID')
    BEGIN
       Print' Adding columns: Protocol_Type_ID'
       ALTER TABLE pump_protocol ADD
          Protocol_Type_ID smallint NULL DEFAULT NULL
          FOREIGN KEY (Protocol_Type_ID) REFERENCES Protocol_Type
    END

    -- DBU 311
    IF NOT EXISTS(select column_name 
                  from information_schema.columns 
                  WHERE TABLE_NAME = 'pump_protocol'
                  AND COLUMN_NAME = 'Outboard_protocol')
    BEGIN
       Print' Adding columns: Outboard_Protocol'
       ALTER TABLE pump_protocol ADD Outboard_Protocol int NOT NULL DEFAULT 0
    END

	-- Enabler v4; default settings for extended ports
    IF NOT EXISTS(SELECT COLUMN_NAME 
                  FROM INFORMATION_SCHEMA.COLUMNS 
                  WHERE TABLE_NAME = 'Pump_Protocol'
                  AND COLUMN_NAME = 'Extended_Port_Settings')
    BEGIN
       PRINT ' Adding columns: Extended_Port_Settings'
       ALTER TABLE Pump_Protocol ADD Extended_Port_Settings NVARCHAR(100) NULL DEFAULT ''
    END
END
go

 
print 'Table: Pump_Type'
go
IF NOT EXISTS(SELECT Table_Name 
          FROM information_schema.tables 
          WHERE Table_Name = 'Pump_Type')
BEGIN
   print ' Created'
   CREATE TABLE Pump_Type (
        Pump_Type_ID         int NOT NULL,
        Protocol_ID          int NOT NULL,
        Pump_Type_Name       char(30) NOT NULL DEFAULT ' ',
        Pump_Type_Desc       varchar(80) NULL,
        Poll_Response_TO     smallint NOT NULL DEFAULT 0.0,
        Max_No_Responses     smallint NOT NULL DEFAULT 0.0,
        Inter_Char_Timeout   smallint NOT NULL,
        Has_Lights           smallint NOT NULL DEFAULT 1,
        Polling_Rate         smallint NOT NULL DEFAULT 1,
        Running_Total_PR     smallint NOT NULL DEFAULT 0.0,
        Has_Preset           smallint NOT NULL DEFAULT 1,
        Max_Price_Levels     smallint NOT NULL DEFAULT 1,
        Price_Format         char(10) NOT NULL DEFAULT 9999999.99,
        Max_Hoses            smallint NOT NULL DEFAULT 1,
        Value_Format         char(10) NOT NULL DEFAULT 9999999.99,
        Volume_Format        char(10) NOT NULL DEFAULT 9999999.99,
        Price_Offset         smallint NOT NULL DEFAULT 0.0,
        Value_Offset         smallint NOT NULL DEFAULT 0.0,
        Is_a_Blender         smallint NOT NULL DEFAULT 0.0,
        Default_Display_Type int      NOT NULL DEFAULT 0.0,
        Single_Hose_Auth     smallint NOT NULL DEFAULT 0.0,
        Multiplier_Support   smallint not null default 0, -- 0 = Multipliers not supported
        Supports_Tag_Reader  smallint NOT NULL DEFAULT 0,
        PRIMARY KEY (Pump_Type_ID),
        FOREIGN KEY (Protocol_ID) REFERENCES Pump_Protocol
 )
END
ELSE
BEGIN

   If NOT EXISTS ( SELECT Column_Name FROM INFORMATION_SCHEMA.COLUMNS 
      WHERE COLUMN_NAME = 'Single_Hose_Auth' 
      AND TABLE_NAME = 'Pump_Type' )
   BEGIN
      print ' Adding column: Single_Hose_Auth'
      ALTER TABLE Pump_Type ADD Single_Hose_Auth  smallint NOT NULL DEFAULT 0.0
   END
   -- DBU 300
   IF NOT EXISTS(SELECT Column_Name 
             FROM information_schema.columns 
             WHERE Table_Name = 'Pump_Type'
             AND Column_Name = 'Default_Display_Type')
   BEGIN
      print ' Adding column: Default_Display_Type'
      ALTER TABLE pump_type ADD Default_Display_Type int NOT NULL DEFAULT 0
   End
   
   IF NOT EXISTS(SELECT * FROM information_schema.columns WHERE Table_Name = 'Pump_Type' AND Column_Name = 'Multiplier_Support')
   BEGIN
       Print ' Add "Multiplier_Support" column to "Pump_Type" table'
       ALTER TABLE Pump_Type ADD Multiplier_Support smallint NOT NULL DEFAULT 0 -- 0 = Multipliers not supported
   END

   -- DBU 407
   IF NOT EXISTS(SELECT Column_Name 
             FROM information_schema.columns 
             WHERE Table_Name = 'Pump_Type'
             AND Column_Name = 'Supports_Tag_Reader')
   BEGIN
      print ' Adding column: Supports_Tag_Reader'
      ALTER TABLE Pump_Type ADD Supports_Tag_Reader smallint NOT NULL DEFAULT 0
   END

END
go

print 'Table: Cards'
go
IF NOT EXISTS(SELECT Table_Name 
              FROM information_schema.tables
              WHERE Table_Name = 'Cards') 
BEGIN
   print ' Created'
   CREATE TABLE Cards (
          Card_ID              int NOT NULL,
          Name			       char(30) NOT NULL DEFAULT ' ',
          Connection_Type      smallint NOT NULL,
          Card_Type		       smallint NOT NULL DEFAULT 0,
          Serial_Number		   char(30) NOT NULL DEFAULT '',
		  Address              int      NOT NULL DEFAULT 0,
          Settings             nvarchar(100),
          PRIMARY KEY (Card_ID)
   )
   
   print ' Adding a default PCI/Express card'
   INSERT INTO Cards ( Card_ID, Connection_Type ) VALUES ( 0, 0 )
END
go

 
print 'Table: Loops'
go
IF NOT EXISTS(SELECT Table_Name 
              FROM information_schema.tables
              WHERE Table_Name = 'loops') 
BEGIN
   print ' Created'
   CREATE TABLE Loops (
          Loop_ID              int NOT NULL,
          Protocol_ID          int NOT NULL,
          Port_Assign          smallint NOT NULL,
          Card				   SMALLINT NOT NULL DEFAULT 0,
          Channel			   SMALLINT NOT NULL DEFAULT 15,
          Port_Name            char(30) NOT NULL DEFAULT ' ',
          Connection_Type      int NOT NULL DEFAULT 0,
          Settings             nvarchar(100),
          PRIMARY KEY (Loop_ID), 
          FOREIGN KEY (Protocol_ID) REFERENCES Pump_Protocol
   )
END
ELSE
BEGIN
   -- DBU 331
   IF NOT EXISTS(select column_name 
          from information_schema.columns
          WHERE TABLE_NAME = 'loops'
          and COLUMN_NAME = 'Connection_Type')
   BEGIN 
      print ' Adding columns: Connection_Type, Settings'
      ALTER TABLE loops ADD 
         Connection_Type int NOT NULL DEFAULT 0,
         Settings nvarchar(100)
   END

   IF NOT EXISTS(SELECT column_name FROM information_schema.columns WHERE TABLE_NAME = 'loops' AND COLUMN_NAME = 'Port_Assign')
   BEGIN 
      print ' Adding column: Port_Assign'
      ALTER TABLE loops ADD Port_Assign smallint NOT NULL
   END
   ELSE
   BEGIN
      print ' Altering column: Port_Assign'
      ALTER TABLE loops ALTER COLUMN Port_Assign smallint NOT NULL
   END

   -- Enabler v4 fields (to match EMB and for future use with EIC)
   IF NOT EXISTS(SELECT column_name FROM information_schema.columns WHERE TABLE_NAME = 'Loops' AND COLUMN_NAME = 'Card')
   BEGIN 
      print ' Adding column: Card'
      ALTER TABLE Loops ADD Card SMALLINT NOT NULL DEFAULT 0
   END
   
   IF NOT EXISTS(SELECT column_name FROM information_schema.columns WHERE TABLE_NAME = 'Loops' AND COLUMN_NAME = 'Channel')
   BEGIN 
      print ' Loops  Adding column: Channel'
      ALTER TABLE Loops ADD Channel SMALLINT NOT NULL DEFAULT 15
   END

END
go


print 'Table: Pumps'
go
IF NOT EXISTS(SELECT table_name 
          FROM information_schema.tables
          WHERE Table_Name = 'Pumps')
BEGIN
 print ' Created'
 CREATE TABLE Pumps (
        Pump_ID              int NOT NULL,
        Pump_Type_ID         int NOT NULL,
        Attendant_ID         int NULL,
        Loop_ID              int NOT NULL,
        Pump_Name            nchar(30) NOT NULL DEFAULT ' ',
        Pump_Description     nvarchar(80) NULL,
        Logical_Number       smallint NOT NULL DEFAULT 0.0,
        Polling_Address      smallint NULL DEFAULT 0.0,
        Serial_Number        char(10) NOT NULL DEFAULT ' ',
        Pump_History         nvarchar(320) NULL,
        Price_1_Level        int NOT NULL DEFAULT 1,
        Price_2_Level        int NOT NULL DEFAULT 1,
        Reserved_by          int           not null default 0,
        Reserve_State        int           not null default 0,
        -- auth_limit_type      int           not null default 0, -- TODO: redundant
        -- auth_hose_mask       smallint      not null default 0, -- TODO: redundant
        -- auth_limit           decimal(12,4) not null default 0, -- TODO: redundant
        -- auth_level           smallint      not null default 0, -- TODO: redundant
        Price_Multiplier     smallint      not null default 0, -- 0 = "No multiplier"
        Value_Multiplier     smallint      not null default 0, -- 0 = "No multiplier"
        Value_Decimals		 smallint      not null default 0,
        Volume_Decimals      smallint      not null default 0,
        Price_Decimals       smallint      not null default 0,
        Deleted              smallint      NOT NULL DEFAULT 0,
        Is_Enabled			 bit		   NOT NULL DEFAULT 1,
        Is_Loaded            bit		   NOT NULL DEFAULT 1,
		Tag_Reader_Installed smallint	   NOT NULL default 0,
        PRIMARY KEY (Pump_ID), 
        FOREIGN KEY (Attendant_ID)    REFERENCES Attendant, 
        FOREIGN KEY (Pump_Type_ID)    REFERENCES Pump_Type, 
        FOREIGN KEY (Loop_ID)         REFERENCES Loops
 )

END 
ELSE
BEGIN

	-- DBU 340
	IF NOT EXISTS(SELECT column_name FROM INFORMATION_SCHEMA.COLUMNS 
	               WHERE COLUMN_NAME = 'Reserve_State' 
		       AND TABLE_NAME = 'Pumps')
	BEGIN
		print ' Adding columns: Reserved_By, Reserve_State, Auth_Limit_Type, Auth_Hose_Mask, Auth_Limit, Auth_Level'
		ALTER TABLE pumps add 
		      Reserved_by         int           not null default 0,
		      Reserve_State       int           not null default 0
		      -- auth_limit_type     int           not null default 0,
		      -- auth_hose_mask      smallint      not null default 0,
		      -- auth_limit          decimal(12,4) not null default 0,
		      -- auth_level          smallint      not null default 0
	END
   
	IF NOT EXISTS(SELECT * FROM information_schema.columns WHERE Table_Name = 'Pumps' AND Column_Name = 'Price_Multiplier')
	BEGIN
		print ' Adding columns: Price_Multiplier, Value_Multiplier'
		ALTER TABLE Pumps ADD Price_Multiplier smallint NOT NULL DEFAULT 0 -- 0 = "No multiplier"
		ALTER TABLE Pumps ADD Value_Multiplier smallint NOT NULL DEFAULT 0 -- 0 = "No multiplier"
	END

	-- DBU 405
	IF NOT EXISTS(SELECT * FROM information_schema.columns WHERE table_name = 'Pumps' AND column_name = 'Deleted')
	BEGIN
		print ' Adding column: Deleted'
		ALTER TABLE Pumps ADD Deleted smallint NOT NULL DEFAULT 0
	END

	-- DBU 408
	IF NOT EXISTS(SELECT * FROM information_schema.columns WHERE table_name = 'Pumps' AND column_name = 'Tag_Reader_Installed')
	BEGIN
		print ' Adding "Tag_Reader_Installed" column to "Pumps" table'
		ALTER TABLE Pumps ADD Tag_Reader_Installed smallint NOT NULL default 0
	END
	
-- New way of storing the pump displays instead of using the pumps display table
	IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Pumps' 
	AND COLUMN_NAME='Value_Decimals')
	BEGIN
		PRINT ' Adding columns: Value_Decimals'
		ALTER TABLE Pumps ADD Value_Decimals SMALLINT NOT NULL DEFAULT 0
	END
	
	IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Pumps' 
	AND COLUMN_NAME='Volume_Decimals')
	BEGIN
		PRINT ' Adding columns: Volume_Decimals'
		ALTER TABLE Pumps ADD Volume_Decimals SMALLINT NOT NULL DEFAULT 0
	END
	
	IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Pumps' 
	AND COLUMN_NAME='Price_Decimals')
	BEGIN
		PRINT ' Adding columns: Price_Decimals'
		ALTER TABLE Pumps ADD Price_Decimals SMALLINT NOT NULL DEFAULT 0
	END

-- New field for blocking pumps
	IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Pumps' 
	AND COLUMN_NAME='Is_Enabled')
	BEGIN
		PRINT ' Adding columns: Is_Enabled'
		ALTER TABLE Pumps ADD Is_Enabled BIT NOT NULL DEFAULT 1
	END
	
-- Remove the pump profile id
	IF EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Pumps' 
	AND COLUMN_NAME='Pump_Profile_ID')
	BEGIN
		EXEC Drop_Constraints 'Pumps', 'Pump_Profile_ID', 'F'
		PRINT ' Removing columns: Pump_Profile_ID'
		ALTER TABLE Pumps DROP COLUMN Pump_Profile_ID
	END

-- New field to determine whether the pump config should be loaded 
	IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Pumps' 
	AND COLUMN_NAME='Is_Loaded')
	BEGIN
		PRINT ' Adding columns: Is_Loaded'
		ALTER TABLE Pumps ADD Is_Loaded BIT NOT NULL DEFAULT 1
	END

    IF EXISTS(SELECT column_name FROM INFORMATION_SCHEMA.COLUMNS 
              WHERE COLUMN_NAME = 'auth_level' 
              AND TABLE_NAME = 'Pumps')
    BEGIN
		EXEC Drop_Constraints 'Pumps', 'auth_limit_type', 'D'
		print ' Removing column: Auth_Limit_Type'
		ALTER TABLE pumps DROP COLUMN auth_limit_type

		EXEC Drop_Constraints 'Pumps', 'auth_hose_mask', 'D'
		print ' Removing column: Auth_Hose_Mask'
		ALTER TABLE pumps DROP COLUMN auth_hose_mask

		EXEC Drop_Constraints 'Pumps', 'auth_limit', 'D'
		print ' Removing column: Auth_Limit'
		ALTER TABLE pumps DROP COLUMN auth_limit

		EXEC Drop_Constraints 'Pumps', 'auth_level', 'D'
		print ' Removing column: Auth_Level'
		ALTER TABLE pumps DROP COLUMN auth_level
    END

END
go

print ' Checking for display formats to convert...'
go
IF EXISTS (SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_NAME='Pumps' 
              AND COLUMN_NAME='Pump_Display_ID')
BEGIN
	-- drop the Update trigger before updating all pump rows
	-- the TR will check for duplicate logical number while updating,
	-- if pump 1 is deleted with Logical number as 1
	-- pump 2 is available with the same LN, then the updating for pump 1 will fail
	-- of course, updating pump 1 is not necessary, but for V3.40.X there is no deleted column
	-- so drop the TG in order to update is much easier than judging the field exists or not
	-- Also, add the TG back is not needed, because later on LoadEnbConfigX will do that for us
	
	IF EXISTS ( SELECT NAME FROM SYSOBJECTS WHERE NAME='TG_Pumps_Update' AND TYPE = 'TR')
	DROP TRIGGER TG_Pumps_Update
	
	DECLARE @RowCount AS INT
	SET @RowCount = (SELECT count(Pump_id) FROM pumps)
	
	DECLARE @Pump_ID AS INT
	SET @Pump_ID=1
	
	DECLARE @count AS INT
	SET @count = 1

	WHILE (@count<=@RowCount)
	BEGIN
		DECLARE @display_id AS INT
	 
		SELECT @display_id = Pump_Display_ID FROM Pumps WHERE pump_id =@Pump_ID 
		
		DECLARE @price AS char(10)
		SELECT @price = pump_price_format FROM pump_display WHERE pump_display_id = @display_id
		
		DECLARE @value AS char(10)
		SELECT @value = Pump_Value_Format FROM pump_display WHERE pump_display_id = @display_id
		
		DECLARE @volume AS char(10)
		SELECT @volume = Pump_Volume_Format FROM pump_display WHERE pump_display_id = @display_id
		
		if (@display_id is not Null)
		-- in case there is a pump has been manually or accidentally deleted
		BEGIN
			print 'Pump ID:' + cast(@Pump_ID as char(3)) + 'Price Deciamls:' + @price + 'Volume Decimals:' + @volume + 'Value Decimals:' + @value
			
			DECLARE @Price_Decimals AS INT
			DECLARE @Volume_Decimals AS INT
			DECLARE @Value_Decimals AS INT
			
			IF ( patindex('%.%',@price) > 0 )
				SET @Price_Decimals = ( len(@price) - patindex('%.%',@price))
			ELSE
				SET @Price_Decimals = 0
			
			IF ( patindex('%.%',@volume) > 0 )
				SET @Volume_Decimals = ( len(@volume) - patindex('%.%',@volume))
			ELSE
				SET @Volume_Decimals = 0
				
			IF ( patindex('%.%',@value) > 0 )
				SET @Value_Decimals = ( len(@value) - patindex('%.%',@value))
			ELSE
				SET @Value_Decimals = 0
			
			-- Update Pumps table
			UPDATE Pumps SET 
			Price_Decimals = @Price_Decimals, 
			Volume_Decimals = @Volume_Decimals,
			Value_Decimals = @Value_Decimals WHERE Pump_id = @Pump_ID
			
			SET @count = @count+1
		END
		
		SET @Pump_ID = @Pump_ID+1
	END
	
	-- Drop the Pump_Display column from the Pumps table and Drop the Pump_Display Table
	IF EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Pumps' AND COLUMN_NAME='Pump_Display_ID')
	BEGIN
	-- removing the pump display id column
		PRINT ' Removing columns: Pump_Display_ID'
		EXEC Drop_Constraints 'Pumps', 'Pump_Display_ID', 'F'
		ALTER TABLE Pumps DROP COLUMN Pump_Display_ID
	END
END
GO

IF EXISTS(select table_name from information_schema.tables 
          WHERE TABLE_NAME = 'Pump_Display')
BEGIN 
   print 'Table: Pump_Display'
   print ' Removed (obsolete)'
   DROP TABLE Pump_Display
END
go 

print 'Table: Tank_Gauge_Type'
go
IF NOT EXISTS( SELECT Table_Name FROM INFORMATION_SCHEMA.TABLES WHERE Table_Name='Tank_Gauge_Type' )
BEGIN
    print ' Created'
    CREATE TABLE Tank_Gauge_Type (
        Tank_Gauge_Type_ID      int          NOT NULL,
        Name                    char(50)     NOT NULL DEFAULT '',
        Protocol_ID             int,
        Max_Tanks               smallint,
        Max_Probe               smallint,
        Gauge_Volume_Flag       smallint     NOT NULL DEFAULT 0,
        Gauge_TC_Volume_Flag    smallint     NOT NULL DEFAULT 0,
        Water_Volume_Flag       smallint     NOT NULL DEFAULT 0,
        Temperature_Flag        smallint     NOT NULL DEFAULT 0,
        Density_Flag            smallint     NOT NULL DEFAULT 0,
        Tank_Delivery_Flag      smallint     NOT NULL DEFAULT 0,
        Poll_Response_TO        int          NOT NULL DEFAULT 0        
        PRIMARY KEY (Tank_Gauge_Type_ID),     
        FOREIGN KEY (Protocol_ID) REFERENCES Pump_Protocol
    )
END
ELSE
BEGIN
    -- Not really required as Tank_Gauge_type has not yet been released yet!
    -- DBU 400
   IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Tank_Gauge_Type' AND COLUMN_NAME='Gauge_Volume_Flag')
   BEGIN
   	print ' Adding columns: Gauge_Volume_Flag, Gauge_TC_Volume_Flag, Water_Volume_Flag, Temperature_Flag, Density_Flag, Tank_Delivery_Flag, Poll_Timer'
    ALTER TABLE Tank_Gauge_Type ADD
        Gauge_Volume_Flag       smallint     NOT NULL DEFAULT 0,
        Gauge_TC_Volume_Flag    smallint     NOT NULL DEFAULT 0,
        Water_Volume_Flag       smallint     NOT NULL DEFAULT 0,
        Temperature_Flag        smallint     NOT NULL DEFAULT 0,
        Density_Flag            smallint     NOT NULL DEFAULT 0,
        Tank_Delivery_Flag      smallint     NOT NULL DEFAULT 0,
        Poll_Response_TO        int          NOT NULL DEFAULT 0
	END
END
GO

print 'Table: Tank_Gauge'
go
IF NOT EXISTS( SELECT Table_Name FROM INFORMATION_SCHEMA.TABLES WHERE Table_Name='Tank_Gauge' )
BEGIN
    print ' Created'
    CREATE TABLE Tank_Gauge (
        Tank_Gauge_ID           int           NOT NULL,
        Name                    nvarchar(50)  NOT NULL DEFAULT '',
        Description             nvarchar(512) NOT NULL DEFAULT '',
        Tank_Gauge_Type_ID      int,
        Tank_Gauge_Number       int,
        Loop_ID                 int,
        Polling_Address         int, 
        PRIMARY KEY (Tank_Gauge_ID), 
        FOREIGN KEY (Tank_Gauge_Type_ID) REFERENCES Tank_Gauge_Type,
        FOREIGN KEY (Loop_ID)            REFERENCES Loops
    ) 
END
GO

print 'Table: Tank_Type'
go
IF NOT EXISTS( SELECT Table_Name FROM INFORMATION_SCHEMA.TABLES WHERE Table_Name='Tank_Type' )
BEGIN
    print ' Created'
    CREATE TABLE Tank_Type (
        Tank_Type_ID            int          NOT NULL,
        Tank_Type_Name          nchar(30)    NOT NULL DEFAULT '',
        PRIMARY KEY (Tank_Type_ID)     
    )
END
GO

print 'Table: Tank_Connection_Type'
go
IF NOT EXISTS( SELECT Table_Name FROM INFORMATION_SCHEMA.TABLES WHERE Table_Name='Tank_Connection_Type' )
BEGIN
    print ' Created'
    CREATE TABLE Tank_Connection_Type (
        Tank_Connection_Type_ID     int           NOT NULL,
        Tank_Connection_Type_Name   nchar(30)     NOT NULL DEFAULT '',
        PRIMARY KEY (Tank_Connection_Type_ID)
    )
END
GO

print 'Table: Tank_Probe_Status'
go
IF NOT EXISTS( SELECT Table_Name FROM INFORMATION_SCHEMA.TABLES WHERE Table_Name='Tank_Probe_Status' )
BEGIN
    print ' Created'
    CREATE TABLE Tank_Probe_Status (
        Tank_Probe_Status_ID        int          NOT NULL,
        Tank_Probe_Status_Name      nchar(30)    NOT NULL DEFAULT '',
        PRIMARY KEY (Tank_Probe_Status_ID),     
    )
END
GO

print 'Table: Tank_Delivery_State'
go
IF NOT EXISTS( SELECT Table_Name FROM INFORMATION_SCHEMA.TABLES WHERE Table_Name='Tank_Delivery_State' )
BEGIN
   print ' Created'
    CREATE TABLE Tank_Delivery_State (
        Tank_Delivery_State_ID      int          NOT NULL,
        Tank_Delivery_State_Name    nchar(30)    NOT NULL DEFAULT '',
        PRIMARY KEY (Tank_Delivery_State_ID),     
    )
END
GO

-- Adding Tank_Probe_Status
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Add_Tank_Probe_Status' AND type = 'P')
   DROP PROCEDURE Add_Tank_Probe_Status
GO

CREATE PROCEDURE Add_Tank_Probe_Status
	@Tank_Probe_Status_ID		int,
	@Name				NCHAR(50)
AS
BEGIN
  IF NOT EXISTS( SELECT Table_Name FROM INFORMATION_SCHEMA.TABLES WHERE Table_Name='Tank_Probe_Status' )
  BEGIN
		print 'Tank_Probe_Status Table does not exist'
		RETURN
  END

  SET @Name = LEFT(@Name,50)

  PRINT 'Tank Type: ' + RTRIM(cast( @Tank_Probe_Status_ID as char )) + ' ' + @Name

  IF ( SELECT count(Tank_Probe_Status_ID) FROM Tank_Probe_Status WHERE Tank_Probe_Status_ID = @Tank_Probe_Status_ID  ) < 1
  BEGIN
	-- add new record
	print 'Adding new record for Tank_Probe_Status' + RTRIM(cast( @Tank_Probe_Status_ID as char ))
        INSERT INTO Tank_Probe_Status
			( Tank_Probe_Status_ID, Tank_Probe_Status_Name )
        VALUES
			( @Tank_Probe_Status_ID, '' )
  END

  UPDATE Tank_Probe_Status
     SET Tank_Probe_Status_Name			= @Name
   WHERE Tank_Probe_Status_ID = @Tank_Probe_Status_ID
END
GO

-- Adding Tank_Connection_Types 
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Add_Tank_Connection_Type' AND type = 'P')
   DROP PROCEDURE Add_Tank_Connection_Type
GO

CREATE PROCEDURE Add_Tank_Connection_Type
	@Tank_Connection_Type_ID		int,
	@Name				NCHAR(50)
AS
BEGIN
  IF NOT EXISTS( SELECT Table_Name FROM INFORMATION_SCHEMA.TABLES WHERE Table_Name='Tank_Connection_Type' )
  BEGIN
		print 'Tank_Connection_Type Table does not exist'
		RETURN
  END

  SET @Name = LEFT(@Name,50)

  PRINT 'Tank Type: ' + RTRIM(cast( @Tank_Connection_Type_ID as char )) + ' ' + @Name

  IF ( SELECT count(Tank_Connection_Type_ID) FROM Tank_Connection_Type WHERE Tank_Connection_Type_ID = @Tank_Connection_Type_ID  ) < 1
  BEGIN
	-- add new record
	print 'Adding new record for Tank_Connection_Type' + RTRIM(cast( @Tank_Connection_Type_ID as char ))
        INSERT INTO Tank_Connection_Type
			( Tank_Connection_Type_ID, Tank_Connection_Type_Name )
        VALUES
			( @Tank_Connection_Type_ID, '' )
  END

  UPDATE Tank_Connection_Type
     SET Tank_Connection_Type_Name		= @Name
   WHERE Tank_Connection_Type_ID = @Tank_Connection_Type_ID
END
GO

-- Adding Tank_Types 
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Add_Tank_Type' AND type = 'P')
   DROP PROCEDURE Add_Tank_Type
GO

CREATE PROCEDURE Add_Tank_Type
	@Tank_Type_ID		int,
	@Name				NCHAR(50)
AS
BEGIN
  IF NOT EXISTS( SELECT Table_Name FROM INFORMATION_SCHEMA.TABLES WHERE Table_Name='Tank_Type' )
  BEGIN
		print 'Tank_Type Table does not exist'
		RETURN
  END

  SET @Name = LEFT(@Name,50)

  PRINT 'Tank Type: ' + RTRIM(cast( @Tank_Type_ID as char )) + ' ' + @Name

  IF ( SELECT count(Tank_Type_ID) FROM Tank_Type WHERE Tank_Type_ID = @Tank_Type_ID  ) < 1
  BEGIN
	-- add new record
	print 'Adding new record for Tank_Type' + RTRIM(cast( @Tank_Type_ID as char ))
        INSERT INTO Tank_Type
			( Tank_Type_ID, Tank_Type_Name )
        VALUES
			( @Tank_Type_ID, '' )
  END

  UPDATE Tank_Type
     SET Tank_Type_Name		= @Name
   WHERE Tank_Type_ID = @Tank_Type_ID
END
GO

PRINT 'Adding Tank Probe Status'
EXEC Add_Tank_Probe_Status
	@Tank_Probe_Status_ID	=1,    
	@Name			='Not Configured'
EXEC Add_Tank_Probe_Status
	@Tank_Probe_Status_ID	=2,
	@Name			='Online'
EXEC Add_Tank_Probe_Status
	@Tank_Probe_Status_ID	=3,
	@Name			='Offline'
EXEC Add_Tank_Probe_Status
	@Tank_Probe_Status_ID	=4,
	@Name			='Unknown'
GO


PRINT 'Adding Tank Connection Types'
EXEC Add_Tank_Connection_Type
	@Tank_Connection_Type_ID	=1,
	@Name				='None'
EXEC Add_Tank_Connection_Type
	@Tank_Connection_Type_ID	=2,
	@Name				='Manifolded - Line Syphon'
EXEC Add_Tank_Connection_Type
	@Tank_Connection_Type_ID	=3,
	@Name				='Manifolded - tank Syphon'
GO

PRINT 'Adding Tank Types'
EXEC Add_Tank_Type
	@Tank_Type_ID	=1,
	@Name			='Manual Dip'
EXEC Add_Tank_Type
	@Tank_Type_ID	=2,
	@Name			='Gauged'
-- Tank_Type_ID 3 intentionally skipped! Reserved future use (AutoCalibrating Tanks)
EXEC Add_Tank_Type
	@Tank_Type_ID	=4,
	@Name			='Gauged - Software Alarms'
GO


print 'Table: Tanks'
go
If NOT EXISTS ( SELECT Table_Name From INFORMATION_SCHEMA.TABLES 
    where table_name = 'Tanks')
BEGIN
   print ' Created'
   CREATE TABLE Tanks (
        Tank_ID              int           NOT NULL,
        Grade_ID             int           NOT NULL,
        Tank_Name            nchar(30)     NOT NULL DEFAULT ' ',
        Tank_Number          int           NOT NULL DEFAULT 0,
        Tank_Description     nvarchar(80)  NULL,
        Physical_Label		 nvarchar(50)  NULL,
        Capacity             decimal(12,4) NOT NULL DEFAULT 0.0,
        Gauge_Level          decimal(12,4) NOT NULL DEFAULT 0.0,
        Temperature          decimal(8,4)  NOT NULL DEFAULT 0.0,
        Gauge_TC_Volume      decimal(12,4) NOT NULL DEFAULT 0.0,
        Water_Level          decimal(12,4) NOT NULL DEFAULT 0.0,
        Dip_Level            decimal(12,4) NOT NULL DEFAULT 0.0,
        Gauge_Volume         decimal(12,4) NOT NULL DEFAULT 0.0,
        Theoretical_Volume   decimal(15,4) NOT NULL DEFAULT 0.0,
        Dip_Volume           decimal(12,4) NOT NULL DEFAULT 0.0,
        Average_Cost         decimal(12,4) NOT NULL DEFAULT 0.0,
        Strapped_Tank_ID     int           NULL,
        Probe_Number         smallint      NULL     DEFAULT 0.0,
        Ullage               decimal(12,4) NOT NULL DEFAULT 0.0,
        Water_Volume         decimal(12,4) NOT NULL DEFAULT 0.0,
        Gauge_alarms         char(50)      NOT NULL DEFAULT ' ',
        Diameter             decimal(10,4) NOT NULL DEFAULT 0.0,
        Low_Volume_Warning   decimal(12,4) NOT NULL DEFAULT 0.0,
        Low_Volume_Alarm     decimal(12,4) NOT NULL DEFAULT 0.0,
        Hi_Volume_Warning    decimal(12,4) NOT NULL DEFAULT 0.0,
        Hi_Volume_Alarm      decimal(12,4) NOT NULL DEFAULT 0.0,
        Hi_Water_Alarm       decimal(8,4)  NOT NULL DEFAULT 0.0,
        Density              decimal(12,4) NULL,
        Tank_Gauge_ID           int        NULL,
        Tank_Type_ID            int        DEFAULT 1,
        Tank_Connection_Type_ID int        NOT NULL DEFAULT 1,
        Tank_Probe_Status_ID    int        DEFAULT 1,
        Tank_Readings_DT        datetime,
        Tank_Delivery_State_ID  int        DEFAULT 1,
        Pump_Delivery_State     tinyint    DEFAULT 0,
        Hi_Temperature       decimal(8,4)  NOT NULL DEFAULT 0.0,
        Low_Temperature      decimal(8,4)  NOT NULL DEFAULT 0.0,
        Loss_Tolerance_Vol   decimal(12,4) NOT NULL DEFAULT 0.0,
        Gain_Tolerance_Vol   decimal(12,4) NOT NULL DEFAULT 0.0,
        Deleted	             smallint      NOT NULL DEFAULT 0,
        Auto_Disable         bit NOT NULL DEFAULT 1,
        Is_Enabled           bit NOT NULL DEFAULT 1,
        PRIMARY KEY (Tank_ID), 
        FOREIGN KEY (Grade_ID)                REFERENCES Grades,
        FOREIGN KEY (Tank_Gauge_ID)           REFERENCES Tank_Gauge,
        FOREIGN KEY (Tank_Type_ID)            REFERENCES Tank_Type,
        FOREIGN KEY (Tank_Connection_Type_ID) REFERENCES Tank_Connection_Type,
        FOREIGN KEY (Tank_Probe_Status_ID)    REFERENCES Tank_Probe_Status,
        FOREIGN KEY (Tank_Delivery_State_ID)  REFERENCES Tank_Delivery_State 
   )
END    
ELSE
BEGIN
   IF NOT EXISTS ( SELECT Column_Name From INFORMATION_SCHEMA.COLUMNS 
        WHERE COLUMN_NAME = 'Probe_Number' 
          AND TABLE_NAME = 'Tanks' ) 
   BEGIN
      Print' Adding columns: Probe_Number'
      ALTER TABLE Tanks ADD Probe_Number smallint NULL DEFAULT 0.0
   END

   -- DBU320
   if (select numeric_precision 
       from information_schema.columns 
       WHERE TABLE_NAME = 'tanks'
       and column_name = 'capacity') < 12
   BEGIN
      exec upgrade_decimal_column 'tanks', 'capacity',           12, 4
      exec upgrade_decimal_column 'tanks', 'gauge_level',        12, 4
      exec upgrade_decimal_column 'tanks', 'temperature',         8, 4
      exec upgrade_decimal_column 'tanks', 'gauge_tc_volume',    12, 4
      exec upgrade_decimal_column 'tanks', 'water_level',        12, 4
      exec upgrade_decimal_column 'tanks', 'dip_level',          12, 4
      exec upgrade_decimal_column 'tanks', 'gauge_volume',       12, 4
      exec upgrade_decimal_column 'tanks', 'dip_volume',         12, 4
      exec upgrade_decimal_column 'tanks', 'average_cost',       12, 4
      exec upgrade_decimal_column 'tanks', 'ullage',             12, 4
      exec upgrade_decimal_column 'tanks', 'water_volume',       12, 4
      exec upgrade_decimal_column 'tanks', 'diameter',           10, 4
      exec upgrade_decimal_column 'tanks', 'low_volume_warning', 12, 4
      exec upgrade_decimal_column 'tanks', 'low_volume_alarm',   12, 4
      exec upgrade_decimal_column 'tanks', 'hi_volume_warning',  12, 4
      exec upgrade_decimal_column 'tanks', 'hi_volume_alarm',    12, 4
      exec upgrade_decimal_column 'tanks', 'hi_water_alarm',      8, 4
   End

   -- DBU 350
   If NOT EXISTS ( SELECT Column_Name From INFORMATION_SCHEMA.COLUMNS 
        where column_name = 'Density' 
        AND TABLE_NAME = 'Tanks' ) 
   BEGIN
      Print' Adding columns: Density'
      ALTER TABLE Tanks ADD
         Density            decimal(12,4) NULL
   END

   -- DBU 358
   IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Tanks' AND COLUMN_NAME='Tank_Gauge_ID')
   BEGIN
       print ' Adding columns: Tank_Gauge_ID'
          ALTER TABLE Tanks ADD Tank_Gauge_ID int FOREIGN KEY (Tank_Gauge_ID) REFERENCES Tank_Gauge
   END

   -- DBU 400
   IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Tanks' AND COLUMN_NAME='Tank_Type_ID')
   BEGIN

		PRINT ' Adding columns: Tank_Type_ID, Tank_Connection_Type_ID, Tank_Probe_Status_ID, Tank_Readings_DT, Tank_Delivery_State_ID, Pump_Delivery_State, Hi_Temperature, Low_Temperature'
		ALTER TABLE Tanks 
		  ADD Tank_Type_ID             int          FOREIGN KEY (Tank_Type_ID) REFERENCES Tank_Type DEFAULT 1,
		      Tank_Connection_Type_ID  int          FOREIGN KEY (Tank_Connection_Type_ID) REFERENCES Tank_Connection_Type DEFAULT 1,
		      Tank_Probe_Status_ID     int          FOREIGN KEY (Tank_Probe_Status_ID)  REFERENCES Tank_Probe_Status DEFAULT 1,
		      Tank_Readings_DT         datetime,
		      Tank_Delivery_State_ID   int          FOREIGN KEY (Tank_Delivery_State_ID)  REFERENCES Tank_Delivery_State DEFAULT 1,
		      Pump_Delivery_State      tinyint      DEFAULT 0,
		      Hi_Temperature           decimal(8,4) NOT NULL DEFAULT 0.0,
		      Low_Temperature          decimal(8,4) NOT NULL DEFAULT 0.0 
   END

   IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Tanks' AND COLUMN_NAME='Physical_Label')
   BEGIN
		PRINT ' Adding columns: Tank_Label'
   		ALTER TABLE Tanks ADD 
			  Physical_Label		 nvarchar(50)  NULL
   END

   IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Tanks' AND COLUMN_NAME='Loss_Tolerance_Vol')
   BEGIN
		PRINT ' Adding columns: Loss_Tolerance_Vol, Gain_Tolerance_Vol'
   		ALTER TABLE Tanks ADD 
      		  Loss_Tolerance_Vol        decimal(12,4) NOT NULL DEFAULT 0.0,
      		  Gain_Tolerance_Vol        decimal(12,4) NOT NULL DEFAULT 0.0
   END

   -- DBU 405
   IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Tanks' AND COLUMN_NAME='Deleted')
   BEGIN
     PRINT ' Adding column: Deleted'
     ALTER TABLE Tanks ADD Deleted smallint NOT NULL DEFAULT 0
   END

   -- DBU 406
   IF NOT EXISTS(SELECT * FROM information_schema.columns WHERE table_name = 'Tanks' AND column_name = 'Auto_Disable')
   BEGIN
      Print ' Adding column: Auto_Disable'
      ALTER TABLE tanks ADD Auto_Disable bit NOT NULL DEFAULT 1
   END

   IF NOT EXISTS(SELECT * FROM information_schema.columns WHERE table_name = 'Tanks' AND column_name = 'Is_Enabled')
   BEGIN
      Print ' Adding column: Is_Enabled'
      ALTER TABLE tanks ADD Is_Enabled bit NOT NULL DEFAULT 1
   END

	-- DBU 408
   IF (SELECT numeric_precision 
         FROM information_schema.columns 
        WHERE TABLE_NAME = 'tanks'
          AND COLUMN_NAME = 'theoretical_volume') < 15
   BEGIN
      EXEC upgrade_decimal_column 'tanks', 'theoretical_volume', 15, 4
   END

   -- NOTE: do NOT add Tank upgrade statements here, there are more steps to go before 
   --       the tank table upgrade is done (see below)   
END
go

print ' Updates to ensure new fields match defaults'
UPDATE Tanks SET Tank_Connection_Type_ID = 1 WHERE isnull(Tank_Connection_Type_ID,0)=0
UPDATE Tanks SET Tank_Probe_Status_ID = 1    WHERE isnull(Tank_Probe_Status_ID,0)=0
UPDATE Tanks SET Tank_Type_ID = 1            WHERE isnull(Tank_Type_ID,0)=0
go

print ' Checking tank_type configuration is valid'
go
IF EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Tanks' AND COLUMN_NAME='Tank_Type')
IF EXISTS (SELECT Tank_ID FROM Tanks WHERE IsNull(Tank_Type_ID,0)=0)
BEGIN
		-- upgrade from older database - we just added the new Tank_Type_ID field (above) now
		-- we need to populate the column based on the previous Tank_Type field setting
		-- Default Tank Connection to 1
		UPDATE Tanks SET Tank_Connection_Type_ID=1  
        DECLARE @SQLStmt varchar(512)
		--DECLARE @StrappedTank AS INT
		-- For Strapped/Switched Tanks
		--SET @StrappedTank=(SELECT Top 1 Tank_ID FROM tanks WHERE Tank_Type>=5)

		--IF @StrappedTank IS NOT NULL
		--BEGIN
				-- start by setting all Tank_Type_ID fields to 'manual dip'
				UPDATE Tanks SET Tank_Type_ID=1 WHERE Tank_Type>=5
				-- Null Strapped Tank IDs
				UPDATE Tanks SET Tank_Connection_Type_ID=1 WHERE Tank_Type>=5 AND ISNULL(Strapped_Tank_ID,0)=0		
				-- Valid Strapped Tank IDs
				UPDATE Tanks SET Tank_Connection_Type_ID=2 WHERE Tank_Type>=5 AND NOT ISNULL(Strapped_Tank_ID,0)=0

				-- Fetch Parent Tank Type, Tank Gauge ID, Probe Number
				UPDATE Tanks SET Tank_Type_ID=Parent_Tank_Type,Tank_Gauge_ID=Parent_Tank_Gauge_ID, Probe_Number = Parent_Probe_Number From 
					   (SELECT Tank_id AS Parent_Tank_ID,Tank_Type AS Parent_Tank_Type,Tank_Gauge_ID AS Parent_Tank_Gauge_ID, Probe_Number AS Parent_Probe_Number
					      FROM Tanks 
					     WHERE Tank_Type in (1,2,3,4) 
						   AND Tank_ID in (SELECT Strapped_Tank_ID FROM Tanks WHERE Tank_Type>=5 AND NOT ISNULL(Strapped_Tank_ID,0)=0)) 
				    AS Parent_Tank 
				 WHERE Tank_Type>=5 AND Strapped_Tank_ID=Parent_Tank_ID

				-- Strapped to Strapped? SET to Normal Tank Type, and No Tank Connection
				UPDATE Tanks SET Tank_Type_ID=1,Tank_Connection_Type_ID=1 From 
					   (SELECT Tank_id AS Parent_Tank_ID,Tank_Type AS Parent_Tank_Type FROM Tanks WHERE Tank_Type>=5 And Tank_ID in (SELECT Strapped_Tank_ID FROM Tanks WHERE Tank_Type>=5 AND NOT ISNULL(Strapped_Tank_ID,0)=0)) 
				    AS Parent_Tank 
				 WHERE Tank_Type>=5 
				   AND Strapped_Tank_ID=Parent_Tank_ID
		--END
END
go

print ' Checking Tanks.Tank_Connection_Type_ID does not allow NULL'
IF(SELECT IS_NULLABLE FROM information_schema.columns 
   WHERE TABLE_NAME = 'Tanks' AND COLUMN_NAME = 'Tank_Connection_Type_ID') = 'YES'
BEGIN
	PRINT ' Modifying table: Tanks modifying Tank_Connection_Type_ID to NOT NULL'
	ALTER TABLE Tanks ALTER COLUMN Tank_Connection_Type_ID INT NOT NULL 
END
go

IF EXISTS(SELECT * FROM information_schema.columns WHERE 
	TABLE_NAME = 'Tanks' AND COLUMN_NAME = 'Tank_Type')
BEGIN
	EXEC Drop_Constraints 'Tanks', 'Tank_Type', 'D'
	Print ' Removing Tank_Type column from Tanks table'
	ALTER TABLE tanks DROP COLUMN Tank_Type
END
go

IF NOT EXISTS ( SELECT * FROM sysobjects WHERE name = 'FK__Tanks__Strapping' )
BEGIN
	PRINT ' Adding FK: Strapping_Tank_ID'
	ALTER TABLE Tanks ADD CONSTRAINT FK__Tanks__Strapping FOREIGN KEY (Strapped_Tank_ID) REFERENCES Tanks(Tank_ID)
END
go

-- In older database its posible to have duplicate tank numbers which is not allowed in V4
PRINT 'Checking for tank number duplicates'
go

DECLARE @ID Int, @Number Int, @LastNumber Int, @NewNumber Int
DECLARE Number_Cursor CURSOR FAST_FORWARD FOR SELECT Tank_ID, Tank_Number FROM Tanks WHERE Deleted = 0 ORDER BY Tank_Number, Tank_ID    
OPEN Number_Cursor
SET @LastNumber = -1
FETCH NEXT FROM Number_Cursor INTO @ID, @Number
WHILE @@Fetch_status = 0
BEGIN

    IF @Number = @LastNumber
    BEGIN
        -- First attempt to set the tank number as the next in sequence based on the tank ID
        SET @NewNumber = (SELECT MAX(Tank_Number) + 1 FROM Tanks WHERE Tank_ID < @ID AND Deleted = 0)
        
        IF NOT @NewNumber IS NULL
        BEGIN
            IF EXISTS (SELECT Tank_Number FROM Tanks WHERE Deleted = 0 AND Tank_Number = @NewNumber )
            BEGIN
                -- Fail safe, use max grade number + 1 
                SET @NewNumber = (SELECT MAX(Tank_Number) + 1 FROM Tanks WHERE Deleted = 0)
            END 
        END 
        
        PRINT 'Updating Tank_ID ' + CONVERT(varchar(10),@ID) + ' number from ' + CONVERT(varchar(10),@Number) + ' to ' + CONVERT(varchar(10),@NewNumber)
        UPDATE Tanks SET Tank_Number = @NewNumber WHERE Tank_ID = @ID
    END
    
    SET @LastNumber = @Number

    FETCH NEXT FROM Number_Cursor INTO @ID, @Number
END
DEALLOCATE Number_Cursor
go


-- end of Tanks table updates

print 'Table: Hose_Total_State'
go
IF NOT EXISTS( SELECT Table_Name FROM INFORMATION_SCHEMA.TABLES WHERE Table_Name='Hose_Total_State' )
BEGIN
    print ' Created'
    CREATE TABLE Hose_Total_State (
        Hose_Total_State_ID     tinyint      NOT NULL,
        Hose_Total_State_Name   nchar(30)    NOT NULL DEFAULT '',
        PRIMARY KEY (Hose_Total_State_ID),     
    )
END
GO
 
print 'Table: Hoses'
go
IF NOT EXISTS(select table_name 
          from information_schema.tables
          WHERE TABLE_NAME = 'Hoses')
Begin
   print ' Created'
   CREATE TABLE Hoses (
        Hose_ID              int NOT NULL,
        Pump_ID              int NOT NULL,
        Grade_ID             int NOT NULL,
        Tank_ID              int NOT NULL,
        Volume_Total         decimal(15,4) NOT NULL DEFAULT 0.0,
        Tank2_ID             int NULL DEFAULT NULL,
        Hose_number          int NOT NULL DEFAULT 1,
        Mechanical_Total     decimal(15,4) NOT NULL DEFAULT 0.0,
        Money_Total          decimal(15,4) NOT NULL DEFAULT 0.0,
        Theoretical_Total    decimal(15,4) NOT NULL DEFAULT 0.0,
        Volume_Total2        DECIMAL(15,4) NULL DEFAULT NULL,
        Money_Total2         DECIMAL(15,4) NULL DEFAULT NULL,
        Theoretical_Total2   DECIMAL(15,4) NULL DEFAULT NULL,
        Blend_Type           INT           NOT NULL DEFAULT 0,
        Volume_Total_Turnover_Correction   decimal(15,4)   NOT NULL DEFAULT 0.0,
        Money_Total_Turnover_Correction    decimal(15,4)   NOT NULL DEFAULT 0.0,
        Volume_Total2_Turnover_Correction  decimal(15,4)   NOT NULL DEFAULT 0.0,
        Volume_Total_State_ID  tinyint     DEFAULT 1,
        Money_Total_State_ID   tinyint     DEFAULT 1,
        Volume_Total2_State_ID tinyint     DEFAULT 1,
        Deleted              smallint      NOT NULL DEFAULT 0,
        Volume_Total1	     DECIMAL(15,4) NULL DEFAULT NULL,
        Money_Total1	     DECIMAL(15,4) NULL DEFAULT NULL,
        Is_Enabled           BIT	NOT NULL DEFAULT 1,
        PRIMARY KEY (Hose_ID), 
        FOREIGN KEY (Grade_ID) REFERENCES Grades, 
        FOREIGN KEY (Tank_ID)  REFERENCES Tanks, 
        FOREIGN KEY (Pump_ID)  REFERENCES Pumps,
        FOREIGN KEY (Volume_Total_State_ID) REFERENCES Hose_Total_State,
        FOREIGN KEY (Money_Total_State_ID) REFERENCES Hose_Total_State,
        FOREIGN KEY (Volume_Total2_State_ID) REFERENCES Hose_Total_State
 )
End
Else
Begin
   -- DBU 335
   IF NOT EXISTS(SELECT NULL FROM INFORMATION_SCHEMA.COLUMNS 
                 WHERE COLUMN_NAME = 'Volume_Total2' 
                 AND TABLE_NAME = 'Hoses')
   BEGIN
       print ' Adding column: Volume_Total2'
       ALTER TABLE Hoses ADD Volume_Total2 DECIMAL(15,4) NULL DEFAULT NULL
   END

   IF NOT EXISTS(SELECT NULL FROM INFORMATION_SCHEMA.COLUMNS
                 WHERE COLUMN_NAME = 'Money_Total2' 
                 AND TABLE_NAME = 'Hoses')
   BEGIN
       print ' Adding columns: Money_Total2, Theoretical_Total2'
      ALTER TABLE Hoses ADD 
         Money_Total2 DECIMAL(15,4)       NULL DEFAULT NULL,
         Theoretical_Total2 DECIMAL(15,4) NULL DEFAULT NULL 
   END

   /* Hoses -> BlendType           */
   /* 0 - Not Blender              */
   /* 1 - Blender (before meter)   */
   /* 2 - Blender (after meter)    */
   IF NOT EXISTS(SELECT NULL FROM INFORMATION_SCHEMA.COLUMNS 
                 WHERE COLUMN_NAME = 'Blend_Type'
                 AND TABLE_NAME = 'Hoses')
   BEGIN
      print ' Hoses  Adding column: Blend_Type'
      ALTER TABLE Hoses ADD Blend_Type INT NOT NULL DEFAULT 0
   END
   
   if (select numeric_precision 
       from information_schema.columns 
       WHERE TABLE_NAME = 'hoses'
       and column_name = 'volume_total') < 15
   Begin
      -- DBU 320
      exec upgrade_decimal_column 'hoses', 'volume_total',       15, 4
      exec upgrade_decimal_column 'hoses', 'mechanical_total',   15, 4
      exec upgrade_decimal_column 'hoses', 'money_total',        15, 4
      exec upgrade_decimal_column 'hoses', 'theoretical_total',  15, 4

     -- DBU 340
      exec upgrade_decimal_column 'hoses', 'Volume_Total2',      15, 4
      exec upgrade_decimal_column 'hoses', 'Money_Total2',       15, 4
      exec upgrade_decimal_column 'hoses', 'Theoretical_Total2', 15, 4
   End

   -- DBU 400
   IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Hoses' AND COLUMN_NAME='Volume_Total_State_ID')
   BEGIN
      PRINT ' Adding columns: Volume_Total_Turnover_Correction, Money_Total_Turnover_Correction, Volume_Total2_Turnover_Correction, Volume_Total_State_ID, Money_Total_State_ID, Volume_Total2_State_ID'
      ALTER TABLE Hoses ADD
          Volume_Total_Turnover_Correction  decimal(15,4)   NOT NULL DEFAULT 0.0,
          Money_Total_Turnover_Correction   decimal(15,4)   NOT NULL DEFAULT 0.0,
          Volume_Total2_Turnover_Correction decimal(15,4)   NOT NULL DEFAULT 0.0,
          Volume_Total_State_ID  tinyint         FOREIGN KEY (Volume_Total_State_ID)  REFERENCES Hose_Total_State DEFAULT 1,
          Money_Total_State_ID   tinyint         FOREIGN KEY (Money_Total_State_ID)   REFERENCES Hose_Total_State DEFAULT 1,
          Volume_Total2_State_ID tinyint         FOREIGN KEY (Volume_Total2_State_ID) REFERENCES Hose_Total_State DEFAULT 1
   END

   -- DBU 405
   IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Hoses' AND COLUMN_NAME='Deleted')
   BEGIN
      PRINT ' Adding columns: Deleted'
      ALTER TABLE Hoses ADD Deleted smallint NOT NULL DEFAULT 0
   END

   -- DBU 407 ITLCR218 PostMix Fuels 
   IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Hoses' AND COLUMN_NAME='Volume_Total1')
   BEGIN
      PRINT ' Adding columns: Volume_Total1, Money_Total1 '
      ALTER TABLE Hoses ADD
          Volume_Total1	     DECIMAL(15,4) NULL DEFAULT NULL,
	  Money_Total1	     DECIMAL(15,4) NULL DEFAULT NULL
   END

   -- Version 4 - new flag for enabling hoses
   IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Hoses' AND COLUMN_NAME='Is_Enabled')
   BEGIN
      PRINT ' Adding columns: Enabled '
      ALTER TABLE Hoses ADD Is_Enabled BIT NOT NULL DEFAULT 1
   END

   -- Add Foreign key for Tank2_ID this makes the validation code for the database column easier
   -- and means the validation code does not need a reference to Enabler database
   IF NOT EXISTS ( SELECT * FROM sysobjects WHERE name = 'FK__Hoses__Tank_ID2' )
   BEGIN
      PRINT ' Adding FK: Tank2_ID'
	  ALTER TABLE Hoses ADD CONSTRAINT FK__Hoses__Tank_ID2 FOREIGN KEY (Tank2_ID) REFERENCES Tanks
   END

End
go

 
print 'Table: PVT'
go
If NOT exists(select table_name from information_schema.tables 
       where table_name = 'PVT')
Begin
 print ' Created'
 CREATE TABLE PVT (
        PVT_ID               int NOT NULL,
        Hose_ID              int NOT NULL,
        PVT_Start_Time       datetime NOT NULL,
        PVT_Stop_Time        datetime,
        PVT_Cause_Code       tinyint NULL,
        PVT_Value            money NOT NULL DEFAULT 0.0,
        PVT_Volume           decimal(15,4) NOT NULL DEFAULT 0.0,
        PVT_Quantity         decimal(10) NOT NULL DEFAULT 0.0,
        PVT_Price            money NOT NULL DEFAULT 0.0,
        PVT_Price_Level      smallint not null default 1
        PRIMARY KEY NONCLUSTERED (PVT_ID), 
        FOREIGN KEY (Hose_ID) REFERENCES Hoses
 )
End
Else
Begin
   -- DBU 342
   IF NOT EXISTS(SELECT NULL FROM INFORMATION_SCHEMA.COLUMNS 
                 WHERE COLUMN_NAME = 'PVT_Price_Level' 
                 AND TABLE_NAME = 'PVT')
   BEGIN
      print ' Adding column: PVT_Price_Level'
      ALTER TABLE PVT add PVT_Price_Level smallint not null default 1
   END

   IF EXISTS(SELECT NULL FROM INFORMATION_SCHEMA.COLUMNS 
             WHERE COLUMN_NAME = 'PVT_Stop_Time' 
              AND TABLE_NAME = 'PVT')
   BEGIN
      print ' Adding column: PVT_Stop_Time'
      ALTER TABLE PVT ALTER COLUMN PVT_Stop_Time datetime
   END

   -- DBU 320
   if (select numeric_precision 
       from information_schema.columns 
       WHERE TABLE_NAME = 'tanks'
       and column_name = 'capacity') < 15
   Begin
      exec upgrade_decimal_column 'pvt', 'pvt_volume',           15, 4
      exec upgrade_decimal_column 'pvt', 'pvt_quantity',         10, 0
   End
End
go

 
if not exists (select name from sysindexes where name = 'XIEPVTStartTime') 
Begin
  print 'Creating index: XIEPVTStartTime on PVT.PVT_Start_Time'
  CREATE INDEX XIEPVTStartTime ON PVT
  (
     PVT_Start_Time
  )
End
go
 
 
if not exists (select name from sysindexes where name = 'XIEPVTCauseCode') 
Begin
  print 'Creating index: XIEPVTCauseCode on PVT.PVT_Cause_Code'
  CREATE INDEX XIEPVTCauseCode ON PVT
  (
     PVT_Cause_Code
  )
End
go

 
if not exists (select name from sysindexes where name = 'XIEPVTStopTime') 
Begin
  print 'Creating index: XIEPVTStopTime on PVT.PVT_Stop_Time'
  CREATE INDEX XIEPVTStopTime ON PVT
  (
     PVT_Stop_Time
  )
End
go
 
 
print 'Table: Period_Types'
go
If NOT exists(select table_name from information_schema.tables 
       where table_name = 'Period_types')
Begin 
   print ' Created'
   CREATE TABLE Period_types (
        Period_Type          int NOT NULL,
        Period_name          nchar(30) NOT NULL,
        Period_description   nvarchar(80) NULL,
        Period_keep_days     smallint NOT NULL DEFAULT 1,
        PRIMARY KEY (Period_Type)
   )
End
go

IF NOT EXISTS( SELECT Table_Name FROM INFORMATION_SCHEMA.TABLES WHERE Table_Name='WetStock_Approval' )
BEGIN
    print 'Creating table: WetStock_Approval'
    CREATE TABLE WetStock_Approval (
        WetStock_Approval_ID    int         NOT NULL,
        DateTime                datetime,
        Approving_Name          nchar(50)   NOT NULL DEFAULT '',
        Approving_ID            nchar(50)   NOT NULL DEFAULT '',
        PRIMARY KEY (WetStock_Approval_ID)
    )
END
GO
 
print 'Table: Periods'
go
If NOT exists(select table_name from information_schema.tables 
       where table_name = 'Periods')
Begin
   print ' Created'
   CREATE TABLE Periods (
        Period_ID            int NOT NULL,
        Period_Create_TS     datetime NOT NULL,
        Period_Type          int NOT NULL,
        Period_Close_DT      datetime NULL,
        Period_State         tinyint NOT NULL DEFAULT 1,
        Period_Name          nchar(30) NULL,
        Period_Number        int NOT NULL DEFAULT 1,
        Tank_Dips_Entered    smallint NOT NULL DEFAULT 0,
        Tank_Drops_Entered   smallint NOT NULL DEFAULT 0,
        Pump_Meter_Entered   smallint NOT NULL DEFAULT 0,
        Exported             int NOT NULL DEFAULT 0,
        Export_Required      int NOT NULL DEFAULT 0,
		WetStock_Out_Of_Variance tinyint not null default 0,
        WetStock_Approval_ID    int,
        PRIMARY KEY NONCLUSTERED (Period_ID), 
        FOREIGN KEY (Period_Type) REFERENCES Period_types,
        FOREIGN KEY (WetStock_Approval_ID) REFERENCES WetStock_Approval
   )
End
Else
Begin
   -- DBU 250
   IF NOT EXISTS(SELECT NULL FROM INFORMATION_SCHEMA.COLUMNS 
                 WHERE COLUMN_NAME = 'Tank_Dips_entered' 
                 AND TABLE_NAME = 'Periods')
   Begin
      print 'Update table: Periods  Adding Columns: Tank_Dips_Entered, Tank_Drops_Entered, Pump_Meter_Entered'
      ALTER TABLE Periods ADD Tank_Dips_Entered  smallint NOT NULL DEFAULT 0
      ALTER TABLE Periods ADD Tank_Drops_Entered smallint NOT NULL DEFAULT 0
      ALTER TABLE Periods ADD Pump_Meter_Entered smallint NOT NULL DEFAULT 0
   End 

   -- DBU 332
   IF NOT EXISTS(SELECT NULL FROM INFORMATION_SCHEMA.COLUMNS 
                 WHERE COLUMN_NAME = 'Exported' 
                 AND TABLE_NAME = 'Periods')
   Begin
      print 'Update table: Periods  Adding Columns: Exported, Export_Required'
      ALTER TABLE Periods ADD Exported int NOT NULL DEFAULT 0
      ALTER TABLE Periods ADD Export_Required int NOT NULL DEFAULT 0
   End

   -- DBU 400
   IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Periods' AND COLUMN_NAME='WetStock_Approval_ID')
   BEGIN
         PRINT ' Adding columns: WetStock_Out_Of_Variance, WetStock_Approval_ID'
      ALTER TABLE Periods ADD
			WetStock_Out_Of_Variance tinyint not null default 0,
            WetStock_Approval_ID    int FOREIGN KEY (WetStock_Approval_ID)  REFERENCES WetStock_Approval
   END        
End
go

-- Periods Update: DBU 353
-- Moved out of the Periods transaction block because if we're upgrading from 
-- Enabler 2.00 the whole block fails (columns being updated doesn't exist yet)
IF EXISTS(SELECT column_name FROM INFORMATION_SCHEMA.COLUMNS 
                 WHERE COLUMN_NAME = 'tank_dips_entered' 
                 AND TABLE_NAME = 'Periods')
Begin
	-- new fields added in DBU250 default to 0, but the fields created for the existing rows
    -- were null, so we fix this here
    print ' Setting any "null" fuel recon fields to 0'
    update periods set tank_dips_entered = 0 where isnull(tank_dips_entered,-1) = -1
    update periods set tank_drops_entered = 0 where isnull(tank_drops_entered,-1) = -1
    update periods set pump_meter_entered = 0 where isnull(pump_meter_entered,-1) = -1
End
GO


PRINT ' Removing periods tank_dips_entered, tank_drops_entered, pump_meter_entered, default constraints'
EXEC Drop_Constraints 'Periods', 'tank_dips_entered', 'D'
EXEC Drop_Constraints 'Periods', 'tank_drops_entered', 'D'
EXEC Drop_Constraints 'Periods', 'pump_meter_entered', 'D'
PRINT ' Adding default constraints for tank_dips_entered, tank_drops_entered, pump_meter_entered'
ALTER TABLE Periods ADD CONSTRAINT DF__Periods__Tank_Dips DEFAULT 0 FOR tank_dips_entered
ALTER TABLE Periods ADD CONSTRAINT DF__Periods__Tank_Drops DEFAULT 0 FOR tank_drops_entered
ALTER TABLE Periods ADD CONSTRAINT DF__Periods__Pump_Meters DEFAULT 0 FOR pump_meter_entered

if not exists (select name from sysindexes where name = 'xieperiodsstate') 
Begin
  print 'Creating index: XIEPeriodsState on Periods.Period_State'
  CREATE INDEX XIEPeriodsState ON Periods
  (
     Period_State
  )
End
go

 
if not exists (select name from sysindexes where name = 'xieperiodscreatetime')
Begin
  print 'Creating index: XIEPeriodsCreateTime on Periods.Period_Create_TS'
  CREATE INDEX XIEPeriodsCreateTime ON Periods
  (
     Period_Create_TS
  )
End
go

 
if not exists (select name from sysindexes where name = 'xie3periodclosetime') 
Begin
  print 'Creating index: XIE3PeriodCloseTime on Periods.Period_Close_DT'
  CREATE INDEX XIE3PeriodCloseTime ON Periods
  (
     Period_Close_DT
  )
End
go


-- checking to see if a field is an Identity field
if (select columnproperty(object_id ('Event_Journal'), 'Event_ID','isIdentity')) = 0
Begin
   print 'Removing old table: Event_Journal'
   delete from Event_Journal
   drop table Event_Journal
End
go
  
print 'Table: Event_Journal'
go
IF NOT EXISTS(select table_name from information_schema.tables 
          WHERE TABLE_NAME = 'Event_Journal')
Begin
 print ' Created'
 CREATE TABLE Event_Journal (
        Event_ID             int IDENTITY,
        Event_Type           int      NOT NULL,
        Device_Type          int      NOT NULL,
        Event_Time_Stamp     datetime NOT NULL DEFAULT getdate(),
        Device_ID            int      NOT NULL,
        Device_Number        smallint NOT NULL DEFAULT 0.0,
        Description          nvarchar(160) NULL,
        PRIMARY KEY NONCLUSTERED (Event_ID), 
        FOREIGN KEY (Device_Type) REFERENCES Device_type, 
        FOREIGN KEY (Event_Type, Device_Type) REFERENCES Event_type
 )
End
go
 
 
if not exists (select name from sysindexes where name = 'xie1eventTimestamp')
Begin
  print 'Creating index: XIE1EventTimeStamp on Event_Journal.Event_Time_Stamp'
  CREATE INDEX XIE1EventTimeStamp ON Event_Journal
  (
     Event_Time_Stamp
  )
End
go
 
  
print 'Table: Hose_History'
go
IF NOT EXISTS(select table_name 
              from information_schema.tables 
              WHERE TABLE_NAME = 'Hose_History')
Begin 
   print ' Created'
   CREATE TABLE Hose_History (
        Hose_ID              int NOT NULL,
        Period_ID            int NOT NULL,
        Open_Meter_Value     decimal(15,4) NOT NULL DEFAULT 0.0,
        Close_Meter_Value    decimal(15,4) NOT NULL DEFAULT 0.0,
        Postpay_Quantity     decimal(9) NOT NULL DEFAULT 0.0,
        Open_Meter_Volume    decimal(15,4) NOT NULL DEFAULT 0.0,
        Postpay_Value        decimal(15,4) NOT NULL DEFAULT 0.0,
        Close_Meter_Volume   decimal(15,4) NOT NULL DEFAULT 0.0,
        Postpay_Volume       decimal(15,4) NOT NULL DEFAULT 0.0,
        Postpay_Cost         decimal(15,4) NOT NULL DEFAULT 0.0,
        Prepay_Quantity      decimal(9) NOT NULL DEFAULT 0.0,
        Prepay_Value         decimal(15,4) NOT NULL DEFAULT 0.0,
        Prepay_Volume        decimal(15,4) NOT NULL DEFAULT 0.0,
        Prepay_Cost          decimal(15,4) NOT NULL DEFAULT 0.0,
        Prepay_Refund_Qty    decimal(9) NOT NULL DEFAULT 0.0,
        Prepay_Refund_Val    decimal(13,4) NOT NULL DEFAULT 0.0,
        Preauth_Quantity     decimal(9) NOT NULL DEFAULT 0.0,
        Prepay_Rfd_Lst_Qty   decimal(9) NOT NULL DEFAULT 0.0,
        Preauth_Value        decimal(15,4) NOT NULL DEFAULT 0.0,
        Prepay_Rfd_Lst_Val   decimal(15,4) NOT NULL DEFAULT 0.0,
        Preauth_Volume       decimal(15,4) NOT NULL DEFAULT 0.0,
        Preauth_Cost         decimal(15,4) NOT NULL DEFAULT 0.0,
        Monitor_Quantity     decimal(9) NOT NULL DEFAULT 0.0,
        Monitor_Value        decimal(15,4) NOT NULL DEFAULT 0.0,
        Monitor_Volume       decimal(15,4) NOT NULL DEFAULT 0.0,
        Monitor_Cost         decimal(15,4) NOT NULL DEFAULT 0.0,
        Driveoffs_Quantity   decimal(9) NOT NULL DEFAULT 0.0,
        Driveoffs_Value      decimal(15,4) NOT NULL DEFAULT 0.0,
        Driveoffs_Volume     decimal(15,4) NOT NULL DEFAULT 0.0,
        Driveoffs_Cost       decimal(15,4) NOT NULL DEFAULT 0.0,
        Test_Del_Quantity    decimal(9) NOT NULL DEFAULT 0.0,
        Test_Del_Volume      decimal(15,4) NOT NULL DEFAULT 0.0,
        Offline_Quantity     decimal(9) NOT NULL DEFAULT 0.0,
        Offline_Volume       decimal(15,4) NOT NULL DEFAULT 0.0,
        Offline_Value        decimal(15,4) NOT NULL DEFAULT 0.0,
        Offline_Cost         decimal(15,4) NOT NULL DEFAULT 0.0,
        Open_Mech_Volume     decimal(15,4) NOT NULL DEFAULT 0.0,
        Close_Mech_Volume    decimal(15,4) NOT NULL DEFAULT 0.0,
        Open_Volume_Turnover_Correction      decimal(15,4) NOT NULL DEFAULT 0.0,
        Open_Money_Turnover_Correction       decimal(15,4) NOT NULL DEFAULT 0.0,
        Close_Volume_Turnover_Correction     decimal(15,4) NOT NULL DEFAULT 0.0,
        Close_Money_Turnover_Correction      decimal(15,4) NOT NULL DEFAULT 0.0,
        Open_Volume_Turnover_Correction2     decimal(15,4) NOT NULL DEFAULT 0.0,
        Close_Volume_Turnover_Correction2    decimal(15,4) NOT NULL DEFAULT 0.0,        
        PRIMARY KEY (Hose_ID, Period_ID), 
        FOREIGN KEY (Period_ID) REFERENCES Periods, 
        FOREIGN KEY (Hose_ID) REFERENCES Hoses
 )
End
Else
BEGIN
-- DBU 250
   IF NOT EXISTS(select column_name 
          from information_schema.columns 
          WHERE TABLE_NAME = 'Hose_History'
          AND COLUMN_NAME = 'Open_Mech_Volume')
   Begin
      print ' Adding columns: Open_Mech_Volume, Close_Mech_Volume'
      ALTER TABLE Hose_History ADD Open_Mech_Volume  decimal(13,3) NOT NULL DEFAULT 0.0
      ALTER TABLE Hose_History ADD Close_Mech_Volume decimal(13,3) NOT NULL DEFAULT 0.0
   End

   if (select numeric_precision 
       from information_schema.columns 
       WHERE TABLE_NAME = 'Hose_History'
       and column_name = 'open_meter_value') < 15
   Begin
      exec upgrade_decimal_column 'hose_history', 'open_meter_value',    15, 4
      exec upgrade_decimal_column 'hose_history', 'close_meter_value',   15, 4
      exec upgrade_decimal_column 'hose_history', 'open_meter_volume',   15, 4
      exec upgrade_decimal_column 'hose_history', 'close_meter_volume',  15, 4
      exec upgrade_decimal_column 'hose_history', 'postpay_value',       15, 4
      exec upgrade_decimal_column 'hose_history', 'postpay_volume',      15, 4
      exec upgrade_decimal_column 'hose_history', 'postpay_cost',        15, 4
      exec upgrade_decimal_column 'hose_history', 'prepay_value',        15, 4
      exec upgrade_decimal_column 'hose_history', 'prepay_volume',       15, 4
      exec upgrade_decimal_column 'hose_history', 'prepay_cost',         15, 4
      exec upgrade_decimal_column 'hose_history', 'prepay_refund_val',   13, 4
      exec upgrade_decimal_column 'hose_history', 'prepay_rfd_lst_val',  15, 4
      exec upgrade_decimal_column 'hose_history', 'preauth_value',       15, 4
      exec upgrade_decimal_column 'hose_history', 'preauth_volume',      15, 4
      exec upgrade_decimal_column 'hose_history', 'preauth_cost',        15, 4
      exec upgrade_decimal_column 'hose_history', 'monitor_value',       15, 4
      exec upgrade_decimal_column 'hose_history', 'monitor_volume',      15, 4
      exec upgrade_decimal_column 'hose_history', 'monitor_cost',        15, 4
      exec upgrade_decimal_column 'hose_history', 'driveoffs_value',     15, 4
      exec upgrade_decimal_column 'hose_history', 'driveoffs_volume',    15, 4  
      exec upgrade_decimal_column 'hose_history', 'driveoffs_cost',      15, 4
      exec upgrade_decimal_column 'hose_history', 'test_del_volume',     15, 4
      exec upgrade_decimal_column 'hose_history', 'offline_volume',      15, 4
      exec upgrade_decimal_column 'hose_history', 'offline_value',       15, 4
      exec upgrade_decimal_column 'hose_history', 'offline_cost',        15, 4
      exec upgrade_decimal_column 'hose_history', 'open_mech_volume',    15, 4
      exec upgrade_decimal_column 'hose_history', 'close_mech_volume',   15, 4
   END

   -- DBU 400
   IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Hose_History' AND COLUMN_NAME='Open_Volume_Turnover_Correction')
   BEGIN
      PRINT ' Adding columns: Open_Volume_Turnover_Correction, Open_Money_Turnover_Correction, Close_Volume_Turnover_Correction, Close_Money_Turnover_Correction, Open_Volume_Turnover_Correction2, Close_Volume_Turnover_Correction2' 
      ALTER TABLE Hose_History ADD
            Open_Volume_Turnover_Correction      decimal(15,4) NOT NULL DEFAULT 0.0,
            Open_Money_Turnover_Correction       decimal(15,4) NOT NULL DEFAULT 0.0,
            Close_Volume_Turnover_Correction     decimal(15,4) NOT NULL DEFAULT 0.0,
            Close_Money_Turnover_Correction      decimal(15,4) NOT NULL DEFAULT 0.0,
            Open_Volume_Turnover_Correction2     decimal(15,4) NOT NULL DEFAULT 0.0,
            Close_Volume_Turnover_Correction2    decimal(15,4) NOT NULL DEFAULT 0.0
   END   
END
go

print 'Table: Hose_PostMix_History'
go
IF NOT EXISTS(select table_name 
              from information_schema.tables 
              WHERE TABLE_NAME = 'Hose_PostMix_History')
Begin 
   print ' Created'
   CREATE TABLE Hose_PostMix_History (
        Hose_ID              int NOT NULL,
        Period_ID            int NOT NULL,
        Base_Grade_Number    smallint NOT NULL,
        Open_Meter_Value     decimal(15,4) NOT NULL DEFAULT 0.0,
        Close_Meter_Value    decimal(15,4) NOT NULL DEFAULT 0.0,
        Open_Meter_Volume    decimal(15,4) NOT NULL DEFAULT 0.0,
        Close_Meter_Volume   decimal(15,4) NOT NULL DEFAULT 0.0,
        Postpay_Quantity     decimal(9) NOT NULL DEFAULT 0.0,
        Postpay_Value        decimal(15,4) NOT NULL DEFAULT 0.0,
        Postpay_Volume       decimal(15,4) NOT NULL DEFAULT 0.0,
        Postpay_Cost         decimal(15,4) NOT NULL DEFAULT 0.0,
        Monitor_Quantity     decimal(9) NOT NULL DEFAULT 0.0,
        Monitor_Value        decimal(15,4) NOT NULL DEFAULT 0.0,
        Monitor_Volume       decimal(15,4) NOT NULL DEFAULT 0.0,
        Monitor_Cost         decimal(15,4) NOT NULL DEFAULT 0.0,
        Driveoffs_Quantity   decimal(9) NOT NULL DEFAULT 0.0,
        Driveoffs_Value      decimal(15,4) NOT NULL DEFAULT 0.0,
        Driveoffs_Volume     decimal(15,4) NOT NULL DEFAULT 0.0,
        Driveoffs_Cost       decimal(15,4) NOT NULL DEFAULT 0.0,
        Test_Del_Quantity    decimal(9) NOT NULL DEFAULT 0.0,
        Test_Del_Volume      decimal(15,4) NOT NULL DEFAULT 0.0,
     	Open_Mech_Volume     decimal(15,4) NOT NULL DEFAULT 0.0,
        Close_Mech_Volume    decimal(15,4) NOT NULL DEFAULT 0.0,
        Open_Money_Turnover_Correction	decimal(15,4) NOT NULL DEFAULT 0.0,	
        Close_Money_Turnover_Correction	decimal(15,4) NOT NULL DEFAULT 0.0,	
        Open_Volume_Turnover_Correction	decimal(15,4) NOT NULL DEFAULT 0.0,	
        Close_Volume_Turnover_Correction decimal(15,4) NOT NULL DEFAULT 0.0,	
        PRIMARY KEY (Hose_ID, Period_ID, Base_Grade_Number), 
        FOREIGN KEY (Period_ID) REFERENCES Periods, 
        FOREIGN KEY (Hose_ID) REFERENCES Hoses
 )
End

  
print 'Table: Price_Level_Types'
go
IF NOT EXISTS(select table_name from information_schema.tables 
              WHERE TABLE_NAME = 'Price_level_Types')
Begin 
 print ' Created'
 CREATE TABLE Price_Level_Types (
        Price_Level          int NOT NULL,
        Level_Name           nchar(30) NOT NULL DEFAULT ' ',
        Level_Description    nvarchar(80) NULL,
        PRIMARY KEY (Price_Level)
 )
End
go

   
print 'Table: Price_Levels'
go
IF NOT EXISTS(select table_name from information_schema.tables 
              WHERE TABLE_NAME = 'Price_levels')
Begin 
 print ' Created'
 CREATE TABLE Price_Levels (
        Price_Level          int NOT NULL,
        Price_Profile_ID     int NOT NULL,
        Grade_Price          money NOT NULL DEFAULT 0.0,
        Price_Index          INT NOT NULL DEFAULT 1,
        Price_Ratio          FLOAT NULL DEFAULT 0,
        PRIMARY KEY (Price_Profile_ID, Price_Level), 
        FOREIGN KEY (Price_Profile_ID) REFERENCES Price_Profile, 
        FOREIGN KEY (Price_Level) REFERENCES Price_Level_Types
 )
End
Else
Begin
    
   /* Price Levels - Price_Index */
   IF NOT EXISTS(SELECT NULL FROM INFORMATION_SCHEMA.COLUMNS
                 WHERE COLUMN_NAME = 'Price_Index' 
                 AND TABLE_NAME = 'Price_Levels')
   BEGIN
      print ' Adding column: Price_Index'
      ALTER TABLE Price_Levels ADD Price_Index INT NOT NULL DEFAULT 1
   END

   /* Price Levels - Price_Ratio */
   IF NOT EXISTS(SELECT NULL FROM INFORMATION_SCHEMA.COLUMNS 
                 WHERE COLUMN_NAME = 'Price_Ratio'
                 AND TABLE_NAME = 'Price_Levels')
   BEGIN
      print ' Adding column: Price_Ratio'
      ALTER TABLE Price_Levels ADD Price_Ratio FLOAT NULL DEFAULT 0
   END
END


-- remove unnamed primary key, and replace with a named one
DECLARE @PrimaryKey NVARCHAR(100)
IF EXISTS(SELECT DISTINCT CONSTRAINT_NAME from information_schema.KEY_COLUMN_USAGE 
          WHERE TABLE_NAME = 'Price_Levels')
BEGIN
   SELECT @PrimaryKey = (SELECT DISTINCT CONSTRAINT_NAME from information_schema.KEY_COLUMN_USAGE 
                         WHERE TABLE_NAME = 'Price_Levels' 
                         and CONSTRAINT_NAME LIKE 'PK%')

    EXEC ('ALTER TABLE dbo.Price_Levels DROP CONSTRAINT ' + @PrimaryKey)    
END

SELECT @PrimaryKey = 'PK_Price_Levels'
EXEC ('ALTER TABLE dbo.Price_Levels ADD CONSTRAINT ' + @PrimaryKey + ' PRIMARY KEY CLUSTERED 
        (Price_Level, Price_Profile_ID, Price_Index) ON [PRIMARY]')
GO

print 'Table: Tank_Movement_Type'
go
IF NOT EXISTS( SELECT Table_Name FROM INFORMATION_SCHEMA.TABLES WHERE Table_Name='Tank_Movement_Type' )
BEGIN
   print ' Created'
    CREATE TABLE Tank_Movement_Type (
        Tank_Movement_Type_ID       int         NOT NULL,
        Tank_Movement_Type_Name     nchar(30)   NOT NULL DEFAULT '',
        PRIMARY KEY (Tank_Movement_Type_ID),     
    )
END
GO
  
print 'Table: Tank_Delivery'
go
IF NOT EXISTS(select table_name from information_schema.tables 
          WHERE TABLE_NAME = 'Tank_Delivery')
Begin
  print ' Created'
  CREATE TABLE Tank_Delivery (
      Tank_Delivery_ID              int NOT NULL,
      Tank_ID                       int NOT NULL,
      Period_ID                     int NOT NULL,
      Drop_Date_Time                datetime NULL,
      Record_Entry_TS               datetime NOT NULL DEFAULT getdate(),
      Drop_Volume                   decimal(15,4) NOT NULL DEFAULT 0.0,
      Delivery_Note_Num             nchar(10) NOT NULL DEFAULT ' ',
      Drop_Volume_Theo              decimal(15,4) NOT NULL DEFAULT 0.0,
      Unit_Cost_Price               money NOT NULL DEFAULT 0.0,
      Driver_ID_Code                nchar(10) NOT NULL,
      Tanker_ID_Code                nchar(10) NOT NULL,
      Delivery_Detail               nchar(40) NULL,
      Dispatched_Volume             decimal(15,4) NULL,
      Original_Invoice_Number       nchar(10)     NULL,
      Received_Vol_At_Ref_Temp      decimal(15,4) NULL,
      Dispatched_Vol_At_Ref_Temp    decimal(15,4) NULL,
      Total_Variance                decimal(15,4) NULL,
      Variance_At_Ref_Temp          decimal(15,4) NULL,
      Temperature_Variance          decimal(15,4) NULL,
      Tank_Movement_Type_ID         int,
      User_ID                       int DEFAULT NULL,
      PRIMARY KEY NONCLUSTERED (Tank_Delivery_ID), 
      FOREIGN KEY (Period_ID) REFERENCES Periods, 
      FOREIGN KEY (Tank_ID) REFERENCES Tanks,
      FOREIGN KEY (Tank_Movement_Type_ID) REFERENCES Tank_Movement_Type
      )
End
ELSE
BEGIN
   -- DBU250
   IF NOT exists(select column_name from INFORMATION_SCHEMA.COLUMNS 
      where COLUMN_NAME = 'Period_ID' 
      and TABLE_NAME = 'Tank_Delivery')    
   Begin
      print ' Adding foreign key: Periods.Period_ID'
      ALTER TABLE Tank_Delivery ADD Period_ID int FOREIGN KEY REFERENCES Periods
   End

   -- DBU343
   IF NOT exists(select column_name from INFORMATION_SCHEMA.COLUMNS 
      where COLUMN_NAME = 'Delivery_Detail' 
      and TABLE_NAME = 'Tank_Delivery')
   Begin
      print ' Adding column: Delivery_Detail'
      ALTER TABLE Tank_Delivery ADD Delivery_Detail nchar(40) NULL
   End

   -- DBU 347
   If NOT EXISTS ( SELECT Column_Name From INFORMATION_SCHEMA.COLUMNS 
                  where column_name = 'Dispatched_Volume' 
                  AND TABLE_NAME = 'Tank_Delivery' )
   BEGIN
      print ' Adding columns: Dispatched_Volume, Original_Invoice_Number '
	  print ' Adding columns: Recieved_Vol_At_Ref_Temp, Dispatched_Vol_At_Ref_Temp'
	  print ' Adding columns: Total_Variance, Variance_At_Ref_Temp, Temperature_Variance'
      ALTER TABLE Tank_Delivery ADD
         Dispatched_Volume          decimal(15,4) NULL,
         Original_Invoice_Number    nchar(10)     NULL,
         Received_Vol_At_Ref_Temp   decimal(15,4) NULL,
         Dispatched_Vol_At_Ref_Temp decimal(15,4) NULL,
         Total_Variance             decimal(15,4) NULL,
         Variance_At_Ref_Temp       decimal(15,4) NULL,
         Temperature_Variance       decimal(15,4) NULL
   END

   -- DBU 400
   IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Tank_Delivery' AND COLUMN_NAME='Tank_Movement_Type_ID')
   BEGIN
      PRINT ' Adding columns: Tank_Movement_Type_ID'
      ALTER TABLE Tank_Delivery ADD Tank_Movement_Type_ID int FOREIGN KEY (Tank_Movement_Type_ID) REFERENCES Tank_Movement_Type
   END

   IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Tank_Delivery' AND COLUMN_NAME='User_ID')
   BEGIN
      PRINT ' Adding columns: User_ID'
	  ALTER TABLE Tank_Delivery ADD User_ID	int DEFAULT NULL
   END

End
go

 
if not exists (select name from sysindexes where name = 'xiedroptime') 
Begin
 print ' Created index: XIEDropTime on Tank_Delivery.Drop_Date_Time'
 CREATE INDEX XIEDropTime ON Tank_Delivery
 (
        Drop_Date_Time
 )
End
go

 
if not exists (select name from sysindexes where name = 'xie2recordentrytimeStamp')  
Begin
 print ' Created index: XIE2RecordEntryTimeStamp on Tank_Delivery.Record_Entry_TS'
 CREATE INDEX XIE2RecordEntryTimeStamp ON Tank_Delivery
 (
        Record_Entry_TS
 )
End
go

  
print 'Table: Hose_Delivery'
go
IF NOT EXISTS(select table_name from information_schema.tables 
          WHERE TABLE_NAME = 'Hose_Delivery')
Begin
 print ' Created'
 CREATE TABLE Hose_Delivery (
        Delivery_ID            int           NOT NULL,
        Hose_ID                int           NOT NULL,
        Attendant_ID           int           NULL,
        Price_Level            int           NOT NULL,
        Completed_TS           datetime      NOT NULL DEFAULT getdate(),
        Cleared_Date_Time      datetime      NULL,
        Delivery_Type          smallint      NOT NULL DEFAULT 1,
        Delivery_State         smallint      NOT NULL DEFAULT 1,
        Delivery_Volume        decimal(12,4) NOT NULL DEFAULT 0.0,
        Delivery_Value         decimal(12,4) NOT NULL DEFAULT 0.0,
        Del_Sell_Price         decimal(12,4) NOT NULL DEFAULT 0.0,
        Del_Cost_Price         decimal(12,4) NOT NULL DEFAULT 0.0,
        Cleared_By             int           NULL DEFAULT NULL,
        Reserved_By            int           NOT NULL DEFAULT NULL,
        Transaction_ID         int           NULL,
        Del_Item_Number        int           NULL,
        Delivery2_Volume       decimal(12,4) NOT NULL DEFAULT NULL,
        Hose_Meter_Volume      decimal(15,4) NOT NULL DEFAULT 0.0,
        Hose_Meter_Value       decimal(15,4) NOT NULL DEFAULT 0.0,
        Hose_Meter_Volume2     decimal(15,4) NOT NULL DEFAULT 0.0,  
        Hose_Meter_Value2      decimal(15,4) NOT NULL DEFAULT 0.0,
        Auth_Ref               int           NULL,
        Blend_Ratio            decimal(8,4)  NOT NULL DEFAULT 0.0,
        Previous_Delivery_Type smallint      NOT NULL DEFAULT 0,
        Delivery1_Volume       decimal(12,4) NOT NULL DEFAULT 0.0,
        Delivery1_Value        decimal(12,4) NOT NULL DEFAULT 0.0,
        Delivery2_Value        decimal(12,4) NOT NULL DEFAULT 0.0,
        Hose_Meter_Volume1     decimal(15,4) NOT NULL DEFAULT 0.0,  
        Hose_Meter_Value1      decimal(15,4) NOT NULL DEFAULT 0.0,
        Grade1_Price	       decimal(12,4) NOT NULL DEFAULT 0.0,
        Grade2_Price	       decimal(12,4) NOT NULL DEFAULT 0.0
        PRIMARY KEY NONCLUSTERED (Delivery_ID),
        FOREIGN KEY (Attendant_ID) REFERENCES Attendant, 
        FOREIGN KEY (Price_Level)  REFERENCES Price_Level_Types, 
        FOREIGN KEY (Hose_ID) REFERENCES Hoses
 )
End
Else
Begin
   IF NOT EXISTS(SELECT NULL FROM INFORMATION_SCHEMA.COLUMNS 
                 WHERE COLUMN_NAME = 'Hose_Meter_Volume2' AND TABLE_NAME = 'Hose_Delivery')
   BEGIN
      print ' Adding columns: Hose_Meter_Volume2,Hose_Meter_Value2, Blend_Ratio'
      ALTER TABLE Hose_Delivery ADD 
         Hose_Meter_Volume2 decimal(15,4) NOT NULL DEFAULT 0.0,
         Hose_Meter_Value2  decimal(15,4) NOT NULL DEFAULT 0.0,
         Blend_Ratio        decimal(8,4)  NOT NULL DEFAULT 0.0
   END

   IF NOT EXISTS(SELECT NULL FROM INFORMATION_SCHEMA.COLUMNS 
                 WHERE COLUMN_NAME = 'Previous_Delivery_Type'
                 AND TABLE_NAME = 'Hose_Delivery')
   Begin
      print ' Adding column: Previous_Delivery_Type'
      ALTER TABLE hose_delivery ADD
         Previous_Delivery_Type smallint NOT NULL DEFAULT 0
   End

   --DBU 350
   If NOT EXISTS (SELECT Column_Name From INFORMATION_SCHEMA.COLUMNS 
                where column_name = 'Auth_Ref' 
                AND TABLE_NAME = 'Hose_Delivery')
   BEGIN
      print ' Adding column: Auth_Ref'
      ALTER TABLE Hose_Delivery ADD
         Auth_Ref    int NULL
   END



   if (select numeric_precision 
       from information_schema.columns 
       WHERE TABLE_NAME = 'Hose_History'
       and column_name = 'open_meter_value') < 12
   -- DBU 320
   Begin
      exec upgrade_decimal_column 'hose_delivery', 'delivery_volume',    12, 4
      exec upgrade_decimal_column 'hose_delivery', 'delivery_value',     12, 4
      exec upgrade_decimal_column 'hose_delivery', 'del_sell_price',     12, 4
      exec upgrade_decimal_column 'hose_delivery', 'del_cost_price',     12, 4 
      exec upgrade_decimal_column 'hose_delivery', 'delivery2_volume',   12, 4
      exec upgrade_decimal_column 'hose_delivery', 'hose_meter_volume',  15, 4
      exec upgrade_decimal_column 'hose_delivery', 'hose_meter_value',   15, 4
   End
 
   if (select numeric_precision 
       from information_schema.columns 
       WHERE TABLE_NAME = 'Hose_History'
       and column_name = 'open_meter_value') < 15
   Begin
      exec upgrade_decimal_column 'hose_delivery', 'Hose_Meter_Volume2', 15, 4
      exec upgrade_decimal_column 'hose_delivery', 'Hose_Meter_Value2',  15, 4
      exec upgrade_decimal_column 'hose_delivery', 'Blend_Ratio',         8, 4
   End

	--DBU 407 ITLCR218 Post-Mix Fuels
   If NOT EXISTS (SELECT Column_Name From INFORMATION_SCHEMA.COLUMNS 
                where column_name = 'Delivery1_Volume' 
                AND TABLE_NAME = 'Hose_Delivery')
   BEGIN
      print ' Adding column: Delivery1_Volume, Delivery1_Value, Delivery2_Value, Grade1_Price, Grade2_Price, Hose_Meter_Volume1, Hose_Meter_Value1'
      ALTER TABLE Hose_Delivery ADD
         	Delivery1_Volume       decimal(12,4) NOT NULL DEFAULT 0.0,
        	Delivery1_Value        decimal(12,4) NOT NULL DEFAULT 0.0,
		Delivery2_Value        decimal(12,4) NOT NULL DEFAULT 0.0,
		Hose_Meter_Volume1     decimal(15,4) NOT NULL DEFAULT 0.0,  
        	Hose_Meter_Value1      decimal(15,4) NOT NULL DEFAULT 0.0,
		Grade1_Price	       decimal(12,4) NOT NULL DEFAULT 0.0,
		Grade2_Price	       decimal(12,4) NOT NULL DEFAULT 0.0
		
   END
End
go

 
if not exists (select name from sysindexes where name = 'XIECompleteTime') 
Begin
  print ' Created index: XIECompleteTime on Hose_Delivery.Completed_TS'
  CREATE INDEX XIECompleteTime ON Hose_Delivery
  (
     Completed_TS
  )
End
go
 
 
if not exists (select name from sysindexes where name = 'XIEDeliveryType') 
Begin
  print ' Created index: XIEDeliveryType on Hose_Delivery.Delivery_Type'
  CREATE INDEX XIEDeliveryType ON Hose_Delivery
  (
     Delivery_Type
  )
End
go
 
 
if not exists (select name from sysindexes where name = 'XIEClearedTime') 
Begin
  print ' Created index: XIEClearedTime on Hose_Delivery.Cleared_Date_Time'
  CREATE INDEX XIEClearedTime ON Hose_Delivery
  (
     Cleared_Date_Time
  )
End
go

  
print 'Table: Site_Profile'
go
IF NOT EXISTS(select table_name 
              from information_schema.tables 
              WHERE TABLE_NAME = 'Site_Profile')
Begin 
 print ' Created'
 CREATE TABLE Site_profile (
        Site_Profile_ID      	int NOT NULL,
        Site_Profile_Name    	nchar(30) NOT NULL,
        Site_Profile_Desc    	nvarchar(80) NULL,
--        Site_Auto_Auth       	smallint NOT NULL DEFAULT 0,
--        Profile_Start_Time   	datetime NOT NULL DEFAULT getdate(),
--        Site_Lights          	smallint NOT NULL DEFAULT 0,
--        Site_Allow_Postpay   	smallint NOT NULL DEFAULT 0,
--        Site_Allow_Prepay    	smallint NOT NULL DEFAULT 0,
--        Site_Stacking        	smallint NOT NULL DEFAULT 0,
--        Site_Auto_Stacking   	smallint NOT NULL DEFAULT 0,
--        Site_Allow_Preauth   	smallint NOT NULL DEFAULT 0,
--        Site_Allow_Monitor   	smallint NOT NULL DEFAULT 0,
--        Site_Allow_Att       	smallint NOT NULL DEFAULT 0,
        Start_Time           	smallint  default 0,
        Site_Profile_Number  	int default 1,
        Valid_Days           	nchar(20) default '1,2,3,4,5,6,7',
--        Prof_Price_1_Level   	int NOT NULL DEFAULT 1,
--        Prof_Price_2_Level   	int NOT NULL DEFAULT 1,
--        Site_Att_Tag_Activate 	smallint NOT NULL DEFAULT 0,
--        Site_Att_Tag_Auth   	smallint NOT NULL DEFAULT 0
        PRIMARY KEY (Site_Profile_ID)
 )
end
else
begin
   -- DBU 315
   IF NOT EXISTS(select column_name
              from information_schema.columns 
              WHERE TABLE_NAME = 'Site_profile'
              And Column_name = 'start_time')
   begin
      print ' Adding columns: Start_Time, Valid_Days, Site_Profile_Number'
      alter table Site_Profile add 
        Start_Time          smallint default 0,
        Valid_Days          nchar(20) default '1,2,3,4,5,6,7',
        Site_Profile_Number int default 1

   end
   
   
   -- Before drop any column, import into Pump Profile table
   -- use Prof_Price_2_Level as a sign in order to find out we have run this query or not
	IF EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Site_Profile' 
	AND COLUMN_NAME='Prof_Price_2_Level')
	BEGIN
		Print 'Start importing Site profile into Pump Profile'
		DECLARE @site_profile_rows AS INT
		SET @site_profile_rows = (SELECT COUNT(*) FROM Site_profile)

		DECLARE @count AS INT
		SET @count = 1

		WHILE (@count <= @site_profile_rows)
		BEGIN
			IF EXISTS (SELECT * FROM Site_profile WHERE Site_Profile_ID = @count )
			BEGIN
				-- Pump profile table 

				-- import site profiles into pump profile table

				DECLARE @Pump_Profile_ID    AS   INT  
				DECLARE @Auto_Authorise     AS   SMALLINT 
				DECLARE @Allow_Postpay      AS   SMALLINT     
				DECLARE @Allow_Prepay       AS   SMALLINT     
				DECLARE @Allow_Preauth      AS   SMALLINT        
				DECLARE @Allow_Monitor      AS   SMALLINT     
				DECLARE @Pump_Lights        AS   SMALLINT     
				DECLARE @Pump_Stacking      AS   SMALLINT      
				DECLARE @Pump_Auto_Stacking AS   SMALLINT     
				DECLARE @Allow_Attendant    AS   SMALLINT     
				DECLARE @prof_Price_1_Level AS   INT             
				DECLARE @prof_Price_2_Level AS   INT          
				DECLARE @Site_Profile_ID    AS   INT          
				-- declare    @Stack_Size			as	SMALLINT  -- new
				
				IF ( SELECT COUNT(*) FROM Pump_Profile)  > 0 
					SET @Pump_Profile_ID = (SELECT MAX(Pump_Profile.Pump_Profile_ID) + 1 FROM Pump_Profile )
				ELSE
					SET @Pump_Profile_ID = 1
				
				
				-- In V3 VB6, ON is -1, OFF is 0. PSRVR accepts the -1 value as ON
				-- In V4 Web app, ON is 1, OFF is 0. So need to use Absolute value when needed.
				
				-- Get the values
				SELECT @Auto_Authorise = ABS(Site_Auto_Auth),
				 @Allow_Postpay = ABS(Site_Allow_Postpay) ,
				 @Allow_Prepay = ABS(Site_Allow_Prepay) ,
				 @Allow_Preauth = ABS(Site_Allow_Preauth) ,
				 @Allow_Monitor = ABS(Site_Allow_Monitor) ,
				 @Pump_Lights = ABS(Site_Lights) ,
				 @Pump_Stacking = ABS(Site_Stacking) ,
				 @Pump_Auto_Stacking = ABS(Site_Auto_Stacking) ,
				 @Allow_Attendant = ABS(Site_Allow_Att) ,
				 @prof_Price_1_Level = ABS(Prof_Price_1_Level) ,
				 @prof_Price_2_Level = ABS(Prof_Price_2_Level)  ,
				 @Site_Profile_ID = ABS(Site_Profile_ID) FROM Site_profile WHERE Site_Profile_ID = @count

				
				INSERT INTO Pump_Profile (Pump_Profile_ID, Auto_Authorise, Allow_Postpay, Allow_Prepay, Allow_Preauth, Allow_Monitor,
				Pump_Lights, Pump_Stacking, Pump_Auto_Stacking, Allow_Attendant, prof_Price_1_Level, prof_Price_2_Level, Site_Profile_ID) 
				VALUES (@Pump_Profile_ID, @Auto_Authorise, @Allow_Postpay, @Allow_Prepay, @Allow_Preauth, @Allow_Monitor,@Pump_Lights, @Pump_Stacking,
				@Pump_Auto_Stacking, @Allow_Attendant, @prof_Price_1_Level, @prof_Price_2_Level, @Site_Profile_ID)
				
				PRINT 'Imported Site Profile '+ cast( @Site_Profile_ID AS Char(3)) + ' with values: 
				Pump_Profile_ID, Auto_Authorise, Allow_Postpay, Allow_Prepay, Allow_Preauth, Allow_Monitor,
				Pump_Lights, Pump_Stacking, Pump_Auto_Stacking, Allow_Attendant, prof_Price_1_Level, prof_Price_2_Level: ' +
				cast (@Pump_Profile_ID AS Char(3)) + cast (@Auto_Authorise AS Char(3)) + cast (@Allow_Postpay  AS Char(3)) +
				cast (@Allow_Prepay AS Char(3)) + cast (@Allow_Preauth AS Char(3)) + cast (@Allow_Monitor AS Char(3)) + 
				cast (@Pump_Lights AS Char(3)) + cast (@Pump_Stacking AS Char(3)) + cast (@Pump_Auto_Stacking AS Char(3)) + 
				cast (@Allow_Attendant AS Char(3)) + cast (@prof_Price_1_Level AS Char(3)) + cast (@prof_Price_2_Level AS Char(3))
				
			END
			
			SET @count = @count +1
		END -- END OF WHILE
	END -- END OF JUDGE 

	
	IF EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Site_Profile' 
	AND COLUMN_NAME='Site_Att_Tag_Auth')
	BEGIN
		EXEC Drop_Constraints 'Site_Profile', 'Site_Att_Tag_Auth', 'D'
		PRINT ' Removing columns: Site_Att_Tag_Auth'
		ALTER TABLE Site_Profile DROP COLUMN Site_Att_Tag_Auth
	END
	
	IF EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Site_Profile' 
	AND COLUMN_NAME='Site_Att_Tag_Activate')
	BEGIN
		EXEC Drop_Constraints 'Site_Profile', 'Site_Att_Tag_Activate', 'D'
		PRINT ' Removing columns: Site_Att_Tag_Activate'
		ALTER TABLE Site_Profile DROP COLUMN Site_Att_Tag_Activate
	END
		
	IF EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Site_Profile' 
	AND COLUMN_NAME='Prof_Price_2_Level')
	BEGIN
		EXEC Drop_Constraints 'Site_Profile', 'Prof_Price_2_Level', 'D'
		PRINT ' Removing columns: Prof_Price_2_Level'
		ALTER TABLE Site_Profile DROP COLUMN Prof_Price_2_Level
	END
	
	IF EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Site_Profile' 
	AND COLUMN_NAME='Prof_Price_1_Level')
	BEGIN
		EXEC Drop_Constraints 'Site_Profile', 'Prof_Price_1_Level', 'D'
		PRINT ' Removing columns: Prof_Price_1_Level'
		ALTER TABLE Site_Profile DROP COLUMN Prof_Price_1_Level
	END
	
	IF EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Site_Profile' 
	AND COLUMN_NAME='Site_Allow_Att')
	BEGIN
		EXEC Drop_Constraints 'Site_Profile', 'Site_Allow_Att', 'D'
		PRINT ' Removing columns: Site_Allow_Att'
		ALTER TABLE Site_Profile DROP COLUMN Site_Allow_Att
	END
	
	IF EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Site_Profile' 
	AND COLUMN_NAME='Site_Allow_Monitor')
	BEGIN
		EXEC Drop_Constraints 'Site_Profile', 'Site_Allow_Monitor', 'D'
		PRINT ' Removing columns: Site_Allow_Monitor'
		ALTER TABLE Site_Profile DROP COLUMN Site_Allow_Monitor
	END

	IF EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Site_Profile' 
	AND COLUMN_NAME='Site_Allow_Preauth')
	BEGIN
		EXEC Drop_Constraints 'Site_Profile', 'Site_Allow_Preauth', 'D'
		PRINT ' Removing columns: Site_Allow_Preauth'
		ALTER TABLE Site_Profile DROP COLUMN Site_Allow_Preauth
	END
	
	IF EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Site_Profile' 
	AND COLUMN_NAME='Site_Auto_Stacking')
	BEGIN
		EXEC Drop_Constraints 'Site_Profile', 'Site_Auto_Stacking', 'D'
		PRINT ' Removing columns: Site_Auto_Stacking'
		ALTER TABLE Site_Profile DROP COLUMN Site_Auto_Stacking
	END
	
	IF EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Site_Profile' 
	AND COLUMN_NAME='Site_Stacking')
	BEGIN
		EXEC Drop_Constraints 'Site_Profile', 'Site_Stacking', 'D'
		PRINT ' Removing columns: Site_Stacking'
		ALTER TABLE Site_Profile DROP COLUMN Site_Stacking
	END
		
	IF EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Site_Profile' 
	AND COLUMN_NAME='Site_Auto_Auth')
	BEGIN
		EXEC Drop_Constraints 'Site_Profile', 'Site_Auto_Auth', 'D'
		PRINT ' Removing columns: Site_Auto_Auth'
		ALTER TABLE Site_Profile DROP COLUMN Site_Auto_Auth
	END

	IF EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Site_Profile' 
	AND COLUMN_NAME='Profile_Start_Time')
	BEGIN
		EXEC Drop_Constraints 'Site_Profile', 'Profile_Start_Time', 'D'
		PRINT ' Removing columns: Profile_Start_Time'
		ALTER TABLE Site_Profile DROP COLUMN Profile_Start_Time
	END
	
	IF EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Site_Profile' 
	AND COLUMN_NAME='Site_Lights')
	BEGIN
		EXEC Drop_Constraints 'Site_Profile', 'Site_Lights', 'D'
		PRINT ' Removing columns: Site_Lights'
		ALTER TABLE Site_Profile DROP COLUMN Site_Lights
	END
	
	IF EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Site_Profile' 
	AND COLUMN_NAME='Site_Allow_Postpay')
	BEGIN
		EXEC Drop_Constraints 'Site_Profile', 'Site_Allow_Postpay', 'D'
		PRINT ' Removing columns: Site_Allow_Postpay'
		ALTER TABLE Site_Profile DROP COLUMN Site_Allow_Postpay
	END
	
	IF EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Site_Profile' 
	AND COLUMN_NAME='Site_Allow_Prepay')
	BEGIN
		EXEC Drop_Constraints 'Site_Profile', 'Site_Allow_Prepay', 'D'
		PRINT ' Removing columns: Site_Allow_Prepay'
		ALTER TABLE Site_Profile DROP COLUMN Site_Allow_Prepay
	END

end
GO

-- assign default profile numbers and valid days to all existing site profile records that has Null fields
PRINT ' Setting Site_Profile_Number, Valid_Days'
update Site_Profile set Site_Profile_Number = Site_Profile_ID where (Site_Profile_ID > 0) AND IsNull(Site_Profile_Number,0)=0
update Site_Profile set Valid_Days = '1,2,3,4,5,6,7' where Site_Profile_ID > 0 And IsNull(Valid_Days,'')=''
GO

print 'Table: Pump_Profile'
go
IF NOT EXISTS(select table_name 
          from information_schema.tables
          WHERE TABLE_NAME = 'Pump_profile') 
BEGIN
	print ' Created'
	CREATE TABLE Pump_Profile (
		Pump_Profile_ID         int NOT NULL,
		Pump_Profile_Pump_ID    int default NULL,
--		Pump_Profile_Name       nchar(30)    NOT NULL DEFAULT ' ',
--		Pump_Profile_Desc       nvarchar(80) NULL,
		Auto_Authorise          smallint     NOT NULL DEFAULT 0,
		Allow_Postpay           smallint     NOT NULL DEFAULT 0,
		Allow_Prepay            smallint     NOT NULL DEFAULT 0,
		Allow_Preauth           smallint     NOT NULL DEFAULT 0,
		Allow_Monitor           smallint     NOT NULL DEFAULT 0,
		Pump_Lights             smallint     NOT NULL DEFAULT 0,
		Pump_Stacking           smallint     NOT NULL DEFAULT 0,
		Pump_Auto_Stacking      smallint     NOT NULL DEFAULT 0,
		Allow_Attendant         smallint     NOT NULL DEFAULT 0,
		prof_Price_1_Level      int          NOT NULL DEFAULT 1,
		prof_Price_2_Level      int          NOT NULL DEFAULT 1,
--		Start_Time              smallint     DEFAULT 0,
--		End_Time                smallint     DEFAULT 0,
--		Valid_Days              nchar(20)    DEFAULT '1,2,3,4,5,6,7',
		Site_Profile_ID         int          DEFAULT NULL,
		Fallback_allow          SMALLINT     NOT NULL DEFAULT 0,
		Fallback_automatic      SMALLINT     NOT NULL DEFAULT 0,	    
		Tag_Reader_Active       SMALLINT     NOT NULL DEFAULT 0,
		Attendant_Tag_Auth      SMALLINT     NOT NULL DEFAULT 0,
		External_Tag_Auth       SMALLINT     NOT NULL DEFAULT 0,
		Stack_Size				SMALLINT     NOT NULL DEFAULT 0,
		CONSTRAINT FK__Pump_Prof__Pump_Profile_Pump_ID FOREIGN KEY (Pump_Profile_Pump_ID) REFERENCES Pumps(Pump_ID), 
		CONSTRAINT FK__Pump_Prof__Site_Profile_ID FOREIGN KEY (Site_Profile_ID) REFERENCES Site_profile, 
		PRIMARY KEY (Pump_Profile_ID)
 )
END
ELSE
BEGIN
   -- DBU 315
   IF NOT EXISTS(select column_name 
             from information_schema.columns
             WHERE TABLE_NAME = 'Pump_profile'
             and column_Name = 'Pump_Profile_Pump_ID')
   Begin
      print ' Adding columns: Pump_Profile_Pump_ID, Site_Profile_ID'
      alter table Pump_Profile add 
         Pump_Profile_Pump_ID int       default NULL,
         Site_Profile_ID      int       default NULL

	  
      -- remove any previously configured profiles they need to be recreated
      delete from Pump_Profile where Pump_Profile_ID > 1 
   End
   
   -- Need to update the pump_profile_pump_id and site_profile_id to be null 
   -- if its less than 1.
   -- Older databases have this as -1 which causes failures when adding
   -- forgein keys below.
   UPDATE Pump_Profile SET Pump_Profile_Pump_ID = NULL WHERE Pump_Profile_Pump_ID < 1
   UPDATE Pump_Profile SET Site_Profile_ID = NULL WHERE Site_Profile_ID < 1
		
-- This is no longer valid - the V4 database has a 'site profile' record in the pump table 
-- if not exists( select pump_profile_id 
--                from pump_profile 
--                where pump_profile_id = 1)
-- Begin
--    print 'Inserting record in Pump_Profile for "Use Site Profile" '
--    insert into pump_profile ( Pump_Profile_ID , Pump_Profile_Name )
--     values ( 1 , 'Use site profile' )
-- END

   -- DBU 334
   IF NOT EXISTS(SELECT column_name FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'prof_Price_2_Level' AND TABLE_NAME = 'Pump_Profile')
   BEGIN
      print ' Adding columns: Prof_Price_1_Level, Prof_Price_2_Level'
      ALTER TABLE Pump_Profile ADD prof_Price_1_Level int NOT NULL DEFAULT 1
      ALTER TABLE Pump_Profile ADD prof_Price_2_Level int NOT NULL DEFAULT 1
   END

   IF NOT EXISTS(SELECT column_name FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'Fallback_allow' AND TABLE_NAME = 'Pump_Profile')
   BEGIN
      print ' Adding columns: Fallback_allow, Fallback_automatic'
      ALTER TABLE Pump_Profile ADD Fallback_allow smallint NOT NULL DEFAULT 0
      ALTER TABLE Pump_Profile ADD Fallback_automatic smallint NOT NULL DEFAULT 0
   END

	IF EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Pump_Profile' 
	AND COLUMN_NAME='Site_Att_Tag_Auth')
	BEGIN
		EXEC Drop_Constraints 'Pump_Profile', 'Site_Att_Tag_Auth', 'D'
		PRINT ' Removing columns: Site_Att_Tag_Auth'
		ALTER TABLE Pump_Profile DROP COLUMN Site_Att_Tag_Auth
	END
	
	IF EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Pump_Profile' 
	AND COLUMN_NAME='Site_Att_Tag_Activate')
	BEGIN
		EXEC Drop_Constraints 'Pump_Profile', 'Site_Att_Tag_Activate', 'D'
		PRINT ' Removing columns: Site_Att_Tag_Activate'
		ALTER TABLE Pump_Profile DROP COLUMN Site_Att_Tag_Activate
	END

   -- Enabler V4 updates
		
	-- Add pumps and site mode foreign key
	IF NOT EXISTS ( SELECT * FROM sysobjects WHERE name = 'FK__Pump_Prof__Pump_Profile_Pump_ID' )
    BEGIN
		PRINT ' Adding FK: FK__Pump_Prof__Pump_Profile_Pump_ID'
		ALTER TABLE Pump_Profile ADD CONSTRAINT FK__Pump_Prof__Pump_Profile_Pump_ID FOREIGN KEY (Pump_Profile_Pump_ID) REFERENCES Pumps(Pump_ID)
    END
    
    IF NOT EXISTS ( SELECT * FROM sysobjects WHERE name = 'FK__Pump_Prof__Site_Profile_ID' )
    BEGIN
		PRINT ' Adding FK: FK__Pump_Prof__Site_Profile_ID'
		ALTER TABLE Pump_Profile ADD CONSTRAINT FK__Pump_Prof__Site_Profile_ID FOREIGN KEY (Site_Profile_ID) REFERENCES Site_profile
    END
	
	-- Remove Pump_Profile_Name
	IF EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Pump_Profile' AND COLUMN_NAME='Pump_Profile_Name')
	BEGIN
		EXEC Drop_Constraints 'Pump_Profile', 'Pump_Profile_Name', 'D'
		PRINT ' Removing columns: Pump_Profile_Name'
		ALTER TABLE Pump_Profile DROP COLUMN Pump_Profile_Name
	END
	-- Remove description
	IF EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Pump_Profile' AND COLUMN_NAME='Pump_Profile_Desc')
	BEGIN
		PRINT ' Removing columns: Pump_Profile_Desc'
		ALTER TABLE Pump_Profile DROP COLUMN Pump_Profile_Desc
	END

	-- Remove start and end times, valid days
	IF EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Pump_Profile' AND COLUMN_NAME='Start_Time')
	BEGIN
		EXEC Drop_Constraints 'Pump_Profile', 'Start_Time', 'D'
		PRINT ' Removing columns: Start_Time'
		ALTER TABLE Pump_Profile DROP COLUMN Start_Time
	END
		
	IF EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Pump_Profile' AND COLUMN_NAME='End_Time')
	BEGIN
		EXEC Drop_Constraints 'Pump_Profile', 'End_Time', 'D'
		PRINT ' Removing columns: End_Time'
		ALTER TABLE Pump_Profile DROP COLUMN End_Time
	END
	
	IF EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Pump_Profile' AND COLUMN_NAME='Valid_Days')
	BEGIN
		EXEC Drop_Constraints 'Pump_Profile', 'Valid_Days', 'D'
		PRINT ' Removing columns: Valid_Days'
		ALTER TABLE Pump_Profile DROP COLUMN Valid_Days
	END
	
	-- Add attendant tagging flags
	IF NOT EXISTS(SELECT column_name FROM information_schema.columns WHERE TABLE_NAME = 'Pump_Profile' AND COLUMN_NAME = 'Tag_Reader_Active')
	BEGIN 
		PRINT ' Adding column: Tag_Reader_Active'
		ALTER TABLE Pump_Profile ADD Tag_Reader_Active SMALLINT NOT NULL DEFAULT 0
	END
   
	IF NOT EXISTS(SELECT column_name FROM information_schema.columns WHERE TABLE_NAME = 'Pump_Profile' AND COLUMN_NAME = 'Attendant_Tag_Auth')
	BEGIN 
		PRINT ' Adding column: Attendant_Tag_Auth'
		ALTER TABLE Pump_Profile ADD Attendant_Tag_Auth SMALLINT NOT NULL DEFAULT 0
	END
	
	-- Add stack size
	IF NOT EXISTS(SELECT column_name FROM information_schema.columns WHERE TABLE_NAME = 'Pump_Profile' AND COLUMN_NAME = 'Stack_Size')
	BEGIN 
		PRINT ' Adding column: Stack_Size'
		ALTER TABLE Pump_Profile ADD Stack_Size SMALLINT NOT NULL DEFAULT 0

	END

	IF NOT EXISTS(SELECT column_name FROM information_schema.columns WHERE TABLE_NAME = 'Pump_Profile' AND COLUMN_NAME = 'External_Tag_Auth')
	BEGIN 
		PRINT ' Adding column: External_Tag_Auth'
		ALTER TABLE Pump_Profile ADD External_Tag_Auth SMALLINT NOT NULL DEFAULT 0
	END	
END 
GO

IF NOT EXISTS(SELECT * FROM information_schema.columns WHERE table_name = 'Global_Settings' AND column_name = 'Can_Disable_Hoses_By_Tank')
BEGIN
	-- Init Stack_Size field - only do this when upgrading database to V4 (hence check for Can_Disable_Hoses_By_Tank - CR324-55)
	PRINT ' Updating column: Stack_Size to V4 default (2)'
	UPDATE  Pump_Profile SET Stack_Size = 2
END
GO
	


-- drop trigger on Global_Settings so we can drop old columns referred to in the procedure
-- this will be recreated by LOAD.SQL
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME = 'TG_Global_Settings_Update' AND TYPE = 'TR')
	DROP TRIGGER  TG_Global_Settings_Update
GO

print 'Table: Global_Settings'
go
IF NOT EXISTS(select table_name 
              from information_schema.tables 
              WHERE TABLE_NAME = 'Global_Settings')
Begin
 print ' Created'
 CREATE TABLE Global_Settings (
        Site_ID                    int          NOT NULL,
        Site_Name                  nchar(40)    NOT NULL DEFAULT ' ',
        Site_Profile_ID            int          NOT NULL,
        Prepay_Reserved_TO         smallint     NOT NULL DEFAULT 0.0,
        Prepay_Refund_TO           smallint     NOT NULL DEFAULT 0.0,
        Prepay_Taken_TO            smallint     NOT NULL DEFAULT 0.0,
        Preauth_Rsvd_TO            smallint     NOT NULL DEFAULT 0.0,
        Reserve_TO                 smallint     NOT NULL DEFAULT 0,
        Prepay_Refund_Type         int                   DEFAULT 0,
        Authorized_Timeout         smallint     NOT NULL DEFAULT 0.0,
        Auto_Modes_On              smallint     NOT NULL DEFAULT 0,
        Monitor_Del_TO             smallint     NOT NULL DEFAULT 0.0,
        PVT_on                     smallint     NOT NULL DEFAULT 0.0,
        Delivery_Idle_TO           smallint     NOT NULL DEFAULT 0.0,
        Event_keep_days            smallint     NOT NULL DEFAULT 1,
        Hose_del_keep_days         smallint     NOT NULL DEFAULT 1,
        Tank_del_keep_days         smallint     NOT NULL DEFAULT 1,
        -- Minimum_Del_Volume         decimal(5,3) NOT NULL DEFAULT 0.0, -- obsolete
        Attendant_support          smallint     NOT NULL DEFAULT 0,
        Att_keep_days              smallint     NOT NULL DEFAULT 1,
        Delivery_Age_TO            smallint     NOT NULL DEFAULT 0.0,
        Tank_Dips                  smallint     NOT NULL DEFAULT 0.0,
        Tank_Drops                 smallint     NOT NULL DEFAULT 0.0,
        Pump_Meters                smallint     NOT NULL DEFAULT 0.0,
        Recon_Edits_Allowed        int          NOT NULL DEFAULT 0,
        Recon_Report_Format        int          NOT NULL DEFAULT 2,
        Recon_Export_Type          int          NOT NULL DEFAULT 0,
        Recon_Export_Mandatory     int          NOT NULL DEFAULT 0,
        Delivering_NR_TO           smallint     NOT NULL DEFAULT 0.0,
        Clear_Att_Dels             int          NOT NULL DEFAULT 1,
        Price_Level_Control        smallint     NOT NULL DEFAULT 0,
        Minimum_Etotal_Diff        decimal(5,3) NOT NULL DEFAULT 0.0,				
        Map_Test_Delivery_To_Tank_Transfer  smallint    NOT NULL DEFAULT 1,
        Use_Hose_Turn_Over                  smallint    NOT NULL DEFAULT 1,        
        Approval_Required_for_FuelRecon     smallint    NOT NULL DEFAULT 1,
        Can_Disable_Hoses_By_Grade          bit         NOT NULL DEFAULT 0,
        Disable_Hose_During_Delivery        bit         NOT NULL DEFAULT 0,
        Backup_Files                        smallint    NOT NULL DEFAULT 1,
        Backup_Time                         datetime    NOT NULL DEFAULT '01:00:00',
        Can_Disable_Hoses_By_Tank           bit         NOT NULL DEFAULT 0,
        Disable_Tank_On_Level_Low_Alarm     bit         NOT NULL DEFAULT 0,
        Disable_Tank_On_Tanker_Delivery     bit         NOT NULL DEFAULT 0,
        Auto_PostMix_Price                  bit         NOT NULL DEFAULT 0,
        Tagging_Support                     smallint    NOT NULL DEFAULT 0,
        Price_Calc_Decimals 	            smallint    NOT NULL DEFAULT 2,
        Price_Calc_Round_Type               smallint    NOT NULL DEFAULT 0,
        Fallback_State                      smallint    NOT NULL DEFAULT 0,
        Offline_Delivery                    smallint    NOT NULL DEFAULT 1,
        PRIMARY KEY (Site_ID), 
        FOREIGN KEY (Site_Profile_ID) REFERENCES Site_profile
 )
End
Else
Begin
   DECLARE @current_width smallint

   -- DBU 250
   IF NOT EXISTS(select column_name 
                 from information_schema.columns 
                 WHERE TABLE_NAME = 'Global_Settings'
                 AND COLUMN_NAME = 'Tank_Dips')
   Begin 
      print ' Adding Columns: Tank_Dips, Tank_Drops, Pump_Meters'
      ALTER TABLE Global_Settings ADD Tank_Dips   smallint NOT NULL DEFAULT 0
      ALTER TABLE Global_Settings ADD Tank_Drops  smallint NOT NULL DEFAULT 0
      ALTER TABLE Global_Settings ADD Pump_Meters smallint NOT NULL DEFAULT 0
   End
   IF NOT EXISTS(select column_name 
                 from information_schema.columns 
                 WHERE TABLE_NAME = 'Global_Settings'
                 AND COLUMN_NAME = 'Delivering_NR_TO')
   Begin
      print ' Adding Column: Delivering_NR_TO'
      ALTER TABLE Global_Settings ADD Delivering_NR_TO smallint NOT NULL DEFAULT 0
   End 

   -- DBU 315
   IF NOT EXISTS(select column_name
                 from information_schema.columns
                 where table_name = 'Global_Settings'
                 and   column_name = 'Auto_Modes_On')
   Begin
      print ' Adding Columns: Auto_Modes_On, Prepay_Refund_Type'
      alter table Global_Settings add 
                  Auto_Modes_On      smallint not null default 0,
                  Prepay_Refund_Type int      default 0
   End

   -- DBU 332
   if not exists(
      select column_name 
      from information_schema.columns
      where table_name = 'Global_Settings'
      and column_name = 'Recon_Edits_Allowed')
   begin
      print ' Adding Columns: Recon_Edits_Allowed, Recon_Report_Format, Recon_Export_Type, Recon_Export_Mandatory'
      -- fields to control the behaviour of Fuel Recon
      ALTER TABLE Global_Settings ADD Recon_Edits_Allowed int NOT NULL DEFAULT 0
      ALTER TABLE Global_Settings ADD Recon_Report_Format int NOT NULL DEFAULT 2
      ALTER TABLE Global_Settings ADD Recon_Export_Type int NOT NULL DEFAULT 0
      ALTER TABLE Global_Settings ADD Recon_Export_Mandatory int NOT NULL DEFAULT 0
   end

   -- DBU 336
   IF NOT EXISTS(SELECT NULL FROM INFORMATION_SCHEMA.COLUMNS 
                 WHERE COLUMN_NAME = 'Clear_Att_Dels' 
                 AND TABLE_NAME = 'Global_Settings')
   BEGIN
      print ' Adding Column: Clear_Att_Dels'
      ALTER TABLE Global_Settings ADD Clear_Att_Dels int NOT NULL DEFAULT 1
   END

   -- DBU 344
   IF NOT EXISTS(SELECT NULL FROM INFORMATION_SCHEMA.COLUMNS 
                 WHERE COLUMN_NAME = 'Price_level_control' 
                 AND TABLE_NAME = 'Global_Settings')
   BEGIN
      print ' Adding Column: Price_Level_Control'
      ALTER TABLE Global_Settings ADD Price_Level_Control smallint NOT NULL DEFAULT 0
   END

   -- DBU 360
   IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Global_Settings' AND COLUMN_NAME='Offline_Delivery')
   BEGIN
      PRINT ' Adding Column: Offline_Delivery'
      ALTER TABLE Global_Settings ADD Offline_Delivery smallint NOT NULL DEFAULT 1
   END

   -- DBU 400
   IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Global_Settings' AND COLUMN_NAME='Map_Test_Delivery_To_Tank_Transfer')
   BEGIN
      PRINT ' Adding columns: Map_Test_Delivery_To_Tank_Transfer, Use_Hose_Turn_Over, Approval_Required_for_FuelRecon'
      ALTER TABLE Global_Settings ADD
            Minimum_Etotal_Diff                     decimal(5,3) NOT NULL DEFAULT 0.0,		
            Map_Test_Delivery_To_Tank_Transfer      smallint    NOT NULL DEFAULT 1,
            Use_Hose_Turn_Over                      smallint    NOT NULL DEFAULT 1,
            Approval_Required_for_FuelRecon         smallint    NOT NULL DEFAULT 1
   END
   
   -- DBU 401
   If not exists(Select * from Information_schema.columns where table_name = 'Global_Settings' and column_name = 'Can_Disable_Hoses_By_Grade')
   Begin
	Print ' Adding columns: Can_Disable_Hoses_By_Grade, Disable_Hose_During_Delivery'
	Alter table Global_Settings add
            Can_Disable_Hoses_By_Grade    bit not null default 0,
            Disable_Hose_During_Delivery  bit not null default 0
   end

   -- DBU 406
   IF NOT EXISTS(SELECT * FROM Information_schema.columns WHERE table_name = 'Global_Settings' AND column_name = 'Backup_Files')
   BEGIN
        PRINT ' Adding columns: Backup_Files'
        ALTER TABLE Global_Settings 
            ADD Backup_Files SMALLINT NOT NULL DEFAULT 1
   END

   -- Enabler V4 updates
   IF NOT EXISTS(SELECT * FROM Information_schema.columns WHERE table_name = 'Global_Settings' AND column_name = 'Backup_Time')
   BEGIN
        PRINT ' Adding columns: Backup_Time'
        ALTER TABLE Global_Settings 
            ADD Backup_Time DATETIME NOT NULL DEFAULT '01:00:00'
   END
  
   IF NOT EXISTS(SELECT * FROM information_schema.columns WHERE table_name = 'Global_Settings' AND column_name = 'Can_Disable_Hoses_By_Tank')
   BEGIN
      Print ' Adding columns: Can_Disable_Hoses_By_Tank'
      ALTER TABLE Global_Settings ADD Can_Disable_Hoses_By_Tank bit NOT NULL DEFAULT 0
   END

   IF NOT EXISTS(SELECT * FROM information_schema.columns WHERE table_name = 'Global_Settings' AND column_name = 'Disable_Tank_On_Level_Low_Alarm')
   BEGIN
      Print ' Adding columns: Disable_Tank_On_Level_Low_Alarm'
      ALTER TABLE Global_Settings ADD Disable_Tank_On_Level_Low_Alarm bit NOT NULL DEFAULT 0
   END

   IF NOT EXISTS(SELECT * FROM information_schema.columns WHERE table_name = 'Global_Settings' AND column_name = 'Disable_Tank_On_Tanker_Delivery')
   BEGIN
      Print ' Adding column: Disable_Tank_On_Tanker_Delivery'
      ALTER TABLE Global_Settings ADD Disable_Tank_On_Tanker_Delivery bit NOT NULL DEFAULT 0
   END
 
   -- DBU 407
   IF NOT EXISTS(SELECT * FROM information_schema.columns WHERE table_name = 'Global_Settings' AND column_name = 'Auto_PostMix_Price')
   BEGIN
      Print ' Adding column: Auto_PostMix_Price'
      ALTER TABLE Global_Settings ADD Auto_PostMix_Price bit NOT NULL DEFAULT 0
   END	

   IF NOT EXISTS(SELECT * FROM information_schema.columns WHERE table_name = 'Global_Settings' AND column_name = 'Tagging_Support')
   BEGIN
      Print ' Adding column: Tagging_Support'
      ALTER TABLE Global_Settings ADD Tagging_Support smallint NOT NULL DEFAULT 0
   END

   IF NOT EXISTS(SELECT * FROM information_schema.columns WHERE table_name = 'Global_Settings' AND column_name = 'Price_Calc_Decimals')
   BEGIN
	Print ' Adding column: Price_Calc_Decimals'
	ALTER TABLE Global_Settings ADD Price_Calc_Decimals smallint NOT NULL DEFAULT 2

	Print ' Adding column: Price_Calc_Round_Type'
	ALTER TABLE Global_Settings ADD Price_Calc_Round_Type smallint NOT NULL DEFAULT 0
   END

   IF NOT EXISTS(SELECT * FROM information_schema.columns WHERE table_name = 'Global_Settings' AND column_name = 'Fallback_State')
   BEGIN
	Print ' Adding column: Fallback_State'
	ALTER TABLE Global_Settings ADD Fallback_State smallint NOT NULL DEFAULT 0
   END

	-- Reserve timeout column
	IF NOT EXISTS(SELECT column_name FROM information_schema.columns WHERE 
	TABLE_NAME = 'Global_Settings' AND COLUMN_NAME = 'Reserve_TO')
	BEGIN 
	  print ' Adding column: Reserve_TO'
	  ALTER TABLE Global_Settings ADD Reserve_TO SMALLINT NOT NULL DEFAULT 0
	END
	
	IF EXISTS(SELECT column_name FROM information_schema.columns WHERE 
	TABLE_NAME = 'Global_Settings' AND COLUMN_NAME = 'Pump_Stack_Size')
	BEGIN 
		print ' populating new Pump_Profile.Pump_Stack_Size column'
		-- populate the new column with the setup in Global_Settings.Pump_Stack_Size 
		-- so the system should behave the same as before
        DECLARE @SQLStatement VARCHAR(512)
		SELECT @SQLStatement = 'UPDATE Pump_Profile SET Stack_Size = (SELECT Pump_Stack_Size FROM Global_settings ) WHERE isnull( Pump_Profile_Pump_ID,-1 ) = -1'
		EXEC ( @SQLStatement )

		EXEC Drop_Constraints 'Global_Settings', 'Pump_Stack_Size', 'D'
		print ' Deleting column: Pump_Stack_Size'
		SELECT @SQLStatement = 'ALTER TABLE Global_Settings DROP COLUMN Pump_Stack_Size'
		EXEC ( @SQLStatement )		
	END
	
	IF EXISTS(SELECT column_name FROM information_schema.columns 
               WHERE TABLE_NAME = 'Global_Settings' 
                 AND COLUMN_NAME = 'Exported')
	BEGIN 
		EXEC Drop_Constraints 'Global_Settings', 'Exported', 'D'
		print ' Deleting column: Exported'
		ALTER TABLE Global_Settings DROP COLUMN Exported
	END
		
	IF EXISTS(SELECT column_name FROM information_schema.columns WHERE 
	TABLE_NAME = 'Global_Settings' AND COLUMN_NAME = 'Export_Required')
	BEGIN 
		EXEC Drop_Constraints 'Global_Settings', 'Export_Required', 'D'
		print ' Deleting column: Export_Required'
		ALTER TABLE Global_Settings DROP COLUMN Export_Required
	END
	
	IF EXISTS(SELECT column_name FROM information_schema.columns WHERE 
	TABLE_NAME = 'Global_Settings' AND COLUMN_NAME = 'Max_Dels_In_Prog')
	BEGIN 
		EXEC Drop_Constraints 'Global_Settings', 'Max_Dels_In_Prog', 'D'
		print ' Deleting column: Max_Dels_In_Prog'
		ALTER TABLE Global_Settings DROP COLUMN Max_Dels_In_Prog
	END
	
	IF EXISTS(SELECT column_name FROM information_schema.columns WHERE 
	TABLE_NAME = 'Global_Settings' AND COLUMN_NAME = 'Tank_gauge_type')
	BEGIN 
		EXEC Drop_Constraints 'Global_Settings', 'Tank_Gauge_Type', 'D'
		print ' Deleting column: Tank_gauge_type'
		ALTER TABLE Global_Settings DROP COLUMN Tank_gauge_type
	END
	
	IF EXISTS(SELECT column_name FROM information_schema.columns WHERE 
	TABLE_NAME = 'Global_Settings' AND COLUMN_NAME = 'Tank_gauge_pars')
	BEGIN 
		EXEC Drop_Constraints 'Global_Settings', 'Tank_Gauge_pars', 'D'
		print ' Deleting column: Tank_gauge_pars'
		ALTER TABLE Global_Settings DROP COLUMN Tank_gauge_pars
	END
	
	IF EXISTS(SELECT column_name FROM information_schema.columns WHERE 
	TABLE_NAME = 'Global_Settings' AND COLUMN_NAME = 'Minimum_Del_Volume')
	BEGIN 
		EXEC Drop_Constraints 'Global_Settings', 'Minimum_Del_Volume', 'D'
		print ' Deleting column: Minimum_Del_Volume'
		ALTER TABLE Global_Settings DROP COLUMN Minimum_Del_Volume
	END	

	select @current_width = ( SELECT character_maximum_length 
	                            FROM INFORMATION_SCHEMA.COLUMNS
	                           WHERE table_name = 'Global_Settings'
	                             AND column_name = 'Site_Name' )

	IF @current_width < 40 
	BEGIN
		print ' Updating column: Site_Name'
		ALTER TABLE Global_Settings ALTER COLUMN Site_Name nchar(40) NOT NULL
	END
End
go

-- apply update only if new field Prepay_Refund_Type was added
PRINT ' Setting: Prepay_Refund_Type (ensuring not null)'
update global_settings set Prepay_Refund_Type = 0 WHERE IsNull(Prepay_Refund_Type,0)=0
go

PRINT ' Setting: checking number of backup files is valid.'
update global_settings set Backup_Files = 1 where Backup_Files = 0
go

print 'Table: Tank_Dip_Type'
go
IF NOT EXISTS( SELECT Table_Name FROM INFORMATION_SCHEMA.TABLES WHERE Table_Name='Tank_Dip_Type' )
BEGIN
   print ' Created'
    CREATE TABLE Tank_Dip_Type (
        Tank_Dip_Type_ID            int         NOT NULL,
        Tank_Dip_Type_Name          nchar(30)   NOT NULL DEFAULT '',
        PRIMARY KEY (Tank_Dip_Type_ID)
    )
END
GO 
  
print 'Table: Tank_History'
go
IF NOT EXISTS(select table_name 
              from information_schema.tables 
              WHERE TABLE_NAME = 'Tank_History')
Begin
 print ' Created'
 CREATE TABLE Tank_History (
        Period_ID                 int NOT NULL,
        Tank_ID                   int NOT NULL,
        Open_Gauge_Volume         decimal(12,4) NOT NULL DEFAULT 0.0,
        Close_Gauge_Volume        decimal(12,4) NOT NULL DEFAULT 0.0,
        Open_Theo_Volume          decimal(15,4) NOT NULL DEFAULT 0.0,
        Close_Theo_Volume         decimal(15,4) NOT NULL DEFAULT 0.0,
        Open_Dip_Volume           decimal(12,4) NOT NULL DEFAULT 0.0,
        Close_Dip_Volume          decimal(12,4) NOT NULL DEFAULT 0.0,
        Hose_Del_Quantity         decimal(10)   NOT NULL DEFAULT 0.0,
        Hose_Del_Volume           decimal(15,4) NOT NULL DEFAULT 0.0,
        Hose_Del_Value            decimal(15,4) NOT NULL DEFAULT 0.0,
        Hose_Del_Cost             decimal(15,4) NOT NULL DEFAULT 0.0,
        Tank_Del_Quantity         decimal(10)   NOT NULL DEFAULT 0.0,
        Tank_Del_Volume           decimal(15,4) NOT NULL DEFAULT 0.0,
        Tank_Del_Cost              decimal(15,4) NOT NULL DEFAULT 0.0,
        Tank_Loss_Quantity            decimal(10,0) NULL     DEFAULT 0,
        Tank_Loss_Volume              decimal(15,4) NOT NULL DEFAULT 0,
        Tank_Transfer_In_Quantity     decimal(10,0) NOT NULL DEFAULT 0,
        Tank_Transfer_In_Volume       decimal(15,4) NOT NULL DEFAULT 0,
        Tank_Transfer_Out_Quantity    decimal(10,0) NOT NULL DEFAULT 0,
        Tank_Transfer_Out_Volume      decimal(15,4) NOT NULL DEFAULT 0,
        Dip_Fuel_Temp                 decimal(12,4) NULL,
        Dip_Fuel_Density              decimal(12,4) NULL,
        Open_Dip_Water_Volume         decimal(12,4) NOT NULL DEFAULT 0.0,
        Close_Dip_Water_Volume        decimal(12,4) NOT NULL DEFAULT 0.0,
        Open_Gauge_TC_Volume          decimal(12,4) NOT NULL DEFAULT 0.0,
        Close_Gauge_TC_Volume         decimal(12,4) NOT NULL DEFAULT 0.0,
        Open_Water_Volume             decimal(12,4) NOT NULL DEFAULT 0.0,
        Close_Water_Volume            decimal(12,4) NOT NULL DEFAULT 0.0,
        Open_Fuel_Density             decimal(12,4),
        Close_Fuel_Density            decimal(12,4),
        Open_Fuel_Temp                decimal(8,4),
        Close_Fuel_Temp               decimal(8,4),
        Open_Tank_Probe_Status_ID     int DEFAULT 1, 
        Close_Tank_Probe_Status_ID    int DEFAULT 1, 				
        Tank_Readings_DT              datetime,
        Open_Tank_Delivery_State_ID	  int DEFAULT 1,
        Close_Tank_Delivery_State_ID  int DEFAULT 1,
        Open_Pump_Delivery_State      tinyint DEFAULT 0,
        Close_Pump_Delivery_State     tinyint DEFAULT 0,
        Open_Dip_Type_ID              int DEFAULT 1,
        Close_Dip_Type_ID             int DEFAULT 1,         
		Tank_Variance_Reason_ID       char(25) default NULL,
		Open_Gauge_TC_Volume_Flag     smallint DEFAULT NULL,
		Close_Gauge_TC_Volume_Flag    smallint DEFAULT NULL,
        PRIMARY KEY (Period_ID, Tank_ID), 
        FOREIGN KEY (Period_ID) REFERENCES Periods, 
        FOREIGN KEY (Tank_ID) REFERENCES Tanks,
        FOREIGN KEY (Open_Tank_Probe_Status_ID) REFERENCES Tank_Probe_Status, 
        FOREIGN KEY (Close_Tank_Probe_Status_ID) REFERENCES Tank_Probe_Status, 
        FOREIGN KEY (Open_Tank_Delivery_State_ID) REFERENCES Tank_Delivery_State,
        FOREIGN KEY (Close_Tank_Delivery_State_ID) REFERENCES Tank_Delivery_State,
        FOREIGN KEY (Open_Dip_Type_ID) REFERENCES Tank_Dip_Type,
        FOREIGN KEY (Close_Dip_Type_ID) REFERENCES Tank_Dip_Type
 )
End
Else
Begin
   -- DBU 343
   IF NOT exists(select 0 from INFORMATION_SCHEMA.COLUMNS 
                 where COLUMN_NAME = 'Tank_Loss_Quantity' 
                 and TABLE_NAME = 'Tank_History')
   Begin
      print ' Adding columns: Tank_Loss_Quantity, Tank_Loss_Volume, Tank_Transfer_In_Quantity, Transfer_In_Volume, Tank_Transfer_Out_Quantity, Tank_Transfer_Out_Volume'
      ALTER TABLE Tank_History ADD 
         Tank_Loss_Quantity decimal(10,0) NULL DEFAULT 0,
         Tank_Loss_Volume decimal(15,4) NOT NULL DEFAULT 0,
         Tank_Transfer_In_Quantity decimal(10,0) NOT NULL DEFAULT 0,
         Tank_Transfer_In_Volume decimal(15,4) NOT NULL DEFAULT 0,
         Tank_Transfer_Out_Quantity decimal(10,0) NOT NULL DEFAULT 0,
         Tank_Transfer_Out_Volume decimal(15,4) NOT NULL DEFAULT 0
   End

   -- DBU 347
   If NOT EXISTS ( SELECT Column_Name From INFORMATION_SCHEMA.COLUMNS 
                  where column_name = 'Dip_Fuel_Temp' 
                  AND TABLE_NAME = 'Tank_History' ) 
   BEGIN
      print ' Adding columns: Dip_Fuel_Temp, Dip_Fuel_Density'
      ALTER TABLE Tank_History ADD
         Dip_Fuel_Temp    decimal(12,4) NULL,
         Dip_Fuel_Density decimal(12,4) NULL
   END
    

   if (select numeric_precision 
       from information_schema.columns 
       WHERE TABLE_NAME = 'Hose_History'
       and column_name = 'open_meter_value') < 12
   Begin
      exec upgrade_decimal_column 'tank_history', 'open_gauge_volume',   12, 4
      exec upgrade_decimal_column 'tank_history', 'close_gauge_volume',  12, 4
      exec upgrade_decimal_column 'tank_history', 'open_dip_volume',     12, 4
      exec upgrade_decimal_column 'tank_history', 'close_dip_volume',    12, 4
      exec upgrade_decimal_column 'tank_history', 'hose_del_quantity',   10, 0
      exec upgrade_decimal_column 'tank_history', 'hose_del_volume',     15, 4
      exec upgrade_decimal_column 'tank_history', 'hose_del_value',      15, 4
      exec upgrade_decimal_column 'tank_history', 'hose_del_cost',       15, 4
      exec upgrade_decimal_column 'tank_history', 'tank_del_quantity',   10, 0
      exec upgrade_decimal_column 'tank_history', 'tank_del_volume',     15, 4
      exec upgrade_decimal_column 'tank_history', 'tank_del_cost',       15, 4
   End

   -- DBU 400
   IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Tank_History' AND COLUMN_NAME='Open_Dip_Water_Volume')
   BEGIN
      PRINT ' Adding columns: Open_Dip_Water_Volume, Close_Dip_Water_Volume, Open_Gauge_TC_Volume, Close_Gauge_TC_Volume, Open_Water_Volume, Close_Water_Volume, Open_Fuel_Density, Close_Fuel_Density, Open_Fuel_Temp, Close_Fuel_Temp, Open_Tank_Probe_Status_ID, Close_Tank_Probe_Status_ID, Tank_Readings_DT, Open_Tank_Delivery_State_ID, Close_Tank_Delivery_State_ID, Open_Pump_Delivery_State, Close_Pump_Delivery_State, Open_Dip_Type_ID, Close_Dip_Type_ID'
      ALTER TABLE Tank_History ADD
            Open_Dip_Water_Volume   decimal(12,4)   NOT NULL DEFAULT 0.0,
            Close_Dip_Water_Volume  decimal(12,4)   NOT NULL DEFAULT 0.0,
            Open_Gauge_TC_Volume    decimal(12,4)   NOT NULL DEFAULT 0.0,
            Close_Gauge_TC_Volume   decimal(12,4)   NOT NULL DEFAULT 0.0,
            Open_Water_Volume       decimal(12,4)   NOT NULL DEFAULT 0.0,
            Close_Water_Volume      decimal(12,4)   NOT NULL DEFAULT 0.0,
            Open_Fuel_Density       decimal(12,4),
            Close_Fuel_Density      decimal(12,4),
            Open_Fuel_Temp          decimal(8,4),
            Close_Fuel_Temp         decimal(8,4),
            Open_Tank_Probe_Status_ID    	int FOREIGN KEY (Open_Tank_Probe_Status_ID)  REFERENCES Tank_Probe_Status DEFAULT 1, 
            Close_Tank_Probe_Status_ID    	int FOREIGN KEY (Close_Tank_Probe_Status_ID)  REFERENCES Tank_Probe_Status DEFAULT 1, 		
            Tank_Readings_DT        datetime,
            Open_Tank_Delivery_State_ID		int FOREIGN KEY (Open_Tank_Delivery_State_ID)  REFERENCES Tank_Delivery_State DEFAULT 1,
            Close_Tank_Delivery_State_ID	int FOREIGN KEY (Close_Tank_Delivery_State_ID)  REFERENCES Tank_Delivery_State DEFAULT 1,
            Open_Pump_Delivery_State     tinyint         DEFAULT 0,
            Close_Pump_Delivery_State     tinyint         DEFAULT 0,
            Open_Dip_Type_ID        int             FOREIGN KEY (Open_Dip_Type_ID)  REFERENCES Tank_Dip_Type DEFAULT 1,
            Close_Dip_Type_ID       int             FOREIGN KEY (Close_Dip_Type_ID)  REFERENCES Tank_Dip_Type DEFAULT 1,
		    Tank_Variance_Reason_ID char(25) DEFAULT NULL
	END   

 	-- DBU 408
   if (select numeric_precision 
       from information_schema.columns 
       WHERE TABLE_NAME = 'Hose_History'
       and column_name = 'close_theo_volume') < 15
   Begin
      exec upgrade_decimal_column 'tank_history', 'open_theo_volume',    15, 4
      exec upgrade_decimal_column 'tank_history', 'close_theo_volume',   15, 4
   End

   IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Tank_History' AND COLUMN_NAME='Open_Gauge_TC_Volume_Flag')
   BEGIN
      PRINT ' Adding columns: Open_Gauge_TC_Volume_Flag, Close_Gauge_TC_Volume_Flag'
      ALTER TABLE Tank_History ADD
            Open_Gauge_TC_Volume_Flag     smallint DEFAULT NULL,
            Close_Gauge_TC_Volume_Flag    smallint DEFAULT NULL
   END
   
   -- DBU 501
   if( select numeric_precision 
       from information_schema.columns 
       WHERE TABLE_NAME = 'tank_history'
       and column_name = 'Open_Fuel_Density')  < 12
   BEGIN
		exec upgrade_decimal_column 'tank_history', 'Open_Fuel_Density',    12, 4
   END
   if( select numeric_precision 
       from information_schema.columns 
       WHERE TABLE_NAME = 'tank_history'
       and column_name = 'Close_Fuel_Density') < 12
   BEGIN
		exec upgrade_decimal_column 'tank_history', 'Close_Fuel_Density',    12, 4
   END
END
go

  
print 'Table: Tank_Strapping'
go
IF NOT EXISTS(SELECT NULL FROM INFORMATION_SCHEMA.TABLES 
              WHERE TABLE_NAME = 'Tank_Strapping')
Begin
   print ' Created'
   CREATE TABLE Tank_Strapping (
        Tank_ID              int NOT NULL,
        Strap_Level          decimal(10,4) NOT NULL DEFAULT 0.0,
        Level_Passes         int NOT NULL DEFAULT 1,
        Strap_Volume         decimal(12,4) NOT NULL DEFAULT 0.0,
        PRIMARY KEY (Tank_ID, Strap_Level), 
        FOREIGN KEY (Tank_ID)
                              REFERENCES Tanks
   )
End
ELSE
BEGIN
   -- DBU 320
   if (select numeric_precision 
       from information_schema.columns 
       WHERE TABLE_NAME = 'Hose_History'
       and column_name = 'open_meter_value') < 15
   Begin
      exec upgrade_decimal_column 'tank_strapping', 'strap_volume',      12, 4
   End
END
go


print 'Table: Tank_Reading_Type'
go
IF NOT EXISTS (SELECT table_name 
              FROM information_schema.tables 
              WHERE TABLE_NAME = 'Tank_Reading_Type')
BEGIN
 print ' Created'
 CREATE TABLE Tank_Reading_Type (
        Tank_Reading_Type_ID        int NOT NULL,
        Tank_Reading_Type_Name      char(50) NOT NULL DEFAULT '',
		PRIMARY KEY (Tank_Reading_Type_ID) 
 )
END
GO

print 'Table: Tank_Readings'
go
IF NOT EXISTS (SELECT table_name 
              FROM information_schema.tables 
              WHERE TABLE_NAME = 'Tank_Readings')
BEGIN
 print ' Created'
 CREATE TABLE Tank_Readings (
        Period_ID                 int NOT NULL,
        Tank_ID                   int NOT NULL,
		Tank_Reading_Type_ID	  int NOT NULL,
        Open_Reading_Value        decimal(15,4) NOT NULL DEFAULT 0.0,
        Close_Reading_Value       decimal(15,4) NOT NULL DEFAULT 0.0,
		User_ID					  int DEFAULT NULL,
        Open_Dip_Type_ID          int DEFAULT 1,
        Close_Dip_Type_ID         int DEFAULT 1,
        PRIMARY KEY (Period_ID, Tank_ID, Tank_Reading_Type_ID), 
        FOREIGN KEY (Period_ID) REFERENCES Periods, 
        FOREIGN KEY (Tank_ID) REFERENCES Tanks,
        FOREIGN KEY (Tank_Reading_Type_ID) REFERENCES Tank_Reading_Type, 
        FOREIGN KEY (Open_Dip_Type_ID) REFERENCES Tank_Dip_Type,
        FOREIGN KEY (Close_Dip_Type_ID) REFERENCES Tank_Dip_Type 
 )
END
ELSE
BEGIN
   IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Tank_Readings' AND COLUMN_NAME='User_ID')
   BEGIN
      PRINT ' Adding columns: User_ID'
	  ALTER TABLE Tank_Readings ADD User_ID	int DEFAULT NULL
   END
END
GO
   
print 'Table: Attendant_History'
go
IF NOT EXISTS(SELECT NULL FROM INFORMATION_SCHEMA.TABLES 
              WHERE TABLE_NAME = 'Attendant_History')
BEGIN
 print ' Created'
 CREATE TABLE Attendant_history (
        Attendant_ID            int            NOT NULL,
        Att_Period_ID           int            NOT NULL,
        Hose_ID                 int            NOT NULL,
        Attendant_Quantity      decimal(9)     NOT NULL DEFAULT 0.0,
        Attendant_Volume        decimal(15,4)  NOT NULL DEFAULT 0.0,
        Attendant_Value         decimal(15,4)  NOT NULL DEFAULT 0.0,
        Att_Open_Meter_Value    decimal(15,4),
        Att_Open_Meter_Volume   decimal(15,4),
        Att_Close_Meter_Value   decimal(15,4),
        Att_Close_Meter_Volume  decimal(15,4),
        Quantity_Total          decimal(9)     NOT NULL DEFAULT 0.0,
        Volume_Total            decimal(15,4)  NOT NULL DEFAULT 0.0,
        Value_Total             decimal(15,4)  NOT NULL DEFAULT 0.0,
        Quantity_Total1          decimal(9)     NOT NULL DEFAULT 0.0,
        Volume_Total1            decimal(15,4)  NOT NULL DEFAULT 0.0,
        Value_Total1             decimal(15,4)  NOT NULL DEFAULT 0.0,
        Quantity_Total2          decimal(9)     NOT NULL DEFAULT 0.0,
        Volume_Total2            decimal(15,4)  NOT NULL DEFAULT 0.0,
        Value_Total2             decimal(15,4)  NOT NULL DEFAULT 0.0,
        Attendant_Quantity1      decimal(9)     NOT NULL DEFAULT 0.0,
        Attendant_Volume1        decimal(15,4)  NOT NULL DEFAULT 0.0,
        Attendant_Value1         decimal(15,4)  NOT NULL DEFAULT 0.0,
        Attendant_Quantity2      decimal(9)     NOT NULL DEFAULT 0.0,
        Attendant_Volume2        decimal(15,4)  NOT NULL DEFAULT 0.0,
        Attendant_Value2         decimal(15,4)  NOT NULL DEFAULT 0.0,
        PRIMARY KEY (Attendant_ID, Hose_ID, Att_Period_ID), 
        FOREIGN KEY (Att_Period_ID) REFERENCES Attendant_Period, 
        FOREIGN KEY (Hose_ID) REFERENCES Hoses, 
        FOREIGN KEY (Attendant_ID) REFERENCES Attendant
 )
END
else
BEGIN

   if (select numeric_precision 
       from information_schema.columns 
       WHERE TABLE_NAME = 'Attendant_History'
       and column_name = 'attendant_volume') < 15
   Begin
      exec upgrade_decimal_column 'attendant_history', 'attendant_volume', 15, 4
      exec upgrade_decimal_column 'attendant_history', 'attendant_value',  15, 4
      exec upgrade_decimal_column 'attendant_history', 'volume_total', 15, 4
      exec upgrade_decimal_column 'attendant_history', 'value_total',  15, 4
   End

   -- Broken since V3. The Open_Meter_Volume should always have been Att_Open_Meter_Volume
   IF EXISTS(SELECT NULL FROM INFORMATION_SCHEMA.COLUMNS 
                 WHERE COLUMN_NAME = 'Open_Meter_Volume' 
                 AND TABLE_NAME = 'Attendant_History')
   BEGIN
      -- sp_rename tested on SQL Server 2000!	
      EXEC sp_rename 'Attendant_History.Open_Meter_Volume', 'Att_Open_Meter_Volume', 'COLUMN'
   END
	       

   -- DBU 336
   IF NOT EXISTS(SELECT NULL FROM INFORMATION_SCHEMA.COLUMNS 
                 WHERE COLUMN_NAME = 'Att_Open_Meter_Value' 
                 AND TABLE_NAME = 'Attendant_History')
   BEGIN
      print ' Adding columns: Att_Open_Meter_Value, Att_Open_Meter_Volume, Att_Close_Meter_Value, Att_Close_Meter_volume'
      ALTER TABLE Attendant_History    ADD Att_Open_Meter_Value   decimal(15,4)
      ALTER TABLE Attendant_History    ADD Att_Open_Meter_Volume  decimal(15,4)
      ALTER TABLE Attendant_History    ADD Att_Close_Meter_Value  decimal(15,4)
      ALTER TABLE Attendant_History    ADD Att_Close_Meter_Volume decimal(15,4)
   END

   -- DBU 341
   IF NOT exists(select column_name from INFORMATION_SCHEMA.COLUMNS 
                 where COLUMN_NAME = 'Quantity_Total' 
                 and TABLE_NAME = 'Attendant_History')
   Begin
      print ' Adding columns: Quantity_Total, Volume_Total, Value_Total'
      ALTER TABLE Attendant_History ADD 
           Quantity_Total decimal(9)  NOT NULL DEFAULT 0.0,
           Volume_Total decimal(15,4) NOT NULL DEFAULT 0.0,
           Value_Total decimal(15,4)  NOT NULL DEFAULT 0.0
   End

	-- DBU 407 ITLCR218 Post-Mix Fuels
	IF NOT exists(select column_name from INFORMATION_SCHEMA.COLUMNS 
	               where COLUMN_NAME = 'Quantity_Total1' 
	                 and TABLE_NAME = 'Attendant_History')
	Begin
		print ' Adding columns: Quantity_Total1, Volume_Total1, Value_Total1, Quantity_Total2, Volume_Total2,Value_Total2, Attendant_Quantity1, Attendant_Volume1, Attendant_Value1, Attendant_Quantity2, Attendant_Volume2, Attendant_Value2'
		ALTER TABLE Attendant_History ADD 
			Quantity_Total1          decimal(9)     NOT NULL DEFAULT 0.0,
			Volume_Total1            decimal(15,4)  NOT NULL DEFAULT 0.0,
			Value_Total1             decimal(15,4)  NOT NULL DEFAULT 0.0,
			Quantity_Total2          decimal(9)     NOT NULL DEFAULT 0.0,
			Volume_Total2            decimal(15,4)  NOT NULL DEFAULT 0.0,
			Value_Total2             decimal(15,4)  NOT NULL DEFAULT 0.0,
			Attendant_Quantity1      decimal(9)     NOT NULL DEFAULT 0.0,
			Attendant_Volume1        decimal(15,4)  NOT NULL DEFAULT 0.0,
        	Attendant_Value1         decimal(15,4)  NOT NULL DEFAULT 0.0,
			Attendant_Quantity2      decimal(9)     NOT NULL DEFAULT 0.0,
			Attendant_Volume2        decimal(15,4)  NOT NULL DEFAULT 0.0,
			Attendant_Value2         decimal(15,4)  NOT NULL DEFAULT 0.0
	End

END
go
 
   
print 'Table: OPT_Key_Map'
go
IF NOT EXISTS(select table_name 
          from information_schema.tables 
          WHERE TABLE_NAME = 'OPT_KEY_MAP')
Begin
 print ' Created'
 CREATE TABLE OPT_Key_Map (
        Key_Map_ID           int NOT NULL,
        Key_Map_Description  char(32) NOT NULL,
        PRIMARY KEY (Key_Map_ID)
  )
End
go

    
print 'Table: OPT_Type'
go
IF NOT EXISTS(select table_name
          from information_schema.tables 
          WHERE TABLE_NAME = 'OPT_Type') 
Begin
 print ' Created'
 CREATE TABLE OPT_Type (
        OPT_Type_ID          int NOT NULL,
        Protocol_ID          int NOT NULL,
        Key_Map_ID           int NOT NULL,
        OPT_Type_Name        char(30) NOT NULL,
        CapMACCalculation    smallint NULL,
        CapLanguage          smallint NULL,
        CapTone              smallint NULL,
        CapPitch             smallint NULL,
        CapVolume            smallint NULL,
        CapDisplay           smallint NULL,
        CapBlink             smallint NULL,
        CapBrightness        smallint NULL,
        CapCharacterSet      smallint NULL,
        CapHMarquee          smallint NULL,
        CapICharWait         smallint NULL,
        CapVMarquee          smallint NULL,
        DeviceWindows        smallint NULL,
        DisplayType          smallint NULL,
        DeviceRows           smallint NULL,
        DeviceColumns        smallint NULL,
        DeviceDescriptors    smallint NULL,
        CapKeyboard          smallint NULL,
        CapKeyUp             smallint NULL,
        CapISO               smallint NULL,
        CapJISOne            smallint NULL DEFAULT 0.0,
        CapJISTwo            smallint NULL DEFAULT 0.0,
        CapRecPresent        smallint NULL DEFAULT 0.0,
        CapRec2Color         smallint NULL,
        CapSecure            smallint NULL DEFAULT 0.0,
        CapRecBarCode        smallint NULL DEFAULT 0.0,
        CapRecBitmap         smallint NULL DEFAULT 0.0,
        CapRecBold           smallint NULL,
        CapRecDhigh          smallint NULL,
        CapRecDwideDhigh     smallint NULL,
        CapRecDwide          smallint NULL,
        CapRecEmptySensor    smallint NULL,
        CapRecItalic         smallint NULL,
        CapRecLeft90         smallint NULL,
        CapRecNearEndSensor  smallint NULL,
        CapRecPapercut       smallint NULL,
        CapRecRight90        smallint NULL,
        CapRecRotate180      smallint NULL,
        CapRecStamp          smallint NULL,
        CapRecUnderline      smallint NULL,
        RecSidewaysMaxLines  smallint NULL,
        RecLineChars         smallint NULL,
        RecSidewaysMaxChars  smallint NULL,
        RecLineDots          smallint NULL,
        RecLinesToPaperCut   smallint NULL,
        OPTResponseTimeout   smallint NULL,
        OPTInterCharTimeout  smallint NULL,
        OPTPollingRate       smallint NULL,
        CapCoverSensor       smallint NULL DEFAULT 0.0,
        OPTMax_No_Responses  smallint NULL DEFAULT 0.0,
        OPTDownloadable      smallint NULL,
        CapVideoSource       smallint NULL DEFAULT 0.0,
        CapTagReader         smallint NULL DEFAULT 0.0,
        PRIMARY KEY (OPT_Type_ID), 
        FOREIGN KEY (Key_Map_ID)  REFERENCES OPT_Key_Map, 
        FOREIGN KEY (Protocol_ID) REFERENCES Pump_Protocol
 )
End
go

    
print 'Table: OPTs'
go
IF NOT EXISTS(select table_name 
          from information_schema.tables 
          WHERE TABLE_NAME = 'OPTs')
Begin
 print ' Created'
 CREATE TABLE OPTs (
        OPT_ID               int NOT NULL,
        Pump_ID              int NULL,
        Loop_ID              int NOT NULL,
        OPT_Type_ID          int NOT NULL,
        OPT_Address          int NOT NULL,
        OPT_Number           smallint NOT NULL,
        OPT_Name             nchar(20) NOT NULL,
        POS_Terminal         int NULL,
        Pumps                char(40) NULL,
        Pump_Control         int NULL DEFAULT 0,
        PRIMARY KEY (OPT_ID), 
        FOREIGN KEY (Pump_ID) REFERENCES Pumps, 
        FOREIGN KEY (Loop_ID) REFERENCES Loops, 
        FOREIGN KEY (OPT_Type_ID) REFERENCES OPT_Type
 )
End
ELSE
BEGIN
  IF EXISTS(select column_name
          from information_schema.columns 
          WHERE TABLE_NAME = 'OPTs'
          and Column_name = 'Pos_Terminal')
  BEGIN
    print ' Adding column: POS_Terminal'
    ALTER TABLE opts ALTER COLUMN pos_terminal int NULL
  END

  IF EXISTS(select column_name
          from information_schema.columns 
          WHERE TABLE_NAME = 'OPTs'
          and Column_name = 'Pump_id')
  Begin
    print ' Adding column: Pump_ID'
    ALTER TABLE opts ALTER COLUMN pump_id int NULL
  End

  -- DBU 331
  IF NOT EXISTS(select column_name
                from information_schema.columns 
                WHERE TABLE_NAME = 'OPTs'
                and Column_name = 'Pumps')
  Begin
    print ' Adding column: Pumps, Pump_Control'
    ALTER TABLE opts ADD Pumps char(40) NULL
    ALTER TABLE opts ADD Pump_Control int NULL DEFAULT 0
  End

END
go

    
print 'Table: OPT_Key_Codes'
go
IF NOT EXISTS(select table_name 
          from information_schema.tables
          WHERE TABLE_NAME = 'OPT_KEY_CODES')
Begin 
 print ' Created'
 CREATE TABLE OPT_Key_Codes (
        Key_Map_ID           int       NOT NULL,
        App_Scan_Code        smallint  NOT NULL,
        OPT_Scan_Code        smallint  NOT NULL,
        Key_Group            smallint  NOT NULL,
        Key_Desc             nchar(40) NULL,
        PRIMARY KEY (Key_Map_ID, OPT_Scan_Code), 
        FOREIGN KEY (Key_Map_ID) REFERENCES OPT_Key_Map
 )
End
Else
Begin
   if not exists(select column_name from information_schema.columns
                 where Table_name = 'opt_key_codes'
                 and column_name = 'key_desc')
   Begin
      print ' Adding column: Key_Desc'
      ALTER TABLE OPT_Key_Codes ADD Key_Desc nchar(40) NULL
   End
END
go
 
    
print 'Table: OPT_Prompt_Map'
go
IF NOT EXISTS(select table_name 
          from information_schema.tables 
          WHERE TABLE_NAME = 'OPT_Prompt_MAP')
Begin
 print ' Created'
 CREATE TABLE OPT_Prompt_Map (
        OPT_Type_ID          int      NOT NULL,
        Prompt_ID            int      NOT NULL,
        Prompt_Type          smallint NOT NULL,
        Screen_Number        int      NOT NULL DEFAULT 0, 
        OPT_Ref              smallint NOT NULL DEFAULT 0,
		PRIMARY KEY (Screen_Number, OPT_Type_ID),
        FOREIGN KEY (Prompt_ID)   REFERENCES Prompts, 
        FOREIGN KEY (OPT_Type_ID) REFERENCES OPT_Type
 )
End
else
Begin
   IF EXISTS(select column_name
          from information_schema.columns 
          WHERE TABLE_NAME = 'OPT_Prompt_MAP'
          AND column_name = 'opt_prompt_id')
   Begin
      print ' Removing column: Opt_Prompt_ID'
      ALTER TABLE OPT_Prompt_Map DROP COLUMN OPT_Prompt_ID
   End

End
GO

-- OPT_Prompt_Map post Processing follows. Separate SQL blocks required for upgrade code to work.
-- 1. Drop the old key based on Prompt_ID
IF NOT EXISTS(select column_name
          from information_schema.columns 
          WHERE TABLE_NAME = 'OPT_Prompt_MAP'
          AND column_name = 'Screen_Number')
Begin
   -- Delete the previously existing primary key
   DECLARE @con_name varchar(200), @cmd varchar(200)
   SET @con_name = (select name from sysobjects where xtype = 'PK' 
				and object_name(sysobjects.parent_obj) = 'OPT_Prompt_Map')
   IF @con_name is not NULL
   BEGIN
      print ' Removing old key: '+@con_name
      SET @cmd = 'ALTER TABLE OPT_Prompt_Map DROP CONSTRAINT ' + @con_name
      EXEC(@cmd)
   END

   print ' Adding columns: Screen_Number, OPT_Ref'
   ALTER TABLE OPT_Prompt_Map ADD 
      Screen_Number int      NOT NULL DEFAULT 0,
      OPT_Ref       smallint NOT NULL DEFAULT 0
END
GO

-- 2. Update all zero ( 0 )Screen_Numbers first
print ' Setting column: Screen_Number (to ensure none set to 0)'
go
UPDATE OPT_Prompt_Map set Screen_Number = Prompt_ID WHERE Screen_Number=0
GO

-- 3. Create the new primary key (if it doesn't exist)
DECLARE @con_name varchar(200), @cmd varchar(200)
SET @con_name = (select name from sysobjects where xtype = 'PK' 
				and object_name(sysobjects.parent_obj) = 'OPT_Prompt_Map')
IF @con_name is NULL
BEGIN
   print ' Adding primary key: (Screen_Number, OPT_Type_ID)'
   ALTER TABLE OPT_Prompt_Map ADD PRIMARY KEY (Screen_Number, OPT_Type_ID)
END
GO	
-- OPT_Prompt_Map post Processing ends.
   
print 'Table: Version_History'
go
IF NOT EXISTS(SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
              WHERE TABLE_NAME = 'Version_History')
BEGIN
 print ' Created'
 CREATE TABLE Version_History (
        Patch_ID             smallint NOT NULL,
        Patch_File_Name      char(30) NOT NULL,
        Patch_DT             datetime NOT NULL,
        Patch_Description    char(80) NOT NULL, 
	PRIMARY KEY(Patch_ID)
 )
END
ELSE
BEGIN

	IF NOT EXISTS (  SELECT DISTINCT CONSTRAINT_NAME FROM information_schema.KEY_COLUMN_USAGE 
                         WHERE TABLE_NAME = 'Version_History' 
                         AND CONSTRAINT_NAME LIKE 'PK%')
	BEGIN
    		ALTER TABLE Version_History ADD CONSTRAINT pk_patch_id PRIMARY KEY (Patch_ID)
	END
END
go


   
print 'Table: Emulation'
go
IF not EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_NAME = 'Emulation') 
BEGIN
	print ' Created'
	CREATE TABLE Emulation (
	       Record_ID       int NOT NULL,
	       Protocol_ID      int NOT NULL DEFAULT 11,
	       Connection_Type  int NOT NULL DEFAULT 0,
	       Comm_Port       int NOT NULL DEFAULT 0,
	       Comm_Settings    char(40),
	       PRIMARY KEY (Record_ID), 
	       FOREIGN KEY (Protocol_ID) REFERENCES Pump_Protocol
 )
END
go


   
print 'Table: Attendant_Period_History'
go
IF not EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_NAME = 'Attendant_Period_History') 
BEGIN
    print ' Created'
    CREATE TABLE Attendant_Period_History (
        Attendant_Period_History_ID         int IDENTITY,
        Att_Period_ID                       int NOT NULL,
        Payment_Type_ID                    int NOT NULL,
        Att_Period_History_Initial_Float    decimal(12,4) NOT NULL DEFAULT 0.0,
        Att_Period_History_Amount_Counted   decimal(12,4) NOT NULL DEFAULT 0.0,
	Att_Volume_Total			decimal(15,4)  NOT NULL DEFAULT 0.0,
	Att_Value_Total				decimal(15,4)  NOT NULL DEFAULT 0.0,
	Cash_Payment_Type			int NOT NULL DEFAULT 0,
        PRIMARY KEY (Attendant_Period_History_ID),
        FOREIGN KEY (Att_Period_ID) REFERENCES Attendant_Period,
    )
END
ELSE
	BEGIN
		IF NOT EXISTS(SELECT column_name FROM INFORMATION_SCHEMA.columns
			WHERE TABLE_NAME = 'Attendant_Period_History' 
			AND column_name = 'Att_Value_Total' )
			BEGIN
				print 'Adding column: Attendant_Value_Total and Attendant_Volume_Total'
				ALTER TABLE Attendant_Period_History ADD Att_Volume_Total decimal(15,4)  NOT NULL DEFAULT 0.0
				ALTER TABLE Attendant_Period_History ADD Att_Value_Total decimal(15,4)  NOT NULL DEFAULT 0.0
				ALTER TABLE Attendant_Period_History ADD Cash_Payment_Type int NOT NULL DEFAULT 0
			END
	END
go

   
print 'Table: Attendant_Safedrop'
go
IF not EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_NAME = 'Attendant_Safedrop') 
BEGIN
    print ' Created'
    CREATE TABLE Attendant_Safedrop (
        Attendant_Safedrop_ID         int IDENTITY,
        Attendant_Period_History_ID       int NOT NULL,
        Att_Safedrop_DateTime          datetime NOT NULL,
        Att_Safedrop_Amount            decimal(12,4) NOT NULL DEFAULT 0.0,
        Att_Safedrop_Transaction_ID       int,

    PRIMARY KEY (Attendant_Safedrop_ID),
    FOREIGN KEY (Attendant_Period_History_ID) REFERENCES Attendant_Period_History
    )
END
go

   
print 'Table: Detected_Tank_Delivery'
go
IF NOT EXISTS ( SELECT table_name From INFORMATION_SCHEMA.tables 
                where TABLE_NAME = 'Detected_Tank_Delivery')
BEGIN
  print ' Created'
  CREATE TABLE Detected_Tank_Delivery (
        Detected_Tank_Delivery_ID   int           NOT NULL,
        Tank_ID                     int           NOT NULL,
        Start_Date_Time             datetime      NULL,
        End_Date_Time               datetime      NULL,
        Start_Volume                decimal(15,4) NULL DEFAULT 0.0,
        End_Volume                  decimal(15,4) NULL DEFAULT 0.0,
        Start_Temperature           decimal(8,4)  NULL DEFAULT 0.0,
        End_Temperature             decimal(8,4)  NULL DEFAULT 0.0,
        Product_Code                nvarchar(10)  NULL DEFAULT '',
        Start_TC_Volume             decimal(15,4) NULL DEFAULT 0.0,
        Start_Water                 decimal(15,4) NULL DEFAULT 0.0,
        Start_Height                decimal(8,4)  NULL DEFAULT 0.0,
        End_TC_Volume               decimal(15,4) NULL DEFAULT 0.0,
        End_Water                   decimal(15,4) NULL DEFAULT 0.0,
        End_Height                  decimal(8,4)  NULL DEFAULT 0.0,
        PRIMARY KEY NONCLUSTERED (Detected_Tank_Delivery_ID),
        FOREIGN KEY (Tank_ID) REFERENCES Tanks
  )
END
ELSE
BEGIN
-- DBU 337
   IF NOT Exists ( SELECT Column_Name From INFORMATION_SCHEMA.COLUMNS 
                   where column_name = 'Start_TC_Volume' 
                   AND TABLE_NAME = 'Detected_Tank_Delivery')
   BEGIN
      print ' Add columns: Product_Code, Start_TC_Volume, Start_Water, Start_Height, End_TC_Volume, End_Water, End_Height'
      ALTER TABLE Detected_Tank_Delivery ADD
           Product_Code     nvarchar(10)  NULL DEFAULT '',
           Start_TC_Volume  decimal(15,4) NULL DEFAULT 0.0,
           Start_Water      decimal(15,4) NULL DEFAULT 0.0,
           Start_Height     decimal(8,4)  NULL DEFAULT 0.0,
           End_TC_Volume    decimal(15,4) NULL DEFAULT 0.0,
           End_Water        decimal(15,4) NULL DEFAULT 0.0,
           End_Height       decimal(8,4)  NULL DEFAULT 0.0
   END

   -- DBU 411
   IF (SELECT numeric_precision 
         FROM information_schema.columns 
        WHERE TABLE_NAME = 'Detected_Tank_Delivery'
          AND COLUMN_NAME = 'Start_Water') < 15
   BEGIN
      EXEC upgrade_decimal_column 'Detected_Tank_Delivery', 'Start_Water', 15, 4
      EXEC upgrade_decimal_column 'Detected_Tank_Delivery', 'End_Water',   15, 4
   END
END
GO



print 'Table: Tank_Loss'
go
IF not EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_NAME = 'Tank_Loss')
BEGIN
   print ' Created'
   CREATE TABLE Tank_Loss (
      Tank_Loss_ID     int NOT NULL,
      Tank_ID          int NOT NULL,
      Period_ID        int NOT NULL,
      Loss_Date_Time   datetime NOT NULL Default GetDate(),
      Record_Entry_TS  datetime NOT NULL Default GetDate(),
      Loss_Volume      decimal(10,4) NOT NULL DEFAULT 0,
      Loss_Volume_Theo decimal(10,4) NOT NULL DEFAULT 0,
      Loss_Doc_Ref     nchar(10) NULL,
      Loss_Detail      nchar(40) NULL,
      Tank_Movement_Type_ID int,
      User_ID          int DEFAULT NULL,
      PRIMARY KEY (Tank_Loss_ID),
      FOREIGN KEY (Tank_ID) REFERENCES Tanks,
      FOREIGN KEY (Period_ID) REFERENCES Periods,
      FOREIGN KEY (Tank_Movement_Type_ID) REFERENCES Tank_Movement_Type
    )
END
ELSE
BEGIN
    -- DBU 400
    IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Tank_Loss' AND COLUMN_NAME='Tank_Movement_Type_ID')
    BEGIN
        PRINT ' Adding columns: Tank_Movement_Type_ID'
        ALTER TABLE Tank_Loss ADD Tank_Movement_Type_ID int FOREIGN KEY (Tank_Movement_Type_ID) REFERENCES Tank_Movement_Type
    END

   IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Tank_Loss' AND COLUMN_NAME='User_ID')
   BEGIN
      PRINT ' Adding columns: User_ID'
	  ALTER TABLE Tank_Loss ADD User_ID	int DEFAULT NULL
   END

END
go

   
print 'Table: Tank_Transfer'
go
IF not EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Tank_Transfer')
BEGIN
   print ' Created'
   CREATE TABLE Tank_Transfer(
      Tank_Transfer_ID   int NOT NULL,
      From_Tank_ID       int NOT NULL,
      To_Tank_ID         int NOT NULL,
      Period_ID          int NOT NULL,
      Transfer_Date_Time datetime NOT NULL Default GetDate(),
      Record_Entry_TS    datetime NOT NULL Default GetDate(),
      Transfer_Volume    decimal(10,4) NOT NULL DEFAULT 0,
      Transfer_Doc_Ref   nchar(10) NULL,
      Transfer_Detail    nchar(40) NULL,
      Tank_Movement_Type_ID int,
      Delivery_ID        int,
      User_ID            int DEFAULT NULL,
      PRIMARY KEY (Tank_Transfer_ID),
      FOREIGN KEY (From_Tank_ID)REFERENCES Tanks(Tank_ID),
      FOREIGN KEY (To_Tank_ID) REFERENCES Tanks(Tank_ID),
      FOREIGN KEY (Period_ID) REFERENCES Periods, 
      FOREIGN KEY (Tank_Movement_Type_ID) REFERENCES Tank_Movement_Type,
      FOREIGN KEY (Delivery_ID) REFERENCES Hose_Delivery
      )
END
ELSE
BEGIN
    -- DBU 400 
     IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Tank_Transfer' AND COLUMN_NAME='Tank_Movement_Type_ID')
    BEGIN
      PRINT ' Adding columns: Tank_Movement_Type_ID, Delivery_ID'
      ALTER TABLE Tank_Transfer ADD 
            Tank_Movement_Type_ID int FOREIGN KEY (Tank_Movement_Type_ID) REFERENCES Tank_Movement_Type,
            Delivery_ID  int FOREIGN KEY (Delivery_ID) REFERENCES Hose_Delivery
    END

   IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Tank_Transfer' AND COLUMN_NAME='User_ID')
   BEGIN
      PRINT ' Adding columns: User_ID'
	  ALTER TABLE Tank_Transfer ADD User_ID	int DEFAULT NULL
   END

END
go

print 'Table: Tank_Variance_Reason'
go
IF NOT EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_NAME = 'Tank_Variance_Reason') 
BEGIN
  print ' Created'
  CREATE TABLE Tank_Variance_Reason
   (
	Reason_ID                int NOT NULL,
	Reason_Description 		 char(80),
	PRIMARY KEY (Reason_ID)
   )
END
GO
   
print 'Table: Enabler_Options'
go
IF not EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_NAME = 'Enabler_Options') 
BEGIN
	print ' Created'
	CREATE TABLE Enabler_Options (
	       Options_ID        int NOT NULL default 1,
	       Tank_Delete       int NOT NULL default 1,
	       Tank_Add          int NOT NULL default 1,
	       Tank_Edit         int NOT NULL default 1,
	       Grade_Delete      int NOT NULL default 1,
	       Grade_Add         int NOT NULL default 1,
	       Grade_Edit        int NOT NULL default 1,
	       Pump_Delete       int NOT NULL default 1,
	       Pump_Add          int NOT NULL default 1,
	       Pump_Edit         int NOT NULL default 1,
	       Hose_Delete       int NOT NULL default 1,
	       Hose_Add          int NOT NULL default 1,
	       Level_Delete      int NOT NULL default 1,
	       Level_Add         int NOT NULL default 1,
	       Mode_Delete       int NOT NULL default 1,
	       Mode_Add          int NOT NULL default 1,
	       Mode_Edit         int NOT NULL default 1,
	       Port_Config       int NOT NULL default 1,
	       Emulation_Config  int NOT NULL default 1,
	       OPT_Config        int NOT NULL default 1,
	       OPT_Delete        int NOT NULL default 1,
	       OPT_Add           int NOT NULL default 1,
	       Price_Edit        int NOT NULL default 1,
	       TG_Config         int NOT NULL default 1,
	       TG_Delete         int NOT NULL default 1,
	       TG_Add            int NOT NULL default 1, 
	       Attendant_Delete  int NOT NULL default 1,
	       Attendant_Add     int NOT NULL default 1,
	       Attendant_Edit    int NOT NULL default 1,
	       PRIMARY KEY (Options_ID)
     	)
END
ELSE
BEGIN
    IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Enabler_Options' AND COLUMN_NAME='TG_Config')
    BEGIN
      PRINT ' Adding columns: TG_Config, TG_Delete, TG_Add'
      ALTER TABLE Enabler_Options ADD 
		TG_Config         int NOT NULL default 1,
		TG_Delete         int NOT NULL default 1,
		TG_Add            int NOT NULL default 1
	END

    IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Enabler_Options' AND COLUMN_NAME='Attendant_Delete')
    BEGIN
      PRINT ' Adding columns: Attendant_Delete, Attendant_Add, Attendant_Edit'
      ALTER TABLE Enabler_Options ADD 
		Attendant_Delete         int NOT NULL default 1,
		Attendant_Add            int NOT NULL default 1,
		Attendant_Edit           int NOT NULL default 1
	END

    IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Enabler_Options' AND COLUMN_NAME='Pump_Edit')
    BEGIN
      PRINT ' Adding columns: Pump_edit, Tank_edit, Grade_edit'
      ALTER TABLE Enabler_Options ADD 
		Tank_Edit         int NOT NULL default 1,
		Grade_Edit        int NOT NULL default 1,
		Pump_Edit         int NOT NULL default 1
	END

   IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Enabler_Options' AND COLUMN_NAME='Options_ID')
    BEGIN
      PRINT ' Adding columns: Options_ID'
      ALTER TABLE Enabler_Options ADD 
		Options_ID         int NOT NULL default 1,
		PRIMARY KEY (Options_ID)
	END

END
go

print 'Table: DBVersion'
go
IF not EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_NAME = 'DBVersion') 
BEGIN
  print ' Created'
    CREATE TABLE DBVersion (
        Version        int NULL DEFAULT 0,
        DateInstalled  datetime NULL 
    )

    INSERT 
      INTO DBVersion ( Version, DateInstalled ) 
    VALUES ( 0, CURRENT_TIMESTAMP )

END
go


print 'Table: Tank_Delivery_Detected_Delivery'
go
IF NOT EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_NAME = 'Tank_Delivery_Detected_Delivery') 
BEGIN
  print ' Created'
  CREATE TABLE Tank_Delivery_Detected_Delivery
   (
    Tank_Del_Detect_ID  int IDENTITY(1,1)PRIMARY KEY CLUSTERED,
    Site_Delivery_ID int NOT NULL,
    Tank_Delivery_ID int NOT NULL,
    Detected_Tank_Delivery_ID int NOT NULL,
    Exported tinyint NOT NULL default (0),
    Record_Entry_TS datetime NOT NULL DEFAULT getdate()
   )
END
ELSE
BEGIN
    IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Tank_Delivery_Detected_Delivery' AND COLUMN_NAME='Tank_Del_Detect_ID')
    BEGIN
      PRINT ' Adding column: Tank_Del_Detect_ID'
      ALTER TABLE Tank_Delivery_Detected_Delivery 
        ADD Tank_Del_Detect_ID  int IDENTITY(1,1)PRIMARY KEY CLUSTERED
    END

    IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Tank_Delivery_Detected_Delivery' AND COLUMN_NAME='Record_Entry_TS')
    BEGIN
      print ' Adding column Record_Entry_TS'
      ALTER TABLE Tank_Delivery_Detected_Delivery
        ADD Record_Entry_TS datetime NOT NULL DEFAULT getdate()
    END
END
GO

print 'Table: Tag_Controller_Type'
go
IF NOT EXISTS(SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
   WHERE TABLE_NAME = 'Tag_Controller_Type')
BEGIN
   PRINT ' Creating table'
   CREATE TABLE Tag_Controller_Type (
      Tag_Controller_Type_ID  int NOT NULL,
      Max_Controllers         int NOT NULL DEFAULT 1,
      Max_Readers             int NOT NULL,
      Name                    nchar(40) NULL,
      Protocol_ID			  int NOT NULL,
      Topology				  int NOT NULL,
      Polling_Rate			  smallint NOT NULL,
      Poll_Response_TO		  smallint NOT NULL,
      Inter_Char_Timeout	  smallint NOT NULL,
	  Tag_Type				  smallint NOT NULL DEFAULT 0
      FOREIGN KEY (Protocol_ID)REFERENCES Pump_Protocol(Protocol_ID),
      PRIMARY KEY (Tag_Controller_Type_ID)
      )
END	
ELSE
BEGIN
	IF NOT EXISTS(SELECT * FROM information_schema.columns WHERE table_name = 'Tag_Controller_Type' AND column_name = 'Polling_Rate')
	BEGIN
      Print ' Adding columns: Protocol_ID, Topology, Polling_Rate, Poll_Response_TO, Inter_Char_Timeout'
      ALTER TABLE Tag_Controller_Type ADD Protocol_ID 			int NOT NULL DEFAULT 11
      ALTER TABLE Tag_Controller_Type ADD Topology 				int NOT NULL DEFAULT 0
      ALTER TABLE Tag_Controller_Type ADD Polling_Rate 			smallint NOT NULL DEFAULT 0
      ALTER TABLE Tag_Controller_Type ADD Poll_Response_TO 		smallint NOT NULL DEFAULT 0
      ALTER TABLE Tag_Controller_Type ADD Inter_Char_Timeout 	smallint NOT NULL DEFAULT 0
      ALTER TABLE Tag_Controller_Type ADD FOREIGN KEY (Protocol_ID)REFERENCES Pump_Protocol(Protocol_ID)
	END

	IF NOT EXISTS(SELECT * FROM information_schema.columns WHERE table_name = 'Tag_Controller_Type' AND column_name = 'Tag_Type')
	BEGIN
      Print 'Adding "Tag_Type" column to "Tag_Controller_Type" table'
      ALTER TABLE Tag_Controller_Type ADD Tag_Type smallint NOT NULL DEFAULT 0
	END
	
	IF NOT EXISTS(SELECT * FROM information_schema.columns WHERE table_name = 'Tag_Controller_Type' AND column_name = 'Max_Controllers')
	BEGIN
      Print 'Adding "Max_Controllers" column to "Tag_Controller_Type" table'
      ALTER TABLE Tag_Controller_Type ADD Max_Controllers int NOT NULL DEFAULT 1
	END
	
END	
GO

print 'Table: Tag_Controller'
go
IF NOT EXISTS(SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
   WHERE TABLE_NAME = 'Tag_Controller')
BEGIN
   PRINT ' Created'
   CREATE TABLE Tag_Controller	(
      Tag_Controller_ID       int NOT NULL,
      Tag_Controller_Type_ID  int NOT NULL,
      Number                            smallint NULL,
      Name                              nchar(40) NULL,
      Loop_ID                           int NOT NULL,
      Polling_Address                   smallint NOT NULL,
      CONSTRAINT FK__Tag_Controller_Tag__Controller_Type FOREIGN KEY (Tag_Controller_Type_ID)REFERENCES Tag_Controller_Type(Tag_Controller_Type_ID),
      CONSTRAINT FK__Tag_Controller__Loops FOREIGN KEY (Loop_ID)REFERENCES Loops(Loop_ID),
      PRIMARY KEY (Tag_Controller_ID)
      )	
END	
ELSE
BEGIN
	IF NOT EXISTS(SELECT * FROM information_schema.columns WHERE table_name = 'Tag_Controller' AND column_name = 'Polling_Address')
	BEGIN
      Print ' Adding column: Polling_Address'
      ALTER TABLE Tag_Controller ADD Polling_Address 	smallint NOT NULL DEFAULT 0
      print ' Adding FK: Tag_Controller_Type_ID'
      ALTER TABLE Tag_Controller ADD FOREIGN KEY (Tag_Controller_Type_ID)REFERENCES Tag_Controller_Type(Tag_Controller_Type_ID)
	END
	
	IF NOT EXISTS ( SELECT * FROM sysobjects WHERE name = 'FK__Tag_Controller__Loops' )
	BEGIN
		PRINT ' Adding FK: FK__Tag_Controller__Loops'
		ALTER TABLE Tag_Controller ADD CONSTRAINT FK__Tag_Controller__Loops FOREIGN KEY (Loop_ID) REFERENCES Loops(Loop_ID)
	END
END
GO

print 'Table: Tag_Reader'
go
IF NOT EXISTS(SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'Tag_Reader')
BEGIN
    PRINT ' Created'
    CREATE TABLE Tag_Reader(
        Tag_Reader_ID         int NOT NULL,
        Tag_Controller_ID     int NOT NULL,
        Polling_Address                 smallint NULL,
        Number                          smallint NULL,
        Name                            nchar(40) NULL,
        Pump_ID                         int NULL,
        CONSTRAINT FK__Tag_Read__Tag_Controller_ID FOREIGN KEY (Tag_Controller_ID)REFERENCES Tag_Controller(Tag_Controller_ID),
        FOREIGN KEY (Pump_ID)REFERENCES Pumps(Pump_ID),
        PRIMARY KEY (Tag_Reader_ID)
	)
END	
GO

print 'Table: Terminals'
go
IF NOT EXISTS(SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'Terminals')
BEGIN
    PRINT ' Created'
    CREATE TABLE Terminals(
		Terminal_ID         int          NOT NULL,
		Name                nvarchar(32) NOT NULL,
		Password            nvarchar(32) NOT NULL,
		Permissions         nchar(16)    NOT NULL,		
		Enabled             BIT          NOT NULL DEFAULT 1,
		Last_Connect        datetime     NULL,
		Api_ID              INT          NOT NULL DEFAULT -1,
		PRIMARY KEY (Terminal_ID)
    )
END	
ELSE
BEGIN
    IF EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Terminals' AND COLUMN_NAME='Allowed_Interfaces')
    BEGIN
		EXEC Drop_Constraints 'Terminals', 'Allowed_Interfaces', 'D'
    	PRINT ' Removing column: Allowed_Interfaces'
    	ALTER TABLE Terminals DROP COLUMN Allowed_Interfaces
    END

END
GO

-- make sure there is a row for Legacy terminals - customers can disable this later if they want
IF NOT EXISTS (SELECT Terminal_ID FROM Terminals WHERE Terminal_ID = -1)
BEGIN
	print ' Adding a record to Terminals for Legacy terminal access'
	INSERT INTO Terminals  ( Terminal_ID, Name, Permissions, Password )
	VALUES ( -1, 'Legacy Client', '1111100000000000', '7a1920d61156abc05a60135aefe8bc67' )
END
go

-- New table to store external tag details
-- must be created before Fuel_Transaction since it refers to this
print 'Table: External_Tag'
go
IF NOT EXISTS(SELECT table_name FROM information_schema.tables WHERE TABLE_NAME = 'External_Tag')
BEGIN
	PRINT ' Created'
	CREATE TABLE External_Tag (
		Tag_ID             int NOT NULL,
		Tag_Number         smallint NOT NULL DEFAULT 1,
		Tag_Data           nvarchar(32) NOT NULL DEFAULT ' ',
		Tag_Description    nvarchar(40) NULL,		
		Tag_Disabled       int NOT NULL DEFAULT 0,
		Date_Scanned       DateTime NULL, 		
		Date_Expiration    DateTime NULL, 
		PRIMARY KEY (Tag_ID)
      )
END
ELSE
BEGIN
	-- If the External_Tag already exists, then check the Tag_Description, Date_Scanned columns 
	IF NOT EXISTS(SELECT table_name FROM information_schema.columns 
	WHERE table_name = 'External_Tag' AND column_Name = 'Tag_Description')
	BEGIN
		Print 'Adding column: Tag_Description, Date_Scanned'
		ALTER TABLE External_Tag ADD
			Tag_Description    nvarchar(40) NULL
		ALTER TABLE External_Tag ADD
			Date_Scanned	   DateTime NULL
	END
END
GO

-- separate index for Tag_Data - will be used when looking up tags to validate
print 'Index: X1External_Tag on External_Tag.Tag_Data'
IF NOT EXISTS (SELECT name FROM sysindexes WHERE name = 'X1External_Tag') 
BEGIN
  print ' Created'
  CREATE INDEX X1External_Tag ON External_Tag
  (
     Tag_Data 
  )
END
GO


print 'Table: Fuel_Transaction'
go
IF NOT EXISTS(SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'Fuel_Transaction')
	BEGIN
		PRINT ' Created'
		CREATE TABLE Fuel_Transaction (
			Transaction_ID       int NOT NULL,
			Created_DateTime     datetime NOT NULL DEFAULT getdate(),
			Client_Reference     nvarchar(32) NOT NULL DEFAULT '',
			Client_Activity      nvarchar(32) NOT NULL DEFAULT '',
			State                int NOT NULL DEFAULT 0,
			Delivery_ID          int NULL DEFAULT NULL,
			Money_Limit          numeric(12,4) NOT NULL DEFAULT 0.0,
			Volume_Limit         numeric(12,4) NOT NULL DEFAULT 0.0,
			Attendant_ID         int NULL DEFAULT NULL ,
			ReservedBy_ID        int NULL DEFAULT NULL ,
			Reserved_DateTime    datetime NULL,
			Reserved_Type        int NOT NULL DEFAULT 0,
			AuthorisedBy_ID      int NULL DEFAULT NULL ,
			Authorised_DateTime  datetime NULL,
			Authorisation_Reason int NOT NULL DEFAULT 0,
			Completion_Reason    int NOT NULL DEFAULT 0,
			Authorisation_Hose_Mask smallint NOT NULL DEFAULT 0,			
			Max_Flow_Rate        numeric(12,4) NOT NULL DEFAULT 0.0,
			Pump_ID              int NOT NULL,
			Error_Flags	         int NOT NULL DEFAULT 0,
			Tag_Data             nvarchar(32) DEFAULT NULL , 
		CONSTRAINT FK_Fuel_Transaction_Delivery_ID     FOREIGN KEY (Delivery_ID)     REFERENCES Hose_Delivery(Delivery_ID),
		CONSTRAINT FK_Fuel_Transaction_Pump_ID         FOREIGN KEY (Pump_ID)         REFERENCES Pumps(Pump_ID),
		CONSTRAINT FK_Fuel_Transaction_Attendant_ID    FOREIGN KEY (Attendant_ID)    REFERENCES Attendant(Attendant_ID),
		PRIMARY KEY (Transaction_ID)
		)
	END
ELSE
	BEGIN
-- This only required to upgrade internal releases and can be removed for public release
		IF NOT EXISTS(SELECT column_name FROM INFORMATION_SCHEMA.columns
		WHERE TABLE_NAME = 'Fuel_Transaction' AND column_name = 'Reserved_Type')
		BEGIN
		  print ' Adding column: Reserved_Type'
		  ALTER TABLE Fuel_Transaction ADD Reserved_Type int NOT NULL DEFAULT 0
		END 

-- This only required to upgrade internal releases and can be removed for public release
		IF NOT EXISTS(SELECT column_name FROM INFORMATION_SCHEMA.columns
		WHERE TABLE_NAME = 'Fuel_Transaction' AND column_name = 'Error_Flags')
		BEGIN
		  print ' Adding column: Error_Flags'
		  ALTER TABLE Fuel_Transaction ADD Error_Flags int NOT NULL DEFAULT 0
		END 

		IF NOT EXISTS(SELECT column_name FROM INFORMATION_SCHEMA.columns
		WHERE TABLE_NAME = 'Fuel_Transaction' AND column_name = 'Authorisation_Hose_Mask')
		BEGIN
		  print ' Adding column: Authorisation_Hose_Mask'
		  ALTER TABLE Fuel_Transaction ADD Authorisation_Hose_Mask smallint NOT NULL DEFAULT 0
		END		

-- Internal release with External_Tag_ID. Remove if exists, Replaced with Tag_Data below
		IF EXISTS(SELECT column_name FROM INFORMATION_SCHEMA.columns
		WHERE TABLE_NAME = 'Fuel_Transaction' AND column_name = 'External_Tag_ID')
		BEGIN
		  print ' Removing column: External_Tag_ID'
		  EXEC Drop_Constraints 'Fuel_Transaction','External_Tag_ID','D'
      EXEC Drop_Constraints 'Fuel_Transaction','External_Tag_ID','F'
		  ALTER TABLE Fuel_Transaction DROP COLUMN External_Tag_ID
		END
		
		IF NOT EXISTS(SELECT column_name FROM INFORMATION_SCHEMA.columns
		WHERE TABLE_NAME = 'Fuel_Transaction' AND column_name = 'Tag_Data')
		BEGIN
		  print ' Adding column: Tag_Data'
		  ALTER TABLE Fuel_Transaction ADD Tag_Data nvarchar(32) DEFAULT NULL
		END		
	END
go

IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Fuel_Transaction' AND COLUMN_NAME='Pump_ID')
BEGIN
	print 'INFO: Fuel_Transaction table does not have Pump_ID column.'
	print 'WARN: Removing existing rows to add the new column.'
	delete from Fuel_Transaction
END
go

IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Fuel_Transaction' AND COLUMN_NAME='Pump_ID')
BEGIN
  print ' Adding column: Pump_ID'
  ALTER TABLE Fuel_Transaction ADD Pump_ID int NULL
  ALTER TABLE Fuel_Transaction ALTER COLUMN Pump_ID int NOT NULL
END
GO

IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Fuel_Transaction' AND COLUMN_NAME='Max_Flow_Rate')
BEGIN
  print ' Adding column: Max_Flow_Rate'
  ALTER TABLE Fuel_Transaction 
    ADD Max_Flow_Rate numeric(12,4) NOT NULL DEFAULT 0.0
END
GO

IF EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Fuel_Transaction' AND COLUMN_NAME='MaxFlowRate') AND EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Fuel_Transaction' AND COLUMN_NAME='Max_Flow_Rate') 
BEGIN
  print ' Copying data from MaxFlowRate to Max_Flow_Rate'
  DECLARE @DYNSQL NVARCHAR(1000)
  SET @DYNSQL = 'UPDATE Fuel_Transaction SET Max_Flow_Rate = MaxFlowRate'
  EXECUTE sp_executesql @DYNSQL
END
GO

IF EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Fuel_Transaction' AND COLUMN_NAME='MaxFlowRate') 
BEGIN
  print ' Removing column: MaxFlowRate'
  ALTER TABLE Fuel_Transaction DROP MaxFlowRate
END
GO

IF EXISTS (SELECT * FROM Fuel_Transaction WHERE Delivery_ID = 0)
BEGIN
	print ' INFO: purging Fuel_Transaction rows where Delivery_ID is zero'
	SELECT * FROM Fuel_Transaction WHERE Delivery_ID = 0
	print ' INFO: removing matching rows'
	DELETE FROM Fuel_Transaction WHERE Delivery_ID = 0
END
go

IF(SELECT IS_NULLABLE FROM information_schema.columns WHERE TABLE_NAME = 'Fuel_Transaction' AND COLUMN_NAME = 'Delivery_ID') <> 'YES'
BEGIN
	print ' Alter column: Delivery_ID - now default is NULL'
	ALTER TABLE Fuel_Transaction ALTER COLUMN Delivery_ID int NULL
	EXEC Drop_Constraints 'Fuel_Transaction', 'Delivery_ID', 'D'
    ALTER TABLE Fuel_Transaction ADD CONSTRAINT DF_Fuel_Transaction_Delivery_ID DEFAULT NULL FOR Delivery_ID
END
go

IF(SELECT IS_NULLABLE FROM information_schema.columns WHERE TABLE_NAME = 'Fuel_Transaction' AND COLUMN_NAME = 'AuthorisedBy_ID') <> 'YES'
BEGIN
	print ' Alter column: AuthorisedBy_ID - now allows NULL'
	ALTER TABLE Fuel_Transaction ALTER COLUMN AuthorisedBy_ID int NULL

	print ' Alter column: AuthorisedBy_ID - default is NULL'
	EXEC Drop_Constraints 'Fuel_Transaction', 'AuthorisedBy_ID', 'D'
	ALTER TABLE Fuel_Transaction ADD CONSTRAINT DF_Fuel_Transaction_AuthorisedBy_ID DEFAULT NULL FOR AuthorisedBy_ID
END
go

IF EXISTS (SELECT * FROM Fuel_Transaction WHERE Attendant_ID = 0)
BEGIN
	print ' INFO: purging Fuel_Transaction rows where Attendant_ID is zero'
	SELECT * FROM Fuel_Transaction WHERE Attendant_ID = 0
	DELETE FROM Fuel_Transaction WHERE Attendant_ID = 0
END
go

IF(SELECT IS_NULLABLE FROM information_schema.columns WHERE TABLE_NAME = 'Fuel_Transaction' AND COLUMN_NAME = 'Attendant_ID') <> 'YES'
BEGIN
	print ' Alter column: Attendant_ID - now allows NULL'
	ALTER TABLE Fuel_Transaction ALTER COLUMN Attendant_ID int NULL

	print ' Alter column: Attendant_ID - default is NULL'
	EXEC Drop_Constraints 'Fuel_Transaction', 'Attendant_ID', 'D'
	ALTER TABLE Fuel_Transaction ADD CONSTRAINT DF_Fuel_Transaction_Attendant_ID DEFAULT NULL FOR Attendant_ID
END
go

IF(SELECT IS_NULLABLE FROM information_schema.columns WHERE TABLE_NAME = 'Fuel_Transaction' AND COLUMN_NAME = 'ReservedBy_ID') <> 'YES'
BEGIN
	print ' Alter column: ReservedBy_ID - now default is NULL'
	ALTER TABLE Fuel_Transaction ALTER COLUMN ReservedBy_ID int NULL
	EXEC Drop_Constraints 'Fuel_Transaction', 'ReservedBy_ID', 'D'
    ALTER TABLE Fuel_Transaction ADD CONSTRAINT DF_Fuel_Transaction_ReservedBy_ID DEFAULT NULL FOR ReservedBy_ID
END
go

IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Fuel_Transaction' AND COLUMN_NAME='Created_DateTime')
BEGIN
  print ' Adding column: Created_DateTime'
  ALTER TABLE Fuel_Transaction ADD Created_DateTime datetime NOT NULL DEFAULT getdate()

  print ' Adding FK: Delivery_ID, Pump_ID, Attendant_ID'
  ALTER TABLE Fuel_Transaction ADD CONSTRAINT FK_Fuel_Transaction_Delivery_ID     FOREIGN KEY (Delivery_ID)     REFERENCES Hose_Delivery(Delivery_ID)
  ALTER TABLE Fuel_Transaction ADD CONSTRAINT FK_Fuel_Transaction_Pump_ID         FOREIGN KEY (Pump_ID)         REFERENCES Pumps(Pump_ID)
  ALTER TABLE Fuel_Transaction ADD CONSTRAINT FK_Fuel_Transaction_Attendant_ID    FOREIGN KEY (Attendant_ID)    REFERENCES Attendant(Attendant_ID)
END
GO

IF NOT EXISTS (SELECT name from sysindexes where name = 'XIE1Fuel_Transaction') 
BEGIN
     print ' Created index: XIE1Fuel_Transaction on Fuel_Transaction.Client_Reference'
     CREATE INDEX XIE1Fuel_Transaction ON Fuel_Transaction
     (
     	Client_Reference
     )  
END
GO

IF NOT EXISTS (SELECT name from sysindexes where name = 'XIE2Fuel_Transaction') 
BEGIN
     print ' Created index: XIE2Fuel_Transaction on Fuel_Transaction.Delivery_ID'
     CREATE NONCLUSTERED INDEX XIE2Fuel_Transaction ON Fuel_Transaction
     (
     	Delivery_ID
     )  
END
GO

IF NOT EXISTS (SELECT name from sysindexes where name = 'XIE3Fuel_Transaction') 
BEGIN
     print ' Created index: XIE3Fuel_Transaction on Fuel_Transaction.State'
     CREATE NONCLUSTERED INDEX XIE3Fuel_Transaction ON Fuel_Transaction
     (
     	State
     )  
END
GO

-- for PCI-DSS compliance

print 'Table: AuditTrace'
go
IF not EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'AuditTrace')
BEGIN
   print ' Created'
   CREATE TABLE AuditTrace(
      Type   		char(1) 	NOT NULL,
      TableName       	varchar(100) 	NOT NULL,
      PK         	varchar(1000)	NOT NULL,
      Changes		nvarchar(3000)  NOT NULL,
      UpdateDate  	varchar(21) 	NOT NULL,
      HostName   	varchar(128)	NOT NULL,
      UserName    	varchar(128)    NOT NULL,
      Result 		char(1)     	NOT NULL, 
      )
END


print 'Table: Grade_PostMix_Ratio'
go
IF not EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Grade_PostMix_Ratio')
BEGIN
   print ' Created'
   CREATE TABLE Grade_PostMix_Ratio(
      Grade_ID INT NOT NULL ,
      Ratio_Index INT NOT NULL,
      Ratio FLOAT NOT NULL DEFAULT 0,
      PRIMARY KEY (Grade_ID, Ratio_Index)
      ) 
END
GO

print 'Table: Roles'
go
IF NOT EXISTS(SELECT table_name FROM information_schema.tables WHERE TABLE_NAME = 'Roles')
BEGIN
	PRINT ' Created'
	CREATE TABLE Roles (
		Role_ID			   INT NOT NULL,
		Role_Name		   NVARCHAR(50) NOT NULL,
		Role_Flags		   BINARY(32) NOT NULL,
		PRIMARY KEY (Role_ID)
	)
End
GO

print 'Table: Users'
go
IF NOT EXISTS(SELECT table_name FROM information_schema.tables WHERE TABLE_NAME = 'Users')
BEGIN
	PRINT ' Created'
	CREATE TABLE Users (
		User_ID					INT NOT NULL,
		Login_Name				NVARCHAR(50) NOT NULL,
		User_Name				NVARCHAR(100) NOT NULL DEFAULT ' ',
		Password				NVARCHAR(100) NOT NULL,
		No_Activity_Timeout		INT,
		Last_Page_Accessed		NVARCHAR(100) NOT NULL DEFAULT ' ',
		Language				NVARCHAR(20) NOT NULL DEFAULT 'default',
		Role_ID					INT NOT NULL 
		--Role_Flags		   binary(32) NOT NULL,
		PRIMARY KEY (Login_Name),
		FOREIGN KEY (Role_ID) REFERENCES Roles,
	)
END
GO


-- dropping the temp store procedure
print 'Removing temporary procedures: upgrade_decimal_column, drop_constraints'
DROP PROCEDURE Upgrade_Decimal_Column
go
DROP PROCEDURE Drop_Constraints
go

-- enable global deadlock trace logging here
DBCC TRACEON (1204,-1)
print 'Deadlock Trace Logging is ON'
go

print CONVERT(varchar,getdate(), 121)
print 'Enabler Database tables complete'
go
