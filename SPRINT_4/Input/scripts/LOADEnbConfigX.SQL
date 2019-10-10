--
-- LOAD_ENBCONFIGX INSTALLATION SCRIPT
--
-- This script is responsible for installing EnbConfigX triggers to the Enabler database
-- 
-- $Header: /Enabler/Data Model/DBU 4.0/LOADEnbConfigX.SQL 14    23/04/15 2:43p Raymondl $
--
--------------------------------------------------------------------------------
PRINT 'Adding TG_Loops_Delete Trigger...'
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME = 'TG_Loops_Delete' AND TYPE = 'TR')
	DROP TRIGGER  TG_Loops_Delete
GO
CREATE TRIGGER  TG_Loops_Delete on Loops
FOR DELETE
AS
BEGIN
    DECLARE  @id int
    SELECT  @id = MIN(Loop_ID) FROM  deleted
    
    WHILE @id is not NULL
    BEGIN
		IF (@id>=1 AND @id<=5)
		BEGIN
			RAISERROR ('Loops 1-5 cannot be deleted',18,1)
			ROLLBACK
			BREAK
        END
        SELECT  @id = MIN(Loop_ID) FROM  deleted WHERE Loop_ID > @id
    END
END
GO

IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME = 'TG_Grades_Update' AND TYPE = 'TR')
	DROP TRIGGER  TG_Grades_Update
GO
PRINT 'Adding TG_Grades_Update Trigger...'
GO
CREATE TRIGGER  TG_Grades_Update on Grades
FOR INSERT, UPDATE 
AS
BEGIN
    DECLARE @Allocation_Limit AS DECIMAL(16,4)
    DECLARE @Alloc_Limit_Type AS INT
    DECLARE @Price_Pole_Segment AS INT
    DECLARE @Delivery_Timeout AS INT
    DECLARE @Grade_Type AS INT
    DECLARE @Blend_Ratio AS DECIMAL(8,4)
    DECLARE @Grade1_ID AS INT,
            @Grade2_ID AS INT,
            @Grade_ID AS INT

    DECLARE @found1 INT,
            @found2 INT
	
	SELECT @Grade_ID = MIN(Grade_ID) FROM INSERTED
	
	SELECT @Allocation_Limit = Allocation_Limit ,
           @Alloc_Limit_Type = Alloc_Limit_Type ,
           @Price_Pole_Segment = Price_Pole_Segment ,
           @Delivery_Timeout = Delivery_Timeout ,
           @Grade_Type = Grade_Type,
           @Blend_Ratio = Blend_Ratio,
           @Grade1_ID = Grade1_ID,
           @Grade2_ID = Grade2_ID
	FROM INSERTED WHERE Grade_ID = @Grade_ID

	WHILE @Grade_ID is not NULL
	BEGIN
		IF ( @Allocation_Limit<0)			
		BEGIN
			RAISERROR ('Allocation Limit: >=0',18,1)
			ROLLBACK
			BREAK
		END
		IF (@Alloc_Limit_Type<0 OR @Alloc_Limit_Type>2)
		BEGIN
			RAISERROR ('Alloc_Limit_Type: 0(nolimit), 1(by value), 2(by volume)',18,1)
			ROLLBACK
			BREAK
		END
		IF (@Price_Pole_Segment<0 OR @Price_Pole_Segment>15)
		BEGIN
			RAISERROR ('Price_Pole_Segment: 0-15',18,1)
			ROLLBACK
			BREAK
		END
		IF (@Delivery_Timeout<0 OR @Delivery_Timeout>9999)
		BEGIN
			RAISERROR ('Delivery Timeout: 0-9999',18,1)
			ROLLBACK
			BREAK
		END
		IF (@Grade_Type<1 OR @Grade_Type>3)
		BEGIN
			RAISERROR ('Grade Type: 1(base grade), 2(blended grade), 3(blended grade-var ratios)',18,1)
			ROLLBACK
			BREAK
		END

		-- blended grades check
		IF (@Grade_Type=2)
		BEGIN
			IF (@Blend_Ratio is NULL OR @Blend_Ratio=0)
			BEGIN
				RAISERROR ('Blended Grade Type but No Blend Ratio',18,1)
				ROLLBACK
				BREAK
			END
			IF (@Blend_Ratio<=0 OR @Blend_Ratio>=100)
			BEGIN
				RAISERROR ('Blend_Ratio: 1-99',18,1)
				ROLLBACK
				BREAK
			END
		END
			
		IF (@Grade_Type=2 OR @Grade_Type=3)
		BEGIN
			-- grade1 and grade2 may be referential constraints?
			SET @found1 = (Select Grade_ID from Grades WHERE Grade_ID=@Grade1_ID)
			SET @found2 = (Select Grade_ID from Grades WHERE Grade_ID=@Grade2_ID)
			IF (@found1 is NULL OR @found2 is NULL)
			BEGIN
				RAISERROR ('Grade1_ID or Grade2_ID missing',18,1)
				ROLLBACK
				BREAK
			END
			IF (@found1 = @found2)
			BEGIN
				RAISERROR ('Grade1_ID is same as Grade2_ID',18,1)
				ROLLBACK
				BREAK
			END
			-- Enbconfig.exe doesn't check this anyway
			--IF (@Grade_ID = @Grade1_ID OR @Grade_ID = @Grade2_ID)
			--BEGIN
			--	RAISERROR ('Grade1_ID/Grade2_ID must be different from Grade_ID',18,1)
			--	ROLLBACK
			--  BREAK
			--END
		END
		
		SELECT @Grade_ID = MIN(Grade_ID) FROM INSERTED WHERE Grade_ID > @Grade_ID

		SELECT @Allocation_Limit = Allocation_Limit ,
				   @Alloc_Limit_Type = Alloc_Limit_Type ,
				   @Price_Pole_Segment = Price_Pole_Segment ,
				   @Delivery_Timeout = Delivery_Timeout ,
				   @Grade_Type = Grade_Type,
				   @Blend_Ratio = Blend_Ratio,
				   @Grade1_ID = Grade1_ID,
				   @Grade2_ID = Grade2_ID
		FROM INSERTED WHERE Grade_ID = @Grade_ID
		
	END
END
GO

IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME = 'TG_Hoses_Update' AND TYPE = 'TR')
	DROP TRIGGER  TG_Hoses_Update
