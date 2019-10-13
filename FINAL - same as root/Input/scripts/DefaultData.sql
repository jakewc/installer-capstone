--
-- ENABLER DATABSE INSTALLATION SCRIPT
--
-- This script is responsible to Configure some default user data
--
-- $Header: /Enabler/Data Model/DBU 4.0/DefaultData.sql 21    17/06/15 3:22p Juno $
--

print 'Removing any previous site data and history'
print CONVERT(varchar,getdate(), 121)
go

print 'Clearing ALL data'
exec sp_zero_data
go

delete from hoses
delete from tank_strapping
delete from tanks
delete from grades
delete from price_levels
delete from price_profile
delete from price_level_types
delete from opts
delete from pumps
-- delete all but the use site mode
delete from pump_profile where Pump_Profile_ID <> 1
go

print 'Done'
go

print ''
print 'Creating default site configuration'
print ''
print 'Adding Grade Pricing'
go

insert into  price_level_types 
( Price_level,  Level_Name ) 
values ( 1 , 'Default' ) 
go

--insert into  price_level_types 
--( Price_level,  Level_Name ) 
--values ( 2 , 'Full Service' ) 
--go

insert into price_profile
( Price_Profile_ID, Price_Profile_Name, parent_grade_id , Scheduled_ST ) 
values ( 1 ,  'Regular pricing', 1 , getdate() ) 

insert into price_profile
( Price_Profile_ID,  Price_Profile_Name, parent_grade_id , Scheduled_ST ) 
values ( 2 ,  'Premium pricing', 2 , getdate() ) 

insert into price_profile
( Price_Profile_ID,  Price_Profile_Name, parent_grade_id , Scheduled_ST ) 
values ( 3 ,  'Diesel pricing', 3 , getdate() ) 

insert into price_profile
( Price_Profile_ID,  Price_Profile_Name, parent_grade_id , Scheduled_ST ) 
values ( 4 ,  'CNG pricing', 4 , getdate() ) 

insert into price_profile
( Price_Profile_ID,  Price_Profile_Name, parent_grade_id , Scheduled_ST ) 
values ( 5 ,  'LPG pricing', 5 , getdate() ) 
go

if not exists ( select * from price_levels )
begin
	print 'WARNING: Inserting default price level rows'
	insert into price_levels
	( Price_level , Price_Profile_ID , Grade_Price ) 
	values ( 1 , 1 , 0.949 ) 

	insert into price_levels
	( Price_level , Price_Profile_ID , Grade_Price ) 
	values ( 1 , 2 , 0.979 ) 

	insert into price_levels
	( Price_level , Price_Profile_ID , Grade_Price ) 
	values ( 1 , 3 , 0.549 ) 

	insert into price_levels
	( Price_level , Price_Profile_ID , Grade_Price ) 
	values ( 1 , 4 , 0.649 ) 

	insert into price_levels
	( Price_level , Price_Profile_ID , Grade_Price ) 
	values ( 1 , 5 , 0.859 ) 
end
else
begin
	/* rows are insterted automatically by a trigger, so should already exist */
	update price_levels
	   set Grade_Price = 0.949
	 where Price_level = 1 
	   and Price_Profile_ID = 1
	
	update price_levels
	   set Grade_Price = 0.979
	 where Price_level = 1
	   and Price_Profile_ID = 2
	
	update price_levels
	   set Grade_Price = 0.549
	 where Price_level = 1 
	   and Price_Profile_ID = 3

	update price_levels
	   set Grade_Price = 0.649
	 where Price_level = 1 
	   and Price_Profile_ID = 4
	
	update price_levels
	   set Grade_Price = 0.859
	 where Price_level = 1 
	   and Price_Profile_ID = 5
end
go

print 'Done'
go

print ''
print 'Adding Grades'
go

insert into grades 
( Grade_ID, Grade_Name, Grade_Number, Price_Profile_ID, Allocation_Limit, Alloc_Limit_Type , Delivery_Timeout , Price_Pole_Segment , Grade_type ) 
values ( 1 , 'Regular'  , 1 , 1 , 0.0 , 0 , 300 , 1 , 1 ) 

insert into grades 
( Grade_ID, Grade_Name, Grade_Number, Price_Profile_ID, Allocation_Limit, Alloc_Limit_Type , Delivery_Timeout , Price_Pole_Segment , Grade_type ) 
values ( 2 , 'Premium'  , 2 , 2 , 0.0 , 0 , 300 , 2 , 1 ) 

