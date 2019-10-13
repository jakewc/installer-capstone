print ' SDK is selected, install Sim and MPP driver'
print ' - Install MPP Protocol and Pump types'
GO

PRINT ' - Install Sim Protocol'
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'add_protocol' AND type = 'P')
   drop procedure add_protocol
go

CREATE PROCEDURE ADD_PROTOCOL
	@RELEASED	  smallint,
	@PROT_TYPE        smallint,
	@PROT_NAME        CHAR(40),
	@PROT_ID          int,
	@DRIVER_CLASS     CHAR(40),
	@INTER_POLL_DELAY smallint,
	@POLL_TYPE        smallint,
	@LINE_CONTROL     tinyint,
	@BAUD_DIVISOR     smallint,
	@PROT_DESC        CHAR(80),
	@OUTBOARD_PROT    smallint,
	@EXT_PORT_PARAMS  VARCHAR(100) = ''
AS
DECLARE 
	@already_added	  smallint,
	@SomeSQL          VARCHAR(256)
BEGIN
  -- If a protocol is set to 0 it is not yet released and should 
  -- not be installed on a site
  IF @RELEASED = 0
	RETURN

  BEGIN TRANSACTION 
  SET @PROT_NAME = LEFT(@PROT_NAME,30)
  SET @PROT_DESC = LEFT(@PROT_DESC,80)
  SET @DRIVER_CLASS = LTRIM(RTRIM(@DRIVER_CLASS))

  print 'Protocol: ' + RTRIM(cast( @PROT_ID as char )) + ' ' + @PROT_NAME

  IF ( SELECT count(Protocol_ID) FROM Pump_Protocol WHERE Protocol_ID = @PROT_ID  ) < 1
  BEGIN
	-- add new record
	print 'Adding new protocol'
     	INSERT INTO pump_protocol
		( protocol_id, Protocol_Name, Protocol_Desc, Driver_Class_ID )
		VALUES (@PROT_ID, @PROT_NAME, '', '' )
  END

  -- update the protocol type id
  IF ( SELECT count(Column_Name) From INFORMATION_SCHEMA.COLUMNS where column_name = 'Protocol_Type_ID' AND TABLE_NAME = 'Pump_Protocol' ) >= 1
  BEGIN
    IF ( @PROT_ID not in (11))
	BEGIN
	-- prevent parse error if field is not there
   	  SELECT @SomeSQL = 'UPDATE Pump_Protocol SET Protocol_Type_id = ' + CONVERT(VARCHAR, @PROT_TYPE)+ ' WHERE Protocol_ID = ' + CONVERT(VARCHAR, @PROT_ID) 
      EXEC (@SomeSQL)
	END
  END

  -- update the outboard protocol
  IF ( SELECT count(Column_Name) From INFORMATION_SCHEMA.COLUMNS where column_name = 'Outboard_Protocol' AND TABLE_NAME = 'Pump_Protocol' ) >= 1
  BEGIN
	-- prevent parse error if field is not there
	DECLARE @OutProtSQL VARCHAR(256)
	SELECT @OutProtSQL = 'UPDATE Pump_Protocol SET Outboard_Protocol = ' + CONVERT(VARCHAR, @OUTBOARD_PROT) + ' WHERE Protocol_ID = ' + CONVERT(VARCHAR, @PROT_ID)
	EXEC (@OutProtSQL)
  END

  -- Now update the main part of the record
  UPDATE pump_protocol 
  SET Protocol_Name    = @PROT_NAME, 
    Protocol_Desc      = @PROT_DESC, 
    Inter_Poll_Delay   = @INTER_POLL_DELAY, 
    Poll_Type          = @POLL_TYPE, 
    Line_Control       = @LINE_CONTROL, 
    Baud_Divisor_latch = @BAUD_DIVISOR
  WHERE protocol_id = @PROT_ID

  -- tank drivers only get a class id for enabler v3.50+
  IF @PROT_TYPE = 2
  BEGIN
    IF ( SELECT count(Column_Name) From INFORMATION_SCHEMA.COLUMNS where column_name = 'Tank_Gauge_id' AND TABLE_NAME = 'Tank_Gauge' ) >= 1
    BEGIN
      -- Enabler version 3.50+ so we need the driver class id for Tank Gauge protocols
      UPDATE pump_protocol SET
        Driver_Class_ID    = @DRIVER_CLASS
      WHERE protocol_id = @PROT_ID
    END
    ELSE
    BEGIN
      -- older Enabler versions use the Tank Gauge code in PSRVR
      UPDATE pump_protocol SET
        Driver_Class_ID    = ''
      WHERE protocol_id = @PROT_ID
    END
  END
  ELSE
  BEGIN
    UPDATE pump_protocol SET
      Driver_Class_ID    = @DRIVER_CLASS
    WHERE protocol_id = @PROT_ID
  END

  IF ( SELECT count(Column_Name) From INFORMATION_SCHEMA.COLUMNS where column_name = 'Extended_Port_Settings' AND TABLE_NAME = 'Pump_Protocol' ) >= 1
  BEGIN
      SELECT @SomeSQL = 'UPDATE Pump_Protocol SET Extended_Port_Settings = '''+@EXT_PORT_PARAMS+''' WHERE protocol_id = ' + CONVERT(VARCHAR, @PROT_ID)
      EXEC (@SomeSQL)
  END

  COMMIT TRANSACTION 
END
go

PRINT ' - INSTALL MPP PROTOCOL'

	EXEC ADD_PROTOCOL @RELEASED = 1,
		@PROT_TYPE = 1,
		@PROT_NAME = 'MPP Simulator', 
		@PROT_ID = 3, 
		@DRIVER_CLASS =   '{0D88C27B-257A-4F97-83CD-044A40F75CE3}',  
		@INTER_POLL_DELAY = 10, 
		@POLL_TYPE = 2, 
		@LINE_CONTROL = 27, 
		@BAUD_DIVISOR = 240,
		@PROT_DESC = 'Using ITL PumpSim cable (null modem)', 
		@OUTBOARD_PROT = 1
GO
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'ADD_PUMP_TYPE' AND type = 'P')
   drop procedure ADD_PUMP_TYPE
go

CREATE PROCEDURE ADD_PUMP_TYPE
	@Pump_Type_ID	  int,
	@Pump_Type_Name	  char(40),
	@Protocol_ID	  int,
	@Poll_Response_TO smallint,
	@Max_No_Responses smallint,
	@Inter_Char_TO	  smallint,
	@Polling_Rate	  smallint,
	@Has_Lights	  smallint,
	@Has_Preset       smallint,
	@Max_Price_Levels smallint,
	@Max_Hoses	  smallint,
	@Is_a_blender	  smallint = 0.0,
	@Running_Total_PR smallint = 0.0,
	@Default_Display_Type int = 0.0,
	@Multiplier_Support smallint = 0,
	@Supports_Tag_Reader smallint = 0
AS

DECLARE @Single_Hose_Auth smallint

BEGIN

  -- Dont try to add a pump type for a Protocol_Id that may not have been released 
  -- or had a problem being installed
  IF ( SELECT count(Protocol_ID) FROM Pump_Protocol WHERE Protocol_ID = @Protocol_ID  ) < 1
	RETURN

  BEGIN TRANSACTION 

  SET @Pump_Type_Name = LEFT(@Pump_Type_Name,30)

  PRINT 'Pump Type: ' + RTRIM(cast( @Pump_Type_ID as char )) + ' ' + @Pump_Type_Name

  IF ( SELECT count(Pump_Type_ID) FROM Pump_Type WHERE Pump_Type_ID = @Pump_Type_ID  ) < 1
  BEGIN
	-- add new record
	print 'Adding new record for pump type ' + RTRIM(cast( @Pump_Type_ID as char ))
        INSERT INTO pump_type 
	       ( pump_type_id, pump_type_name, protocol_id, pump_type_desc, inter_char_timeout, value_format, volume_format, price_format )
        VALUES
               ( @Pump_Type_ID, '', 11, NULL, 0, '', '', '' )
  END

  -- First we update mandatory fields which have been in the database forever

  UPDATE Pump_Type
     SET Pump_Type_Name     = @Pump_Type_Name,
	 Protocol_ID        = @Protocol_ID,
	 Poll_Response_TO   = @Poll_Response_TO,
	 Max_No_Responses   = @Max_No_Responses,
	 Inter_Char_Timeout = @Inter_Char_TO,
	 Polling_Rate       = @Polling_Rate,
	 Has_Lights         = @Has_Lights,
	 Has_Preset         = @Has_Preset,
	 Max_Price_Levels   = @Max_Price_Levels,
	 Max_Hoses          = @Max_Hoses
   WHERE Pump_Type_ID       = @Pump_Type_ID

  -- Next we update optional fields which have been recently added (may not be present)

  -- update the is a blender field
  IF ( SELECT count(Column_Name) From INFORMATION_SCHEMA.COLUMNS where column_name = 'Is_A_Blender' AND TABLE_NAME = 'Pump_Type' ) >= 1
  BEGIN
      -- prevent parse error if field is not there
      DECLARE @IsBlenderSQL VARCHAR(256)
      SELECT @IsBlenderSQL = 'UPDATE Pump_Type SET Is_A_Blender = ' + CONVERT(VARCHAR, @Is_A_Blender)+ ' WHERE Pump_Type_ID = ' + CONVERT(VARCHAR, @Pump_Type_ID) 
      EXEC (@IsBlenderSQL)
  END

  -- update the running total poll rate field
  IF ( SELECT count(Column_Name) From INFORMATION_SCHEMA.COLUMNS where column_name = 'Running_Total_PR' AND TABLE_NAME = 'Pump_Type' ) >= 1
  BEGIN
      -- prevent parse error if field is not there
      DECLARE @RTRateSQL VARCHAR(256)
      SELECT @RTRateSQL = 'UPDATE Pump_Type SET Running_Total_PR = ' + CONVERT(VARCHAR, @Running_Total_PR)+ ' WHERE Pump_Type_ID = ' + CONVERT(VARCHAR, @Pump_Type_ID) 
      EXEC (@RTRateSQL)
  END

  -- update the default display type field
  IF ( SELECT count(Column_Name) From INFORMATION_SCHEMA.COLUMNS where column_name = 'Default_Display_Type' AND TABLE_NAME = 'Pump_Type' ) >= 1
  BEGIN
      -- prevent parse error if field is not there
      DECLARE @DefaultSQL VARCHAR(256)
      SELECT @DefaultSQL = 'UPDATE Pump_Type SET Default_Display_Type = ' + CONVERT(VARCHAR, @Default_Display_Type)+ ' WHERE Pump_Type_ID = ' + CONVERT(VARCHAR, @Pump_Type_ID) 
      EXEC (@DefaultSQL)
  END

  -- update the single hose auth field
  IF ( SELECT count(Column_Name) From INFORMATION_SCHEMA.COLUMNS where column_name = 'Single_Hose_Auth' AND TABLE_NAME = 'Pump_Type' ) >= 1
  BEGIN
      -- prevent parse error if field is not there
      DECLARE @SingleSQL VARCHAR(256)
      SELECT @SingleSQL = 'UPDATE Pump_Type SET Single_Hose_Auth = ' + CONVERT(VARCHAR, @Single_Hose_Auth)+ ' WHERE Pump_Type_ID = ' + CONVERT(VARCHAR, @Pump_Type_ID) 
      EXEC (@SingleSQL)
  END

  -- update the multiplier support field
  IF ( SELECT count(Column_Name) From INFORMATION_SCHEMA.COLUMNS where column_name = 'Multiplier_Support' AND TABLE_NAME = 'Pump_Type' ) >= 1
  BEGIN
      -- prevent parse error if field is not there
      DECLARE @MultiplierSQL VARCHAR(256)
      SELECT @MultiplierSQL = 'UPDATE Pump_Type SET Multiplier_Support = ' + CONVERT(VARCHAR, @Multiplier_Support)+ ' WHERE Pump_Type_ID = ' + CONVERT(VARCHAR, @Pump_Type_ID) 
      EXEC (@MultiplierSQL)
  END
  
  -- update the tagging support field
  IF ( SELECT count(Column_Name) From INFORMATION_SCHEMA.COLUMNS where column_name = 'Supports_Tag_Reader' AND TABLE_NAME = 'Pump_Type' ) >= 1
  BEGIN
      -- prevent parse error if field is not there
      DECLARE @TaggingSupportSQL VARCHAR(256)
      SELECT @TaggingSupportSQL = 'UPDATE Pump_Type SET Supports_Tag_Reader = ' + CONVERT(VARCHAR, @Supports_Tag_Reader)+ ' WHERE Pump_Type_ID = ' + CONVERT(VARCHAR, @Pump_Type_ID) 
      EXEC (@TaggingSupportSQL)
  END

  COMMIT TRANSACTION 
END
go

PRINT ' - INSTALL MPP PUMP TYPES'

	EXEC ADD_PUMP_TYPE 
		@Pump_Type_ID = 4, 
		@Pump_Type_Name       = 'MPP Sim', 
		@Protocol_ID          = 3, 
		@Poll_Response_TO     = 300, 
		@Max_No_Responses     = 3, 
		@Inter_Char_TO        = 20, 
		@Polling_Rate         = 200, 
		@Has_Lights           = 1, 
		@Has_Preset           = 1, 
		@Max_Price_levels     = 2,
		@Max_Hoses            = 5

	EXEC ADD_PUMP_TYPE
 		@pump_type_id = 156,
	 	@Pump_Type_Name       = 'MPP Sim (7/8 digit)',
		@Protocol_ID          = 3, 
		@Poll_Response_TO     = 300, 
		@Max_No_Responses     = 3, 
		@Inter_Char_TO        = 20, 
		@Polling_Rate         = 200, 
		@Has_Lights           = 1, 
		@Has_Preset           = 1, 	
		@Max_Price_levels     = 2,
		@Max_Hoses            = 5

GO

print '===' + Rtrim ( cast ( getdate() as char ) ) + '==='
print '=== Installation Complete ==='
GO