GO
PRINT 'Adding TG_Hoses_Update Trigger...'
GO
CREATE TRIGGER TG_Hoses_Update on Hoses
FOR INSERT, UPDATE 
AS
BEGIN

	IF NOT (UPDATE(Hose_ID) OR UPDATE(Blend_Type) OR UPDATE(Pump_ID) OR UPDATE(Hose_Number) OR UPDATE(Grade_ID) OR UPDATE(Tank_ID))
	BEGIN
		RETURN
	END


	DECLARE @Blend_Type AS INT,
			@HoseID AS INT,
			@PumpID AS INT,
			@HoseNumber AS INT,
			@MaxHoses AS INT,
			@TankID1 as INT,
			@TankID2 as INT,
			@GradeID as INT
	
	SELECT @HoseID = MIN(Hose_ID) FROM INSERTED

	WHILE @HoseID is not NULL
	BEGIN

		SELECT @Blend_Type = Blend_Type,
		   @PumpID = Pump_ID,
		   @HoseNumber = Hose_Number,
		   @GradeID = Grade_ID,
		   @TankID1 = Tank_ID,
		   @TankID2 = Tank2_ID
		FROM INSERTED WHERE Hose_ID = @HoseID

		-- This does not work if Grade_ID is a blended Grade!
		--SET @TankID2 = (SELECT Tank_ID from tanks WHERE Grade_ID = @GradeID AND Tank_ID = @TankID1 )
		--IF (@TankID2 IS NULL )
		--BEGIN
		--	RAISERROR('Grade does not match the Tank',18,1)
		--	ROLLBACK
		--	BREAK
		--END
		
		IF (@Blend_Type<0 OR @Blend_Type>2 )
		BEGIN
			RAISERROR ('Blend_Type: 0(no blend), 1(blend before), 2(blend after)',18,1)
			ROLLBACK
			BREAK
		END
	
		IF (@HoseNumber is NULL OR @HoseNumber<=0)
		BEGIN
			RAISERROR ('HoseNumber: >=0',18,1)
			ROLLBACK
			BREAK
		END
	
		IF UPDATE(Blend_Type) 
		BEGIN
			-- Because in EnbConfig Hoses are often added first as non-blended and then
			-- set to blended, we need to check here for both the Insert and Update cases
			-- to see if the post-mix hose history exists
			IF( @Blend_Type = 1 or @Blend_Type = 2)
			BEGIN

				IF NOT EXISTS (SELECT Period_ID FROM Hose_PostMix_History WHERE Hose_ID = @HoseID and Base_Grade_Number = 1 and Period_ID = (SELECT Period_ID FROM Periods WHERE Period_State = 1 and Period_Type = 2))
				BEGIN
					-- Base Grade 1
					INSERT INTO Hose_Postmix_History 
      					( 	Hose_ID , 
        					Period_ID , 
	        				Base_Grade_Number)	
      						SELECT 
          						@HoseID ,
							Period_ID,
		        				1	 
						FROM Periods
        					WHERE Period_State = 1
	
						-- Base Grade 2
					INSERT INTO Hose_Postmix_History 
      					( 	Hose_ID , 
        					Period_ID , 
	        				Base_Grade_Number)	
      						SELECT 
          						@HoseID ,
							Period_ID,
		        				2	 
						FROM Periods
        					WHERE Period_State = 1 	
				END
			END
		END

		-- In comments, since EnbConfig defaults to next available UNDELETED hose number
		--IF (@HoseNumber IN (SELECT Hose_Number FROM Hoses WHERE Pump_ID=@PumpID AND Hose_ID<>@HoseID AND Hoses.Deleted=0))
		--BEGIN
		--	RAISERROR ('HoseNumber: duplicate',18,1)
		--	ROLLBACK
		--	BREAK
		--END
		-- verify the hosenumber. in comments since EnbConfig allows this!
		--	SET @MaxHoses=( SELECT Max_Hoses FROM Hoses, Pumps, Pump_Type
		--                WHERE Pumps.Pump_Type_ID=Pump_Type.Pump_Type_ID AND
		--                      Hoses.Pump_ID = Pumps.Pump_ID AND
		--                      Hose_ID=@HoseID)
		--	IF (@HoseNumber > @MaxHoses)
		--	BEGIN
		--		RAISERROR ('HoseNumber: > @MaxHoses',18,1)
		--		ROLLBACK
		--		BREAK
		--END 
		
		SELECT @HoseID = MIN(Hose_ID) FROM INSERTED WHERE Hose_ID > @HoseID
	END

END
GO

IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME = 'TG_Hoses_Insert' AND TYPE = 'TR')
	DROP TRIGGER  TG_Hoses_Insert
GO
PRINT 'Adding TG_Hoses_Insert Trigger...'
GO
CREATE TRIGGER TG_Hoses_Insert on Hoses
AFTER INSERT
AS
BEGIN
	DECLARE @Hose_ID AS INT
	DECLARE @Blend_Type AS INT

	SELECT @Hose_ID = MIN(Hose_ID) FROM INSERTED

	SELECT @Blend_Type = Blend_Type
	FROM INSERTED WHERE Hose_ID = @Hose_ID



	WHILE @Hose_ID is not NULL
	BEGIN
		IF (@Hose_ID > 0 )
		BEGIN
			INSERT INTO Hose_History ( Hose_ID, Period_ID ) SELECT @Hose_ID, Period_ID FROM Periods WHERE Period_State = 1
		END

		SELECT @Hose_ID = MIN(Hose_ID) FROM INSERTED WHERE Hose_ID > @Hose_ID

		SELECT @Blend_Type = Blend_Type
		FROM INSERTED WHERE Hose_ID = @Hose_ID
	END
END
GO

IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME = 'TG_Hoses_Delete' AND TYPE = 'TR')
	DROP TRIGGER  TG_Hoses_Delete
GO
PRINT 'Adding TG_Hoses_Delete Trigger...'
GO
CREATE TRIGGER TG_Hoses_Delete on Hoses
INSTEAD OF DELETE
AS
BEGIN
	DECLARE @Hose_ID AS INT
	SELECT @Hose_ID = MIN(Hose_ID) FROM DELETED
		
	--RAISERROR( 'Cannot Delete Hose %d',18,1,@Hose_ID )
	--ROLLBACK
	-- This script came from sp_del_hose
	
	WHILE @Hose_ID is not NULL
	BEGIN
		BEGIN TRANSACTION
		DELETE FROM pvt where hose_id = @hose_id
		DELETE FROM hose_delivery WHERE hose_id = @hose_id 
		DELETE FROM hose_history WHERE hose_id = @hose_id
		DELETE FROM Hose_PostMix_History where hose_id = @hose_id
		DELETE FROM Hoses WHERE Hose_ID = @Hose_ID
		COMMIT TRANSACTION
		
		SELECT @Hose_ID = MIN(Hose_ID) FROM DELETED WHERE Hose_ID > @Hose_ID
	END