insert into grades 
( Grade_ID, Grade_Name, Grade_Number, Price_Profile_ID, Allocation_Limit, Alloc_Limit_Type , Delivery_Timeout , Price_Pole_Segment , Grade_type ) 
values ( 3 , 'Diesel'   , 3 , 3 , 0.0 , 0 , 600 , 3 , 1 ) 

insert into grades 
( Grade_ID, Grade_Name, Grade_Number, Price_Profile_ID, Allocation_Limit, Alloc_Limit_Type , Delivery_Timeout , Price_Pole_Segment , Grade_type ) 
values ( 4 , 'CNG'      , 4 , 4 , 0.0 , 0 , 600 , 4 , 1 ) 

insert into grades 
( Grade_ID, Grade_Name, Grade_Number, Price_Profile_ID, Allocation_Limit, Alloc_Limit_Type , Delivery_Timeout , Price_Pole_Segment , Grade_type ) 
values ( 5 , 'LPG'      , 5 , 5 , 0.0 , 0 , 600 , 5 , 1 ) 
go

print ' - Setting min_price to 0.001 for any set to zero'
update grades set min_price = 0.001 where min_price = 0.0 
go

print ' - Setting max_price to 99999 for any set to zero'
update grades set max_price = 99999.0 where max_price = 0.0 
go

print ' - Make sure grade Volume_Unit_ID is not null (default is Litres)'
update Grades SET Volume_Unit_ID=1 where ISNULL(Volume_Unit_ID,0)=0
go

print 'Done'
go

print ''
print 'Adding Tanks'
go

insert into tanks 
( Tank_ID , Tank_number , Grade_ID , Tank_Name , Capacity , tank_type_id , diameter , low_volume_warning , low_volume_alarm , hi_volume_warning , hi_volume_alarm , gauge_alarms ) 
values ( 1 , 1 , 1 , 'Regular tank' , 20000 , 1 , 2.7 , 1000 , 500 , 19000 , 19500 , '00000000000000000000000000000000000000000000000000' ) 

insert into tanks 
( Tank_ID , Tank_number , Grade_ID , Tank_Name , Capacity , tank_type_id , diameter , low_volume_warning , low_volume_alarm , hi_volume_warning , hi_volume_alarm , gauge_alarms ) 
values ( 2 , 2 , 2 , 'Pulp tank' , 20000 , 1 , 2.7 , 1000 , 500 , 19000 , 19500 , '00000000000000000000000000000000000000000000000000') 

insert into tanks 
( Tank_ID , Tank_number , Grade_ID , Tank_Name , Capacity , tank_type_id , diameter , low_volume_warning , low_volume_alarm , hi_volume_warning , hi_volume_alarm , gauge_alarms ) 
values ( 3 , 3 , 3 , 'Diesel tank' , 20000 , 1 , 2.7  , 1000 , 500 , 19000 , 19500 , '00000000000000000000000000000000000000000000000000')  

insert into tanks 
( Tank_ID , Tank_number , Grade_ID , Tank_Name , Capacity , tank_type_id , diameter , low_volume_warning , low_volume_alarm , hi_volume_warning , hi_volume_alarm , gauge_alarms ) 
values ( 4 , 4 , 4 , 'CNG tank' , 20000 , 1 , 2.7  , 1000 , 500 , 19000 , 19500 , '00000000000000000000000000000000000000000000000000')  

insert into tanks 
( Tank_ID , Tank_number , Grade_ID , Tank_Name , Capacity , tank_type_id , diameter , low_volume_warning , low_volume_alarm , hi_volume_warning , hi_volume_alarm , gauge_alarms ) 
values ( 5 , 5 , 5 , 'LPG tank' , 20000 , 1 , 2.7 , 1000 , 500 , 19000 , 19500 , '00000000000000000000000000000000000000000000000000')  
go

print 'Done'
go


