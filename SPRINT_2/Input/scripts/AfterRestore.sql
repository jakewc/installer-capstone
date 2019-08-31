-- Adding the BUILTIN\ADMINISTRATORS into the sysadmin group
DECLARE @available int
SET @available=0

SET @available = ( 
SELECT	COUNT(IS_SRVROLEMEMBER('sysadmin', name))
FROM	sys.server_principals p where sid=0x01020000000000052000000020020000)

-- if @available = 0 -> BUILTIN\ADMINISTRATORS is not available, add the group into the sysadmin
IF @available=0 
BEGIN
CREATE login [BUILTIN\Administrators] FROM windows
EXEC sp_addsrvrolemember
  @LogiName= 'BUILTIN\Administrators',
  @RoleName='sysadmin'
END


/* Grant permission to EnbUserRole and EnbAuditRole for all tables in Enabler database */
USE enablerdb
GO

/* Re-create SP CreateLoginAndRoles for backwards compatibility with OLDER databases */
PRINT 'Creating CreateLoginAndRoles'
GO

IF EXISTS (SELECT NAME FROM sysobjects WHERE NAME = 'CreateLoginAndRoles' AND TYPE = 'p')
  DROP PROCEDURE CreateLoginAndRoles
GO

CREATE PROCEDURE CreateLoginAndRoles
	@ServerName	  varchar(100) = NULL,
	@GroupName	  varchar(100),
	@RoleDesc	  varchar(100)
	
AS
BEGIN
	DECLARE @hostname varchar(100)
	DECLARE @logname varchar(100)

	SET @hostname = host_name()
	IF @ServerName IS NULL
	BEGIN
		SET @logname = @hostname + '\'+ @GroupName
	END
	ELSE
	BEGIN	
		SET @logname =  @ServerName + '\'+ @GroupName
	END
	PRINT 'creating login name AND role  for ' + @logname	
	IF NOT EXISTS (SELECT NAME FROM sysusers WHERE NAME = @RoleDesc) 	
	BEGIN
		EXEC sp_addrole @RoleDesc
		IF EXISTS (SELECT NAME FROM sysusers WHERE NAME = @logname )
		BEGIN 
			EXEC sp_revokelogin @logname
		END
		EXEC sp_grantlogin @logname
		-- creating the login name (for current database)

	    	IF EXISTS (SELECT NAME FROM sysusers WHERE NAME = @logname )
		BEGIN
			EXEC sp_revokedbaccess @logname
	    	END
		EXEC sp_grantdbaccess @logname, NULL
		EXEC sp_addrolemember @RoleDesc, @logname
		EXEC sp_defaultdb @logname,'EnablerDB'
	END
END
GO

EXEC CreateLoginAndRoles 
        @ServerName = 'BUILTIN',
        @GroupName ='Users', 
        @RoleDesc ='EnablerUserRole'

EXEC CreateLoginAndRoles 
        @GroupName ='EnablerAdministrators', 
        @RoleDesc ='EnablerAdministratorRole'

GO

USE enablerdb
GO
DECLARE tnames_cursor CURSOR

FOR

SELECT distinct table_name FROM EnablerDB.INFORMATION_SCHEMA.COLUMNS WHERE table_catalog = 'ENABLERDB' AND table_schema = 'dbo'
OPEN tnames_cursor
DECLARE @tablename sysname
FETCH NEXT FROM tnames_cursor INTO @tablename
WHILE (@@FETCH_STATUS <> -1)
BEGIN
    IF (@@FETCH_STATUS <> -2)
    BEGIN	
        SELECT @tablename = RTRIM(@tablename) 
            PRINT 'grant to ' + @tablename
	    EXEC ('grant select on ' + @tablename + ' to EnablerUserRole')
            EXEC ('grant select, update, delete, insert on ' + @tablename + ' to EnablerAdministratorRole')
    END
    FETCH NEXT FROM tnames_cursor INTO @tablename
END
CLOSE tnames_cursor

DEALLOCATE tnames_cursor

GO

