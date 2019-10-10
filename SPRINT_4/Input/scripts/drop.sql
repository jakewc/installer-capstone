drop table event_journal
drop table event_type
drop table device_type 
drop table pvt
drop table attendant_history
drop table attendant_period
drop table hose_history 
drop table tank_history 
drop table periods 
drop table period_types
drop table hose_delivery
drop table hoses
drop table tank_delivery
drop table tank_strapping
drop table tanks
drop table grades
drop table pumps
drop table pump_type
drop table loops
drop table pump_protocol
drop table pump_profile
drop table attendant
drop table global_settings
drop table site_profile
drop table price_levels
drop table price_profile
drop table price_level_types
drop table protocol_type
drop table prompts
go 
DROP PROCEDURE sp_log_patch
DROP PROCEDURE sp_log_delivery 
DROP PROCEDURE sp_clear_delivery 
DROP PROCEDURE sp_update_delivery
DROP PROCEDURE sp_log_event
DROP PROCEDURE sp_close_pvt
DROP PROCEDURE sp_close_prd_res 
DROP PROCEDURE sp_close_period 
DROP PROCEDURE sp_clean 
DROP PROCEDURE sp_log_tanker_del
DROP PROCEDURE sp_zero
DROP PROCEDURE sp_logon_att 
DROP PROCEDURE sp_att_modify_period
DROP PROCEDURE sp_logoff_att_all
DROP PROCEDURE sp_logoff_att
DROP PROCEDURE sp_setup_tank
DROP PROCEDURE sp_adjust_strap
DROP PROCEDURE sp_log_auto_del
DROP PROCEDURE sp_del_hose
DROP PROCEDURE sp_del_tank
DROP PROCEDURE sp_check_prices
DROP PROCEDURE sp_att_open_period
DROP PROCEDURE sp_att_save_amount
DROP PROCEDURE sp_log_detected_tank_del
DROP PROCEDURE sp_check_detected_tank_del
DROP PROCEDURE sp_log_delivery_ex
DROP PROCEDURE sp_log_tank_loss
DROP PROCEDURE sp_log_tank_transfer
DROP PROCEDURE sp_logoff_att_pump
DROP PROCEDURE sp_logon_att_site
DROP PROCEDURE sp_reinstate_delivery
go 

use msdb
go
exec sp_dropdevice "Enabler"
go