print ''
print 'Creating or Updating Site profiles'
go

	-- site profiles
	if not exists (select Site_Profile_ID from site_profile where site_profile_ID = 1)
		insert into site_profile
		( Site_Profile_ID, Site_Profile_Number, Site_Profile_Name, Site_Profile_Desc, Start_Time, Valid_Days ) 
		values ( 1 , 1, 'Day mode' , 'Site mode for day time operation', 800, '1,2,3,4,5,6,7' ) 
	else
		update site_profile 
		   set start_time = 800, valid_days = '1,2,3,4,5,6,7', site_profile_number = 1 
		 where site_profile_id = 1

	if not exists (select Site_Profile_ID from site_profile where site_profile_ID = 2)
		insert into site_profile
		( Site_Profile_ID, Site_Profile_Number, Site_Profile_Name, Site_Profile_Desc, Start_Time, Valid_Days ) 
		values ( 2 , 2, 'Night mode' , 'Site mode for night time operation', 2000,  '1,2,3,4,5,6,7' ) 
	else
		update site_profile 
		   set start_time = 2000, valid_days = '1,2,3,4,5,6,7', site_profile_number = 2 
		 where site_profile_id = 2

    print 'Updating Pump Profile records for the default site modes'
	go

	declare @profile_id as int
	set @profile_id = ( select max( pump_profile_id )+1 from pump_profile )

	-- the profile record for the site mode is now a row in the pump_profile table with a null in pump_profile_pump_id
	if not exists (select Site_Profile_ID from pump_profile where isnull(site_profile_ID ,0) = 0 and isnull( pump_profile_pump_id, 0 )=0 )
	   insert into pump_profile
	   ( Pump_Profile_ID, allow_postpay, allow_prepay, allow_preauth, pump_stacking )
	   values( @profile_id , 2, 2, 2, 2 )
	go

	declare @profile_id as int
	set @profile_id = ( select max( pump_profile_id )+1 from pump_profile )

	-- the profile record for the site mode is now a row in the pump_profile table with a null in pump_profile_pump_id
	if not exists (select Site_Profile_ID from pump_profile where site_profile_ID = 1 and isnull( pump_profile_pump_id, 0 )=0 )
	   insert into pump_profile
	   ( Pump_Profile_ID, Site_Profile_ID, allow_postpay, allow_prepay, allow_preauth, pump_stacking, stack_size )
	   values( @profile_id , 1, 1, 1, 1, 1, 1 )
	go

	declare @profile_id as int
	set @profile_id = ( select max( pump_profile_id )+1 from pump_profile )

	if not exists (select Site_Profile_ID from pump_profile where site_profile_ID = 2 and isnull( pump_profile_pump_id, 0 )=0 )
	   insert into pump_profile
	   ( Pump_Profile_ID, Site_Profile_ID, allow_postpay, allow_prepay, allow_preauth, pump_stacking, stack_size )
	   values( @profile_id, 2, 1, 1, 1, 1, 1 )
    go

print 'Done'
go

-- pump configuration

print ''
print 'Setting Port 1 to MPPSIM protocol'
go

update loops set protocol_id = 3 where loop_id = 1
go

print 'Done'
go

print ''
print 'Adding Pumps 1 to 4'
go

-- pump default display configuration to match MPPSim default display configuration.
insert into pumps
( Pump_ID , Pump_Type_ID , Loop_ID , Pump_Name , Logical_Number , Polling_Address , value_decimals, volume_decimals, price_decimals ) 
values ( 1 , 4 , 1 , 'Pump 1' , 1 , 1 , 2 , 3 , 3 ) 

insert into pumps
( Pump_ID , Pump_Type_ID , Loop_ID , Pump_Name , Logical_Number , Polling_Address , value_decimals, volume_decimals, price_decimals ) 
values ( 2 , 4 , 1 , 'Pump 2' , 2 , 2 , 2 , 3 , 3 ) 

insert into pumps
( Pump_ID , Pump_Type_ID , Loop_ID , Pump_Name , Logical_Number , Polling_Address , value_decimals, volume_decimals, price_decimals ) 
values ( 3 , 4 , 1 , 'Pump 3' , 3 , 3 , 2 , 3 , 3 ) 

insert into pumps
( Pump_ID , Pump_Type_ID , Loop_ID , Pump_Name , Logical_Number , Polling_Address , value_decimals, volume_decimals, price_decimals ) 
values ( 4 , 4 , 1 , 'Pump 4' , 4 , 4 , 2 , 3 , 3 ) 
go

print 'Done'
go

print ''
print 'Adding Hoses for Pumps 1 to 4'
go

insert into hoses 
( Hose_ID , Pump_ID , Tank_ID , Grade_id, Volume_Total, Money_Total, Hose_number ) 
values ( 1 , 1 , 1 , 1 , 0 , 0 , 1 ) 