/* Checks here for for backwards compatibility with OLDER databases */
IF EXISTS(SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'AuditTrace')
    BEGIN
	REVOKE SELECT on AuditTrace from EnablerUserRole  
	GRANT INSERT ON AuditTrace TO EnablerUserRole
    END
IF EXISTS(SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Tank_Readings')
	GRANT SELECT, INSERT,UPDATE,DELETE   ON Tank_Readings	 TO EnablerUserRole

GRANT SELECT, INSERT ON Event_Journal TO EnablerUserRole	
GRANT SELECT, INSERT,UPDATE,DELETE  ON Price_Profile 	 TO EnablerUserRole
GRANT SELECT, INSERT, UPDATE, DELETE ON Site_Profile 	 TO EnablerUserRole
GRANT SELECT, INSERT, UPDATE, DELETE ON Global_Settings  TO EnablerUserRole
GRANT SELECT, INSERT, UPDATE, DELETE ON Pump_Profile 	 TO EnablerUserRole
GRANT SELECT, INSERT, UPDATE, DELETE ON Price_Levels 	 TO EnablerUserRole
GRANT SELECT, INSERT, UPDATE, DELETE ON Tank_Loss    	 TO EnablerUserRole
GRANT SELECT, INSERT, UPDATE, DELETE ON Tank_Transfer    TO EnablerUserRole
GRANT SELECT, INSERT, UPDATE, DELETE ON Tank_Delivery    TO EnablerUserRole
GRANT SELECT, UPDATE ON Periods 			 TO EnablerUserRole
GRANT SELECT, INSERT,UPDATE,DELETE   ON Tank_History	 TO EnablerUserRole
GRANT SELECT, INSERT,UPDATE,DELETE   ON Hose_History	 TO EnablerUserRole

/* Grant permisson to enabler for stored procedures */

USE enablerdb
GO

DECLARE spnames_cursor CURSOR

FOR

SELECT DISTINCT name FROM enablerdb..sysobjects WHERE type = 'P' ORDER BY name
OPEN spnames_cursor
DECLARE @spname sysname
FETCH NEXT FROM spnames_cursor INTO @spname
WHILE (@@FETCH_STATUS <> -1)
BEGIN
    IF (@@FETCH_STATUS <> -2)
        BEGIN	
            SELECT @spname = RTRIM(@spname) 
            PRINT 'grant on ' + @spname
            -- grant execute on sp_ to enabler
            EXEC ('grant execute on ' + @spname + ' to EnablerUserRole')
            EXEC ('grant execute on ' + @spname + ' to EnablerAdministratorRole')
        END
    FETCH NEXT FROM spnames_cursor INTO @spname
END
CLOSE spnames_cursor

DEALLOCATE spnames_cursor
GO

/* Revoke execute permissions on SPs */
/* Checks here for for backwards compatibility with OLDER databases */
IF  EXISTS (SELECT NAME FROM sysobjects WHERE NAME = 'sp_zero_data' AND TYPE = 'p')
   REVOKE EXECUTE ON sp_zero_data 	FROM EnablerUserRole
IF EXISTS(SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Populate_Enabler_Site_Setting')
   REVOKE EXECUTE ON Populate_Enabler_Site_Setting FROM EnablerUserRole
REVOKE EXECUTE ON sp_zero 	FROM EnablerUserRole
IF  EXISTS (SELECT NAME FROM sysobjects WHERE NAME = 'add_protocol' AND TYPE = 'p')
   REVOKE EXECUTE ON ADD_PROTOCOL FROM EnablerUserRole
IF  EXISTS (SELECT NAME FROM sysobjects WHERE NAME = 'add_pump_type' AND TYPE = 'p')
   REVOKE EXECUTE ON ADD_PUMP_TYPE FROM EnablerUserRole
REVOKE EXECUTE ON CreateLoginAndRoles	FROM EnablerUserRole
IF  EXISTS (SELECT NAME FROM sysobjects WHERE NAME = 'sp_add_device_event_type' AND TYPE = 'p')
   REVOKE EXECUTE ON sp_add_device_event_type	FROM EnablerUserRole
GO

-----------------------------------------------------

/* we no longer create the Enabler database login - this is no longer required by Enabler applications 
 * so the install no longer grants access to stored procedures and tables */