END
GO


-- Drop the 'old' Tanks_Trigger
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Tanks_Trigger' AND type = 'TR')
	DROP TRIGGER Tanks_Trigger
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME = 'TG_Tanks_Update' AND TYPE = 'TR')
	DROP TRIGGER  TG_Tanks_Update
GO
PRINT 'Adding TG_Tanks_Update Trigger...'
GO
CREATE TRIGGER TG_Tanks_Update on Tanks
FOR INSERT, UPDATE 
AS
BEGIN
    DECLARE @Tank_Type AS INT,
            @Tank_Connection_Type AS INT,
            @Tank_ID AS INT
    DECLARE @Capacity AS DECIMAL(16,4),
            @Lowvolumew AS DECIMAL(16,4),
            @Lowvolumea AS DECIMAL(16,4),
            @Highvolumew AS DECIMAL(16,4),
            @Highvolumea AS DECIMAL(16,4),
            @HiTemperature AS DECIMAL(16,4),
            @LowTemperature AS DECIMAL(16,4)
    DECLARE @Strapped_Tank_ID AS INT
    DECLARE @Diameter AS DECIMAL(9,3)
    DECLARE @found AS INT
    DECLARE @Tank_Type_ID_Diff AS INT,
			@Tank_Connection_Type_ID_Diff AS INT,
			@Capacity_Diff AS INT,
			@Strapped_Tank_ID_Diff AS INT,
			@Low_Volume_Warning_Diff AS INT,
			@Low_Volume_Alarm_Diff AS INT,
			@Hi_Volume_Warning_Diff AS INT,
			@Hi_Volume_Alarm_Diff AS INT,
			@Hi_Temperature_Diff AS INT,
			@Low_Temperature_Diff AS INT

	-- If none of the configuration columns are different then just exit	
	SELECT
		@Tank_Type_ID_Diff = CASE WHEN I.Tank_Type_ID <> D.Tank_Type_ID THEN 1 ELSE 0 END,
		@Tank_Connection_Type_ID_Diff = CASE WHEN I.Tank_Connection_Type_ID <> D.Tank_Connection_Type_ID THEN 1 ELSE 0 END,
		@Capacity_Diff = CASE WHEN I.Capacity <> D.Capacity THEN 1 ELSE 0 END,
		@Strapped_Tank_ID_Diff = CASE WHEN I.Strapped_Tank_ID <> D.Strapped_Tank_ID THEN 1 ELSE 0 END,
		@Low_Volume_Warning_Diff = CASE WHEN I.Low_Volume_Warning <> D.Low_Volume_Warning THEN 1 ELSE 0 END,
		@Low_Volume_Alarm_Diff = CASE WHEN I.Low_Volume_Alarm <> D.Low_Volume_Alarm THEN 1 ELSE 0 END,
		@Hi_Volume_Warning_Diff = CASE WHEN I.Hi_Volume_Warning <> D.Hi_Volume_Warning THEN 1 ELSE 0 END,
		@Hi_Volume_Alarm_Diff = CASE WHEN I.Hi_Volume_Alarm <> D.Hi_Volume_Alarm THEN 1 ELSE 0 END,
		@Hi_Temperature_Diff = CASE WHEN I.Hi_Temperature <> D.Hi_Temperature THEN 1 ELSE 0 END,
		@Low_Temperature_Diff = CASE WHEN I.Low_Temperature <> D.Low_Temperature THEN 1 ELSE 0 END
	FROM
		INSERTED I JOIN DELETED D ON I.Tank_ID = D.Tank_ID

	IF( @Tank_Type_ID_Diff = 0 AND
		@Tank_Connection_Type_ID_Diff = 0 AND
		@Capacity_Diff = 0 AND
		@Strapped_Tank_ID_Diff = 0 AND
		@Low_Volume_Warning_Diff = 0 AND
		@Low_Volume_Alarm_Diff = 0 AND
		@Hi_Volume_Warning_Diff = 0 AND
		@Hi_Volume_Alarm_Diff = 0 AND
		@Hi_Temperature_Diff = 0 AND
		@Low_Temperature_Diff = 0 )
	BEGIN
		-- To get here this must be an update on a data column which we don't want to fail
		RETURN
	END

	SELECT	@Tank_ID = MIN(Tank_ID) FROM INSERTED

    SELECT  @Tank_Type = Tank_Type_ID,
            @Tank_Connection_Type = Tank_Connection_Type_ID,
            @Capacity = Capacity,
            @Strapped_Tank_ID = Strapped_Tank_ID ,
            @Diameter = Diameter,
            @Lowvolumew = Low_Volume_Warning,
            @Lowvolumea = Low_Volume_Alarm,
            @Highvolumew = Hi_Volume_Warning,
            @Highvolumea = Hi_Volume_Alarm,
            @HiTemperature = Hi_Temperature,
            @LowTemperature = Low_Temperature
	FROM INSERTED WHERE Tank_ID = @Tank_ID

	WHILE @Tank_ID is not NULL
	BEGIN
		IF NOT (@Tank_Type =1 OR @Tank_Type=2 OR @Tank_Type=4 )
		BEGIN
			RAISERROR ('Tank_Type: 1(manual), 2(gauged), 4(gauge-autoreconcile)',18,1)
			ROLLBACK
			BREAK
		END

		IF (@Capacity <1 OR @Capacity >250000 )
		BEGIN
			RAISERROR ('Capacity: 1-250000',18,1)
			ROLLBACK
			BREAK
		END

		-- Tank Type Checks?
		IF (@Tank_Type>=2 AND @Tank_Type<=4)
		BEGIN
			IF (@Diameter is NULL)
			BEGIN
				RAISERROR ('Diameter: NULL',18,1)
				ROLLBACK
				BREAK
			END
			IF (@Diameter<1 OR @Diameter>20)
			BEGIN
				RAISERROR ('Diameter: 1-20',18,1)
				ROLLBACK
				BREAK
			END
		END

		-- Strapped Tank?
		IF (@Tank_Connection_Type=2 OR @Tank_Connection_Type=3 )
		BEGIN
			SET @found = (Select Tank_ID from Tanks Where Tank_ID=@Strapped_Tank_ID)
			IF (@found is NULL AND @Strapped_Tank_ID>0)
			BEGIN
				RAISERROR ('Strapped_Tank_ID: not found',18,1)
				ROLLBACK
				BREAK
			END
			IF (@Strapped_Tank_ID = @Tank_ID)
			BEGIN
				RAISERROR ('Strapped_Tank_ID: same as Tank_ID',18,1)
				ROLLBACK
				BREAK
			END

		END

		--volume checks
		IF (@lowvolumea>@capacity OR @lowvolumew>@capacity OR
			@highvolumea>@capacity OR @highvolumew>@capacity)
		BEGIN
			RAISERROR ('Alarm/Warning Volume > Capacity',18,1)
			ROLLBACK
			BREAK
		END
		IF (@lowvolumea>@lowvolumew)
		BEGIN
			RAISERROR ('Low_Volume_Alarm > Low_Volume_Warning',18,1)
			ROLLBACK
			BREAK
		END
		IF (@highvolumew>@highvolumea)
		BEGIN
			RAISERROR ('Hi_Volume_Warning > Hi_Volume_Alarm',18,1)
			ROLLBACK
			BREAK
		END
		IF (@HiTemperature<@LowTemperature)
		BEGIN
			RAISERROR ('HiTemperature<LowTemperature',18,1)
			ROLLBACK
			BREAK
		END
		IF (@lowvolumea>@highvolumew OR @lowvolumew>@highvolumew OR
			@highvolumea<@lowvolumew OR @highvolumew<@lowvolumew)
		BEGIN
			RAISERROR ('Incompatible Alarms and Warning',18,1)
			ROLLBACK
			BREAK
		END
		
		/* go to next tank */
		SELECT	@Tank_ID = MIN(Tank_ID) FROM INSERTED WHERE Tank_ID > @Tank_ID

		SELECT  @Tank_Type = Tank_Type_ID,
				@Tank_Connection_Type = Tank_Connection_Type_ID,
				@Capacity = Capacity,
				@Strapped_Tank_ID = Strapped_Tank_ID ,
				@Diameter = Diameter,
				@Lowvolumew = Low_Volume_Warning,
				@Lowvolumea = Low_Volume_Alarm,
				@Highvolumew = Hi_Volume_Warning,
				@Highvolumea = Hi_Volume_Alarm,
				@HiTemperature = Hi_Temperature,
				@LowTemperature = Low_Temperature
		FROM INSERTED WHERE Tank_ID = @Tank_ID
    END
