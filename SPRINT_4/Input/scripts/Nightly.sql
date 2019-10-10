-- Lower the deadlock priority so this volunteers
-- to fail if a deadlock is encountered
SET DEADLOCK_PRIORITY LOW
GO

-- Check whether the Enabler dump device (backup device)
-- exists before trying to use it. Create if not found.
DECLARE @DEVICEEXISTS INT
SET @DEVICEEXISTS = 
  (SELECT COUNT(*) FROM master.dbo.SYSDEVICES WHERE name = 'Enabler')

-- Build up a new name for the Enabler backup file

DECLARE @dt as VARCHAR(100)
DECLARE @fn as VARCHAR(100)

SET @dt = CONVERT(VARCHAR, GETDATE(), 121)
SET @fn = 'C:\EnablerDB\Enabler_' + LEFT(@dt, 4) + '' + SUBSTRING(@dt, 6,2) + SUBSTRING(@dt, 9,2) + '' + '.dmp'

-- @fn will look something like this... C:\EnablerDB\Enabler_20100322.dmp

-- drop dump device and recreate it using the new file name

IF (@DEVICEEXISTS = 1) 
   EXECUTE sp_dropdevice 'Enabler'

PRINT 'Creating Dump Device Enabler'
EXECUTE sp_addumpdevice 'disk','Enabler',@fn
GO

-- start doing the actual backing up
BACKUP DATABASE EnablerDB TO Enabler WITH INIT 
GO 

-- SQL2008 (version 10) no longer supports transaction/log backup. 
DECLARE @DECPOS SMALLINT
DECLARE @MAJORREV SMALLINT

SET @DECPOS = (SELECT CHARINDEX('.',CONVERT(CHAR(20),SERVERPROPERTY('productversion'))))
SET @MAJORREV = (SELECT SUBSTRING(CONVERT(CHAR(20),SERVERPROPERTY('productversion')),1,@DECPOS-1))
IF @MAJORREV < 10
BEGIN
	PRINT 'executing...BACKUP TRANSACTION EnablerDB WITH TRUNCATE_ONLY'
	DECLARE @DYNSQL NVARCHAR(1000)
	SET @DYNSQL = 'BACKUP TRANSACTION EnablerDB WITH TRUNCATE_ONLY'
	EXECUTE (@DYNSQL)
END

-- purging some old records
EXEC sp_clean 
GO 
