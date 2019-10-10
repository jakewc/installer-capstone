-- SetVersion.sql - Creates required DBVersion table and determines current database
--                  version if that has not already been set.
-- 
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'DoesFieldExist' AND type = 'P')
   drop procedure DoesFieldExist
go

CREATE PROCEDURE DoesFieldExist
	@Tab char(100),
	@Fld char(100)
AS
DECLARE @RetCode int
BEGIN
	SET @RetCode = 0
	IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @Tab)
	BEGIN
		IF (SELECT count(column_name) ReqC FROM INFORMATION_SCHEMA.COLUMNS where column_name = @Fld AND TABLE_NAME = @Tab) > 0
		BEGIN
			print 'Table ' + RTRIM(@Tab) + ' Column ' + RTRIM(@Fld) + ' exists'
			SET @RetCode = 1
		END
	END
	RETURN @RetCode
END
GO

IF not EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'DBVersion') 
   BEGIN
        CREATE TABLE DBVersion (Version       int NULL DEFAULT 0,
                                DateInstalled datetime NULL )
	INSERT INTO DBVersion (Version, DateInstalled) Values ( 0, CURRENT_TIMESTAMP )
   END
go

--- SET VERSION

DECLARE @myvers int
DECLARE @hasField int
SET @myvers = 0

-- Version 2.00

EXEC @hasField = DoesFieldExist 'PUMP_PROFILE', 'ALLOW_ATTENDANT'
IF @hasField > 0 And EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ATTENDANT_PERIOD')
BEGIN
	SET @myvers = 200
	print 'DB Version 2.00'
END

-- Version 2.50

EXEC @hasField = DoesFieldExist 'PUMPS', 'PUMP_DISPLAY_ID'
IF @hasField > 0 And EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'PUMP_DISPLAY')
BEGIN
	SET @myvers = 250
	print 'DB Version 2.50'
END

-- Version 2.51
/*
-- Check for the attendant_period field, default value changes from CURRENT_TIMESTAMP to NULL
EXEC @hasField = DoesFieldExist 'Table', 'Col'
IF @hasField > 0 And EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Table2')
BEGIN
	SET @myvers = 251
	print 'DB Version 2.51'
END
*/

-- Version 3.00

EXEC @hasField = DoesFieldExist 'PUMP_PROTOCOL', 'PROTOCOL_TYPE_ID'
IF @hasField > 0 And EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'OPT_TYPE')
BEGIN
	SET @myvers = 300
	print 'DB Version 3.00'
END


-- Version 3.10

EXEC @hasField = DoesFieldExist 'EMULATION', 'RECORD_ID'
IF @hasField > 0 And EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'EMULATION')
BEGIN
	SET @myvers = 310
	print 'DB Version 3.10'
END


-- Version 3.11

EXEC @hasField = DoesFieldExist 'PUMP_PROTOCOL', 'OUTBOARD_PROTOCOL'
IF @hasField > 0
BEGIN
	SET @myvers = 311
	print 'DB Version 3.11'
END

-- Version 3.15

EXEC @hasField = DoesFieldExist 'SITE_PROFILE', 'VALID_DAYS'
IF @hasField > 0
BEGIN
	SET @myvers = 315
	print 'DB Version 3.15'
END

-- Version 3.30

EXEC @hasField = DoesFieldExist 'OPT_KEY_CODES', 'KEY_DESC'
IF @hasField > 0
BEGIN
	SET @myvers = 330
	print 'DB Version 3.30'
END


-- Store the result

print 'DB Version found:' + STR(@myvers)
IF (SELECT Version from DBVersion) = 0
BEGIN
	UPDATE DBVersion set Version = @myvers, DateInstalled = CURRENT_TIMESTAMP
	print 'Saved version info'
END

select * from DBVersion

-- END