END
GO

IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME = 'TG_Tanks_Insert' AND TYPE = 'TR')
	DROP TRIGGER  TG_Tanks_Insert
GO
PRINT 'Adding TG_Tanks_Insert Trigger...'
GO
CREATE TRIGGER TG_Tanks_Insert on Tanks
AFTER INSERT
AS
BEGIN
	DECLARE @Tank_ID AS INT
	SELECT @Tank_ID = MIN(Tank_ID)
	FROM INSERTED

	WHILE @Tank_ID is not NULL
	BEGIN
		IF (@Tank_ID>0 )
		BEGIN
			INSERT INTO Tank_History ( Tank_ID, Period_ID ) SELECT @Tank_ID, Period_ID FROM Periods WHERE Period_State = 1
		END
		SELECT @Tank_ID = MIN(Tank_ID) FROM INSERTED WHERE Tank_ID > @Tank_ID
	END
END
GO

IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME = 'TG_Tanks_Delete' AND TYPE = 'TR')
	DROP TRIGGER  TG_Tanks_Delete
GO
PRINT 'Adding TG_Tanks_Delete Trigger...'
GO
CREATE TRIGGER TG_Tanks_Delete on Tanks
INSTEAD OF DELETE
AS
BEGIN
	DECLARE @Tank_ID AS INT
	SELECT @Tank_ID = MIN(Tank_ID)
	FROM DELETED

	WHILE @Tank_ID is not NULL
	BEGIN
		BEGIN TRANSACTION
		DELETE FROM Tank_History WHERE Tank_ID = @Tank_ID
		DELETE FROM Tank_Delivery WHERE Tank_ID = @Tank_ID
		DELETE FROM Tank_Loss WHERE Tank_ID = @Tank_ID
		DELETE FROM Tank_Transfer WHERE From_Tank_ID = @Tank_ID OR To_Tank_ID = @Tank_ID
		DELETE FROM Tank_Readings WHERE Tank_ID = @Tank_ID
		DELETE FROM Tanks WHERE Tank_ID = @Tank_ID
		COMMIT TRANSACTION
		
		SELECT @Tank_ID = MIN(Tank_ID) FROM DELETED WHERE Tank_ID > @Tank_ID
	END
END
GO


IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME = 'TG_Loops_Update' AND TYPE = 'TR')
	DROP TRIGGER  TG_Loops_Update
GO
PRINT 'Adding TG_Loops_Update Trigger...'
GO
CREATE TRIGGER TG_Loops_Update on Loops
FOR INSERT, UPDATE 
AS
BEGIN
	DECLARE @Port_Assign AS INT,
            @ProtocolID AS INT,
			@LoopID AS INT

	SELECT @LoopID = MIN(Loop_ID) FROM INSERTED

	SELECT @Port_Assign  = Port_Assign,
           @ProtocolID = Protocol_ID
	FROM INSERTED WHERE Loop_ID = @LoopID

	WHILE @LoopID is not NULL
	BEGIN
		-- Port Assignment?
		IF (@Port_Assign<0 OR @Port_Assign>99)
		BEGIN
			RAISERROR ('Port_Assign: 0-99',18,1)
			ROLLBACK
			BREAK
		END
		-- IFSF condition commented out as we install Port 5 with 'Not Installed'
		-- IFSF Port And NOT IFSF Protocol
		--IF (@LoopID=5 AND @ProtocolID<>9)
		--BEGIN
		--	RAISERROR ('IFSF Port should be assigned IFSF Protocol',18,1)
		--	ROLLBACK
		--	BREAK
		--END
		
		SELECT @LoopID = MIN(Loop_ID) FROM INSERTED WHERE Loop_ID > @LoopID

		SELECT @Port_Assign  = Port_Assign,
			   @ProtocolID = Protocol_ID
		FROM INSERTED WHERE Loop_ID = @LoopID
	END
END
GO

IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME = 'TG_Pumps_Update' AND TYPE = 'TR')
	DROP TRIGGER  TG_Pumps_Update
