-- ENABLER DATABASE DOCUMENTATION SCRIPT
--
-- this script adds self-documentation attributes to the Enabler database entities
-- for information about the database schema refer to our SDK documentation
--
-- $Header: /Enabler/Data Model/DBU 4.0/EnablerDBDoc.sql 52    22/11/18 9:26a Build-enabler $
--
-- this script CANNOT be used on SQL2000 - it requires SQL 2005+ 

-- remove existing database extended property
BEGIN
	DECLARE @DYNSQL NVARCHAR(3900)
	SELECT @DYNSQL = 'EXEC sys.sp_dropextendedproperty @name = ''' + REPLACE(CAST(SEP.name AS NVARCHAR(300)),'''','''''') + ''''
	  FROM sys.extended_properties SEP
	 WHERE class_desc = N'DATABASE'
	-- print @DYNSQL
	EXECUTE sp_executesql @DYNSQL
END
go

-- add a fresh one
EXEC sys.sp_addextendedproperty 
 @name = N'EnablerDB', 
 @value= N'The Enabler Database stores configuration and historic data for a site forecourt.'
go

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'setTableDesc' AND type = 'P')
   DROP PROCEDURE setTableDesc
go

CREATE PROCEDURE setTableDesc
 @TableName as nvarchar(128),
 @Summary as nvarchar(3500)
