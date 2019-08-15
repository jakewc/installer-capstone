exec sp_dboption 'enablerdb' , 'single user' , 'TRUE'
go 
DBCC CHECKTABLE (Attendant,REPAIR_ALLOW_DATA_LOSS)
go
DBCC CHECKTABLE (Attendant_Period,REPAIR_ALLOW_DATA_LOSS)
go
DBCC CHECKTABLE (Price_Profile,REPAIR_ALLOW_DATA_LOSS)
go
DBCC CHECKTABLE (Grades,REPAIR_ALLOW_DATA_LOSS)
go
DBCC CHECKTABLE (Tanks,REPAIR_ALLOW_DATA_LOSS)
go
DBCC CHECKTABLE (Pump_Protocol,REPAIR_ALLOW_DATA_LOSS)
go
DBCC CHECKTABLE (Pump_Type,REPAIR_ALLOW_DATA_LOSS)
go
DBCC CHECKTABLE (Loops,REPAIR_ALLOW_DATA_LOSS)
go
DBCC CHECKTABLE (Pump_Profile,REPAIR_ALLOW_DATA_LOSS)
go
DBCC CHECKTABLE (Pumps ,REPAIR_ALLOW_DATA_LOSS)
go
DBCC CHECKTABLE (Hoses ,REPAIR_ALLOW_DATA_LOSS)
go
DBCC CHECKTABLE (Attendant_history ,REPAIR_ALLOW_DATA_LOSS)
go
DBCC CHECKTABLE (Tank_Strapping ,REPAIR_ALLOW_DATA_LOSS)
go
DBCC CHECKTABLE (Period_types ,REPAIR_ALLOW_DATA_LOSS)
go
DBCC CHECKTABLE (Periods ,REPAIR_ALLOW_DATA_LOSS)
go
DBCC CHECKTABLE (Tank_History ,REPAIR_ALLOW_DATA_LOSS)
go
DBCC CHECKTABLE (Site_profile ,REPAIR_ALLOW_DATA_LOSS)
go
DBCC CHECKTABLE (Global_Settings ,REPAIR_ALLOW_DATA_LOSS)
go
DBCC CHECKTABLE (Price_Level_Types ,REPAIR_ALLOW_DATA_LOSS)
go
DBCC CHECKTABLE (Hose_Delivery ,REPAIR_ALLOW_DATA_LOSS)
go
DBCC CHECKTABLE (Tank_Delivery,REPAIR_ALLOW_DATA_LOSS)
go
DBCC CHECKTABLE (Price_Levels ,REPAIR_ALLOW_DATA_LOSS)
go
DBCC CHECKTABLE (Device_type ,REPAIR_ALLOW_DATA_LOSS)
go
DBCC CHECKTABLE (Event_type ,REPAIR_ALLOW_DATA_LOSS)
go
DBCC CHECKTABLE (Event_Journal ,REPAIR_ALLOW_DATA_LOSS)
go
DBCC CHECKTABLE (PVT ,REPAIR_ALLOW_DATA_LOSS)
go

BACKUP DATABASE ENABLERDB TO Enabler WITH INIT
go 

BACKUP LOG ENABLERDB WITH TRUNCATE_ONLY 
go

exec sp_dboption 'enablerdb' , 'single user' , 'FALSE'
go