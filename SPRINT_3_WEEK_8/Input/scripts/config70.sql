--Create new Enabler database files 
CREATE DATABASE ENABLERDB
on primary (name=ENBData,filename='c:\enablerdb\ENBData.dat',size=100MB)
log on (name=ENBLog,filename='c:\enablerdb\ENBLog.dat',size=50MB)
GO

use msdb 
go 

EXECUTE sp_addumpdevice "disk","Enabler","c:\EnablerDB\Enabler.dmp"
go 