as
begin
	DECLARE @DYNSQL NVARCHAR(3900)

	print ''
	print 'Add table doc: '+@TableName
	
	select @DYNSQL = 'EXEC sp_dropextendedproperty @name = '''+xp.name+''',@level0type = ''schema'',@level0name = ''' + object_schema_name(xp.major_id) + ''',@level1type = ''table'',@level1name = ''' + @TableName + ''''
	  from sys.extended_properties xp
	  join sys.tables t on xp.major_id = t.object_id
	 where xp.class_desc = 'OBJECT_OR_COLUMN'
	   and t.name = @TableName
	   and xp.minor_id = 0
	EXECUTE sp_executesql @DYNSQL

	set @DYNSQL = N'EXEC sys.sp_addExtendedProperty @name = N''MS_Description'', @value = ''' + @Summary + ''', @level0type = N''SCHEMA'', @level0name = dbo, @level1type = N''TABLE'',  @level1name = ' + @TableName + ';'
	EXECUTE sp_executesql @DYNSQL
end
go

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'setColumnDesc' AND type = 'P')
   DROP PROCEDURE setColumnDesc
go

CREATE PROCEDURE setColumnDesc
 @TableName as nvarchar(128),
 @ColumnName as nvarchar(128),
 @Summary as nvarchar(3500)
as
begin
	DECLARE @DYNSQL NVARCHAR(3900)

	print 'Add column doc: '+@TableName+'.'+@ColumnName

   	select @DYNSQL = 'EXEC sp_dropextendedproperty @name = '''+sys.extended_properties.name+''' ,@level0type = ''schema'' ,@level0name = ''' + object_schema_name(extended_properties.major_id) + ''' ,@level1type = ''table'' ,@level1name = ''' + object_name(extended_properties.major_id) + ''' ,@level2type = ''column'' ,@level2name = ''' + columns.name + ''''
	  from sys.extended_properties
	  join sys.columns
	    on columns.object_id = extended_properties.major_id
	   and columns.column_id = extended_properties.minor_id
	 where extended_properties.class_desc = 'OBJECT_OR_COLUMN'
	   and columns.name = @ColumnName
	   and object_name(columns.object_id) = @TableName
	   and extended_properties.minor_id > 0
	EXECUTE sp_executesql @DYNSQL

	set @DYNSQL = N'EXEC sys.sp_addExtendedProperty @name = N''MS_Description'', @value = ''' + @Summary + ''', @level0type = N''SCHEMA'', @level0name = dbo, @level1type = N''TABLE'',  @level1name = ' + @TableName + ', @level2type = N''COLUMN'', @level2name = ' + @ColumnName + ';'
	EXECUTE sp_executesql @DYNSQL
end
go


--------------------------------------------------------------------------------
-- Attendant table 
EXEC SetTableDesc N'Attendant', N'Stores details of people who work at the site as Forecourt Attendants.'

EXEC SetColumnDesc N'Attendant', 'Attendant_ID', N'Private unique identifier for this forecourt attendant.'
EXEC SetColumnDesc N'Attendant', 'Attendant_Name', N'Attendant Name as used on reports.'
EXEC SetColumnDesc N'Attendant', 'Attendant_Logon_ID', N'Configurable username that your application may use to validate Attendant logon.'
EXEC SetColumnDesc N'Attendant', 'Attendant_Number', N'Configurable Number for the Attendant.'
EXEC SetColumnDesc N'Attendant', 'Attendant_Password', N'Configurable password that your application may use to validate Attendant logon.'
EXEC SetColumnDesc N'Attendant', 'Attendant_disabled', N'Indicates the Attendant has been locked out of the system, when set Enabler will not allow the Attendant to LogOn.'
EXEC SetColumnDesc N'Attendant', 'Attendant_Blocked_Reason', N'Indicates the reason the Attendant is blocked.'
EXEC SetColumnDesc N'Attendant', 'Warning_Level', N'Amount of money allowed in cashier bag before Attendant float warning is activated.'
EXEC SetColumnDesc N'Attendant', 'Alarm_Level', N'Amount of money allowed in cashier bag before Attendant is blocked - safedrop required before new deliveries are authorised.'
EXEC SetColumnDesc N'Attendant', 'Deleted', N'The deleted state of the attendant row:<br>
<pre> 1 = Deleted
 0 = Active</pre>'
EXEC SetColumnDesc N'Attendant', 'Attendant_Tag_ID', N'Link to the Attendant Tag assigned to this Attendant.'
EXEC SetColumnDesc N'Attendant', 'Attendant_Tag_Active', N'Indicates whether the Attendant tag is active.<br>
<pre> 1 = Active
 0 = Inactive</pre>'
go

--------------------------------------------------------------------------------
-- Attendant_history table
EXEC SetTableDesc N'Attendant_History', N'This table stores hose historical totals of Forecourt Attendants based on Attendant periods.<br><br>
<b>NOTE:</b><br>
<ol>
 <li>Attendant periods do not work like the site report periods (shift/day/month), and are not closed by the sp_close_period stored procedure.</li>
</ol>'

EXEC SetColumnDesc N'Attendant_history', 'Att_Period_ID', N'Unique identifier that links this history to a specific Attendant_Period.'
EXEC SetColumnDesc N'Attendant_history', 'Attendant_ID', N'Unique identifier that links this history record to the corresponding Attendant.'
EXEC SetColumnDesc N'Attendant_history', 'Attendant_Quantity', N'The total number of deliveries done on this hose during this attendant period and that were cleared against the attendant.'
EXEC SetColumnDesc N'Attendant_history', 'Attendant_Quantity1', N'The total number of deliveries done on this hose during this attendant period and that were cleared against the attendant.'
EXEC SetColumnDesc N'Attendant_history', 'Attendant_Quantity2', N'The total number of deliveries done on this hose during this attendant period and that were cleared against the attendant.'
EXEC SetColumnDesc N'Attendant_history', 'Attendant_Value', N'The total money value of deliveries done on this hose during this attendant period and that were cleared against the attendant.'
EXEC SetColumnDesc N'Attendant_history', 'Attendant_Value1', N'The total money value of 1st base grade in deliveries done on this hose during this attendant period and that were cleared against the attendant.'
EXEC SetColumnDesc N'Attendant_history', 'Attendant_Value2', N'The total money value of 2nd base grade in deliveries done on this hose during this attendant period and that were cleared against the attendant.'
EXEC SetColumnDesc N'Attendant_history', 'Attendant_Volume', N'The total volume of deliveries done on this hose during this attendant period and that were cleared against the attendant.'
EXEC SetColumnDesc N'Attendant_history', 'Attendant_Volume1', N'The total volume of 1st base grade in deliveries done on this hose during this attendant period and that were cleared against the attendant.'
EXEC SetColumnDesc N'Attendant_history', 'Attendant_Volume2', N'The total volume of 2nd base grade in deliveries done on this hose during this attendant period and that were cleared against the attendant.'
EXEC SetColumnDesc N'Attendant_history', 'Hose_ID', N'Unique identifier that links this record to the hose that made these deliveries.'
EXEC SetColumnDesc N'Attendant_history', 'Quantity_Total', N'The total number of deliveries done on this hose during this attendant period.'
EXEC SetColumnDesc N'Attendant_history', 'Quantity_Total1', N'The total number of deliveries done on this hose for the 1st base grade during this attendant period.'
EXEC SetColumnDesc N'Attendant_history', 'Quantity_Total2', N'The total number of deliveries done on this hose for the 1st base grade during this attendant period.'
EXEC SetColumnDesc N'Attendant_history', 'Value_Total', N'The total money value of deliveries done on this hose during this attendant period.'
EXEC SetColumnDesc N'Attendant_history', 'Value_Total1', N'The total money value of 1st base grade in deliveries done on this hose during this attendant period.'
EXEC SetColumnDesc N'Attendant_history', 'Value_Total2', N'The total money value of 2nd base grade in deliveries done on this hose during this attendant period.'
EXEC SetColumnDesc N'Attendant_history', 'Volume_Total', N'The total volume of deliveries done on this hose during this attendant period.'
EXEC SetColumnDesc N'Attendant_history', 'Volume_Total1', N'The total volume of 1st base grade in deliveries done on this hose during this attendant period.'
EXEC SetColumnDesc N'Attendant_history', 'Volume_Total2', N'The total volume of 2nd base grade in deliveries done on this hose during this attendant period.'
EXEC SetColumnDesc N'Attendant_history', 'Att_Open_Meter_Value', N'The electronic money meter reading at the start of the attendant period.'
EXEC SetColumnDesc N'Attendant_history', 'Att_Close_Meter_Value', N'The electronic money meter reading at the end of the attendant period.'
EXEC SetColumnDesc N'Attendant_history', 'Att_Open_Meter_Volume', N'The electronic money volume reading at the start of the attendant period.'
EXEC SetColumnDesc N'Attendant_history', 'Att_Close_Meter_Volume', N'The electronic volume meter reading at the end of the attendant period.'
go
--------------------------------------------------------------------------------
-- Attendant_Period table
EXEC SetTableDesc N'Attendant_Period', 'This table stores Forecourt Attendant periods, and indicates the status of each.'

EXEC SetColumnDesc N'Attendant_Period', 'Att_Period_ID','identifier for this attendant period.'
EXEC SetColumnDesc N'Attendant_Period', 'Attendant_ID','identifier of the attendant that owns this attendant period.'
EXEC SetColumnDesc N'Attendant_Period', 'Att_Period_State', 'The state of the period<br>
<pre> 1 = Open
 2 = Closed
 3 = Reconciled</pre>'
EXEC SetColumnDesc N'Attendant_Period', 'Att_Period_Open_DT', 'The date and time that this attendant period began. '
EXEC SetColumnDesc N'Attendant_Period', 'Att_Period_Close_DT','datetime  The date and time that this attendant period was closed. If this period is open this column will contain NULL.'
EXEC SetColumnDesc N'Attendant_Period', 'Att_Period_Number','A public number that identifies this period, it is incremented each time a new attendant period is opened. '
EXEC SetColumnDesc N'Attendant_Period', 'Att_Logged_On','This field indicates whether the attendant is currently logged on. '
go

--------------------------------------------------------------------------------
-- Attendant_Period_History table
EXEC SetTableDesc N'Attendant_Period_History', 'This table is used to store the opening float and final (counted) amount for each payment type in an Attendant Period.'

EXEC SetColumnDesc N'Attendant_Period_History', 'Attendant_Period_History_ID','Unique private identifier of this record. '
EXEC SetColumnDesc N'Attendant_Period_History', 'Att_Period_ID','A link to the Attendant_Period that this record relates to. '
EXEC SetColumnDesc N'Attendant_Period_History', 'Payment_Type_ID','Provided for Enabler Client applications to store reference to a payment type in your application '
EXEC SetColumnDesc N'Attendant_Period_History', 'Att_Period_History_Initial_Float','Stores the opening (float) amount for this payment type. '
EXEC SetColumnDesc N'Attendant_Period_History', 'Att_Period_History_Amount_Counted','Stores the cash amount counted for the attendant at the end of the period - for Attendant reconciliation.'
EXEC SetColumnDesc N'Attendant_Period_History', 'Att_Volume_Total','Stores the total deliveried volume for a specific payment type.'
EXEC SetColumnDesc N'Attendant_Period_History', 'Att_Value_Total','Stores the total deliveried value for a specific payment type.'
EXEC SetColumnDesc N'Attendant_Period_History', 'Cash_Payment_Type','A flag indicates the current payment type is a cash payment type.'
go

--------------------------------------------------------------------------------
-- Attendant_Period_Safedrop table
EXEC SetTableDesc N'Attendant_Safedrop', 'This table is used to store the details of each Safedrop made by the Attendant.'

EXEC SetColumnDesc N'Attendant_Safedrop', 'Attendant_Safedrop_ID','Unique private identifier of this record. '
EXEC SetColumnDesc N'Attendant_Safedrop', 'Attendant_Period_History_ID','A link to the Attendant_Period_History that this record relates to. The Attendant_Period_History table record contains the opening float and closing amounts for the Attendant Period.'
EXEC SetColumnDesc N'Attendant_Safedrop', 'Att_Safedrop_DateTime','The date/time this safedrop is entered '
EXEC SetColumnDesc N'Attendant_Safedrop', 'Att_Safedrop_Amount','This field stores the money value of the safedrop '
EXEC SetColumnDesc N'Attendant_Safedrop', 'Att_Safedrop_Transaction_ID','This field is provided to allow each saferop to be linked back to the transaction number in your audit trail. '
go

--------------------------------------------------------------------------------
-- Audit_Trace table
EXEC SetTableDesc N'AuditTrace', 'This table can be used to record changes to system data or configuration for audit trail use. By default this table is not used, but can be used for specific site systems as required.'
EXEC SetColumnDesc N'AuditTrace', 'Type','Indicates whether the update was an update, insert or delete operation.'
EXEC SetColumnDesc N'AuditTrace', 'TableName','The name of the table updated.'
EXEC SetColumnDesc N'AuditTrace', 'PK','The primary key value for the row modified'
EXEC SetColumnDesc N'AuditTrace', 'Changes','Description of the change.'
EXEC SetColumnDesc N'AuditTrace', 'UpdateDate','Date the change was made'
EXEC SetColumnDesc N'AuditTrace', 'HostName','The network name of the computer that made the change.'
EXEC SetColumnDesc N'AuditTrace', 'UserName','The username or login under which the changes were made.'
EXEC SetColumnDesc N'AuditTrace', 'Result',''

--------------------------------------------------------------------------------
-- Detected_Tank_Delivery table
EXEC SetTableDesc N'Detected_Tank_Delivery' , '<p>This table contains the details of tank deliveries (fuel pumped into the site tanks from a distribution tanker), as detected automatically by the tank gauge and download by Enabler periodically. This requires a genuine Veeder-Root gauge, connected via a PC serial port (not an Enabler card port).</p>
<p><b>Important Note</b>: Do not modify the date-time fields for existing records, as they are used to prevent duplicate copies of tank deliveries being stored.</p>
<p>You should normally use the <b>temperature-compensated</b> volumes for any calculations, as they adjust for the change in density of the fuel as temperature changes. The temperature compensated figures are generated by the gauge, not the Enabler.</p>
<p>There is currently no interaction between this table and the manual Tank_Delivery table.</p>
<p>* Heights and water heights may be zero if the gauge does not support these features.</p>'

EXEC SetColumnDesc N'Detected_Tank_Delivery', 'Detected_Tank_Delivery_ID','Unique private identifier given to the delivery by the Enabler when the delivery is downloaded from the Tank Gauge. Note this is allocated by Enabler, not the gauge. '
EXEC SetColumnDesc N'Detected_Tank_Delivery', 'Tank_ID','A link to the Tank that received the delivery. Note: this is not the same as the tank number in the gauge. '
EXEC SetColumnDesc N'Detected_Tank_Delivery', 'Start_Date_Time','The time and date that the delivery began. '
EXEC SetColumnDesc N'Detected_Tank_Delivery', 'End_Date_Time','The time and date that the delivery ended. '
EXEC SetColumnDesc N'Detected_Tank_Delivery', 'Start_TC_Volume','The temperature-compensated volume of fuel in the tank at the start of the delivery. '
EXEC SetColumnDesc N'Detected_Tank_Delivery', 'End_TC_Volume','The temperature-compensated volume of fuel in the tank at the end of the delivery. '
EXEC SetColumnDesc N'Detected_Tank_Delivery', 'Start_Volume','The volume of fuel in the tank at the start of the delivery. You should normally use the temperature compensated volume instead of this one. '
EXEC SetColumnDesc N'Detected_Tank_Delivery', 'End_Volume','The volume of fuel in the tank at the end of the delivery. You should normally use the temperature compensated volume instead of this one. '
EXEC SetColumnDesc N'Detected_Tank_Delivery', 'Start_Temperature','The temperature of the fuel in the tank at the start of the delivery. '
EXEC SetColumnDesc N'Detected_Tank_Delivery', 'End_Temperature','The temperature of the fuel in the tank at the end of the delivery. '
EXEC SetColumnDesc N'Detected_Tank_Delivery', 'Start_Water','The height of water in the tank at the start of the delivery. * '
EXEC SetColumnDesc N'Detected_Tank_Delivery', 'End_Water','The height of water in the tank at the end of the delivery. * '
EXEC SetColumnDesc N'Detected_Tank_Delivery', 'Start_Height','The total height of liquid (fuel plus water, if any) in the tank at the start of the delivery. * '
EXEC SetColumnDesc N'Detected_Tank_Delivery', 'End_Height','The total height of liquid in the tank at the end of the delivery. * '
EXEC SetColumnDesc N'Detected_Tank_Delivery', 'Product_Code','The text product code returned by the tank gauge, if configured. This is not used by Enabler in identifying the tank or product. '

go


--------------------------------------------------------------------------------
-- Device_Type table
EXEC SetTableDesc N'Device_Type' , 'This table contains a list of predefined device types used to record Forecourt and System events. See the <a href=
"EnablerDB_db~s-dbo~t-Event_Journal.html">Event_Journal</a> and <a href=
"EnablerDB_db~s-dbo~t-Event_Type.html">Event_Type</a> tables for more information.<br><br>

The following topics document the pre-defined device and event types:</br>
&nbsp;&nbsp;<a href="Event Types.html">Event Types</a><br>
&nbsp;&nbsp;<a href="Device Types.html">Device Types</a>
'

EXEC SetColumnDesc N'Device_Type','Device_Type','Public unique key that identifies the type of device - see Description for details.'
EXEC SetColumnDesc N'Device_Type','Device_Name','The name of the device type. '
EXEC SetColumnDesc N'Device_Type','Device_Description','An optional description of the device type. '
go

--------------------------------------------------------------------------------
-- Emulation table
EXEC SetTableDesc N'Emulation' , 'Configuration of Interface drivers to Emulate other Forecourt Controllers.'

EXEC SetColumnDesc N'Emulation', 'Record_ID','Unique ID for the Emulation configuration record'
EXEC SetColumnDesc N'Emulation', 'Protocol_ID','Link to the protocol definition.'
EXEC SetColumnDesc N'Emulation', 'Connection_Type','Specifies the type of communication port used for by the emulation interface driver.'
EXEC SetColumnDesc N'Emulation', 'Comm_Port','Indicates the serial port (if used) for communications.'
EXEC SetColumnDesc N'Emulation', 'Comm_Settings','Contains serial communications parameters where a serial port is used.'
go

--------------------------------------------------------------------------------
-- Enabler_Options table

--EXEC SetTableDesc N'Enabler_Options' , 'The Enabler Options Table determines the allowed functionality of various components of Enabler. It is designed so that there is no User Interface to be able to change the settings. At the moment fields in this table only change the behavour of our pre-build Configuration and Management applications. Further details on the operation and interaction of these tables is after the details of the fields.
--
--All fields are int and non zero values indicate that option is allowed. Zero indicates disallowed.'
--EXEC SetColumnDesc N'Enabler_Options','Options_ID','Unique identifier for this row - not used.'
--EXEC SetColumnDesc N'Enabler_Options','Tank_Delete','Disables the Tank Delete button. '
--EXEC SetColumnDesc N'Enabler_Options','Tank_Add','Disables the Tank Add button. '
--EXEC SetColumnDesc N'Enabler_Options','Tank_Edit','Makes the Tanks configuration page read-only. '
--EXEC SetColumnDesc N'Enabler_Options','Grade_Delete','Disables the Grade Delete button. '
--EXEC SetColumnDesc N'Enabler_Options','Grade_Add','Disables the Grade Add button. '
--EXEC SetColumnDesc N'Enabler_Options','Grade_Edit','Makes the Grades configuration page read-only. '
--EXEC SetColumnDesc N'Enabler_Options','Pump_Delete','Disables the Pump Ddelete button '
--EXEC SetColumnDesc N'Enabler_Options','Pump_Add','Disables the Pump Add button. '
--EXEC SetColumnDesc N'Enabler_Options','Pump_Edit','Makes the pump configuration page read-only. '
--EXEC SetColumnDesc N'Enabler_Options','Hose_Delete','Disables the Hose Delete button. '
--EXEC SetColumnDesc N'Enabler_Options','Hose_Add','Disables the Hose Add Button '
--EXEC SetColumnDesc N'Enabler_Options','Level_Delete','Disables the Delete Level button (Grade pricing tab). '
--EXEC SetColumnDesc N'Enabler_Options','Level_Add','Disables the Add Level button (Grade pricing tab). '
--EXEC SetColumnDesc N'Enabler_Options','Mode_Delete','Disables the Delete Site Mode and Delete Profile buttons. '
--EXEC SetColumnDesc N'Enabler_Options','Mode_Add','Disables the Add Site Mode and Add Profile buttons. '
--EXEC SetColumnDesc N'Enabler_Options','Mode_Edit','Makes the Site Mode and Add Profile configuration read-only. '
--EXEC SetColumnDesc N'Enabler_Options','Port_Config','Makes the Ports tab read only '
--EXEC SetColumnDesc N'Enabler_Options','Emulation_Config','Disables setting up Emulation loops. '
--EXEC SetColumnDesc N'Enabler_Options','OPT_Config','Disables the OPT tab. '
--EXEC SetColumnDesc N'Enabler_Options','OPT_Delete','Disables the Delete OPT button. '
--EXEC SetColumnDesc N'Enabler_Options','OPT_Add','Disables the Add OPT button. '
--EXEC SetColumnDesc N'Enabler_Options','Price_Edit','Disables editing of Grade prices and also disables changing a Grades active price profile. '
--EXEC SetColumnDesc N'Enabler_Options','TG_Config','Disables the Tank Gauge tab. '
--EXEC SetColumnDesc N'Enabler_Options','TG_Delete','Disables the Delete Tank Gauge button. '
--EXEC SetColumnDesc N'Enabler_Options','TG_Add','Disables the Add Tank Gauge button. '
--EXEC SetColumnDesc N'Enabler_Options','Attendant_Delete','Disables the Attendant Delete button. '
--EXEC SetColumnDesc N'Enabler_Options','Attendant_Edit','Makes the Attendant configuration read-only. '
--EXEC SetColumnDesc N'Enabler_Options','Attendant_Add','Disables the Attendant Add button. '
--go


--------------------------------------------------------------------------------
-- Event_Journal table
EXEC SetTableDesc N'Event_Journal' , 'This table records forecourt and system events that occur at the site. See <a href=
"EnablerDB_db~s-dbo~t-Event_Type.html">Event_Type</a> and <a href=
"EnablerDB_db~s-dbo~t-Device_Type.html">Device_Type</a> topics for more information.'

EXEC SetColumnDesc N'Event_Journal', 'Event_ID','Unique private key allocated by the system as events occur. '
EXEC SetColumnDesc N'Event_Journal', 'Event_Type','The event type can be any of those listed in the Event_Type table. '
EXEC SetColumnDesc N'Event_Journal', 'Device_Type','The device type of the device that created the event, as defined in the device type table. '
EXEC SetColumnDesc N'Event_Journal', 'Event_Time_Stamp','Time and date that the event occurred. '
EXEC SetColumnDesc N'Event_Journal', 'Device_ID','Link to ID of the device that created the event. '
EXEC SetColumnDesc N'Event_Journal', 'Device_Number','The logical number of the device that created the event. '
EXEC SetColumnDesc N'Event_Journal', 'Description','More detailed description  used to further describe the event. '
go

--------------------------------------------------------------------------------
-- Event_Type table
EXEC SetTableDesc N'Event_Type' , 'This table contains a list of predefined event types. See <a href=
"EnablerDB_db~s-dbo~t-Event_Journal.html">Event_Journal</a> and <a href=
"EnablerDB_db~s-dbo~t-Device_Type.html">Device_Type</a> for more information.'

EXEC SetColumnDesc N'Event_Type', 'Event_Type','Private unique key for event_type. '
EXEC SetColumnDesc N'Event_Type', 'Event_name','Short name for event. '
EXEC SetColumnDesc N'Event_Type', 'Device_Type','The type of device that creates this type of event. '
EXEC SetColumnDesc N'Event_Type', 'Event_description','Long description for event. '
EXEC SetColumnDesc N'Event_Type', 'Log_event','Whether the event is logged to the event journal or not.<br>
<pre>   0 = No
 &lt;&gt;0 = Yes</pre> '
EXEC SetColumnDesc N'Event_Type', 'Display_event','Whether the event is sent to all psrvr clients to be displayed or not.<br>
<pre>   0 = No
 &lt;&gt;0 = Yes</pre> '
EXEC SetColumnDesc N'Event_Type', 'Event_level','The level of the event:
<pre> 1 = informational
 2 = warning
 3 = alarm</pre>'
go

--------------------------------------------------------------------------------
-- Fuel_Transaction table
EXEC SetTableDesc N'Fuel_Transaction' , 'This table keeps a record of forecourt fueling activity. In contrast to the Hose_Delivery table , rows are instered into this table as soon as a pump is reserved or authorised to deliver, making this table a full record of forecourt control activity including cases where no fuel was delivered.'

EXEC SetColumnDesc N'Fuel_Transaction','Transaction_ID','Internal identifier for this fuel transaction.'
EXEC SetColumnDesc N'Fuel_Transaction','Pump_ID','Internal identifier for the pump where this transaction occurred.'
EXEC SetColumnDesc N'Fuel_Transaction','Client_Reference','Optional application-specific data provided by the client application using the Enabler API.'
EXEC SetColumnDesc N'Fuel_Transaction','Client_Activity','Optional application-specific data to indicate the type of transaction (e.g. Prepay or Preset).'
EXEC SetColumnDesc N'Fuel_Transaction','State','State of the fuelling transaction:<br>
<pre> 1 = Initialising
 2 = Reserved
 3 = Cancelled
 4 = Authorised
 5 = Fuelling
 6 = Completed
 7 = Cleared
</pre>'
EXEC SetColumnDesc N'Fuel_Transaction','Delivery_ID','The ID of the related row in the Hose_Delivery table.'
EXEC SetColumnDesc N'Fuel_Transaction','Money_Limit','Money limit for the transaction (optional).'
EXEC SetColumnDesc N'Fuel_Transaction','Volume_Limit','Volume/Quantity limit for the transaction (optional).'
EXEC SetColumnDesc N'Fuel_Transaction','Attendant_ID','The ID of the authorising Attendant (optional)'
EXEC SetColumnDesc N'Fuel_Transaction','ReservedBy_ID','The ID of the terminal that reserved the pump for this transaction. Where the pump was not reserved this field will be -1.'
EXEC SetColumnDesc N'Fuel_Transaction','Reserved_DateTime','The date/time the pump was reserved for a transaction (start of the transaction).'
EXEC SetColumnDesc N'Fuel_Transaction','Reserved_Type','Indicates the current type of reserve applying to this transaction (for internal use).'
EXEC SetColumnDesc N'Fuel_Transaction','AuthorisedBy_ID','The ID of the Terminal that authorised this transaction. For transactions authorised by Pump Server the ID will be -1.'
EXEC SetColumnDesc N'Fuel_Transaction','Authorised_DateTime','The date/time the pump was authorised to deliver fuel.'
EXEC SetColumnDesc N'Fuel_Transaction','Authorisation_Reason','Indicates how the pump was authorised to begin fuelling:<br>
<pre> 0 = Not authorised
 1 = Authorised by API
 2 = Attendant authorised
 3 = Monitor (by Pump Server)
 4 = Auto Auth (by Pump Server)
 5 = Fallback (by Pump Server)
 6 = Pump self authorised
 7 = Authorised by External Tag read
</pre>'
EXEC SetColumnDesc N'Fuel_Transaction','Completion_Reason','Indicates how the transaction was completed:<br>
<pre> 0 = Not Complete
 1 = Cancelled before nozzle lift
 2 = Timeout of Auth before nozzle lift
 3 = Normal nozzle hung up
 4 = No fuel was delivered
 5 = Delivery stopped through API
 6 = Authorised limit reached
 7 = Stopped due to error
 8 = Offline delivery
</pre>'
EXEC SetColumnDesc N'Fuel_Transaction','Max_Flow_Rate','The peak flow rate in units per minute (e.g. litres per minute) observed during the transaction. This data is derived from running totals readings, and is <b>provided for statistical use only</b>.'
EXEC SetColumnDesc N'Fuel_Transaction','Tag_Data','The external Tag Data that authorised the transaction.'
go

--------------------------------------------------------------------------------
-- Global_Settings table
EXEC SetTableDesc N'Global_Settings' , '<p>This table stores general settings used by system for operation.</p>
<p>In v4 the following fields have been moved to other tables:<br>
&nbsp;Pump_Stack_Size (moved to Pump_Profile)<br>
&nbsp;Tank_gauge_type (configured in Tank_Gauge)<br>
&nbsp;Tank_gauge_pars (configured in Tank_Gauge)<br></p>
<p>And the following fields have been removed (obsolete):<br>
&nbsp;Exported<br>
&nbsp;Export_Required<br>
&nbsp;Max_Dels_In_Prog<br>
&nbsp;Minimum_Del_Volume</p>'

EXEC SetColumnDesc N'Global_Settings', 'Site_ID','Private unique key used to identify this site, this is for future development where more one site may be linked into one logical system  '
EXEC SetColumnDesc N'Global_Settings', 'Site_Name','A short name used by the system operator to identify the site.'
EXEC SetColumnDesc N'Global_Settings', 'Site_Profile_ID','The ID identifying which site profile record is currently being used '
EXEC SetColumnDesc N'Global_Settings', 'Prepay_Reserved_TO','The maximum time in seconds that a pump will remain authorised for a prepay delivery without starting the delivery. If this timeout is reached the reserve on the pump is removed, and a prepay refund delivery for the total amount is generated '
EXEC SetColumnDesc N'Global_Settings', 'Prepay_Refund_TO','The timeout in seconds that a prepay refund locks out the pump. Default value 180 ie. three minutes. During this time the customer is able to return to the shop and retrieve their refund after this the refund is cleared automatically from the pump and the pump is released.  '
EXEC SetColumnDesc N'Global_Settings', 'Prepay_Taken_TO','The time in seconds that the pump remains locked out after the prepay refund is taken by the customer. The actual timeout is this value less the time that the prepay refund was on the pump before the customer took it. The purpose of this timeout is to prevent operator fraud.  '
EXEC SetColumnDesc N'Global_Settings', 'Preauth_Rsvd_TO','The maximum time (seconds) that a pump remains authorised for a Preauth delivery without starting the delivery. When the timeout is reached the reserve on the pump is removed, and the pump returns to the locked state. '
EXEC SetColumnDesc N'Global_Settings', 'Authorized_Timeout','The time that a compulsory authorise pump will remain authorised after being authorised by an operator without the customer starting a delivery.'
EXEC SetColumnDesc N'Global_Settings', 'Monitor_Del_TO','The time in seconds that a delivery will remain before being automatically cleared as a Monitor delivery (if Monitor deliveries are enabled).<br>
Also the time in seconds that an Attendant or Attendant Tag authorised delivery will remain before being automatically cleared as an Attendant delivery.'
EXEC SetColumnDesc N'Global_Settings', 'PVT_on','No longer supported. A flag to turn PVT totalling on/off.<br>
<pre> 0 = off
 1 = on</pre>'
EXEC SetColumnDesc N'Global_Settings', 'Delivery_Idle_TO','The maximum time in seconds of a hose being out and idle before the pump goes into hose_left_out state '
EXEC SetColumnDesc N'Global_Settings', 'Event_keep_days','The number of days to retain events in the events journal. '
EXEC SetColumnDesc N'Global_Settings', 'Hose_del_keep_days','The number of days to retain hose deliveries, int the hose_deliveries table. '
EXEC SetColumnDesc N'Global_Settings', 'Tank_del_keep_days','The number of days to retain tank deliveries, int the tank_deliveries table. '
EXEC SetColumnDesc N'Global_Settings', 'Attendant_support','Is the attendant mode supported on this site.<br>
<pre>   0 = no
 <> 0 = yes
</pre>
If no the Attendants screen is disabled. '
EXEC SetColumnDesc N'Global_Settings', 'Att_keep_days','The number of days to keep closed attendant periods on the system. '
EXEC SetColumnDesc N'Global_Settings', 'Delivery_Age_TO','The maximum number of seconds of age for an unpaid delivery before it is displayed in red indicating that this is a possible drive off. '
EXEC SetColumnDesc N'Global_Settings', 'Tank_Dips','Does the Fuel Reconciliation Application require/permit the entry of manual tank dips. '
EXEC SetColumnDesc N'Global_Settings', 'Tank_Drops','Does the Fuel Reconciliation Application require/permit the entry of tank drops.  '
EXEC SetColumnDesc N'Global_Settings', 'Pump_Meters','Does the Fuel Reconciliation Application require/permit the entry of the pump mechanical meter reads '
EXEC SetColumnDesc N'Global_Settings', 'Delivering_NR_TO','If a pump is delivering and goes to not responding state, if the pump is still not responding after this timeout expires a delivery will automatically be created from the most recent running total. Set to 0 to disable. It is recomended that this field is left at the default of zero. '
EXEC SetColumnDesc N'Global_Settings', 'Prepay_Refund_Type','Reserved for future implementation. This field will set the style of (Legacy) Prepay Refund calculations. The value zero indicates that the standard calculation method is to be used, this is the most compatible with existing applications making use of the EnbPumpX. 1 indicates that the new method of calculation is used. Consult the Programers Reference for information on how this affects the use of Enabler ActiveX controls or Legacy Prepays on the new API. '
EXEC SetColumnDesc N'Global_Settings', 'Auto_Modes_On','Indicates if Enabler is currently Automatically performing switching between Mode Profiles based on the Start/End and Valid days settings. '
EXEC SetColumnDesc N'Global_Settings', 'Recon_Edits_Allowed','Indicates whether Fuel Reconciliation allows edits to already reconciled periods. '
EXEC SetColumnDesc N'Global_Settings', 'Recon_Report_Format','Indicates which report format Fuel Reconciliation should use when viewing and printing reconciations. Default: 2.<br><br>The valid values are:<br>
<ul>
 <li>0 = Old Detailed Tank data report (requires FuelReconReport.exe)</li>
 <li>2 = Daily Tank Reconciliation Report (Default).</li>
</ul> '
EXEC SetColumnDesc N'Global_Settings', 'Recon_Export_Type','Reserved for future use - exporting of Fuel Reconciliation data. '
EXEC SetColumnDesc N'Global_Settings', 'Recon_Export_Mandatory','Reserved for future use - will determine whether Fuel Reconciliation can exit with a reconciled period that has not yet been exported. '
EXEC SetColumnDesc N'Global_Settings', 'Clear_Att_Dels','Indicates if Enabler is currently Automatically clearing attendant deliveries - if you need to generate transactions in your audit trail for attendant deliveries, you can set this to 0. When you do this your application becomes responsible for clearing attendant deliveries. '
EXEC SetColumnDesc N'Global_Settings', 'Price_Level_Control','Indicates if Enabler is currently using Pump Based or Profile Based price level configuration. Setting to zero means Pump Based which is the Enablers existing behavour prior to version 3.40.8. Set this field to 1 for Profile Based price level control - this ignores any price levels configured in the Pumps table. '
EXEC SetColumnDesc N'Global_Settings', 'Offline_Delivery','Indicates if Enabler will create an `Offline Delivery` record for changes in pump meters. '
EXEC SetColumnDesc N'Global_Settings', 'Map_Test_Delivery_To_Tank_Transfer','If set to 1, used by Fuel Reconciliation to allow Test Deliveries to be mapped to Tank Transfers.'
EXEC SetColumnDesc N'Global_Settings', 'Use_Hose_Turn_Over','If set to 1, Pump Server will use Hose Turnover fields. Default is 1. '
EXEC SetColumnDesc N'Global_Settings', 'Approval_Required_for_FuelRecon','If set to 1, Indicates whether an approval is required before publishing Fuel Reconciliation data. '
EXEC SetColumnDesc N'Global_Settings', 'Can_Disable_Hoses_By_Grade','Controls the facility to block grades.<br>
1 (TRUE) = The ability to block grades is active at this site. '
EXEC SetColumnDesc N'Global_Settings', 'Disable_Hose_During_Delivery','Reserved for future implementation. This extends disabling of hoses to stopping deliveries already in progress.<br>
1 (TRUE) = When a hose is disabled (e.g. the cashier blocks a grade that the hose delivers), any delivery in progress at that hose id immediately stopped.<br>
0 (FALSE) = Prevent authorisation of any new delivery attempts but do not interrupt any deliveries already in progress. '
EXEC SetColumnDesc N'Global_Settings', 'Backup_Files','Maximum number of backup files to keep. The backup files archive set is automatically maintained by the backup script.
The backup script will delete all but the n newest files that match the pattern "Enabler_*.dmp", where `n` represents the number of backup files.'
EXEC SetColumnDesc N'Global_Settings', 'Backup_Time','The regular backup time to run the backup script. '
EXEC SetColumnDesc N'Global_Settings', 'Can_Disable_Hoses_By_Tank','This determines whether tanks can be blocked and unblocked.<br>
1 (TRUE) = Tanks can be blocked and unblocked'
EXEC SetColumnDesc N'Global_Settings', 'Disable_Tank_On_Level_Low_Alarm','This determines whether the `Low Level` alarm from a tank gauge will automatically disable/enable a tank.<br>
1 (TRUE) = The tank will be automatically disabled when the `Low Level` alarm is detected, and enabled when the alarm is off (and no tanker delivery is in progress).' 
EXEC SetColumnDesc N'Global_Settings', 'Disable_Tank_On_Tanker_Delivery','This determines whether the detection of a tanker delivery will automatically disable/enable a tank.<br>
1 (TRUE) = The tank will be automatically disabled when a tanker delivery is detected, and enabled when the delivery stops (and the `Low Level` alarm is not active). '
EXEC SetColumnDesc N'Global_Settings', 'Minimum_Etotal_Diff','Site-wide threshold for discrepancies in electronic totals. Discrepancies over this limit are logged by Pump Server as an `offline delivery` record.'
EXEC SetColumnDesc N'Global_Settings', 'Auto_PostMix_Price','Determines whether Enabler automatically calculates post mix pricing using pricing for base grades. When set blend prices may not be set directly.'
EXEC SetColumnDesc N'Global_Settings', 'Price_Calc_Decimals','Where Enabler calculates prices for blended, this site setting indicates the number of decimals for the resulting prices.'
EXEC SetColumnDesc N'Global_Settings', 'Price_Calc_Round_Type','Determines if calculated blend prices are rounded or truncated:<br>
<pre> 0 = Round
 1 = Truncate
</pre>
In both cases the calculations use Price_Calc_Decimals.'
EXEC SetColumnDesc N'Global_Settings', 'Tagging_Support','Determines whether Enabler Attendant Tagging features are active, this applies to both configuration and pump server operation.'
EXEC SetColumnDesc N'Global_Settings', 'Fallback_State','Stores the current state of `Fallback` mode based on other configurations. This facility allows Pump Server to automatically authorise pumps if all client applications go offline.'
EXEC SetColumnDesc N'Global_Settings', 'Reserve_TO','Time in seconds that a Pump Reserve remains in place. After this timeout the Reserve will be cancelled and events fired to connected terminals.'
go

--------------------------------------------------------------------------------
-- Grade_PostMix_Ratio table
EXEC SetTableDesc N'Grade_PostMix_Ratio', 'This table has a row for each valid blend ratio for each grade. Ratios configured here can then have prices assigned per ratio where blend prices are calculated manually. '

EXEC SetColumnDesc N'Grade_PostMix_Ratio', 'Grade_ID','Unique private ID, used to link this grade to other entities. '
EXEC SetColumnDesc N'Grade_PostMix_Ratio', 'Ratio_Index','Logical index for  blend ratio '
EXEC SetColumnDesc N'Grade_PostMix_Ratio', 'Ratio','The blend ratio Grade 1 to Grade 2. For example 80 indicates an 80:20 blend. '

--------------------------------------------------------------------------------
-- Grades table
EXEC SetTableDesc N'Grades', 'This table stores the Grade properties.'

EXEC SetColumnDesc N'Grades', 'Grade_ID','Unique private ID, used to link this grade to other entities  '
EXEC SetColumnDesc N'Grades', 'Grade_Name','A short name used by the system operator to identify this grade. eg "Unleaded", "Super" etc. This is also the name that would be printed on receipts for the customer. '
EXEC SetColumnDesc N'Grades', 'Price_Profile_ID','The ID of the price profile that is currently being used by this grade  '
EXEC SetColumnDesc N'Grades', 'Grade_Description','An optional, longer, more detailed description of the grade.'
EXEC SetColumnDesc N'Grades', 'Allocation_Limit','The allocation limit for this grade, ie. the maximum value or grade, ie. the maximum value or volume that can be delivered in one delivery of this grade. If the allocation limit is "0", this allocation limit is disabled. The allocation limit can be on the volume of the delivery, or the value. Note certain types of pumps do not accept allocation limits. '
EXEC SetColumnDesc N'Grades', 'Alloc_Limit_Type','This determines the type of the allocation limit:<br>
<pre> 0 = No Limit
 1 = By Value
 2 = By Quantity/Volume </pre>'
EXEC SetColumnDesc N'Grades', 'Oil_Company_Code','Optional field for the Oil Company product name or code.  '
EXEC SetColumnDesc N'Grades', 'Tax_Link','Optional link to the tax table of the host system - this defines the tax details for the selling of this grade '
EXEC SetColumnDesc N'Grades', 'Group_Link','An optional link to some form of group table from the host system, this is used to group various grades together for reporting purposes - this may be the departments or table from the host system or similar. '
EXEC SetColumnDesc N'Grades', 'Delivery_Timeout','The maximum time in seconds allowed for a delivery of this grade. Once expired a warning is displayed on the Enabler icon. '
EXEC SetColumnDesc N'Grades', 'Price_Pole_Segment','The segment number for the price of this grade on the price sign. If set to zero the price of this grade is not displayed. '
EXEC SetColumnDesc N'Grades', 'Grade_Type','The type of this grade<br>
<pre> 1 = base grade
 2 = blended grade</pre>'
EXEC SetColumnDesc N'Grades', 'Grade1_ID','If this is a blended grade, this is a link to the first base grade for this blend. Otherwise it is NULL. '
EXEC SetColumnDesc N'Grades', 'Grade2_ID','If this is a blended grade, this is a link to the second base grade for this blend. Otherwise it is NULL. '
EXEC SetColumnDesc N'Grades', 'Blend_Ratio','If this is a blended grade, this is the percentage of the total that is the first base grade. '
EXEC SetColumnDesc N'Grades', 'Grade_Number','External reference for this Grade. '
EXEC SetColumnDesc N'Grades', 'Min_Price','Price halo (low limit) used for validation of prices entered in Enabler Configuration. '
EXEC SetColumnDesc N'Grades', 'Max_Price','Price halo (upper limit) used for validation of prices entered in Enabler Configuration. '
EXEC SetColumnDesc N'Grades', 'Loss_Tolerance','Wet Stock Reconciliation tolerance - a percentage of product turnover (sales). Defaults to 0.50.
This value is used in the Fuel Reconciliation report to highlight where the variance is outside tolerance. The variance is the difference between Net volume change and Change in Measured Tank Volume (e.g. Dips). '
EXEC SetColumnDesc N'Grades', 'Gain_Tolerance','Wet Stock Reconciliation tolerance. Defaults to 0.25. See Loss_Tolerance. '
EXEC SetColumnDesc N'Grades', 'Is_Enabled','The blocked state of this grade.<br>
0 (FALSE) = This grade has been manually blocked. '
EXEC SetColumnDesc N'Grades', 'Deleted','The deleted state of the grade:<br>
<pre> 1 = Deleted
 0 = Active</pre> '
EXEC SetColumnDesc N'Grades', 'Volume_Unit_ID','The ID of the Volume_Unit that is currently being used by this grade. '
go

--------------------------------------------------------------------------------
-- Hose_Delivery table
EXEC SetTableDesc N'Hose_Delivery' , 'This table stores the hose deliveries recorded.'

EXEC SetColumnDesc N'Hose_Delivery', 'Delivery_ID','Unique identifier allocated by the system when the delivery is logged. '
EXEC SetColumnDesc N'Hose_Delivery', 'Hose_ID','A link to the Hose that made this delivery. '
EXEC SetColumnDesc N'Hose_Delivery', 'Attendant_ID','The ID of the Attendant that was logged onto this pump when this delivery was taken. If this pump was not in attendant mode when this delivery was done, this column will be NULL. '
EXEC SetColumnDesc N'Hose_Delivery', 'Price_Level','The price level on the pump that this delivery was taken at. '
EXEC SetColumnDesc N'Hose_Delivery', 'Completed_TS','The time and date this delivery was completed. ie. as close as possible to when the hose was hung up. '
EXEC SetColumnDesc N'Hose_Delivery', 'Cleared_Date_Time','The time and date that this delivery was cleared from the system. ie. when a transaction containing this delivery was finalised. This value is only relevant for post pay deliveries. '
EXEC SetColumnDesc N'Hose_Delivery', 'Delivery_Type','Indicates the type and status of the delivery. Refer to The Enabler Programmers Reference for a description of the valid values for Delivery.Type.
See <a href="Delivery Types.html">Delivery Types</a> '
EXEC SetColumnDesc N'Hose_Delivery', 'Delivery_State','The state of the pump at the end of this delivery - the normal state is "delivery finished". However in error states it may be delivery overrun , prepay refund etc '
EXEC SetColumnDesc N'Hose_Delivery', 'Delivery_Volume','The total volume of the delivery. The units are as defined in the Windows Regional Settings. For a blended delivery this will be the total of both grades volumes dispensed. This ensures that no matter what the delivery type this is always the total volume. '
EXEC SetColumnDesc N'Hose_Delivery', 'Delivery_Value','The total price of the delivery. '
EXEC SetColumnDesc N'Hose_Delivery', 'Delivery1_Value','The contribution to Delivery_Value by the first base grade. '
EXEC SetColumnDesc N'Hose_Delivery', 'Delivery2_Value','The contribution to Delivery_Value by the second base grade. '
EXEC SetColumnDesc N'Hose_Delivery', 'Del_Sell_Price','The unit sell price for the delivery as reported by the pump. Note that if the pump supports setting the price locally the delivery_sell_price may be different from the price set for the relevant Grade.  '
EXEC SetColumnDesc N'Hose_Delivery', 'Del_Cost_Price','The unit cost price for the delivery (calculated).  '
EXEC SetColumnDesc N'Hose_Delivery', 'Grade1_Price','The unit price for the first base grade. Zero for non-blend deliveries. '
EXEC SetColumnDesc N'Hose_Delivery', 'Grade2_Price','The unit price for the second base grade. Zero for non-blend deliveries. '
EXEC SetColumnDesc N'Hose_Delivery', 'Cleared_By','The unit identifier of the POS or Card terminal that cleared this delivery. Note that for monitor deliveries this field will be null. '
EXEC SetColumnDesc N'Hose_Delivery', 'Reserved_By','The unit identifier of the POS or Card terminal that reserved this delivery. Note that for most deliveries this field will be null. '
EXEC SetColumnDesc N'Hose_Delivery', 'Transaction_ID','The ID of the transaction that includes the delivery. This is an optional field and is only used by a host program if necessary. This field is not used by The Enabler applications. '
EXEC SetColumnDesc N'Hose_Delivery', 'Del_Item_Number','Optional field for use by host application. This field is not used by The Enabler applications. '
EXEC SetColumnDesc N'Hose_Delivery', 'Delivery1_Volume','The volume of the first base grade for a delivery of on a logical nozzle.'
EXEC SetColumnDesc N'Hose_Delivery', 'Delivery2_Volume','The volume of the second base grade for a delivery of on a logical nozzle. Note that the volume of the first grade is<br>
<pre>Delivery_Volume - Delivery2_volume</pre>'
EXEC SetColumnDesc N'Hose_Delivery', 'Hose_Meter_Volume','The electronic volume meter of this hose at the end of this delivery. If the pump does not support electronic meters this value will be zero. The field is only populated with values that have been retreived from the pump. '
EXEC SetColumnDesc N'Hose_Delivery', 'Hose_Meter_Volume1','The electronic volume meter for the first base grade on this hose at the end of this delivery. This field is only used for Post Mix Blending pumps (where the meters measure fuel before blending), refer to the Blend_Type field in the Hoses table for more information. For all other pump types the field will be zero. '
EXEC SetColumnDesc N'Hose_Delivery', 'Hose_Meter_Volume2','The electronic volume meter for the second base grade on this hose at the end of this delivery. This field is only used for Post Mix Blending pumps (where the meters measure fuel before blending), refer to the Blend_Type field in the Hoses table for more information. For all other pump types the field will be zero. '
EXEC SetColumnDesc N'Hose_Delivery', 'Hose_Meter_Value','The electronic value meter of this hose at the end of this delivery. If the pump does not support electronic meters this value will be zero. The field is only populated with values that have been retreived from the pump. '
EXEC SetColumnDesc N'Hose_Delivery', 'Hose_Meter_Value1','The electronic value meter for the first base grade on this hose at the end of this delivery. This field is only used for Post Mix Blending pumps (where the meters measure fuel before blending), refer to the Blend_Type field in the Hoses table for more information. For all other pump types the field will be zero. '
EXEC SetColumnDesc N'Hose_Delivery', 'Hose_Meter_Value2','The electronic value meter for the second base grade on this hose at the end of this delivery. This field is only used for Post Mix Blending pumps (where the meters measure fuel before blending), refer to the Blend_Type field in the Hoses table for more information. For all other pump types the field will be zero. '
EXEC SetColumnDesc N'Hose_Delivery', 'Blend_Ratio','Indicates the blend ratio selected for this delivery. For non-blending pumps this field will be zero (0). '
EXEC SetColumnDesc N'Hose_Delivery', 'Previous_Delivery_Type','When a delivery is reinstated, this field stores the original delivery type (prior to reinstating). If the reinstate process is cancelled the delivery is set back to this type. '
EXEC SetColumnDesc N'Hose_Delivery', 'Auth_Ref','Reserved for future use. '
go

--------------------------------------------------------------------------------
-- Hose_History table
EXEC SetTableDesc N'Hose_History' , 'This table stores the historical total of hose deliveries based on periods.'

EXEC SetColumnDesc N'Hose_History', 'Hose_ID','Link to the hose that owns this history record  '
EXEC SetColumnDesc N'Hose_History', 'Period_ID','Link to the period that contains this history record  '
EXEC SetColumnDesc N'Hose_History', 'Open_Meter_Value','The value of the electronic meter for this hose when the record was opened. Note this value will only be defined if the pump that owns the hose supports electronic totals, otherwise the contents will be null. '
EXEC SetColumnDesc N'Hose_History', 'Close_Meter_Value','The value of the electronic totals when the record was closed, if the record is open this field will be null. '
EXEC SetColumnDesc N'Hose_History', 'Open_Meter_Volume','The value of the electronic volume meter for this hose when the record was opened. Note this value will only be defined if the pump that owns the hose supports electronic totals, otherwise the contents will be null. '
EXEC SetColumnDesc N'Hose_History', 'Close_Meter_Volume','The value of the electronic volume meter when the record was closed, if the record is open the contents will be null. '
EXEC SetColumnDesc N'Hose_History', 'Open_Volume_Turnover_Correction','The volume turnover calculation value for the hose when the period was opened. '
EXEC SetColumnDesc N'Hose_History', 'Close_Volume_Turnover_Correction','The volume turnover calculation value for the hose when the period was closed. If the period is still open, the value for this field is null. '
EXEC SetColumnDesc N'Hose_History', 'Open_Money_Turnover_Correction','The value turnover calculation value for the hose when the period was opened. '
EXEC SetColumnDesc N'Hose_History', 'Close_Money_Turnover_Correction','The value turnover calculation value for the hose when the period was closed. If the period is still open, the value for this field is null. '
EXEC SetColumnDesc N'Hose_History', 'Open_Volume_Turnover_Correction2','The volume2 turnover calculation value for the hose when the period was opened. '
EXEC SetColumnDesc N'Hose_History', 'Close_Volume_Turnover_Correction2','The volume2 turnover calculation value for the hose when the period was closed. If the period is still open, the value for this field is null. '
EXEC SetColumnDesc N'Hose_History', 'Postpay_Value','The total monetary value of all the postpay deliveries done on this hose since the record was opened. '
EXEC SetColumnDesc N'Hose_History', 'Postpay_Quantity','The number of postpay deliveries done on this hose since the record was opened. '
EXEC SetColumnDesc N'Hose_History', 'Postpay_Volume','The total volume of all postpay deliveries done on this hose since the record was opened, in the units defined in the global settings. '
EXEC SetColumnDesc N'Hose_History', 'Postpay_Cost','The total monetary cost of all the postpay deliveries done on this hose since the record was opened. The cost price is derived from the corresponding average cost column from the tank table, multiplied by the volume of each delivery. '
EXEC SetColumnDesc N'Hose_History', 'Prepay_Quantity','The number of Prepay deliveries done on this hose since the record was opened. '
EXEC SetColumnDesc N'Hose_History', 'Prepay_Value','The total monetary value of all the prepay deliveries done on this hose since the record was opened. '
EXEC SetColumnDesc N'Hose_History', 'Prepay_Volume','The total volume of all prepay deliveries done on this hose since the record was opened, in the units defined in the global settings. '
EXEC SetColumnDesc N'Hose_History', 'Prepay_Cost','The total monetary cost of all the prepay deliveries done on this hose since the record was opened. The cost price is derived from the corresponding average cost column from the tank table, multiplied by from the tank table, multiplied by the volume of each delivery. '
EXEC SetColumnDesc N'Hose_History', 'Prepay_Refund_Qty','The number of claimed Prepay refunds done on this hose since the record was opened.  '
EXEC SetColumnDesc N'Hose_History', 'Prepay_Refund_Val','The total monetary value of all the claimed prepay refunds done on this hose since the record was opened. Note this represents money leaving the system.  '
EXEC SetColumnDesc N'Hose_History', 'Prepay_Rfd_Lst_Qty','The number of unclaimed Prepay refunds done on this hose since the record was opened. '
EXEC SetColumnDesc N'Hose_History', 'Preauth_Quantity','The number of Preauth deliveries done on this hose since the record was opened.  '
EXEC SetColumnDesc N'Hose_History', 'Preauth_Value','The total monetary value of all the Preauth deliveries done on this hose since the record was opened. '
EXEC SetColumnDesc N'Hose_History', 'Prepay_Rfd_Lst_Val','The total monetary value of all the unclaimed prepay refunds done on this hose since the record was opened. Note this represents money leaving the system.  '
EXEC SetColumnDesc N'Hose_History', 'Preauth_Volume','The total volume of all Preauth deliveries done on this hose since the record was opened, in the units defined in the global settings. '
EXEC SetColumnDesc N'Hose_History', 'Preauth_Cost','The total monetary cost of all the Preauth deliveries done on this hose since the record was opened. The cost price is derived from the corresponding average cost column from the tank table, multiplied by the volume of each delivery. '
EXEC SetColumnDesc N'Hose_History', 'Monitor_Quantity','The number of monitor deliveries done on this hose since the record was opened. '
EXEC SetColumnDesc N'Hose_History', 'Monitor_Value','The total monetary value of all the monitor deliveries done on this hose since the record was opened. Note this value is not accounted for by other transactions in the system, and is used to verify what the pump attendant reports at the end of his shift.  '
EXEC SetColumnDesc N'Hose_History', 'Monitor_Volume','The total volume of all monitor deliveries done on this hose since the record was opened, in the units defined in the global settings. '
EXEC SetColumnDesc N'Hose_History', 'Monitor_Cost','The total monetary cost of all the monitor deliveries done on this hose since the record was opened. The cost price is derived from the corresponding average cost column from the tank table, multiplied by the volume of each delivery. '
EXEC SetColumnDesc N'Hose_History', 'Driveoffs_Quantity','The number of drive off deliveries done on this hose since the record was opened. '
EXEC SetColumnDesc N'Hose_History', 'Driveoffs_Value','The total volume of all drive off deliveries done on this hose since the record was opened, in the units defined in the global settings. '
EXEC SetColumnDesc N'Hose_History', 'Driveoffs_Volume','The total volume of all Driveoff deliveries done on this hose since the record was opened, in the units defined in the global settings. '
EXEC SetColumnDesc N'Hose_History', 'Driveoffs_Cost','The total monetary cost of all the Driveoff deliveries done on this hose since the record was opened. The cost price is derived from the corresponding average cost column from the tank table, multiplied by the volume of each delivery. '
EXEC SetColumnDesc N'Hose_History', 'Test_Del_Quantity','The number of test deliveries done on this hose since the record was opened. '
EXEC SetColumnDesc N'Hose_History', 'Test_Del_Volume','The total volume of all test deliveries done on this hose since the record was opened, in the units defined in the global settings. '
EXEC SetColumnDesc N'Hose_History', 'Offline_Quantity','The number of offline deliveries detected during this period. '
EXEC SetColumnDesc N'Hose_History', 'Offline_Volume','The total volume of offline deliveries detected during this period. '
EXEC SetColumnDesc N'Hose_History', 'Offline_Value','The total value of offline deliveries detected during this period. '
EXEC SetColumnDesc N'Hose_History', 'Offline_Cost','The total value of offline deliveries detected during this period. '
EXEC SetColumnDesc N'Hose_History', 'Open_Mech_Volume','The mechanical pump meter read from the pump at the beginning of the period as entered thru the fuel reconciliation application. '
EXEC SetColumnDesc N'Hose_History', 'Close_Mech_Volume','The mechanical pump meter read from the pump at the end of the period as entered thru the fuel reconciliation application. '
go

--------------------------------------------------------------------------------
-- Enabler_PostMix_History table TODO
EXEC SetTableDesc N'Hose_PostMix_History' , 'This table stores base grade historical totals for post-mix hoses that deliver blended grades. Each post-mix blending hose will have two records, one for each base grade that makes up the blended grade that the hose delivers.'

EXEC SetColumnDesc N'Hose_PostMix_History', 'Hose_ID','Link to the post-mix blending hose that owns this history record '
EXEC SetColumnDesc N'Hose_PostMix_History', 'Period_ID','Link to the period that contains this history record '
EXEC SetColumnDesc N'Hose_PostMix_History', 'Base_Grade_Number','Indicates which base grade this record is for<br>
<pre> 1 = first grade
 2 = second grade</pre>'
EXEC SetColumnDesc N'Hose_PostMix_History', 'Open_Meter_Value','Opening reading for this period from the money electronic total/meter. Note that if the pump does not provide a dedicated meter for base grades this data will be calculated from a blended meter reading.'
EXEC SetColumnDesc N'Hose_PostMix_History', 'Close_Meter_Value','Closing reading for this period from the money electronic total/meter.'
EXEC SetColumnDesc N'Hose_PostMix_History', 'Open_Meter_Volume','Opening reading for this period from the volume/quantity electronic total/meter. If the pump does not provide dedicated meter for base grades this data will be calculated from a blended meter reading.'
EXEC SetColumnDesc N'Hose_PostMix_History', 'Close_Meter_Volume','Closing reading for this period from the volume/quantity electronic total/meter.'
EXEC SetColumnDesc N'Hose_PostMix_History', 'Postpay_Quantity','The number of postpay deliveries done on this hose for the specified base grade since the record was opened.'
EXEC SetColumnDesc N'Hose_PostMix_History', 'Postpay_Value','The total money value of postpay deliveries done on this hose for the specified base grade since the record was opened.'
EXEC SetColumnDesc N'Hose_PostMix_History', 'Postpay_Volume','The total fuel volume/quantity of postpay deliveries done on this hose for the specified base grade since the record was opened.'
EXEC SetColumnDesc N'Hose_PostMix_History', 'Postpay_Cost','The total money cost of postpay deliveries done on this hose for the specified base grade component since the record was opened. The cost price is derived from the corresponding average cost column from the tank table, multiplied by the volume of each delivery.'
EXEC SetColumnDesc N'Hose_PostMix_History', 'Monitor_Quantity','The number of monitor deliveries for this hose for the specified base grade since the record was opened.'
EXEC SetColumnDesc N'Hose_PostMix_History', 'Monitor_Value','The total money value of monitor deliveries done on this hose for the specified base grade since the record was opened.'
EXEC SetColumnDesc N'Hose_PostMix_History', 'Monitor_Volume','The total fuel volume/quantity of monitor deliveries done on this hose for the specified base grade since the record was opened.'
EXEC SetColumnDesc N'Hose_PostMix_History', 'Monitor_Cost','The total money cost of monitor deliveries done on this hose for the specified base grade component since the record was opened. The cost price is derived from the corresponding average cost column from the tank table, multiplied by the volume of each delivery.'
EXEC SetColumnDesc N'Hose_PostMix_History', 'Driveoffs_Quantity','The number of drive-off deliveries for this hose for the specified base grade since the record was opened.'
EXEC SetColumnDesc N'Hose_PostMix_History', 'Driveoffs_Value','The total money value of drive-off deliveries done on this hose for the specified base grade since the record was opened.'
EXEC SetColumnDesc N'Hose_PostMix_History', 'Driveoffs_Volume','The total fuel volume/quantity of drive-off deliveries done on this hose for the specified base grade since the record was opened.'
EXEC SetColumnDesc N'Hose_PostMix_History', 'Driveoffs_Cost','The total money cost of drive-off deliveries done on this hose for the specified base grade component since the record was opened. The cost price is derived from the corresponding average cost column from the tank table, multiplied by the volume of each delivery.'
EXEC SetColumnDesc N'Hose_PostMix_History', 'Test_Del_Quantity','The number of test deliveries for this hose for the specified base grade component since the record was opened.'
EXEC SetColumnDesc N'Hose_PostMix_History', 'Test_Del_Volume','The total volume/quantity of test deliveries done on this hose+base grade since the record was opened.'
EXEC SetColumnDesc N'Hose_PostMix_History', 'Open_Mech_Volume','Opening reading for this period from the mechanical volume/quantity meter on the pump.'
EXEC SetColumnDesc N'Hose_PostMix_History', 'Close_Mech_Volume','Closing reading for this period from the mechanical volume/quantity meter on the pump.'
EXEC SetColumnDesc N'Hose_PostMix_History', 'Open_Money_Turnover_Correction','Opening money turnover correction to allow for meter rollover and reset.'
EXEC SetColumnDesc N'Hose_PostMix_History', 'Close_Money_Turnover_Correction','Closing money turnover correction to allow for meter rollover and reset.'
EXEC SetColumnDesc N'Hose_PostMix_History', 'Open_Volume_Turnover_Correction','Opening volume/quantity turnover correction to allow for meter rollover and reset.'
EXEC SetColumnDesc N'Hose_PostMix_History', 'Close_Volume_Turnover_Correction','Closing volume/quantity turnover correction to allow for meter rollover and reset.'
go


--------------------------------------------------------------------------------
-- Hose_Total_State table
EXEC SetTableDesc N'Hose_Total_State' , '<p>This table provides definition (self-documentation) of the allowed values for the State fields associated with each Hose Electronic Total reading. These fields indicate whether an electronic total has been read correctly, failed, or is not supported by the dispenser.</p><p>The data populated in the system table indicates the following:</p><table><th>Hose_Total_State_ID</th><th>Description</th><tr><td>1</td><td>Meter reading was successful.</td></tr><tr><td>2</td><td>Meter reading is not supported by the dispenser.</td></tr><tr><td>3</td><td>Totals supported but an error occurred during reading.</td></tr><tr><td>4</td><td>Meter readings validity is unconfirmed/unknown.</td></tr></table>'

EXEC SetColumnDesc N'Hose_Total_State', 'Hose_Total_State_ID','Unique private identifier for this hose meter state. '
EXEC SetColumnDesc N'Hose_Total_State', 'Hose_Total_State_Name','A short name used by the system to represent the result this hose meter error or state. '
go

--------------------------------------------------------------------------------
-- Hoses table
EXEC SetTableDesc N'Hoses' , '<p>Entity to store configuration and current data for pump hoses setup on the forecourt. A hose may also be referred to as a Nozzle. Values for the Blend_Type column:</p>
<pre> 0 = Not a blending hose
 1 = Blending hose (before hose meter)
 2 = Blending hose (after hose meter) - also known as a PostMix pump
</pre>

<p>Notes on Turnover Correction fields:</p>
<ol>
<li>Each electronic total has a Turnover Correction figure to allow more reliable measurement of pump use when an electronic meter is reset or rolls over. To get an always increasing pump turnover calculate:<br>
  Volume_Total + Volume_Total_Turnover_Correction</li>
<li>This functionality is only available for Pump Drivers that provide meter reading status (indicates success or failure of meter reading).</li>
</ol>'

EXEC SetColumnDesc N'Hoses', 'Hose_ID','Unique private identifier for this hose '
EXEC SetColumnDesc N'Hoses', 'Pump_ID','A link to the pump than owns this hose. '
EXEC SetColumnDesc N'Hoses', 'Grade_ID','A link to the grade for this hose, note that if this is a logical nozzle, this may be different from the contents of the tank_id tank. '
EXEC SetColumnDesc N'Hoses', 'Tank_ID','A link to the Tank that this hose is connected to. '
EXEC SetColumnDesc N'Hoses', 'Tank2_ID','The ID of the second Tank that makes up the rest of the grade blend. If this is not a logical hose then this column is NULL. '
EXEC SetColumnDesc N'Hoses', 'Hose_number','The logical number of the hose, starting at 1, upto the number of hoses this pump has installed. This is used to identify which of the physical hoses on the pump it is.  '
EXEC SetColumnDesc N'Hoses', 'Mechanical_Total','The last mechanical meter read entered into the system in the Management screen. This field is otherwise unused by Enabler. '
EXEC SetColumnDesc N'Hoses', 'Volume_Total','The last electronic volume total retrieved from the pump - note if the pump type does not support electronic totals, the contents are "0".  '
EXEC SetColumnDesc N'Hoses', 'Volume_Total1','The last electronic volume total retrieved from the pump for the first grade on Blending pumps. For non-blending hoses this field will be set to zero. '
EXEC SetColumnDesc N'Hoses', 'Volume_Total2','The last electronic volume total retrieved from the pump for the first grade on Blending pumps. For non-blending hoses this field will be set to zero. '
EXEC SetColumnDesc N'Hoses', 'Money_Total','The last electronic money total retrieved from the pump. - note if the pump type does not support electronic totals, the contents are "0".  '
EXEC SetColumnDesc N'Hoses', 'Money_Total1','The last electronic money total retrieved from the pump for the first grade on Blending pumps. For non-blending hoses this field will be set to zero. '
EXEC SetColumnDesc N'Hoses', 'Money_Total2','The last electronic money total retrieved from the pump for the second grade on Blending pumps. For non-blending hoses this field will be set to zero. '
EXEC SetColumnDesc N'Hoses', 'Theoretical_Total','The theoretical meter value calculated by Enabler based on the total volume of deliveries done on this hose. '
EXEC SetColumnDesc N'Hoses', 'Theoretical_Total2','The theoretical meter value calculated by Enabler based on the total volume of deliveries done on this hose for the second grade on Blending pumps. '
EXEC SetColumnDesc N'Hoses', 'Blend_Type','See note above for description of values. '
EXEC SetColumnDesc N'Hoses', 'Volume_Total_Turnover_Correction','Turnover correction to allow for meter rollover and reset. Used for stock reconciliation.'
EXEC SetColumnDesc N'Hoses', 'Money_Total_Turnover_Correction','Turnover correction for Money_Total field. '
EXEC SetColumnDesc N'Hoses', 'Volume_Total2_Turnover_Correction','Turnover correction for Volume_Total2 field. '
EXEC SetColumnDesc N'Hoses', 'Volume_Total_State_ID','A link to the Hose Total State table. Refers to the current state of the volume meter. '
EXEC SetColumnDesc N'Hoses', 'Money_Total_State_ID','A link to the Hose Total State table. Refers to the current state of the money meter. '
EXEC SetColumnDesc N'Hoses', 'Volume_Total2_State_ID','A link to the Hose Total State table. Refers to the current state of the volume2 meter. '
EXEC SetColumnDesc N'Hoses', 'Deleted','Delete marker for this record:<br>
<pre> 1 = Deleted
 0 = Active</pre>'
EXEC SetColumnDesc N'Hoses', 'Is_Enabled','Block reason for this hose. When non-zero Pump Server will prevents authorisation of this hose. '
go

--------------------------------------------------------------------------------
-- Cards table
EXEC SetTableDesc N'Cards' , '<p>This table stores a list of Enabler Cards (Enabler PCI Express and Enabler E) configured in the system.</p>

<p>On a clean install, this will only include an entry for the Enabler PCI/Express card. However, Enabler E cards can be stored and configured here as well.</p>
<p>NOTE: Versions prior to Enabler 4.5.x do not have support for this Cards table.</p>

<p><b></i>WARNING: It is recomended that this table is only modified using the Enabler Configuration Application. Incorrect values in this table will adversely effect the operation of The Enabler.</i></b></p>'

EXEC SetColumnDesc N'Cards', 'Card_ID','A unique private identifier for this Enabler card '
EXEC SetColumnDesc N'Cards', 'Name','User defined name or location of the Enabler Card. '
EXEC SetColumnDesc N'Cards', 'Connection_Type','The type connection to an Enabler Card ( 0=Local(PCI/Express), 1=Local(RS232), 2=Lan(UDP), 3=USB(Enabler E), 4=Lan(Enabler E) ). '
EXEC SetColumnDesc N'Cards', 'Card_Type','The actual type of Enabler card ( 0=Unknown, 1=Enabler PCI, 2= Enabler Express, 3= Enabler Express V3, 4=Enabler E, 5=Enabler Interface Card, ). '
EXEC SetColumnDesc N'Cards', 'Serial_Number','Unique Serial Number of the card if present. '
EXEC SetColumnDesc N'Cards', 'Address','The current address of the card. '
EXEC SetColumnDesc N'Cards', 'Settings','Settings associated with the Card Type. Reserved for future use. '
go


--------------------------------------------------------------------------------
-- Loops table
EXEC SetTableDesc N'Loops' , '<p>The Enabler supports communication using various protocols. The Enabler Card has five Ports, and each Port can communicate using a different protocol.</p>

<p>Each record in the Loops table defines the protocol and the associated Enabler Card Port that will be used for this protocol. The first five records are always present because the Enabler Card always has five ports. The fields Connection Type, Comm Port and Settings are not relevant for protocols that will be using an Enabler Card Port.</p>

<p>In versions that do support addition of extra ports the Ports can not be used for Enabler Card configuration.</p>

<p>NOTE: Versions before Enabler 3.30 do not support adding additional Ports.</p>

<p><b></i>WARNING: It is recomended that this table is only modified using the Enabler Configuration Application. Incorrect values in this table will adversely effect the operation of The Enabler.</i></b></p>'

EXEC SetColumnDesc N'Loops', 'Loop_ID','A unique private identifier for this loop  '
EXEC SetColumnDesc N'Loops', 'Protocol_ID','A link to the protocol table to determine the driver type used for this loop '
EXEC SetColumnDesc N'Loops', 'Port_Assign','The Enabler Card Port that this loop is connected to. '
EXEC SetColumnDesc N'Loops', 'Card','The Enabler Card number<br>
<pre> 1 = Enabler PCI/Express card</pre>'
EXEC SetColumnDesc N'Loops', 'Channel','Reserved for future use. '
EXEC SetColumnDesc N'Loops', 'Port_Name','A name for the port used by the Enabler Configuration Application '
EXEC SetColumnDesc N'Loops', 'Connection_Type','The type of connection. If the Port_assign is greater than 5 this field is used. Values greater than 0 indicate the type of connection ( 0=Local(PCI/Express), 1=Local(RS232), 2=Lan(UDP), 3=USB(Enabler E), 4=Lan(Enabler E) )  '
EXEC SetColumnDesc N'Loops', 'Settings','Settings associated with the Connection Type. '
go

--EXEC SetTableDesc N'OPT_Key_Codes' , ''
--EXEC SetTableDesc N'OPT_Key_Map' , ''
--EXEC SetTableDesc N'OPT_Prompt_Map' , ''
--EXEC SetTableDesc N'OPT_Type' , ''
--EXEC SetTableDesc N'OPTs' , ''

--------------------------------------------------------------------------------
-- PVT table
--EXEC SetTableDesc N'PVT' , ''
--go

--------------------------------------------------------------------------------
-- Period_Types table
EXEC SetTableDesc N'Period_Types' , '<p>This table stores the historic periods defined for reporting periods in Enabler.</p>
<p>Default data in this table at installation is:</p>
<table>
<tr>
 <th>Period_Type</th>
 <th>Period_Name</th>
</tr>
<tr><td>1</td><td>Shift</td></tr>
<tr><td>2</td><td>Day</td></tr>
<tr><td>3</td><td>Month</td></tr>
</table>
'

EXEC SetColumnDesc N'Period_Types', 'Period_Type','A numeric ID identifying the type of the period. This period type is used to close/open new periods. '
EXEC SetColumnDesc N'Period_Types', 'Period_name','The logical name given to the period.'
EXEC SetColumnDesc N'Period_Types', 'Period_description','Optional longer description of the period type '
EXEC SetColumnDesc N'Period_Types', 'Period_keep_days','The number of days to keep this type of closed off period. '
go

--------------------------------------------------------------------------------
-- Periods table
EXEC SetTableDesc N'Periods' , 'This table has a row for each historic period total stored in the database.'

EXEC SetColumnDesc N'Periods', 'Period_ID','Unique private key for this period  '
EXEC SetColumnDesc N'Periods', 'Period_Create_TS','The time and date when the period commenced '
EXEC SetColumnDesc N'Periods', 'Period_Type','The type of the period - the value of this field is defined by the contents of the Period_Types table. '
EXEC SetColumnDesc N'Periods', 'Period_Close_DT','The time and date when the period ended - this column is null if the period is still open  '
EXEC SetColumnDesc N'Periods', 'Period_State','The current state of the period:<br>
<pre> 1 = open
 2 = closed</pre>'
EXEC SetColumnDesc N'Periods', 'Period_Name','An optional name for the period  '
EXEC SetColumnDesc N'Periods', 'Period_Number','A public sequential number allocated to the period when it was started. '
EXEC SetColumnDesc N'Periods', 'Tank_Dips_Entered','A flag determining if tank dips have been entered for this period yet. This is used by the Fuel reconciliation application  '
EXEC SetColumnDesc N'Periods', 'Tank_Drops_Entered','A flag determining if tank drops have been entered for this period yet. This is used by the Fuel reconciliation application '
EXEC SetColumnDesc N'Periods', 'Pump_Meter_Entered','A flag determining if pump mechanical meter readings have been entered for this period yet. This is used by the Fuel reconciliation application '
EXEC SetColumnDesc N'Periods', 'Exported','A flag indicating whether Fuel Reconciliation has exported data for this period (0 = data not exported) '
EXEC SetColumnDesc N'Periods', 'Export_Required','A flag indicating whether Fuel Reconciliation has completed all of the reconciliation steps for this period. This field is used depending on the configuration of the Recon_ fields in the Global_Settings table '
EXEC SetColumnDesc N'Periods', 'Wetstock_Approval_ID','A link to the Wetstock Approval table. Refers to the wetstock reconciliation approval entry for this period. '
EXEC SetColumnDesc N'Periods', 'WetStock_Out_Of_Variance','A flag indicating the tank variance status of a period:<br>
<pre> 0 = Not checked yet
 1 = Within tolerance range
 2 = Out of variance</pre>'
go

--------------------------------------------------------------------------------
-- Price_Level_types table
EXEC SetTableDesc N'Price_Level_Types' , 'This table stores the predefined price level types in Enabler.'

EXEC SetColumnDesc N'Price_Level_Types', 'Price_Level','Price level number, starting at 1 and going up. The number of price levels configured should match the number of price levels supported by the pump types being used.  '
EXEC SetColumnDesc N'Price_Level_Types', 'Level_Name','A short name used by the system operator to identify this price level, ie. "Cash", "Credit" etc. '
EXEC SetColumnDesc N'Price_Level_Types', 'Level_Description','An optional, longer, more detailed description of this price level. '
go

--------------------------------------------------------------------------------
-- Price_Levels table
EXEC SetTableDesc N'Price_Levels' , 'This table stores the grade prices based on price level.'

EXEC SetColumnDesc N'Price_Levels', 'Price_Level','Price level number, starting at 1 and going up. The number of price levels configured should match the number of price levels supported by the pump types being used. '
EXEC SetColumnDesc N'Price_Levels', 'Price_Profile_ID','A link to the price profile that owns this price '
EXEC SetColumnDesc N'Price_Levels', 'Grade_Price','The actual grade price. Note this has up to 4 decimal places as some countries set prices down to a tenth of a unit. '
EXEC SetColumnDesc N'Price_Levels', 'Price_Index','Logical number for this price level for use with blended grades. '
EXEC SetColumnDesc N'Price_Levels', 'Price_Ratio','Blend ratio which this price applies to. '
go

--------------------------------------------------------------------------------
-- Price_Profile table
EXEC SetTableDesc N'Price_Profile' , 'This table stores the scheduled price profiles for grades.'

EXEC SetColumnDesc N'Price_Profile', 'Scheduled_ST','A scheduled start time and date for this price profile, Note this may be NULL and as such can only be manually applied.  '
EXEC SetColumnDesc N'Price_Profile', 'Parent_Grade_ID','The ID of the grade that this scheduled price change applies to. '
EXEC SetColumnDesc N'Price_Profile', 'Price_Profile_ID','Unique private key for this price profile  '
EXEC SetColumnDesc N'Price_Profile', 'Price_Profile_Name','An optional short name for this price profile  '
EXEC SetColumnDesc N'Price_Profile', 'Deleted','The deleted state of the price profile:<br>
<pre> 1 = Deleted
 0 = Active</pre>'
go

--EXEC SetTableDesc N'Prompts' , ''
--go

--------------------------------------------------------------------------------
-- Protocol_type table
EXEC SetTableDesc N'Protocol_Type', '<p>This table defines the type of each Protocol in order to help the Configuration Application validate port settings.</p>
<p>The valid values of Protocol_Type_ID are:</p>
<table>
 <th>Protocol_Type_ID</th>
 <th>Description</th>
<tr><td>1</td><td>Pump/Dispenser</td></tr>
<tr><td>2</td><td>Tank Gauge</td></tr>
<tr><td>3</td><td>OPT</td></tr>
<tr><td>4</td><td>Emulation (Forecourt API Emulation)</td></tr>
</table>
'
EXEC SetColumnDesc N'Protocol_Type', 'Protocol_Type_ID','Unique private key for this protocol_type '
EXEC SetColumnDesc N'Protocol_Type', 'Protocol_Type_Name','A description for this protocol type'
go

--------------------------------------------------------------------------------
-- Pump_ table
EXEC SetTableDesc N'Pump_Profile' , '<p>Refer to Site_Profile Table for a description of the relationship between these tables.</p>
<p>In Enabler V4 The following columns have been removed:</p>

<p>&nbsp;Pump_Profile_Name*<br>
&nbsp;Pump_Profile_Desc*<br>
&nbsp;Start_Time+<br>
&nbsp;End_Time+<br>
&nbsp;Valid_Days+</p>
<p>Where:<br>
&nbsp;* Enabler Configuration only uses the name field to be set for site profiles.<br>
&nbsp;+ Automatic scheduling is now provided for site profiles only.</p>
'
EXEC SetColumnDesc N'Pump_Profile', 'Pump_Profile_ID','Unique private ID used to identify this pump profile description. '
EXEC SetColumnDesc N'Pump_Profile', 'Auto_Authorise','Is the pump auto-authorise, ie. will the pump start delivering without requiring authorisation by a system operator when the hose is removed by a customer:<br>
<pre> 0 = Compulsory Auth
 1 = Auto auth
 2 = Use site profile setting.
</pre>
This mode is only relevant for postpay and monitor deliveries. If both of the Allow_Postpay and Allow_Monitor flags are 1 the contents of this column are ignored. Note: This setting can override that specified in the site profile. '
EXEC SetColumnDesc N'Pump_Profile', 'Allow_Postpay','Can this profile do postpay deliveries:<br>
<pre> 0 = No
 1 = Yes
 2 = Use site profile setting
</pre>
Note this setting can override that specified in the site setting. '
EXEC SetColumnDesc N'Pump_Profile', 'Allow_Prepay','Can this profile do prepay deliveries:<br>
<pre> 0 = No
 1 = Yes
 2 = Use site profile setting
</pre>
Note this setting can override that specified in the site setting.  '
EXEC SetColumnDesc N'Pump_Profile', 'Allow_Preauth','Can this profile do preauth deliveries:<br>
<pre> 0 = No
 1 = Yes
 2 = Use site profile setting
</pre>
Note this setting can override that specified in the site setting. '
EXEC SetColumnDesc N'Pump_Profile', 'Allow_Monitor','Can this profile do monitor deliveries:<br>
<pre> 0 = No
 1 = Yes
 2 = Use site profile setting
</pre>
Note: If Monitor deliveries are permitted, then the pump is Auto Auth regardless of other settings. Also note that this setting can override that specified in the site setting. '
EXEC SetColumnDesc N'Pump_Profile', 'Pump_Lights','Are the pump lights on or off for this profile:<br>
<pre> 0 = Off
 1 = On
 2 = Use site profile setting
</pre>
Note this setting can override that specified in the site profile. '
EXEC SetColumnDesc N'Pump_Profile', 'Pump_Stacking','Is pump stacking allowed during this profile:<br>
<pre> 0 = No
 1 = Yes
 2 = Use site profile setting
</pre>
A pump stack is a per pump stack of un-cleared deliveries. Note this Setting can override that specified in the site profile table. '
EXEC SetColumnDesc N'Pump_Profile', 'Pump_Auto_Stacking','Is auto pump stacking allowed during this profile:<br>
<pre> 0 = No
 1 = Yes
 2 = Use site profile setting
</pre>Auto pump stacking is the shifting of a current delivery to the pump Stack, if there is room, when a Pump calls, allowing the pump to auto-authorise and start Delivering again. Note this setting can override that specified in the site setting table. '
EXEC SetColumnDesc N'Pump_Profile', 'Allow_Attendant','Whether attendant mode deliveries are permitted on this pump.<br>
<pre> 0 = No
 1 = Yes
 2 = Use site profile setting
</pre>'
EXEC SetColumnDesc N'Pump_Profile', 'Pump_Profile_Pump_ID','Pump that this record defines behavour for. '
EXEC SetColumnDesc N'Pump_Profile', 'Site_Profile_ID','Site Mode Profile record that this record inherites behavour from. '
EXEC SetColumnDesc N'Pump_Profile', 'Prof_Price_1_Level','Setting for price level 1. '
EXEC SetColumnDesc N'Pump_Profile', 'Prof_Price_2_Level','Setting for price level 2. '
EXEC SetColumnDesc N'Pump_Profile', 'Fallback_Allow','Whether fallback mode is allowed for this pump. 
<pre> 0 = No
 1 = Yes
 2 = Use site profile setting
</pre>'
EXEC SetColumnDesc N'Pump_Profile', 'Fallback_Automatic','Determines whether fallback mode is activated automatically when all client applications disconnect. '
EXEC SetColumnDesc N'Pump_Profile', 'Tag_Reader_Active','(reserved for future use)'
EXEC SetColumnDesc N'Pump_Profile', 'Attendant_Tag_Auth','Is pump authorised when when a valid attendant tag is presented:<br>
<pre> 0 = No
 1 = Yes
 2 = Use site profile setting
</pre>
A valid tag is the Tag set in the attendants table or for dynamic tags that set on the LogonForecourt API command. Note When used on a pump profile this will override the site profile. '
EXEC SetColumnDesc N'Pump_Profile', 'External_Tag_Auth','Determines if pumps are authorised when a valid external tag is presented.
<pre> 0 = No
 1 = Yes
 2 = Use site profile setting
</pre>'
EXEC SetColumnDesc N'Pump_Profile', 'Stack_Size','This column determines the maximum number of stacked (complete unsold) pump deliveries that may be stored for this pump. Replaces the previous site-wide setting <tt>Global_Settings.Pump_Stack_Size</tt>.'
go

--------------------------------------------------------------------------------
-- Pump_Protocol table
EXEC SetTableDesc N'Pump_Protocol' , '<p>This table contains a list of available protocols for forecourt devices and controller emulation.</p>
<p>As new protocols are added this table is updated by Enabler installers - and should not be modified by Integrator applications.</p>'

EXEC SetColumnDesc N'Pump_Protocol', 'Protocol_ID','Private unique key. '
EXEC SetColumnDesc N'Pump_Protocol', 'Protocol_Name','A short name used by the system operator to identify the pump protocol. '
EXEC SetColumnDesc N'Pump_Protocol', 'Protocol_Type_ID','Type of protocol. Refer to protocol type table. '
EXEC SetColumnDesc N'Pump_Protocol', 'Protocol_Desc','Extra detail regarding this protocol. '
EXEC SetColumnDesc N'Pump_Protocol', 'Driver_Class_ID','The COM class ID of the respective in-process DLL for this protocol. This will be pre configured by The Enabler install. '
EXEC SetColumnDesc N'Pump_Protocol', 'Inter_Poll_Delay','Field for internal use by Enabler. This field should not be adjusted. '
EXEC SetColumnDesc N'Pump_Protocol', 'Poll_Type','Field for internal use by Enabler. This field should not be adjusted. '
EXEC SetColumnDesc N'Pump_Protocol', 'Line_Control','Field for internal use by Enabler. This field should not be adjusted. '
EXEC SetColumnDesc N'Pump_Protocol', 'Baud_Divisor_latch','Field for internal use by Enabler. This field should not be adjusted. '
EXEC SetColumnDesc N'Pump_Protocol', 'Outboard_Protocol','Field for internal use by Enabler. This field should not be adjusted. '
EXEC SetColumnDesc N'Pump_Protocol', 'Extended_Port_Settings','Field for internal use by Enabler. This field should not be adjusted. '
go

--------------------------------------------------------------------------------
-- Pump_Type table
EXEC SetTableDesc N'Pump_Type' , 'This table stores the defined dispeser types supported by The Enabler. Each pump type is related to a Pump Protocol, and can be selected using Enabler Configuration.'

EXEC SetColumnDesc N'Pump_Type', 'Pump_Type_ID','Unique private identifier for this pump type '
EXEC SetColumnDesc N'Pump_Type', 'Protocol_ID','Link to the Protocol table defining the type of protocol for this pump type. '
EXEC SetColumnDesc N'Pump_Type', 'Pump_Type_Name','A short name used by the system operator to identify this pump type. '
EXEC SetColumnDesc N'Pump_Type', 'Pump_Type_Desc','An optional, longer, more detailed description of this pump type. '
EXEC SetColumnDesc N'Pump_Type', 'Poll_Response_TO','The time in milliseconds that the system waits for a response to a poll of this pump type before deciding that it has not responded. '
EXEC SetColumnDesc N'Pump_Type', 'Max_No_Responses','The maximum time in milli seconds between characters for a valid response. '
EXEC SetColumnDesc N'Pump_Type', 'Inter_Char_Timeout',''
EXEC SetColumnDesc N'Pump_Type', 'Has_Lights','Does this pump have lights that can be remote controlled?: <br>
<pre> 0 = No
 1 = Yes</pre>'
EXEC SetColumnDesc N'Pump_Type', 'Polling_Rate','The minimum delay in ms between idle polls to a pump of this type. '
EXEC SetColumnDesc N'Pump_Type', 'Running_Total_PR','The delay in seconds between polls for the running total on a pump with a running total. The smaller this number the more accurate the current running total is, however this may adversely affect the response times of other pumps on the same loop. '
EXEC SetColumnDesc N'Pump_Type', 'Has_Preset','Does this pump type have a preset unit?<br>
<pre> 0 = No
 1 = Yes
</pre>
A preset unit is the keypad where the customer enters the desired amount of the delivery. However it is taken to mean by the system as whether this pump can accept Preset amounts and as such do prepay Deliveries, as this is usually the case. '
EXEC SetColumnDesc N'Pump_Type', 'Max_Price_Levels','The number of price levels supported by this pump type. '
EXEC SetColumnDesc N'Pump_Type', 'Price_Format','deprecated - unused since Version 2.20'
EXEC SetColumnDesc N'Pump_Type', 'Max_Hoses','The maximum number of hoses supported by this pump type. '
EXEC SetColumnDesc N'Pump_Type', 'Value_Format','deprecated - unused since Version 2.20 '
EXEC SetColumnDesc N'Pump_Type', 'Volume_Format','deprecated - unused since Version 2.20'
EXEC SetColumnDesc N'Pump_Type', 'Price_Offset','deprecated - unused since Version 2.20'
EXEC SetColumnDesc N'Pump_Type', 'Value_Offset','deprecated - unused since Version 2.20'
EXEC SetColumnDesc N'Pump_Type', 'Is_a_Blender','A flag to identify if this pump type is a blender or not.<br>
<pre>   0 = not a blender
&lt;&gt; 0 = a blender</pre> '
EXEC SetColumnDesc N'Pump_Type', 'Default_Display_Type','If this pump type has a suitable default display ID (eg non 0) it will be automatically configured when the pump type is changed.  '
EXEC SetColumnDesc N'Pump_Type', 'Single_Hose_Auth','Indicates whether the pump supports authorisation of individual hoses.'
EXEC SetColumnDesc N'Pump_Type', 'Multiplier_Support','Used to identify the level to which this type of pump supports Multipliers. 0 indicates no support, 1 indicates support for multipliers controlled only by Enabler, 2 indicates the pump itself is aware of multipiers. '
EXEC SetColumnDesc N'Pump_Type', 'Supports_Tag_Reader','Indicates whether the pump has a built-in tag reader.'
go

--------------------------------------------------------------------------------
-- Pumps table
EXEC SetTableDesc N'Pumps' , '<p>Each record in this table represents a Logical Pump (aka fuelling position) and corresponds to a Pump in our Enabler API. A &quot;logical pump&quot; is also sometimes referred to as a pump <i>side</i>. In most cases a &quot;Physical Pump&quot; (aka Dispenser) has two &quot;logical pumps&quot; (sides) each with a display and one or more hoses.</p>
<p>A more complete discussion of the concept of Logical and Physical pumps is available on our website: <br>
<a href="http://integration.co.nz/FAQ-PumpNozzle.htm">How Many Pumps,and Nozzles Can The Enabler Support?</a> </p>
<p>In Enabler v4 the following obsolete fields were removed from this table:<Br>
&nbsp;Pump_Display_ID<br>
&nbsp;Pump_Profile_ID
</p>'

EXEC SetColumnDesc N'Pumps', 'Pump_ID','Unique private identifier of the pump  '
EXEC SetColumnDesc N'Pumps', 'Pump_Type_ID','Link to the pump type table defining the type of this pump  '
EXEC SetColumnDesc N'Pumps', 'Attendant_ID','The ID of the Attendant currently logged onto this pump. This field should not be modified by applications other than the Enabler Pump Server service. New records should have this field set to NULL. '
EXEC SetColumnDesc N'Pumps', 'Loop_ID','Link to the Loop table placing this pump on a specific loop. '
EXEC SetColumnDesc N'Pumps', 'Pump_Name','A short name used by the system operator to identify this pump. '
EXEC SetColumnDesc N'Pumps', 'Pump_Description','Not available for use by applications other than Enabler Configuration. The use of this field as a Description field, is no longer supported. '
EXEC SetColumnDesc N'Pumps', 'Logical_Number','The pump number of the pump as Displayed on the POS and card Terminals. '
EXEC SetColumnDesc N'Pumps', 'Polling_Address','The polling address of the pump used by the pump driver to Communicate to the pump. This is Restricted to 1 to 16 '
EXEC SetColumnDesc N'Pumps', 'Serial_Number','A ten character serial number for the pump. This is only entered for Reference purposes. '
EXEC SetColumnDesc N'Pumps', 'Pump_History','Not supported by Enabler Configuration Application '
EXEC SetColumnDesc N'Pumps', 'Price_1_Level','Price Level profile for pumps pricing level 1 '
EXEC SetColumnDesc N'Pumps', 'Price_2_Level','Price Level profile for pumps pricing level 2 '
EXEC SetColumnDesc N'Pumps', 'Reserved_by','Reserved for use by the Pump server to persist terminal with reserve on this pump '
EXEC SetColumnDesc N'Pumps', 'Reserve_State','Reserved for use by the Pump server '
-- Obsolete fields removed in V4
-- EXEC SetColumnDesc N'Pumps', 'Auth_Limit_Type','Reserved for use by the Pump server '
-- EXEC SetColumnDesc N'Pumps', 'Auth_Hose_Mask','Reserved for use by the Pump server '
-- EXEC SetColumnDesc N'Pumps', 'Auth_Limit','Reserved for use by the Pump server '
-- EXEC SetColumnDesc N'Pumps', 'Auth_Level','Reserved for use by the Pump server '
EXEC SetColumnDesc N'Pumps', 'Price_Multiplier','The price multiplier configuration for this pump. Zero indicates no multipliers. '
EXEC SetColumnDesc N'Pumps', 'Value_Multiplier','The value multiplier configuration for this pump. Zero indicates no multipliers. '
EXEC SetColumnDesc N'Pumps', 'Deleted','The deleted state of the pump:<br>
<pre> 1 = Deleted
 0 = Used</pre>'
EXEC SetColumnDesc N'Pumps', 'Tag_Reader_Installed','Indicates whether the pump has an integrated Tag Reader fitted. '
EXEC SetColumnDesc N'Pumps', 'Value_Decimals','Contains a number indicating the number of decimal digits in the pump money display. '
EXEC SetColumnDesc N'Pumps', 'Volume_Decimals','Contains a number indicating the number of decimal digits in the pump quantity/volume display. '
EXEC SetColumnDesc N'Pumps', 'Price_Decimals','Contains a number indicating the number of decimal digits in the pump unit price display. '
EXEC SetColumnDesc N'Pumps', 'Is_Enabled','Stores Pump level block reason for the dispenser.'
EXEC SetColumnDesc N'Pumps', 'Is_Loaded','Determines whether the Pump Configuration row should be loaded by Enabler.'
go

--------------------------------------------------------------------------------
-- Roles table
EXEC SetTableDesc N'Roles' , 'Configuration of user roles for security in Enabler. This primarily determines the access users have to use Enabler Web applications.'

EXEC SetColumnDesc N'Roles', 'Role_ID','Unique private identifier for this role.'
EXEC SetColumnDesc N'Roles', 'Role_Name','Name for this role.'
EXEC SetColumnDesc N'Roles', 'Role_Flags','Access flags to indicate allowed/disallowed activities for this role.'
go

--------------------------------------------------------------------------------
-- Site_Profile table
EXEC SetTableDesc N'Site_Profile' , '<p>The Site Profile Table determines the allowed behavour of pumps. This table works in conjunction with the Pumps Table. Further details on the operation and interaction of these tables is after the details of the fields.</p>
<p>In Enabler v4 the following fields were removed from this table - the default site flags are now set in the Pump_Profile table:<br>
&nbsp;Site_Auto_Auth<br>
&nbsp;Site_Lights<br>
&nbsp;Site_Allow_Postpay<br>
&nbsp;Site_Allow_Prepay<br>
&nbsp;Site_Stacking<br>
&nbsp;Site_Auto_Stacking<br>
&nbsp;Site_Allow_Preauth<br>
&nbsp;Site_Allow_Monitor<br>
&nbsp;Site_Allow_Att<br>
&nbsp;Prof_Price_1_Level<br>
&nbsp;Prof_Price_2_Level<br>
&nbsp;Site_Att_Tag_Activiate<br>
&nbsp;Site_Att_Tag_Auth
</p>
'
EXEC SetColumnDesc N'Site_Profile', 'Site_Profile_ID','Unique private key identifying this site profile. '
EXEC SetColumnDesc N'Site_Profile', 'Site_Profile_Name','A short name used by the system operator to identify this site profile, eg. Week nights, public holidays etc. '
EXEC SetColumnDesc N'Site_Profile', 'Site_Profile_Desc','An optional, more detailed description of this site profile. '
EXEC SetColumnDesc N'Site_Profile', 'Start_Time','When Auto_Mode_On this is the start time of thie profile. When this time is reached this profile and its associated pump profiles will become the active mode profile. If this is the active profile this field is not used. '
EXEC SetColumnDesc N'Site_Profile', 'Valid_Days','Valid days on which the profile is active.<br>
<pre> 1 = Sunday
 2 = Monday
 3 = Tuesday
 4 = Wednesday
 5 = Thursday
 6 = Friday
 7 = Saturday</pre>
The field contains a comma delimeted set of valid days. For example "1,6,7" indicates Sunday, Friday and Saturday. '
EXEC SetColumnDesc N'Site_Profile', 'Site_Profile_Number','External reference for this site profile. '
go

--------------------------------------------------------------------------------
-- Tag table
EXEC SetTableDesc N'Tag' , 'This table stores the details of tags that are setup for use at the site. In current software Tags can only be used for Attendant Tagging functionality.'

EXEC SetColumnDesc N'Tag', 'Tag_ID','Private unique identifier for the tag.'
EXEC SetColumnDesc N'Tag', 'Tag_Number','External Reference number for the tag.'
EXEC SetColumnDesc N'Tag', 'Tag_Data','The unique identifying data stored on the tag - read when the tag is presented.'
EXEC SetColumnDesc N'Tag', 'Tag_Description','Optional description for the tag (e.g. a logical Tag number).'
EXEC SetColumnDesc N'Tag', 'Tag_Disabled','Reserved for future use. The disabled state of the tag.'
EXEC SetColumnDesc N'Tag', 'Date_Scanned','The recent date/time when the tag was scanned to authorize a delivery.'
EXEC SetColumnDesc N'Tag', 'Date_Expiration','Reserved for future use. The date/time when the tag is set to expire.'
go

--------------------------------------------------------------------------------
-- Tag_Controller table
EXEC SetTableDesc N'Tag_Controller'	, 'Configuration of tag reader control equipment installed at the site.'

EXEC SetColumnDesc N'Tag_Controller', 'Tag_Controller_ID','Private internal identifier for the tag controller. '
EXEC SetColumnDesc N'Tag_Controller', 'Tag_Controller_Type_ID','Link to the Tank Controller Type setup.'
EXEC SetColumnDesc N'Tag_Controller', 'Number','Logical number of a tag controller.'
EXEC SetColumnDesc N'Tag_Controller', 'Name','Name for a tag controller.'
EXEC SetColumnDesc N'Tag_Controller', 'Loop_ID','Link to the Enabler Port used to communicate with the tag controller.'
EXEC SetColumnDesc N'Tag_Controller', 'Polling_Address','Address used to communicate with the tag controller.'
go

--------------------------------------------------------------------------------
-- Tag_Controller_Type table
EXEC SetTableDesc N'Tag_Controller_Type' , 'Internal definition of the Tag Controller types supported by Enabler for internal use.'

EXEC SetColumnDesc N'Tag_Controller_Type', 'Tag_Controller_Type_ID','Internal identifier for the Tank Controller type.'
EXEC SetColumnDesc N'Tag_Controller_Type', 'Max_Readers','Number of readers supported by the Tag Controller.'
EXEC SetColumnDesc N'Tag_Controller_Type', 'Name','Brand name and/or model of the Tag Controller.'
EXEC SetColumnDesc N'Tag_Controller_Type', 'Protocol_ID','Link to the row in the protocols table used for this type of Tag Controller.'
EXEC SetColumnDesc N'Tag_Controller_Type', 'Topology','(for internal use).'
EXEC SetColumnDesc N'Tag_Controller_Type', 'Polling_Rate','(for internal use).'
EXEC SetColumnDesc N'Tag_Controller_Type', 'Poll_Response_TO','(for internal use).'
EXEC SetColumnDesc N'Tag_Controller_Type', 'Inter_Char_Timeout','(for internal use).'
EXEC SetColumnDesc N'Tag_Controller_Type', 'Tag_Type','(for internal use).'
EXEC SetColumnDesc N'Tag_Controller_Type', 'Max_Controllers','(for internal use).'
go

--------------------------------------------------------------------------------
-- Tag_Reader table
EXEC SetTableDesc N'Tag_Reader', 'Stores configuration of Tag Reader equipment installed at the site.'

EXEC SetColumnDesc N'Tag_Reader', 'Tag_Reader_ID','Unique internal identifier for a Tag Reader.'
EXEC SetColumnDesc N'Tag_Reader', 'Tag_Controller_ID','Link to the Tag Controller a Tag Reader is connected to.'
EXEC SetColumnDesc N'Tag_Reader', 'Polling_Address','Address for a Tag Reader.'
EXEC SetColumnDesc N'Tag_Reader', 'Number','Logical number for a Tag Reader.'
EXEC SetColumnDesc N'Tag_Reader', 'Name','Name for a Tag Reader.'
EXEC SetColumnDesc N'Tag_Reader', 'Pump_ID','Optional link to the Pump (Fuelling position) where the Tag reader is mounted.'
go

--------------------------------------------------------------------------------
-- External_Tag table
EXEC SetTableDesc N'External_Tag' , 'This table stores an external list of tags that can be used to authorised a pump.'

EXEC SetColumnDesc N'External_Tag', 'Tag_ID','Private unique identifier for the tag.'
EXEC SetColumnDesc N'External_Tag', 'Tag_Number','External Reference number for the tag.'
EXEC SetColumnDesc N'External_Tag', 'Tag_Data','The unique identifying data stored on the tag - read when the tag is presented.'
EXEC SetColumnDesc N'External_Tag', 'Tag_Description','Optional description for the tag (e.g. a logical Tag number).'
EXEC SetColumnDesc N'External_Tag', 'Tag_Disabled','The disabled state of the tag. If set to true Tag cannot be used to authorize a pump.'
EXEC SetColumnDesc N'External_Tag', 'Date_Scanned','The recent date/time when the tag was scanned to authorize a delivery.'
EXEC SetColumnDesc N'External_Tag', 'Date_Expiration','Reserved for future use. The date/time when the tag is set to expire.'
go

--------------------------------------------------------------------------------
-- Tank_Connection table
EXEC SetTableDesc N'Tank_Connection_Type' , 'This table contains a list of tank connection types.'

EXEC SetColumnDesc N'Tank_Connection_Type', 'Tank_Connection_Type_ID','Unique private identifier for this tank connection type.'
EXEC SetColumnDesc N'Tank_Connection_Type', 'Tank_Connection_Type_Name','A short name used by the system operator to identify this tank connection type.'
go

--------------------------------------------------------------------------------
-- Tank_Delivery table
EXEC SetTableDesc N'Tank_Delivery' , '<p>This table contains details of tanker deliveries (deliveries of fuel from a distribution tanker into the site tanks), as manually entered using the Enabler Fuel Reconciliation application.</p>
<p>See also <a href=
"EnablerDB_db~s-dbo~t-Detected_Tank_Delivery.html">Detected_Tank_Delivery</a> table</p>
<p>Key for notes below:<br>
&nbsp;* optional data fields that can be entered using Enabler Fuel Reconciliation.<br>
&nbsp;+ these fields are calculated by The Enabler Fuel Reconciliation application when the preceeding (optional) fields are entered.<br>
</p>
'

EXEC SetColumnDesc N'Tank_Delivery', 'Tank_Delivery_ID','Unique private identifier given to the tank delivery by the system when the delivery is entered into the system. '
EXEC SetColumnDesc N'Tank_Delivery', 'Tank_ID','A link to the Tank that received the delivery. '
EXEC SetColumnDesc N'Tank_Delivery', 'Period_ID','A link to the Period in which this tank drop occurred.  '
EXEC SetColumnDesc N'Tank_Delivery', 'Tank_Movement_Type_ID','A link to the Tank_Movement_Type table. This can either be Delivery-Ticket or Delivery-TruckMeter. '
EXEC SetColumnDesc N'Tank_Delivery', 'Drop_Date_Time','The time and date that the delivery was made. '
EXEC SetColumnDesc N'Tank_Delivery', 'Record_Entry_TS','The time and date that the delivery was entered into the system.  '
EXEC SetColumnDesc N'Tank_Delivery', 'Drop_Volume','The volume of the delivery in the units specified in the global settings table. '
EXEC SetColumnDesc N'Tank_Delivery', 'Delivery_Note_Num','The external identifying number given to the delivery by the supplier. '
EXEC SetColumnDesc N'Tank_Delivery', 'Drop_Volume_Theo','If this tank delivery record was generated automatically by the tank reconciliation system (tank type 4 only) then this field contains the volume of the tank drop as calculated by the system. If this field is zero, it was not generated by the system and was most likely entered manually. Note that all automatically generated records require a corresponding manual record be entered, before the theoretical level of the tank is updated. '
EXEC SetColumnDesc N'Tank_Delivery', 'Unit_Cost_Price','The cost per unit of volume for this delivery. This is used to compute the new average cost for the tank. '
EXEC SetColumnDesc N'Tank_Delivery', 'Driver_ID_Code','A ten character identification code for the tanker driver. '
EXEC SetColumnDesc N'Tank_Delivery', 'Tanker_ID_Code','A ten character identification code for the tanker vehicle. '
EXEC SetColumnDesc N'Tank_Delivery', 'Delivery_Detail','A forty character description of the tank delivery. '
EXEC SetColumnDesc N'Tank_Delivery', 'Dispatched_Volume','(See *) Measured volume when fuel was loaded at the refinery/depot (at ambient temperature)'
EXEC SetColumnDesc N'Tank_Delivery', 'Original_Invoice_Number','(See *)The number or reference of the original invoice given at the refinery or depot. (Alphanumeric, 10 characters). '
EXEC SetColumnDesc N'Tank_Delivery', 'Received_Vol_At_Ref_Temp','(See *)This is the volume of fuel received at the site, adjusted to the standard reference point of 15°C. This value is calculated by users and entered. '
EXEC SetColumnDesc N'Tank_Delivery', 'Dispatched_Vol_At_Ref_Temp','(See *) Temperature Compensated Dispatched Volume. Where used, this value is calculated at the refinery/depot and included in the delivery invoice. '
EXEC SetColumnDesc N'Tank_Delivery', 'Total_Variance','(See +) The difference in actual volumes, i.e (received volume) - (dispatched volume) '
EXEC SetColumnDesc N'Tank_Delivery', 'Variance_At_Ref_Temp','(See +)(Transit Variance). The difference in temperature-adjusted volumes, i.e.(received volume at reference) - (dispatched volume at reference) '
EXEC SetColumnDesc N'Tank_Delivery', 'Temperature_Variance','(See +) The part of the Total Variance that is due to temperature changes from dispatch to delivery, i.e.(Total Variance - Transit Variance) '
EXEC SetColumnDesc N'Tank_Delivery', 'User_ID','A unique identifier for the person who entered the tanker delivery details (see <tt>Users</tt> table). '

go

--------------------------------------------------------------------------------
-- Tank_Detected_Delivery table
EXEC SetTableDesc N'Tank_Delivery_Detected_Delivery', 'This table provides a link between rows in the tables:<br>
<table>
 <tr><td>Detected_Tank_Deliveries</td><td>Automatically detected tanker deliveries</td></tr>
 <tr><td>Tank_delivery</td><td>Manually entred tanker deliveries</td></tr>
</table>
'

EXEC SetColumnDesc N'Tank_Delivery_Detected_Delivery', 'Tank_Del_Detect_ID','Unique private identifier for rows in this table.'
EXEC SetColumnDesc N'Tank_Delivery_Detected_Delivery', 'Site_Delivery_ID','Unique identifier for the logical tanker delivery represented by the linked data.'
EXEC SetColumnDesc N'Tank_Delivery_Detected_Delivery', 'Tank_Delivery_ID','Link to a row in the Tank_Delivery table.'
EXEC SetColumnDesc N'Tank_Delivery_Detected_Delivery', 'Detected_Tank_Delivery_ID','Link to a row in the Detected_Tank_Delivery table.'
EXEC SetColumnDesc N'Tank_Delivery_Detected_Delivery', 'Exported','Provided for export processing. Indicates whether the associated data has been exported.'
EXEC SetColumnDesc N'Tank_Delivery_Detected_Delivery', 'Record_Entry_TS','Indicates the date-time (timestamp) when the detected delivery details were recorded by Enabler.'

go

--------------------------------------------------------------------------------
-- Tank_Delivery_State table
EXEC SetTableDesc N'Tank_Delivery_State', 'This table contains a list of predefined tank delivery states.'

EXEC SetColumnDesc N'Tank_Delivery_State', 'Tank_Delivery_State_ID','Unique private identifier for this tank delivery state. '
EXEC SetColumnDesc N'Tank_Delivery_State', 'Tank_Delivery_State_Name','A short name used by the system operator to identify the tanker delivery state. '
go

--------------------------------------------------------------------------------
-- Tank_Dip_Type table
EXEC SetTableDesc N'Tank_Dip_Type' , 'This table contains a list of predefined tank dip types.'

EXEC SetColumnDesc N'Tank_Dip_Type', 'Tank_Dip_Type_ID','Unique private identifier for the dip type of a tank. '
EXEC SetColumnDesc N'Tank_Dip_Type', 'Tank_Dip_Type_Name','A short name used by the system operator to identify the dip type of a tank. '
go

--------------------------------------------------------------------------------
-- Tank_Gauge table
EXEC SetTableDesc N'Tank_Gauge' , 'This table has a record for each Tank Gauge console used at the site. A Tank Gauge is used by a Tank for fetching Tank levels and data.'

EXEC SetColumnDesc N'Tank_Gauge', 'Tank_Gauge_ID','Unique private identifier of the Tank Gauge '
EXEC SetColumnDesc N'Tank_Gauge', 'Name','A short name for the Tank Gauge, used by the operator to identify it. '
EXEC SetColumnDesc N'Tank_Gauge', 'Description','An optional, longer, more detailed description of the tank gauge. '
EXEC SetColumnDesc N'Tank_Gauge', 'Tank_Gauge_Type_ID','A link to the Tank_Gauge_Type that this Tank Gauge refers to. '
EXEC SetColumnDesc N'Tank_Gauge', 'Tank_Gauge_Number','The number of the Tank Gauge. It is an external reference number. '
EXEC SetColumnDesc N'Tank_Gauge', 'Loop_ID','A Link to the Loop table placing this Tank Gauge on a specific loop.  '
EXEC SetColumnDesc N'Tank_Gauge', 'Polling_Address','Stores the address of the ATG Console used for communication. Not used by all ATG interfaces.  '
go

--------------------------------------------------------------------------------
-- Tank_Gauge_Type table
EXEC SetTableDesc N'Tank_Gauge_Type', 'This table stores details for each type of Tank Gauge Consoles supported by The Enabler. The Tank Gauge type used can be selected using Enabler Configuration.' 

EXEC SetColumnDesc N'Tank_Gauge_Type', 'Tank_Gauge_Type_ID','Unique private identifier of the Tank Gauge Type. '
EXEC SetColumnDesc N'Tank_Gauge_Type', 'Name','A short name for the Tank Gauge Type, used by the operator to identify it. '
EXEC SetColumnDesc N'Tank_Gauge_Type', 'Protocol_ID','Link to the Protocol table defining the type of protocol for this Tank Gauge Type. '
EXEC SetColumnDesc N'Tank_Gauge_Type', 'Max_Tanks','Number of Tanks allowed to be linked to this Tank Gauge Type. '
EXEC SetColumnDesc N'Tank_Gauge_Type', 'Max_Probe','Maximum Probe Number allowed to be linked to this Tank Gauge Type. '
EXEC SetColumnDesc N'Tank_Gauge_Type', 'Gauge_Volume_Flag','If set to 1, indicates that Gauge_Volume level is supported by this tank gauge type. Default is 0. '
EXEC SetColumnDesc N'Tank_Gauge_Type', 'Gauge_TC_Volume_Flag','If set to 1, indicates that Gauge_TC_Volume level is supported by this tank gauge type. Default is 0. '
EXEC SetColumnDesc N'Tank_Gauge_Type', 'Water_Volume_Flag','If set to 1, indicates that Water_Volume level is supported by this tank gauge type. Default is 0. '
EXEC SetColumnDesc N'Tank_Gauge_Type', 'Temperature_Flag','If set to 1, indicates that Temperature is supported by this tank gauge type. Default is 0. '
EXEC SetColumnDesc N'Tank_Gauge_Type', 'Density_Flag','If set to 1, indicates that Density is supported by this tank gauge type. Default is 0. '
EXEC SetColumnDesc N'Tank_Gauge_Type', 'Tank_Delivery_Flag','If set to 1, indicates that the gauge can detect tanker deliveries. Default is 0. '
EXEC SetColumnDesc N'Tank_Gauge_Type', 'Poll_Response_TO','The Poll Response timeout for this gauge. '
go

--------------------------------------------------------------------------------
-- Tank_History table
EXEC SetTableDesc N'Tank_History' , 'This table stores the historical (open/close) readings of tanks based on periods.'

EXEC SetColumnDesc N'Tank_History', 'Period_ID','A link to the Period that contains this history record. '
EXEC SetColumnDesc N'Tank_History', 'Tank_ID','A link to the Tank that owns this history record. '
EXEC SetColumnDesc N'Tank_History', 'Open_Gauge_Volume','The tank gauge volume at the start of this period. '
EXEC SetColumnDesc N'Tank_History', 'Close_Gauge_Volume','The tank gauge volume at the end of this period. '
EXEC SetColumnDesc N'Tank_History', 'Open_Water_Volume','The tank gauge water volume at the start of this period. '
EXEC SetColumnDesc N'Tank_History', 'Close_Water_Volume','The tank gauge water volume at the end of this period. '
EXEC SetColumnDesc N'Tank_History', 'Open_Gauge_TC_Volume','The tank gauge TC (temperature compensated) volume when this period was opened. '
EXEC SetColumnDesc N'Tank_History', 'Open_Gauge_TC_Volume_Flag','Indicates whether the ATG provides Temperature Compensated volume reading when the period is opened.'
EXEC SetColumnDesc N'Tank_History', 'Close_Gauge_TC_Volume_Flag','Indicates whether the ATG provides Temperature Compensated volume reading when the period is closed.'
EXEC SetColumnDesc N'Tank_History', 'Close_Gauge_TC_Volume','The tank gauge TC (temperature compensated) volume when this period was closed. '
EXEC SetColumnDesc N'Tank_History', 'Open_Fuel_Density','The opening density readings reported by the tank gauge for this period. '
EXEC SetColumnDesc N'Tank_History', 'Close_Fuel_Density','The closing density readings reported by the tank gauge for this period. '
EXEC SetColumnDesc N'Tank_History', 'Open_Fuel_Temp','The opening temperature readings reported by the tank gauge for this period. '
EXEC SetColumnDesc N'Tank_History', 'Close_Fuel_Temp','The closing temperature readings reported by the tank gauge for this period. '
EXEC SetColumnDesc N'Tank_History', 'Open_Theo_Volume','The tank theoretical volume when this period was opened. '
EXEC SetColumnDesc N'Tank_History', 'Close_Theo_Volume','The tank theoretical volume when this period was closed. '
EXEC SetColumnDesc N'Tank_History', 'Open_Dip_Volume','The tank dip ( manual ) volume when this period was opened. '
EXEC SetColumnDesc N'Tank_History', 'Close_Dip_Volume','The tank dip ( manual ) volume when this period was closed. '
EXEC SetColumnDesc N'Tank_History', 'Open_Dip_Water_Volume','The tank dip water ( manual ) volume when this period was opened. '
EXEC SetColumnDesc N'Tank_History', 'Close_Dip_Water_Volume','The tank dip water ( manual ) volume when this period was closed. '
EXEC SetColumnDesc N'Tank_History', 'Open_Dip_Type_ID','A link to the Tank Dip_Type table. Refers to the opening quality of manually entered dip levels. '
EXEC SetColumnDesc N'Tank_History', 'Close_Dip_Type_ID','A link to the Tank Dip_Type table. Refers to the closing quality of manually entered dip levels. '
EXEC SetColumnDesc N'Tank_History', 'Hose_Del_Quantity','The total number of hose deliveries done from this tank during this period. '
EXEC SetColumnDesc N'Tank_History', 'Hose_Del_Volume','The total volume of hose deliveries done from this tank during this period. '
EXEC SetColumnDesc N'Tank_History', 'Hose_Del_Value','The total value of hose deliveries done from this tank during this period. '
EXEC SetColumnDesc N'Tank_History', 'Hose_Del_Cost','The total cost of hose deliveries done from this tank during this period. '
EXEC SetColumnDesc N'Tank_History', 'Tank_Del_Quantity','The number of deliveries into that tank for that period. '
EXEC SetColumnDesc N'Tank_History', 'Tank_Del_Volume','The total volume of tank deliveries during this period. '
EXEC SetColumnDesc N'Tank_History', 'Tank_Del_Cost','The total cost of deliveries into the tank during that period. '
EXEC SetColumnDesc N'Tank_History', 'Tank_Loss_Quantity','The number of losses from that tank for this period. '
EXEC SetColumnDesc N'Tank_History', 'Tank_Loss_Volume','The total volume of tank losses during this period. '
EXEC SetColumnDesc N'Tank_History', 'Tank_Transfer_In_Quantity','The number of transfers to that tank for this period. '
EXEC SetColumnDesc N'Tank_History', 'Tank_Transfer_In_Volume','The total volume of transfers to that tank during this period. '
EXEC SetColumnDesc N'Tank_History', 'Tank_Transfer_Out_Quantity','The number of transfers from that tank for this period. '
EXEC SetColumnDesc N'Tank_History', 'Tank_Transfer_Out_Volume','The total volume of transfers from that tank during this period. '
EXEC SetColumnDesc N'Tank_History', 'Open_Tank_Probe_Status_ID','Indicates the status of the probe when the period was opened - see Tank Probe_Status table.'
EXEC SetColumnDesc N'Tank_History', 'Close_Tank_Probe_Status_ID','Indicates the status of the probe when the period was closed - see Tank Probe_Status table. '
EXEC SetColumnDesc N'Tank_History', 'Tank_Readings_DT','Date and Time stamp for the last tank gauge readings for this period. '
EXEC SetColumnDesc N'Tank_History', 'Open_Tank_Delivery_State_ID','A link to the Tank Delivery State table. Refers whether a tanker delivery was detected while the period is being opened. '
EXEC SetColumnDesc N'Tank_History', 'Close_Tank_Delivery_State_ID','A link to the Tank Delivery State table. Refers whether a tanker delivery was detected while the period is being closed. '
EXEC SetColumnDesc N'Tank_History', 'Open_Pump_Delivery_State','A flag indicating whether a pump delivery was made from the tank while the period is being opened. '
EXEC SetColumnDesc N'Tank_History', 'Close_Pump_Delivery_State','A flag indicating whether a pump delivery was made from the tank while the period is being closed. '
EXEC SetColumnDesc N'Tank_History', 'Dip_Fuel_Temp','The tank dip ( manual ) temperature when this period was closed. '
EXEC SetColumnDesc N'Tank_History', 'Dip_Fuel_Density','The tank dip ( manual ) density when this period was closed. '
EXEC SetColumnDesc N'Tank_History', 'Tank_Variance_Reason_ID','A comma delimeted list of possible reasons for tank variances. Refer to Tank Variance_Reason for the list. '

go

--------------------------------------------------------------------------------
-- Tank_Loss table
EXEC SetTableDesc N'Tank_Loss' , 'This table contains details of tank losses as manually entered using the Enabler Fuel Reconciliation application.'

EXEC SetColumnDesc N'Tank_Loss', 'Tank_Loss_ID','Unique private identifier given to the tank loss by the system when the loss is entered into the system. '
EXEC SetColumnDesc N'Tank_Loss', 'Tank_ID','A link to the Tank that received the loss. '
EXEC SetColumnDesc N'Tank_Loss', 'Period_ID','A link to the Period in which this tank loss occurred.  '
EXEC SetColumnDesc N'Tank_Loss', 'Tank_Movement_Type_ID','A link to the Tank_Movement_Type table. Tank_Movement_Type_ID can any be any of the following: ProductUplift, WaterUplift, or Empty. '
EXEC SetColumnDesc N'Tank_Loss', 'Loss_Date_Time','The time and date that the loss happened. '
EXEC SetColumnDesc N'Tank_Loss', 'Record_Entry_TS','The time and date that the loss was entered into the system.  '
EXEC SetColumnDesc N'Tank_Loss', 'Loss_Volume','The volume of the loss in the units specified in the global settings table. '
EXEC SetColumnDesc N'Tank_Loss', 'Loss_Volume_Theo','If this tank loss record was generated automatically by the tank reconciliation system (tank type 4 only) then this field contains the volume of the tank loss as calculated by the system. If this field is zero, it was not generated by the system and was most likely entered manually. Note that all automatically generated records require a corresponding manual record be entered, before the theoretical level of the tank is updated. '
EXEC SetColumnDesc N'Tank_Loss', 'Loss_Doc_Ref','A reference to the document that describes the transfer. '
EXEC SetColumnDesc N'Tank_Loss', 'Loss_Detail','A description of the tank loss. '
EXEC SetColumnDesc N'Tank_Loss', 'User_ID','When set this indicates the user who entered the Tank Loss data (see <a href=
"EnablerDB_db~s-dbo~t-Users.html">Users</a> table). '

go

--------------------------------------------------------------------------------
-- Tank_Movement_Type table
EXEC SetTableDesc N'Tank_Movement_Type' , 'This table contains a list of predefined tank movements.'

EXEC SetColumnDesc N'Tank_Movement_Type', 'Tank_Movement_Type_ID','Unique private identifier for this tank movement type. '
EXEC SetColumnDesc N'Tank_Movement_Type', 'Tank_Movement_Type_Name','A short name used by the system operator to identify this tank movement type. '
go

--------------------------------------------------------------------------------
-- Tank_Probe_Status table
EXEC SetTableDesc N'Tank_Probe_Status' , 'This table defines the tank probe status values - as used in the Tanks and Tank_History tables.
<table>
<tr><th>Tank_Probe_Status_ID</th><th>Description</th></tr>
<tr><td>1</td><td>Indicates there is no tank probe assigned to the tank.</td></tr>
<tr><td>2</td><td>There is a probe assigned to the tank, and the probe is online and communicating as expected.</td></tr>
<tr><td>3</td><td>The probe assigned to the tank is offline (not responding). E.g. the communication link to the tank gauge console is down.</td></tr>
<tr><td>4</td><td>The probe status is unknown or cannot be determined.</td></tr>
</table>'

EXEC SetColumnDesc N'Tank_Probe_Status', 'Tank_Probe_Status_ID','Unique private identifier for the status of a tank probe. '
EXEC SetColumnDesc N'Tank_Probe_Status', 'Tank_Probe_Status_Name','A short name used by the system operator to identify the status of a tank probe. '
go

--------------------------------------------------------------------------------
-- Tank_Reading_Type table
EXEC SetTableDesc N'Tank_Reading_Type' , 'This table contains a list of predefined tank reading types.'

EXEC SetColumnDesc N'Tank_Reading_Type', 'Tank_Reading_Type_ID','Unique private identifier for this tank reading type. '
EXEC SetColumnDesc N'Tank_Reading_Type', 'Tank_Reading_Type_Name','The description for this tank reading type. '
go

--------------------------------------------------------------------------------
-- Tank_Readings table
EXEC SetTableDesc N'Tank_Readings' , 'This table stores the historical (open/close) readings of tanks based on periods. This is a replacement table for a few of the tank reading fields found in the Tank_History table.'

EXEC SetColumnDesc N'Tank_Readings', 'Period_ID','A link to the Period that contains this history record. '
EXEC SetColumnDesc N'Tank_Readings', 'Tank_ID','A link to the Tank that owns this history record. '
EXEC SetColumnDesc N'Tank_Readings', 'Tank_Reading_Type_ID','A link to the Tank Reading Type. '
EXEC SetColumnDesc N'Tank_Readings', 'Open_Reading_Value','The value for this tank reading when the period was opened. '
EXEC SetColumnDesc N'Tank_Readings', 'Close_Reading_Value','The value for this tank reading when the period was closed. '
EXEC SetColumnDesc N'Tank_Readings', 'User_ID','A unique identifier for the person who entered the tank reading (see <a href=
"EnablerDB_db~s-dbo~t-Users.html">Users</a> table). '
EXEC SetColumnDesc N'Tank_Readings', 'Open_Dip_Type_ID','A link to the Tank Dip_Type table. Refers to the opening quality for this tank reading. '
EXEC SetColumnDesc N'Tank_Readings', 'Close_Dip_Type_ID','A link to the Tank Dip_Type table. Refers to the closing quality for this tank reading. '
go

--------------------------------------------------------------------------------
-- Tank_Strapping table TODO
--EXEC SetTableDesc N'Tank_Strapping' , ''
--go

--------------------------------------------------------------------------------
-- Tank_Transfer table
EXEC SetTableDesc N'Tank_Transfer', 'This table contains details of tank transfers as manually entered using the Enabler Fuel Reconciliation application.'

EXEC SetColumnDesc N'Tank_Transfer', 'Tank_Transfer_ID','Unique private identifier given to the tank transfer by the system when the transfer is entered into the system. '
EXEC SetColumnDesc N'Tank_Transfer', 'From_Tank_ID','A link to the Tank where the fuel was transferred from. '
EXEC SetColumnDesc N'Tank_Transfer', 'To_Tank_ID','A link to the Tank where the fuel was transferred to. '
EXEC SetColumnDesc N'Tank_Transfer', 'Period_ID','A link to the Period in which this tank loss occurred.  '
EXEC SetColumnDesc N'Tank_Transfer', 'Tank_Movement_Type_ID','A link to the Tank_Movement_Type table. Tank_Movement_Type_ID can be TestTransfer or TanktoTank. '
EXEC SetColumnDesc N'Tank_Transfer', 'Delivery_ID','Optional link to a row in Hose_Delivery table that indicates the details of fuel transferred using a forecourt dispenser.'
EXEC SetColumnDesc N'Tank_Transfer', 'Transfer_Date_Time','The time and date that the transfer happened. '
EXEC SetColumnDesc N'Tank_Transfer', 'Record_Entry_TS','The time and date that the transfer was entered into the system.  '
EXEC SetColumnDesc N'Tank_Transfer', 'Transfer_Volume','The volume of the transfer in the units specified in the global settings table. '
EXEC SetColumnDesc N'Tank_Transfer', 'Transfer_Doc_Ref','A reference to the document that describes the transfer. '
EXEC SetColumnDesc N'Tank_Transfer', 'Transfer_Detail','A description of the tank transfer. '
EXEC SetColumnDesc N'Tank_Transfer', 'User_ID','When specified this indicates the person who entered the tank transfer data (see <a href=
"EnablerDB_db~s-dbo~t-Users.html">Users</a> table). '
go

--------------------------------------------------------------------------------
-- Tank_Type table
EXEC SetTableDesc N'Tank_Type' , 'This table contains a list of predefined tank types.'

EXEC SetColumnDesc N'Tank_Type', 'Tank_Type_ID','Unique private identifier for this tank type. '
EXEC SetColumnDesc N'Tank_Type', 'Tank_Type_Name','A short name used by the system operator to identify this tank type. '
go

--------------------------------------------------------------------------------
-- Tank_Variance_Reason table
EXEC SetTableDesc N'Tank_Variance_Reason', 'This table stores a predefined list of reasons for tank variances.'

EXEC SetColumnDesc N'Tank_Variance_Reason', 'Reason_ID','Unique private identifier for this tank variance reason. '
EXEC SetColumnDesc N'Tank_Variance_Reason', 'Reason_Description','The description for this tank variance reason. '

go

--------------------------------------------------------------------------------
-- Tanks table
EXEC SetTableDesc N'Tanks' , '<p>Each Tank is defined by one record. Many of the fields are populated from data retreived from a Tank Gauge, and will remain as zero if there is no Tank Gauge connected.</p>
<p>In Enabler v4.0 the following fields have been removed:<br>
&nbsp;Tank_Type</p>'

EXEC SetColumnDesc N'Tanks', 'Tank_ID','Unique private identifier of the tank '
EXEC SetColumnDesc N'Tanks', 'Grade_ID','A link to the Grade that this tank contains '
EXEC SetColumnDesc N'Tanks', 'Tank_Name','A short name for the tank, used by the operator to identify it. '
EXEC SetColumnDesc N'Tanks', 'Tank_Number','The number of the tank. It is an external reference number. (In Enabler versions prior to 3.2 this was the number of the tank as configured in the tank gauge.) '
EXEC SetColumnDesc N'Tanks', 'Tank_Description','An optional, longer, more detailed description of the tank. '
EXEC SetColumnDesc N'Tanks', 'Capacity','The physical capacity of the tank. '
EXEC SetColumnDesc N'Tanks', 'Gauge_Level','The current level of the tank (in meters) as reported by an electronic tank gauge connected to this tank. '
EXEC SetColumnDesc N'Tanks', 'Temperature','The temperature in the tank as reported by the Tank Gauge. '
EXEC SetColumnDesc N'Tanks', 'Gauge_TC_Volume','The temperature corrected volume in the tank as reported by the Tank Gauge. '
EXEC SetColumnDesc N'Tanks', 'Water_Volume','The water volume of the tank as reported by the Tank Gauge. '
EXEC SetColumnDesc N'Tanks', 'Water_Level','The water level of the tank (in meters) as reported by the Tank Gauge. '
EXEC SetColumnDesc N'Tanks', 'Dip_Level','The last manual tank dip level reading as entered by the operator. '
EXEC SetColumnDesc N'Tanks', 'Gauge_Volume','The current volume in the tank as reported by the Tank Gauge. '
EXEC SetColumnDesc N'Tanks', 'Theoretical_Volume','The theoretical volume of the tank as calculated by the system every time a delivery is completed or a tank delivery is entered. '
EXEC SetColumnDesc N'Tanks', 'Dip_Volume','The last manual tank dip volume reading as entered by the operator. '
EXEC SetColumnDesc N'Tanks', 'Average_Cost','The average unit cost of the fuel in this tank. The average cost is a rolling weighted average. ie. when a tank drop is done the new average cost is: ( current_level * average_cost + drop_volume * drop_cost_price ) / ( current_level + drop_volume ) '
EXEC SetColumnDesc N'Tanks', 'Strapped_Tank_ID','An optional link to the tank ID of another record in the Tank Table to which this tank may be connected. The levels for strapped tanks are tied, and the system considers them as one logical tank. The value of this field is only used when the Tank_Type is set to Strapped or Switch. '
EXEC SetColumnDesc N'Tanks', 'Ullage','The ullage level of the tank as reported by the Tank Gauge. '
EXEC SetColumnDesc N'Tanks', 'Water_Volume','The water volume of the tank as reported by the Tank Gauge. '
EXEC SetColumnDesc N'Tanks', 'Gauge_alarms','An string of 50 ASCII characters, either 0 or 1 representing the state of up to fifty tank alarms or warnings (reported by the tank gauge). <br>
<pre> 1 = alarm/warning is active.
 0 = inactive</pre>'
EXEC SetColumnDesc N'Tanks', 'Tank_Type_ID','A link to the Tank Type table. Refers to the type of tank. This field will be used (in conjunction with the Tank_Connection_Type field) as a replacement for the legacy Tank_Type field. '
EXEC SetColumnDesc N'Tanks', 'Tank_Connection_Type_ID','A link to the Tank_Connection_Type table. Refers to the connection of a tank. This field will be used (in conjunction with the Tank_Type_ID field) as a replacement for the legacy Tank_Type field. '
EXEC SetColumnDesc N'Tanks', 'Tank_Gauge_ID','A link to the Tank Gauge that this tank is linked to. '
EXEC SetColumnDesc N'Tanks', 'Tank_Probe_Status_ID','A link to the Tank Probe_Status table. Refers to the current status of the probe for a gauged tank. '
EXEC SetColumnDesc N'Tanks', 'Tank_Readings_DT','Date and Time stamp for the last tank gauge readings. '
EXEC SetColumnDesc N'Tanks', 'Tank_Delivery_State_ID','A link to the Tank Delivery State table. Refers whether a tanker delivery is detected for the tank. '
EXEC SetColumnDesc N'Tanks', 'Pump_Delivery_State','A flag indicating whether a pump delivery is being made from the tank. '
EXEC SetColumnDesc N'Tanks', 'Diameter','The diameter of the tank in meters. '
EXEC SetColumnDesc N'Tanks', 'Low_Volume_Warning','The minimum volume in a tank below which a warning is generated of the need for a tank drop. '
EXEC SetColumnDesc N'Tanks', 'Low_Volume_Alarm','The minimum volume in a tank below which an alarm is generated to indicate the need for a tank drop. '
EXEC SetColumnDesc N'Tanks', 'Low_Temperature','The minimum temperature allowed for the tank. '
EXEC SetColumnDesc N'Tanks', 'Hi_Volume_Warning','The maximum volume above which a warning is generated to indicate that the tank has been overfilled. '
EXEC SetColumnDesc N'Tanks', 'Hi_Volume_Alarm','The maximum volume above which an alarm is generated to indicate that the tank has been overfilled. '
EXEC SetColumnDesc N'Tanks', 'Hi_Water_Alarm','The maximum level of the water in a tank above which an alarm is generated. '
EXEC SetColumnDesc N'Tanks', 'Hi_Temperature','The maximum temperature allowed for the tank. '
EXEC SetColumnDesc N'Tanks', 'Probe_Number','Since Enabler version 3.2 this is the probe/tank number of the tank as configured in the Tank Gauge. '
EXEC SetColumnDesc N'Tanks', 'Density','The observed average density of the product in the Tank Gauge. '
EXEC SetColumnDesc N'Tanks', 'Deleted','The deleted state of the tank:<br>
<pre> 1 = Deleted
 0 = Active</pre>'
EXEC SetColumnDesc N'Tanks', 'Auto_Disable','<p>This determines whether the tank can be automatically disabled and enabled.</p>
<p>1 (TRUE) = This tank can be automatically disabled and enabled (e.g. Blocked/Unblocked). Is_Enabled bit  The blocked state of this tank.</p>
<p>0 (FALSE) = This tank must be manually blocked using the API or Enabler Web.</p>'
EXEC SetColumnDesc N'Tanks', 'Physical_Label','Text indicating any physical labels or makings on the tank or cover plate.'
EXEC SetColumnDesc N'Tanks', 'Loss_Tolerance_Vol','Tolerance for stock shrinkage/loss used for stock reconciliation on this tank.'
EXEC SetColumnDesc N'Tanks', 'Gain_Tolerance_Vol','Tolerance for stock gain used for stock reconciliation on this tank.'
EXEC SetColumnDesc N'Tanks', 'Is_Enabled','Indicate the block status/reason(s) for this tank. Tanks may be blocked manually or automatically. Zero indicates the tank is active. '
go

--------------------------------------------------------------------------------
-- Terminals table
EXEC SetTableDesc N'Terminals', 'This table provides access control and connectivity options for client applications (terminals) that connect to The Enabler Server.'

EXEC SetColumnDesc N'Terminals', 'Terminal_ID','Internal identifier for this terminal. Used by the client application to connect using The Enabler API.'
EXEC SetColumnDesc N'Terminals', 'Name','Logical name (description) of the connecting application.'
EXEC SetColumnDesc N'Terminals', 'Password','Optional password to restrict or control connection of client applications.'
EXEC SetColumnDesc N'Terminals', 'Permissions','Flags to determine what API functionality the client application can use. <br>
A 16 byte string with each offset assigned to a specific API permission (&quot;1&quot; for Enabled, &quot;0&quot; Not Disabled).<br>
<pre>
Offset   Description
0        Allowed to Connect
1        Allowed to Control pumps
2        Allowed to Change Price
3        Allowed to Change Modes
4        Allowed to Change Configuration
5-15     Unused (Default to &quot;0&quot;)
</pre>'
EXEC SetColumnDesc N'Terminals', 'Enabled','Option to allow/disallow connection of the client application.'
EXEC SetColumnDesc N'Terminals', 'Last_Connect','Date/time this client application last connected to the server.'
EXEC SetColumnDesc N'Terminals', 'Api_ID','Reserved for future use. Default is -1.'
go

--------------------------------------------------------------------------------
-- Users table
EXEC SetTableDesc N'Users' , 'Contains details of users authorised to access the Enabler server.'

EXEC SetColumnDesc N'Users', 'User_ID',            'Internal identifier of the user.'
EXEC SetColumnDesc N'Users', 'Login_Name',         'Login for the user.'
EXEC SetColumnDesc N'Users', 'User_Name',          'Real name of the user.'
EXEC SetColumnDesc N'Users', 'Password',           'Password used to validate logins to Enabler Web.'
EXEC SetColumnDesc N'Users', 'No_Activity_Timeout','Time in seconds for a Web session to be idle before the user is logged out.'
EXEC SetColumnDesc N'Users', 'Last_Page_Accessed', 'Link to the last page accessed (used for reconnections).'
EXEC SetColumnDesc N'Users', 'Language',           'Language of the user - determines the strings used in Enabler Web applications. '
EXEC SetColumnDesc N'Users', 'Role_ID',            'Link to the role profile for the user. This determines the access rights for the user.'
go

-- EXEC SetTableDesc N'Version_History' , ''

--------------------------------------------------------------------------------
-- Volume_Unit table
EXEC SetTableDesc N'Volume_Unit' , 'This table contains a list of predefined Grades units of measure.'

EXEC SetColumnDesc N'Volume_Unit', 'Volume_Unit_ID','Unique private identifier for this unit of measure. '
EXEC SetColumnDesc N'Volume_Unit', 'Volume_Unit_Name','The description for this unit of measure. '
EXEC SetColumnDesc N'Volume_Unit', 'Volume_Short_Name','The short description for this unit of measure. '
go

--------------------------------------------------------------------------------
-- WetStock_Approval table
EXEC SetTableDesc N'WetStock_Approval', 'This table contains Wetstock Approval data to be used for tank reconciliation.'

EXEC SetColumnDesc N'WetStock_Approval', 'Wetstock_Approval_ID','Unique private identifier for this wetstock approval entry. '
EXEC SetColumnDesc N'WetStock_Approval', 'DateTime','Specifies the date time stamp for the approval. '
EXEC SetColumnDesc N'WetStock_Approval', 'Approving_Name','The name of the person who has Approved or Authorized wet stock data for this period. '
EXEC SetColumnDesc N'WetStock_Approval', 'Approving_ID','The User_ID of the person who has Approved or Authorized wet stock data for this period (see <a href=
"EnablerDB_db~s-dbo~t-Users.html">Users</a> table). '
go


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'setColumnDesc' AND type = 'P')
   DROP PROCEDURE setColumnDesc
go
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'setTableDesc' AND type = 'P')
   DROP PROCEDURE setTableDesc
go
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'setTableSummary' AND type = 'P')
   DROP PROCEDURE setTableSummary
go
