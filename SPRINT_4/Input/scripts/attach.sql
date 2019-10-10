--Attach to existing Enabler database files 
print 'Attaching to existing Enabler database files'
exec sp_attach_db @dbname = 'EnablerDB', 
  @filename1 = 'C:\enablerdb\EnbData.dat', 
  @filename2 = 'C:\enablerdb\EnbLog.dat'  
go

--Drop enabler login and user if it does exists
IF EXISTS(SELECT * FROM MASTER.DBO.SYSLOGINS WHERE loginname = 'enabler')
BEGIN
	PRINT 'enabler user dropped'		
	use enablerdb
	exec sp_dropuser enabler
	PRINT 'enabler login dropped'
	exec sp_droplogin enabler
end
GO


-- Check which SQL version do we have
--Recreate enabler login and user
DECLARE @DOT AS INT
DECLARE @BASEVERSION AS FLOAT
SET @DOT = ( SELECT CHARINDEX('.',LTRIM(CAST(SERVERPROPERTY('productversion') AS CHAR))))
SET @BASEVERSION = ( SELECT CONVERT(FLOAT,SUBSTRING(LTRIM(CAST(SERVERPROPERTY('productversion') AS CHAR)),1,@DOT)))
--SQL Server 2005 has its Major version set to 9.0 onwards..
IF @BASEVERSION >= 9.0
BEGIN
	PRINT 'Using New Password'
	use enablerdb
	exec sp_addlogin enabler,En4bl3r
END
ELSE
BEGIN
	PRINT 'Using Legacy Password'
	use enablerdb
	exec sp_addlogin enabler,enabler
END
go

exec sp_adduser enabler
go

ALTER DATABASE ENABLERDB SET AUTO_CLOSE OFF WITH NO_WAIT
go