GO
PRINT 'Adding TG_Pumps_Update Trigger...'
GO
CREATE TRIGGER TG_Pumps_Update on Pumps
FOR INSERT,UPDATE 
AS
BEGIN
	DECLARE @Logical_Number AS INT,
		@Polling_Address AS INT,
		@Price_1_Level AS INT,
		@Price_2_Level AS INT,
		@Loop_ID AS INT,
		@Pump_Type_ID AS INT,
		@Pump_ID AS INT,
		@Deleted AS INT
    DECLARE @found1 INT,
		@found2 INT
	
	SELECT @Pump_ID = MIN(Pump_ID) 
	  FROM INSERTED 

	SELECT @Logical_Number = Logical_Number,
		@Polling_Address = Polling_Address,
		@Price_1_Level = Price_1_Level,
		@Price_2_Level = Price_2_Level,
		@Loop_ID = Loop_ID,
		@Pump_Type_ID = Pump_Type_ID,
		@Deleted = Deleted
	 FROM INSERTED 
	WHERE Pump_ID = @Pump_ID

	WHILE @Pump_ID is not NULL
	BEGIN
		-- EnConfig.EXE updates the field separately for IFSF
			-- so disable the checks for this
		IF (@Loop_ID<>5)
		BEGIN
			-- A Mechanical Pump! Ignore Polling_Address and Pump Type Compatibility
			IF (@Pump_Type_ID<>80)
			BEGIN
				--Polling Address
			IF (@Polling_Address=NULL OR @Polling_Address<1 OR @Polling_Address>127)
			BEGIN
				RAISERROR ('Polling_Address: 1-127',18,1)
				ROLLBACK
				BREAK
			END
			--This causes inability to delete a pump after it had been assigned to
			--port 2, even if the port has since been set to Not Installed.
			--Pump Type compatibility
			--IF (@Pump_Type_ID NOT IN
			--	(SELECT Pump_Type_ID FROM Pump_Type WHERE Protocol_ID in 
			--		(SELECT Protocol_ID FROM Loops WHERE loop_id=@Loop_ID)
			--	)
			--) 
			--BEGIN
			--	RAISERROR ('Pump_Type: Incompatible with Loop and Protocol setting',18,1)
			--	ROLLBACK
			--END
		END

			--Price Level Checks Commented out as DefaultData.SQL inserts default pumps with pricelevels EVEN before inserting the price levels!
			--Price levels valid? 
			--SET @found1 = (Select Price_Profile_ID from Price_Profile Where Price_Profile_ID=@Price_1_Level )
			--SET @found2 = (Select Price_Profile_ID from Price_Profile Where Price_Profile_ID=@Price_2_Level )
			--IF (@found1 is NULL OR @found2 is NULL)
			--BEGIN
			--		RAISERROR ('Price_Level : Price Level not found',18,1)
			--		ROLLBACK
			--END
		END

		IF (@Logical_Number<1 OR @Logical_Number>99)
		BEGIN
			RAISERROR ('Logical_Number: 1-99',18,1)
			ROLLBACK
			BREAK
		END
		
		IF ( @Deleted = 0 )
		BEGIN
			--Logical number duplicate?
			SET @found1 = (Select TOP 1 Pump_ID from Pumps Where Logical_Number=@Logical_Number AND Pump_ID<>@Pump_ID AND Pumps.Deleted = 0)
			IF (@found1 is NOT NULL)
			BEGIN
				RAISERROR ('Logical_Number: Duplicate found!',18,1)
				ROLLBACK
				BREAK
			END

			--Polling address duplicate? Mechanical pumps are ignored
			SET @found1 = (Select TOP 1 Pump_ID from Pumps Where Polling_Address=@Polling_Address AND Loop_ID=@Loop_ID AND Pump_ID<>@Pump_ID AND @Pump_Type_ID<>80 AND Pumps.Deleted = 0)
			IF (@found1 is NOT NULL)
			BEGIN
				RAISERROR ('Polling_Address: Duplicate found!',18,1)
				ROLLBACK
				BREAK
			END
		END

		/* go to next record */
		SELECT @Pump_ID = MIN(Pump_ID) FROM INSERTED WHERE Pump_ID > @Pump_ID
		SELECT @Logical_Number = Logical_Number,
			@Polling_Address = Polling_Address,
			@Price_1_Level = Price_1_Level,
			@Price_2_Level = Price_2_Level,
			@Loop_ID = Loop_ID,
			@Pump_Type_ID = Pump_Type_ID,
			@Deleted = Deleted
		 FROM INSERTED 
		WHERE Pump_ID = @Pump_ID
	END
END
GO


IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME = 'TG_Global_Settings_Update' AND TYPE = 'TR')
	DROP TRIGGER  TG_Global_Settings_Update
GO
PRINT 'Adding TG_Global_Settings_Update Trigger...'
GO
CREATE TRIGGER TG_Global_Settings_Update on Global_Settings
FOR INSERT, UPDATE 
AS
BEGIN
    DECLARE @Prepay_Reserved_TO AS INT,
            @Prepay_Refund_TO AS INT,
            @Prepay_Taken_TO AS INT,
            @Preauth_Rsvd_TO AS INT,
            @Authorized_Timeout AS INT,
            @Monitor_Del_TO AS INT,
            @PVT_on AS INT,
            @Delivery_Idle_TO AS INT,
            @Event_keep_days AS INT,
            @Hose_del_keep_days AS INT,
            @Tank_del_keep_days AS INT,
            @Attendant_support AS INT,
            @Att_keep_days AS INT,
            @Delivery_Age_TO AS INT,
            @Tank_Dips AS INT,
            @Tank_Drops AS INT,
            @Pump_Meters AS INT,
            @Delivering_NR_TO AS INT,
            @Recon_Report_Format AS INT,
            @Recon_Export_Type AS INT,
            @Auto_Modes_On AS INT,
            @Backup_Files AS INT
