print ' SDK is not selected - Delete Sim and MPP driver'
print ' - Set pump type as Mechanical Pump'
UPDATE pumps SET pump_type_id = 80 WHERE pump_id IN  (SELECT pump_id FROM pumps WHERE pump_type_id IN ( SELECT pump_type_id FROM pump_type WHERE protocol_ID = 3 ) )
go

print ' - Set pump protocol as NOT INSTALLED'
update loops set protocol_id = 11 where protocol_id in ( select protocol_id  from loops where protocol_id = 3 )
go

print ' - Delete MPP pump types from Pump with protocol = 3: MPP Simulator'
delete from pump_type where protocol_id = 3
go

print ' - Delete MPP Protocol'
delete from pump_protocol where protocol_id = 3
go

print '===' + Rtrim ( cast ( getdate() as char ) ) + '==='
print '=== Uninstallation Complete ==='
go