insert into hoses 
( Hose_ID , Pump_ID , Tank_ID , Grade_id, Volume_Total, Money_Total, Hose_number ) 
values ( 2 , 1 , 2 , 2 , 0 , 0 , 2 ) 
            
insert into hoses 
( Hose_ID , Pump_ID , Tank_ID , Grade_id, Volume_Total, Money_Total, Hose_number ) 
values ( 3 , 1 , 3 , 3 , 0 , 0 , 3 ) 

insert into hoses 
( Hose_ID , Pump_ID , Tank_ID , Grade_id, Volume_Total, Money_Total, Hose_number ) 
values ( 4 , 1 , 4 , 4 , 0 , 0 , 4 ) 

insert into hoses 
( Hose_ID , Pump_ID , Tank_ID , Grade_id, Volume_Total, Money_Total, Hose_number ) 
values ( 5 , 2 , 1 , 1 , 0 , 0 , 1 ) 

insert into hoses 
( Hose_ID , Pump_ID , Tank_ID , Grade_id, Volume_Total, Money_Total, Hose_number ) 
values ( 6 , 2 , 2 , 2 , 0 , 0 , 2 ) 
            
insert into hoses 
( Hose_ID , Pump_ID , Tank_ID , Grade_id, Volume_Total, Money_Total, Hose_number ) 
values ( 7 , 2 , 3 , 3 , 0 , 0 , 3 ) 

insert into hoses 
( Hose_ID , Pump_ID , Tank_ID , Grade_id, Volume_Total, Money_Total, Hose_number ) 
values ( 8 , 2 , 4 , 4 , 0 , 0 , 4 ) 
go

insert into hoses 
( Hose_ID , Pump_ID , Tank_ID , Grade_id, Volume_Total, Money_Total, Hose_number ) 
values ( 9 , 3 , 1 , 1 , 0 , 0 , 1 ) 

insert into hoses 
( Hose_ID , Pump_ID , Tank_ID , Grade_id, Volume_Total, Money_Total, Hose_number ) 
values ( 10 , 3 , 2 , 2 , 0 , 0 , 2 ) 
            
insert into hoses 
( Hose_ID , Pump_ID , Tank_ID , Grade_id, Volume_Total, Money_Total, Hose_number ) 
values ( 11 , 3 , 3 , 3 , 0 , 0 , 3 ) 

insert into hoses 
( Hose_ID , Pump_ID , Tank_ID , Grade_id, Volume_Total, Money_Total, Hose_number ) 
values ( 12 , 3 , 4 , 4 , 0 , 0 , 4 ) 

insert into hoses 
( Hose_ID , Pump_ID , Tank_ID , Grade_id, Volume_Total, Money_Total, Hose_number ) 
values ( 13 , 4 , 1 , 1 , 0 , 0 , 1 ) 

insert into hoses 
( Hose_ID , Pump_ID , Tank_ID , Grade_id, Volume_Total, Money_Total, Hose_number ) 
values ( 14 , 4 , 2 , 2 , 0 , 0 , 2 ) 
            
insert into hoses 
( Hose_ID , Pump_ID , Tank_ID , Grade_id, Volume_Total, Money_Total, Hose_number ) 
values ( 15 , 4 , 3 , 3 , 0 , 0 , 3 ) 

insert into hoses 
( Hose_ID , Pump_ID , Tank_ID , Grade_id, Volume_Total, Money_Total, Hose_number ) 
values ( 16 , 4 , 4 , 4 , 0 , 0 , 4 ) 
go

print ''
print 'Adding periods'
go

-- These records are no longer deleted, so just set the names back to the defaults
UPDATE period_types set period_name = 'Shift' WHERE period_type = 1
UPDATE period_types set period_name = 'Day' WHERE period_type = 2
UPDATE period_types set period_name = 'Month' WHERE period_type = 3
UPDATE period_types set period_name = 'Year' WHERE period_type = 4
go

print 'Done'
go

-- closing periods will ensure that history records for tanks, grades, hoses etc will be created
print ''
print 'Closing periods'
go

exec sp_close_period 1 
exec sp_close_period 2
exec sp_close_period 3
exec sp_close_period 4
go

print 'Done'
print CONVERT(varchar,getdate(), 121)
go