-- TODO additional fields not considered here
--  Reserve_TO
--  Delivering_NR_TO
--  Recon_Edits_Allowed
--  Recon_Export_Mandatory
--  Clear_Att_Dels
--  Price_Level_Control
--  Minimum_Etotal_Diff
--  Map_Test_Delivery_To_Tank_Transfer
--  Use_Hose_Turn_Over
--  Approval_Required_for_FuelRecon
--  Can_Disable_Hoses_By_Grade
--  Disable_Hose_During_Delivery
--  Backup_Time
    DECLARE @Minimum_Del_Volume AS DECIMAL(16,4)


    SELECT  @Prepay_Reserved_TO = Prepay_Reserved_TO,
            @Prepay_Refund_TO = Prepay_Refund_TO,
            @Prepay_Taken_TO = Prepay_Taken_TO,
            @Preauth_Rsvd_TO = Preauth_Rsvd_TO,
            @Authorized_Timeout = Authorized_Timeout,
            @Monitor_Del_TO = Monitor_Del_TO,
            @PVT_on = PVT_on,
            @Delivery_Idle_TO = Delivery_Idle_TO,
            @Event_keep_days = Event_keep_days,
            @Hose_del_keep_days = Hose_del_keep_days,
            @Tank_del_keep_days = Tank_del_keep_days,
            @Attendant_support = Attendant_support,
            @Att_keep_days = Att_keep_days,
            @Delivery_Age_TO = Delivery_Age_TO,
            @Tank_Dips = Tank_Dips,
            @Tank_Drops = Tank_Drops,
            @Pump_Meters = Pump_Meters,
            @Delivering_NR_TO = Delivering_NR_TO,
            @Recon_Report_Format = Recon_Report_Format,
            @Recon_Export_Type = Recon_Export_Type,
            @Auto_Modes_On = Auto_Modes_On,
            @Backup_Files = Backup_Files
    FROM INSERTED
	
	-- Only have one instance in the database so should only be editing 1 row.
	-- Could include the ID and a While loop but seems redudant.

    --IF (@Pump_Stack_Size<0 OR @Pump_Stack_Size>200)
    --BEGIN
	--	RAISERROR ('Pump_Stack_Size: 0-200',18,1)
	--	ROLLBACK
    --END	

    -- Timeouts
    -- Spot #10485 - Prepay Reserved Timeout
    --      increased max value to 1200 
    --      don't allow zero anymore. Pump server behavior is currently undefined for 0 timeout values
    IF (@Prepay_Reserved_TO<1 OR @Prepay_Reserved_TO>9999)
    BEGIN
		RAISERROR ('Prepay_Reserved_TO: 1-9999',18,1)
        ROLLBACK
    END
    IF (@Prepay_Refund_TO<0 OR @Prepay_Refund_TO>9999)
    BEGIN
		RAISERROR ('Prepay_Refund_TO: 0-9999',18,1)
		ROLLBACK
    END
    IF (@Prepay_Taken_TO<0 OR @Prepay_Taken_TO>9999)
    BEGIN
		RAISERROR ('Prepay_Taken_TO: 0-9999',18,1)
		ROLLBACK
    END
    IF (@Preauth_Rsvd_TO<0 OR @Preauth_Rsvd_TO>9999)
    BEGIN
		RAISERROR ('Preauth_Rsvd_TO: 0-9999',18,1)
		ROLLBACK
    END
    --EnbConfig Limit is 600. GilbarcoPAM sets this to 999! Follow 999 then
    --IF (@Authorized_Timeout<0 OR @Authorized_Timeout>600)
    IF (@Authorized_Timeout<0 OR @Authorized_Timeout>9999)
    BEGIN
		RAISERROR ('Authorized_Timeout: 0-9999',18,1)
		ROLLBACK
    END
    IF (@Monitor_Del_TO<0 OR @Monitor_Del_TO>9999)
    BEGIN
		RAISERROR ('Monitor_Del_TO: 0-9999',18,1)
		ROLLBACK
    END
    IF (@Delivery_Idle_TO<0 OR @Delivery_Idle_TO>9999)
    BEGIN
		RAISERROR ('Delivery_Idle_TO: 0-9999',18,1)
		ROLLBACK
    END

    -- History
    IF (@Event_keep_days<=0 OR @Event_keep_days>1000)
    BEGIN
		RAISERROR ('Event_keep_days: 1-1000',18,1)
		ROLLBACK
    END
    IF (@Hose_del_keep_days<0 OR @Hose_del_keep_days>1000)
    BEGIN
		RAISERROR ('Hose_del_keep_days: 0-1000',18,1)
		ROLLBACK
    END
    IF (@Tank_del_keep_days<0 OR @Tank_del_keep_days>1000)
    BEGIN
		RAISERROR ('Tank_del_keep_days: 0-1000',18,1)
		ROLLBACK
    END
	IF (@Attendant_support=1 AND (@Att_keep_days<0 OR @Att_keep_days>1000))
    BEGIN
		RAISERROR ('Att_keep_days: 0-1000',18,1)
		ROLLBACK
    END
    -- obsolete
    --IF (@Minimum_Del_Volume<0 OR @Minimum_Del_Volume>0.999)
    --BEGIN
	--	RAISERROR ('Minimum_Del_Volume: 0-0.999',18,1)
	--	ROLLBACK
    --END
    --IF (@Max_Dels_In_Prog<0 OR @Max_Dels_In_Prog>30)
    --BEGIN
	--	RAISERROR ('Max_Dels_In_Prog: 0-30',18,1)
	--	ROLLBACK
    --END

    -- Flags
    IF (@PVT_on<0 OR @PVT_on>1)
    BEGIN
		RAISERROR ('PVT_on: 0-1',18,1)
		ROLLBACK
    END
    IF (@Attendant_support<0 OR @Attendant_support>1)
    BEGIN
		RAISERROR ('Attendant_support: 0-1',18,1)
		ROLLBACK
    END
    IF (@Delivery_Age_TO<0 OR @Delivery_Age_TO>9999)
    BEGIN
		RAISERROR ('Delivery_Age_TO: 0-9999',18,1)
		ROLLBACK
    END
    IF (@Tank_Dips<0 OR @Tank_Dips>1)
    BEGIN
		RAISERROR ('Tank_Dips: 0-1',18,1)
		ROLLBACK
    END
    IF (@Tank_Drops<0 OR @Tank_Drops>1)
    BEGIN
		RAISERROR ('Tank_Drops: 0-1',18,1)
		ROLLBACK
    END
    IF (@Pump_Meters<0 OR @Pump_Meters>1)
    BEGIN
		RAISERROR ('Pump_Meters: 0-1',18,1)
		ROLLBACK
    END
    IF (@Auto_Modes_On<0 OR @Auto_Modes_On>1)
    BEGIN
		RAISERROR ('Auto_Modes_On: 0-1',18,1)
		ROLLBACK
    END
    IF (@Delivering_NR_TO<0 OR @Delivering_NR_TO>9999)
    BEGIN
		RAISERROR ('Delivering_NR_TO: 0-9999',18,1)
		ROLLBACK
    END
    IF (@Recon_Report_Format<0 OR @Recon_Report_Format>2)
    BEGIN
		RAISERROR ('Recon_Report_Format: 0-2',18,1)
		ROLLBACK
    END
    IF (@Recon_Export_Type<0 OR @Recon_Export_Type>3)
    BEGIN
		RAISERROR ('Recon_Export_Type: 0-3',18,1)
		ROLLBACK
    END
    IF (@Backup_Files <0 OR @Backup_Files>31)
    BEGIN
		RAISERROR ('Backup_Files: 1-31',18,1)
		ROLLBACK
    END
