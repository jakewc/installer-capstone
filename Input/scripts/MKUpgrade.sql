--
-- ENABLER DATABSE INSTALLATION SCRIPT
--
-- This script generates a batch file to run update scripts to refresh or add data
-- to Enabler system tables (e.g. Pump Types), and selectively adds the default
-- user data (new installs only). Used for used new and upgrade installs.
--
-- $Header: /Enabler/Data Model/DBU 4.0/MKUpgrade.sql 2     17/04/12 3:21p Dwighth $
--

SET NOCOUNT ON

-- clean up in case previous attempt failed
IF EXISTS (SELECT name FROM tempdb..sysobjects WHERE left(name,5) = '#tdbu')
   DROP TABLE #tdbu
go

DECLARE @new as int
SET @new = (select count(pump_id) from enablerdb..Pumps)

print '@echo off'
print 'echo.'
-- if we complete the upgrade we create a file - so remove it now if it exists
print 'if exist C:\Enabler\DBUPGRADE_OK attrib C:\Enabler\DBUPGRADE_OK -r'
print 'if exist C:\Enabler\DBUPGRADE_OK del C:\Enabler\DBUPGRADE_OK'
print 'echo ' + CONVERT(char, CURRENT_TIMESTAMP)
print 'echo.'


-- run update scripts to refresh system data
print 'echo.'
print 'echo Populate system tables'
print 'oSQL.EXE -E -S%1 -d EnablerDB -n -i populate.sql'

-- for new installs we provide default data
if @new = 0 
BEGIN
	print 'echo New database - add default data now'
	print 'oSQL.EXE -E -S%1 -d EnablerDB -n -i DefaultData.sql'
END
Else
BEGIN
	print 'echo Database already installed - default data not required'
END

-- ok we completed successfully so create a file to indicate this
print 'echo Upgrade complete >> c:\enabler\DBUPGRADE_OK'
print 'goto end'

print ':End'
print 'echo ------------------------'
go
