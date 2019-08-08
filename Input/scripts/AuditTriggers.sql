-- the main PCI-DSS auditing stored procedure

PRINT 'Creating WriteAuditEntry'
GO

IF EXISTS (SELECT NAME FROM sysobjects WHERE NAME = 'WriteAuditEntry' AND TYPE = 'p')
  DROP PROCEDURE WriteAuditEntry
GO

CREATE  PROCEDURE WriteAuditEntry
	@Tablename	  varchar(100)
AS
BEGIN

DECLARE @bit int ,
	@field int ,
	@maxfield int ,
	@char int ,
	@fieldname varchar(500) ,
	@Type	   char(1),
	@PKCols    varchar(1000) ,
	@sqlStart  nvarchar(500),
	@sql1       nvarchar(4000), 
	@sql2       nvarchar(4000),
	@sql3       nvarchar(4000),
	@sql4       nvarchar(4000),
	@sqlEnd	    nvarchar(500),
	@sqlTemp    nvarchar(500),
	@UpdateDate varchar(21) ,
	@UserName varchar(128) ,
	@Result   char(1),
	@HostName varchar(128) ,
	@PKSelect varchar(1000),
	@FirstTime int

	-- date and user
	SELECT 	@UserName = system_user , @HostName = host_name() , 
		@UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)

	-- Action
       	IF exists (select * from #ins)
		IF exists (select * from #del)
			select @Type = 'U'
		ELSE
			select @Type = 'I'
	ELSE
		SELECT @Type = 'D'

        
	-- Get primary key columns for full outer join
	SELECT	@PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
	FROM	INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk ,
		INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
	WHERE 	pk.TABLE_NAME = @TableName
	and	CONSTRAINT_TYPE = 'PRIMARY KEY'
	and	c.TABLE_NAME = pk.TABLE_NAME
	and	c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
	
	-- Get primary key select for insert
	SELECT @PKSelect = coalesce(@PKSelect+'+','') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +',d.' + COLUMN_NAME + '))+''>''' 
	FROM	INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk ,
		INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
	WHERE 	pk.TABLE_NAME = @TableName
	and	CONSTRAINT_TYPE = 'PRIMARY KEY'
	and	c.TABLE_NAME = pk.TABLE_NAME
	and	c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
	
        IF @PKCols IS NULL
	BEGIN
		RAISERROR('no PK on table %s', 16, -1, @TableName)
		RETURN
	END
	
	SELECT @field = 0, @maxfield = max(ORDINAL_POSITION) from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @TableName
	SELECT @Result='S'

	SET @sqlStart = ''
	SET @sql1     = '' 
	SET @sql2     = ''
	SET @sql3     = ''
	SET @sql4     = ''
	SET @sqlEnd   = ''

	SET @FirstTime   = 0 

	SELECT @sqlStart = @sqlStart + 	' insert AuditTrace (Type, TableName, PK, Changes, UpdateDate, HostName, UserName,Result)'
	SELECT @sqlStart = @sqlStart + 	' select ''' + @Type + ''''
	SELECT @sqlStart = @sqlStart + 	',''' + @TableName + ''''
	SELECT @sqlStart = @sqlStart + 	',' + @PKSelect

	WHILE @field < @maxfield
	BEGIN
		SELECT @field = min(ORDINAL_POSITION) from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @TableName and ORDINAL_POSITION > @field
		SELECT @bit = (@field - 1 )% 8 + 1
		SELECT @bit = power(2,@bit - 1)
                SELECT @char = ((@field - 1) / 8) + 1
               
		-- Warning: @ColsUpdated is based on COLUMNS_UPDATED(), which TSQL documentation indicates is incompatible with 
		-- the ORDINAL_POSITION in SQL Server 2005. Therefore we need to do some upgrade on this part of the procedure/trigger.
		               
                
		IF substring(COLUMNS_UPDATED() ,@char, 1) & @bit > 0 or @Type in ('I','D')
		BEGIN
			SELECT @fieldname = COLUMN_NAME from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @TableName and ORDINAL_POSITION = @field

			IF @FirstTime = 0
			BEGIN
				SET @sqlTemp = ',N'''
			END
			ELSE
			BEGIN	
				SET @sqlTemp = ','	
			END

			SET @FirstTime = 1


			SELECT @sqlTemp = @sqlTemp + '<' + @fieldname + '={'' + ISNULL(convert(nvarchar(500),d.' + @fieldname + '),''NULL'') + ''}''+ ISNULL(convert(nvarchar(1000),i.' + @fieldname + '),''NULL'') + ''>'


			IF (LEN(@sql1) < 3500 )
			BEGIN
				SELECT @sql1 = @sql1 + @sqlTemp
			END
			ELSE IF (LEN(@sql2) < 3500 )
			BEGIN
				SELECT @sql2 = @sql2 + @sqlTemp
			END
			ELSE IF (LEN(@sql3) < 3500 )
			BEGIN
				SELECT @sql3 = @sql3 + @sqlTemp
			END
			ELSE
			BEGIN
				SELECT @sql4 = @sql4 + @sqlTemp
			END
                        
		END
	END
	

	SELECT @sqlend = @sqlend + 	''',''' + @UpdateDate + ''''
	SELECT @sqlend = @sqlend + 	',''' + @HostName + ''''
	SELECT @sqlend = @sqlend + 	',''' + @UserName + ''''
	SELECT @sqlend = @sqlend + 	',''' + @Result   + ''''
	SELECT @sqlend = @sqlend + 	' from #ins i full outer join #del d'
	SELECT @sqlend = @sqlend + 	@PKCols
	
	EXEC(@sqlStart + @sql1 + @sql2+ @sql3 + @sql4+ @sqlEnd) 


END
go


--------------------------------------------------
-- Triggers for PCI-DSS Audit Trail compliance
--------------------------------------------------

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Attendant_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Attendant_Trigger
GO
CREATE TRIGGER Audit_Attendant_Trigger ON Attendant
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Attendant'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Attendant_history_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Attendant_history_Trigger
GO
CREATE TRIGGER Audit_Attendant_history_Trigger ON Attendant_history
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Attendant_history'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Attendant_Period_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Attendant_Period_Trigger
GO
CREATE TRIGGER Audit_Attendant_Period_Trigger ON Attendant_Period
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Attendant_Period'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Attendant_Period_History_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Attendant_Period_History_Trigger
GO
CREATE TRIGGER Audit_Attendant_Period_History_Trigger ON Attendant_Period_History
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Attendant_Period_History'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Attendant_Safedrop_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Attendant_Safedrop_Trigger
GO
CREATE TRIGGER Audit_Attendant_Safedrop_Trigger ON Attendant_Safedrop
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Attendant_Safedrop'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Detected_Tank_Delivery_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Detected_Tank_Delivery_Trigger
GO
CREATE TRIGGER Audit_Detected_Tank_Delivery_Trigger ON Detected_Tank_Delivery
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Detected_Tank_Delivery'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Device_type_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Device_type_Trigger
GO
CREATE TRIGGER Audit_Device_type_Trigger ON Device_type
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Device_type'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Enabler_Options_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Enabler_Options_Trigger
GO
CREATE TRIGGER Audit_Enabler_Options_Trigger ON Enabler_Options
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Enabler_Options'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Event_type_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Event_type_Trigger
GO
CREATE TRIGGER Audit_Event_type_Trigger ON Event_type
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Event_type'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Global_Settings_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Global_Settings_Trigger
GO
CREATE TRIGGER Audit_Global_Settings_Trigger ON Global_Settings
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Global_Settings'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Grades_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Grades_Trigger
GO
CREATE TRIGGER Audit_Grades_Trigger ON Grades
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Grades'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Hoses_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Hoses_Trigger
GO
CREATE TRIGGER Audit_Hoses_Trigger ON Hoses
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Hoses'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Loops_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Loops_Trigger
GO
CREATE TRIGGER Audit_Loops_Trigger ON Loops
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Loops'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_OPT_Key_Codes_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_OPT_Key_Codes_Trigger
GO
CREATE TRIGGER Audit_OPT_Key_Codes_Trigger ON OPT_Key_Codes
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'OPT_Key_Codes'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_OPT_Key_Map_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_OPT_Key_Map_Trigger
GO
CREATE TRIGGER Audit_OPT_Key_Map_Trigger ON OPT_Key_Map
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'OPT_Key_Map'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_OPT_Prompt_Map_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_OPT_Prompt_Map_Trigger
GO
CREATE TRIGGER Audit_OPT_Prompt_Map_Trigger ON OPT_Prompt_Map
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'OPT_Prompt_Map'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_OPT_Type_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_OPT_Type_Trigger
GO
CREATE TRIGGER Audit_OPT_Type_Trigger ON OPT_Type
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'OPT_Type'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_OPTs_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_OPTs_Trigger
GO
CREATE TRIGGER Audit_OPTs_Trigger ON OPTs
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'OPTs'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Period_types_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Period_types_Trigger
GO
CREATE TRIGGER Audit_Period_types_Trigger ON Period_types
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Period_types'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Periods_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Periods_Trigger
GO
CREATE TRIGGER Audit_Periods_Trigger ON Periods
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Periods'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Price_Level_Types_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Price_Level_Types_Trigger
GO
CREATE TRIGGER Audit_Price_Level_Types_Trigger ON Price_Level_Types
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Price_Level_Types'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Price_Levels_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Price_Levels_Trigger
GO
CREATE TRIGGER Audit_Price_Levels_Trigger ON Price_Levels
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Price_Levels'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Price_Profile_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Price_Profile_Trigger
GO
CREATE TRIGGER Audit_Price_Profile_Trigger ON Price_Profile
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Price_Profile'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Prompts_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Prompts_Trigger
GO
CREATE TRIGGER Audit_Prompts_Trigger ON Prompts
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Prompts'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Protocol_Type_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Protocol_Type_Trigger
GO
CREATE TRIGGER Audit_Protocol_Type_Trigger ON Protocol_Type
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Protocol_Type'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Pump_Display_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Pump_Display_Trigger
GO
CREATE TRIGGER Audit_Pump_Display_Trigger ON Pump_Display
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Pump_Display'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Pump_Profile_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Pump_Profile_Trigger
GO
CREATE TRIGGER Audit_Pump_Profile_Trigger ON Pump_Profile
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Pump_Profile'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Pump_Protocol_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Pump_Protocol_Trigger
GO
CREATE TRIGGER Audit_Pump_Protocol_Trigger ON Pump_Protocol
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Pump_Protocol'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Pump_Type_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Pump_Type_Trigger
GO
CREATE TRIGGER Audit_Pump_Type_Trigger ON Pump_Type
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Pump_Type'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Pumps_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Pumps_Trigger
GO
CREATE TRIGGER Audit_Pumps_Trigger ON Pumps
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Pumps'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Site_profile_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Site_profile_Trigger
GO
CREATE TRIGGER Audit_Site_profile_Trigger ON Site_profile
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Site_profile'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Tank_Connection_Type_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Tank_Connection_Type_Trigger
GO
CREATE TRIGGER Audit_Tank_Connection_Type_Trigger ON Tank_Connection_Type
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Tank_Connection_Type'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Tank_Delivery_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Tank_Delivery_Trigger
GO
CREATE TRIGGER Audit_Tank_Delivery_Trigger ON Tank_Delivery
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Tank_Delivery'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Tank_Delivery_Detected_Delivery_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Tank_Delivery_Detected_Delivery_Trigger
GO
CREATE TRIGGER Audit_Tank_Delivery_Detected_Delivery_Trigger ON Tank_Delivery_Detected_Delivery
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Tank_Delivery_Detected_Delivery'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Tank_Delivery_State_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Tank_Delivery_State_Trigger
GO
CREATE TRIGGER Audit_Tank_Delivery_State_Trigger ON Tank_Delivery_State
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Tank_Delivery_State'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Tank_Gauge_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Tank_Gauge_Trigger
GO
CREATE TRIGGER Audit_Tank_Gauge_Trigger ON Tank_Gauge
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Tank_Gauge'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Tank_Gauge_Type_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Tank_Gauge_Type_Trigger
GO
CREATE TRIGGER Audit_Tank_Gauge_Type_Trigger ON Tank_Gauge_Type
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Tank_Gauge_Type'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Tank_History_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Tank_History_Trigger
GO
CREATE TRIGGER Audit_Tank_History_Trigger ON Tank_History
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Tank_History'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Tank_Loss_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Tank_Loss_Trigger
GO
CREATE TRIGGER Audit_Tank_Loss_Trigger ON Tank_Loss
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Tank_Loss'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Tank_Movement_Type_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Tank_Movement_Type_Trigger
GO
CREATE TRIGGER Audit_Tank_Movement_Type_Trigger ON Tank_Movement_Type
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Tank_Movement_Type'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Tank_Probe_Status_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Tank_Probe_Status_Trigger
GO
CREATE TRIGGER Audit_Tank_Probe_Status_Trigger ON Tank_Probe_Status
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Tank_Probe_Status'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Tank_Reading_Type_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Tank_Reading_Type_Trigger
GO
CREATE TRIGGER Audit_Tank_Reading_Type_Trigger ON Tank_Reading_Type
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Tank_Reading_Type'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Tank_Readings_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Tank_Readings_Trigger
GO
CREATE TRIGGER Audit_Tank_Readings_Trigger ON Tank_Readings
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Tank_Readings'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Tank_Strapping_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Tank_Strapping_Trigger
GO
CREATE TRIGGER Audit_Tank_Strapping_Trigger ON Tank_Strapping
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Tank_Strapping'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Tank_Transfer_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Tank_Transfer_Trigger
GO
CREATE TRIGGER Audit_Tank_Transfer_Trigger ON Tank_Transfer
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Tank_Transfer'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Tank_Type_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Tank_Type_Trigger
GO
CREATE TRIGGER Audit_Tank_Type_Trigger ON Tank_Type
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Tank_Type'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Tank_Variance_Reason_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Tank_Variance_Reason_Trigger
GO
CREATE TRIGGER Audit_Tank_Variance_Reason_Trigger ON Tank_Variance_Reason
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Tank_Variance_Reason'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Tanks_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Tanks_Trigger
GO
CREATE TRIGGER Audit_Tanks_Trigger ON Tanks
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Tanks'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_Version_History_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_Version_History_Trigger
GO
CREATE TRIGGER Audit_Version_History_Trigger ON Version_History
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'Version_History'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_WetStock_Approval_Trigger' AND type = 'TR')
	DROP TRIGGER Audit_WetStock_Approval_Trigger
GO
CREATE TRIGGER Audit_WetStock_Approval_Trigger ON WetStock_Approval
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	-- get list of columns into temporary tables
	SELECT * INTO #ins FROM INSERTED
	SELECT * INTO #del FROM DELETED
	-- write to the audit trail table based on temp tables and columns updated
	EXEC WriteAuditEntry 'WetStock_Approval'
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Audit_AuditTrace_Del' AND type = 'TR')
	DROP TRIGGER Audit_AuditTrace_Del
GO
CREATE TRIGGER Audit_AuditTrace_Del on AuditTrace FOR DELETE
AS
BEGIN
DECLARE @d as datetime,
	@UpdateDate varchar(21) ,
	@UserName varchar(128) ,
	@HostName varchar(128) 
	

	-- date and user
	SELECT 	@UserName = system_user , @HostName = host_name() , 
		@UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)


        SELECT @d = (select top 1 UpdateDate from deleted order by UpdateDate)
      	IF datediff(day,@d,getdate()) < 93
	BEGIN 
      		RAISERROR ('Records may not be deleted!',10,99)
	  	ROLLBACK
		INSERT INTO AuditTrace(Type,TableName,PK,Changes,UpdateDate,HostName,UserName,Result) VALUES('D','AuditTrace','','',@UpdateDate,@HostName,@UserName,'F')
		
	END
END
GO

  PRINT 'DEBUG: end of AuditTriggers.sql'