END
GO

IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME = 'TG_PriceProfile_Update' AND TYPE = 'TR')
	DROP TRIGGER  TG_PriceProfile_Update
GO
PRINT 'Adding TG_PriceProfile_Update Trigger...'
GO
CREATE TRIGGER  TG_PriceProfile_Update on Price_Profile
FOR INSERT, UPDATE 
AS
BEGIN
	DECLARE @PriceProfileID AS INT

	SELECT @PriceProfileID = MIN(Price_Profile_ID) FROM INSERTED

	WHILE @PriceProfileID is not NULL
	BEGIN
		IF ( @PriceProfileID <=0 )			
		BEGIN
			RAISERROR ('Price_Profile_ID: >=0',18,1)
			ROLLBACK
		END
		SELECT @PriceProfileID = MIN(Price_Profile_ID) FROM INSERTED WHERE Price_Profile_ID > @PriceProfileID
	END
END
GO


-- Start: Attendant Tagging Triggers (& function) --------------------------------------

	-- 'TG_Tag_Controller_Update'
	IF EXISTS  (SELECT NAME FROM sysobjects WHERE NAME = 'TG_Tag_Controller_Update' AND xtype='TR')
		begin
			print 'Found TG_Tag_Controller_Update Trigger, dropping trigger'
			DECLARE @sqlCommand nvarchar(1000)
			SET @sqlCommand = 'DROP TRIGGER TG_Tag_Controller_Update'
			exec(@sqlCommand)
		end
	GO
	IF EXISTS (SELECT table_name FROM information_schema.tables WHERE table_name = 'Tag_Controller' )
	BEGIN
		PRINT 'Adding TG_Tag_Controller_Update Trigger...'
		DECLARE @sqlCommand nvarchar(1000)
		SET @sqlCommand = '
			CREATE TRIGGER  TG_Tag_Controller_Update on Tag_Controller
			FOR INSERT, UPDATE 
			AS
			BEGIN
				DECLARE @Number AS INT
		
				SELECT @Number = Number FROM INSERTED
			
				IF @Number is not NULL
				BEGIN
					IF ( @Number <=0 )			
					BEGIN
						RAISERROR (''Number: >=0'',18,1)
						ROLLBACK
					END
				END
			END'
		EXECUTE  (@sqlCommand)
	END
	GO

----------------------------------------------------------------------------------------

	-- TG_Tag_Controller_Delete
	IF EXISTS  (SELECT NAME FROM sysobjects WHERE NAME = 'TG_Tag_Controller_Delete' AND xtype='TR')
		begin
			print 'Found TG_Tag_Controller_Delete Trigger, dropping trigger'
			DECLARE @sqlCommand nvarchar(1000)
			SET @sqlCommand = 'DROP TRIGGER TG_Tag_Controller_Delete'
			exec(@sqlCommand)
		end
	GO
	IF EXISTS (SELECT table_name FROM information_schema.tables WHERE table_name = 'Tag_Controller' )
	BEGIN
		PRINT 'Adding TG_Tag_Controller_Delete Trigger...'
		DECLARE @sqlCommand nvarchar(1000)
		SET @sqlCommand = '
			CREATE TRIGGER  TG_Tag_Controller_Delete on Tag_Controller
			FOR DELETE
			AS
			BEGIN
				DECLARE @NumRecs int
				DECLARE @Tag_Controller_ID int
				SELECT @Tag_Controller_ID = (Tag_Controller_ID) FROM deleted
	
				SET @NumRecs = (SELECT COUNT(Tag_Reader_ID) FROM Tag_Reader WHERE Tag_Controller_ID = @Tag_Controller_ID)
	    
				IF @NumRecs is not NULL
					BEGIN
					IF (@NumRecs>0)
					BEGIN
						RAISERROR (''Tag_Controller in use, cannot be deleted'',18,1)
						ROLLBACK
					END
	       
				END
			END'
		EXECUTE  (@sqlCommand)
	
	END
	GO

----------------------------------------------------------------------------------------

	-- TG_Tag_Reader_Update
	IF EXISTS  (SELECT NAME FROM sysobjects WHERE NAME = 'TG_Tag_Reader_Update' AND xtype='TR')
		begin
			print 'Found TG_Tag_Reader_Update Trigger, dropping trigger'
			DECLARE @sqlCommand nvarchar(1000)
			SET @sqlCommand = 'DROP TRIGGER TG_Tag_Reader_Update'
			exec(@sqlCommand)
		end
	GO
	IF EXISTS (SELECT table_name FROM information_schema.tables WHERE table_name = 'Tag_Controller' )
	BEGIN
		PRINT 'Adding TG_Tag_Reader_Update Trigger...'
		DECLARE @sqlCommand nvarchar(1000)
		SET @sqlCommand = '
			CREATE TRIGGER  TG_Tag_Reader_Update on Tag_Reader
			FOR INSERT, UPDATE 
			AS
			BEGIN
				DECLARE @Number AS INT
	
				SELECT @Number = Number FROM INSERTED
	
				IF @Number is not NULL
				BEGIN
					IF ( @Number <=0 )			
					BEGIN
						RAISERROR (''Number: >=0'',18,1)
						ROLLBACK
					END
				END
			END'
		EXECUTE  (@sqlCommand)
	
	END
	GO

----------------------------------------------------------------------------------------


-- NOTE: the following function is used by TG_Tag_Update to check for valid characters
----------------------------------------------------------------------------------------
-- Description:
-- Check the supplied string to see if it consists only of 
-- allowed characters, A-Z (uppercase only), numbers 0-9 and spaces.
-- Parameters: 	@String (String to search)
-- Returns: 	0 for success, 1 for failure
----------------------------------------------------------------------------------------
--IF EXISTS (SELECT NAME FROM SYS.TABLES WHERE NAME = 'Tag' )
--BEGIN
	IF EXISTS (SELECT 1 FROM SYSOBJECTS WHERE id = Object_ID('[dbo].[fn_check_chars]')  and type= 'FN')
		DROP FUNCTION [dbo].[fn_check_chars]
	GO

	CREATE FUNCTION fn_check_chars(@P_String VARCHAR(500))
	RETURNS BIT
	AS
	BEGIN
 
	DECLARE @V_RetValue BIT
	DECLARE @V_Position INT
 
	SET @V_Position = 1
	SET @V_RetValue = 0   
 
	-- Loop through all the characters
	WHILE @V_Position <= DATALENGTH(@P_String)
	           AND @V_RetValue = 0
	BEGIN
	    -- Check if ascii value of the character is valid
	    -- Note: Ascii value of A is 65 and Z is 90, Ascii value of 0 is 48 and 9 is 57, or SPACE
	    IF ASCII(SUBSTRING(@P_String, @V_Position, 1)) BETWEEN 65 AND 90 
	      OR ASCII(SUBSTRING(@P_String, @V_Position, 1)) BETWEEN 48 AND 57
	        OR ASCII(SUBSTRING(@P_String, @V_Position, 1)) BETWEEN 32 AND 32
	        SELECT @V_RetValue = 0
	    ELSE
	        SELECT @V_RetValue = 1      
	    -- Move to next character       
	    SET @V_Position = @V_Position + 1
	END
	 
	RETURN @V_RetValue
	 
	END
	
	GO

	IF EXISTS (SELECT loginname FROM master.dbo.syslogins WHERE name = 'enabler' ) 
	BEGIN
		GRANT EXECUTE ON [dbo].[fn_check_chars] TO enabler
	END
	GO

----------------------------------------------------------------------------------------

	--  TG_Tag_Delete
	--PRINT 'TG_Tag_Update'
	IF EXISTS  (SELECT NAME FROM sysobjects WHERE NAME = 'TG_Tag_Update' AND xtype='TR')
		begin
			print 'Found TG_Tag_Update Trigger, dropping trigger'
			DECLARE @sqlCommand nvarchar(1000)
			SET @sqlCommand = 'DROP TRIGGER TG_Tag_Update'
			exec(@sqlCommand)
		end
	GO
	IF EXISTS (SELECT table_name FROM information_schema.tables WHERE table_name = 'Tag' )
	BEGIN
		PRINT 'Adding TG_Tag_Update Trigger...'
		DECLARE @sqlCommand nvarchar(1000)
		SET @sqlCommand = '
			CREATE TRIGGER  TG_Tag_Update on Tag
			FOR INSERT, UPDATE 
			AS
			BEGIN
				DECLARE @TagData AS CHAR(32) 
				DECLARE @Res AS INT
				DECLARE @TagID as INT
	
				SELECT @TagID = (Tag_ID) FROM INSERTED
				SELECT @TagData = (Tag_Data) FROM INSERTED
				SET @Res = (SELECT dbo.fn_check_chars(@TagData))
				IF @Res = 1
				BEGIN
					RAISERROR ( ''Tag Data contains invalid chars'' ,18,1)
					ROLLBACK
				END
				ELSE
				BEGIN
					UPDATE Tag SET Date_Scanned = GetDate() WHERE Tag_ID = @TagID
				END
			END'
		EXECUTE  (@sqlCommand)
	
	END
	GO


----------------------------------------------------------------------------------------

	--  TG_Tag_Delete
	--PRINT 'TG_Tag_Delete'
	IF EXISTS  (SELECT NAME FROM sysobjects WHERE NAME = 'TG_Tag_Delete' AND xtype='TR')
		begin
			print 'Found TG_Tag_Delete Trigger, dropping trigger'
			DECLARE @sqlCommand nvarchar(1000)
			SET @sqlCommand = 'DROP TRIGGER TG_Tag_Delete'
			exec(@sqlCommand)
		end
	GO
	IF EXISTS (SELECT table_name FROM information_schema.tables WHERE table_name = 'Tag' )
	BEGIN
		PRINT 'Adding TG_Tag_Delete Trigger...'
		DECLARE @sqlCommand nvarchar(1000)
		SET @sqlCommand = '
			CREATE TRIGGER  TG_Tag_Delete on Tag
			FOR DELETE
			AS
			BEGIN
				DECLARE @NumRecs int
				DECLARE @Tag_ID int
				SELECT @Tag_ID = (Tag_ID) FROM deleted
		
				SET @NumRecs = (SELECT COUNT(Attendant_Tag_ID) FROM Attendant WHERE Attendant_Tag_ID = @Tag_ID)
	    
				IF @NumRecs is not NULL
				BEGIN
					IF (@NumRecs>0)
					BEGIN
						RAISERROR (''Tag in use by Attendant, cannot be deleted'',18,1)
						ROLLBACK
					END	       
				END
			END'
		EXECUTE  (@sqlCommand)
	
	END
	GO

---------------------------------------------------------------------------------------

-- end of... Attendant Tagging triggers -----------------------------------------------


-- Remove / Rollback  EnbConfigX Triggers
--IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME = 'TG_Loops_Delete' AND TYPE = 'TR')
--	DROP TRIGGER  TG_Loops_Delete
--GO
--IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME = 'TG_Grades_Update' AND TYPE = 'TR')
--	DROP TRIGGER  TG_Grades_Update
--GO
--IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME = 'TG_Hoses_Update' AND TYPE = 'TR')
--	DROP TRIGGER  TG_Hoses_Update
--GO
--IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME = 'TG_Hoses_Insert' AND TYPE = 'TR')
--	DROP TRIGGER  TG_Hoses_Insert
--GO
--IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME = 'TG_Hoses_Delete' AND TYPE = 'TR')
--	DROP TRIGGER  TG_Hoses_Delete
--GO
--IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME = 'TG_Tanks_Update' AND TYPE = 'TR')
--	DROP TRIGGER  TG_Tanks_Update
--GO
--IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME = 'TG_Tanks_Insert' AND TYPE = 'TR')
--	DROP TRIGGER  TG_Tanks_Insert
--GO
--IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME = 'TG_Tanks_Delete' AND TYPE = 'TR')
--	DROP TRIGGER  TG_Tanks_Delete
--GO
--IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME = 'TG_Loops_Update' AND TYPE = 'TR')
--	DROP TRIGGER  TG_Loops_Update
--GO
--IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME = 'TG_Pumps_Update' AND TYPE = 'TR')
--	DROP TRIGGER  TG_Pumps_Update
--GO
--IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME = 'TG_Global_Settings_Update' AND TYPE = 'TR')
--	DROP TRIGGER  TG_Global_Settings_Update
--GO
--IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME = 'TG_PriceProfile_Update' AND TYPE = 'TR')
--	DROP TRIGGER  TG_PriceProfile_Update
--GO

