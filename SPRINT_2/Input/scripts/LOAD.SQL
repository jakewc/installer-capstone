--
--
-- ENABLER DATABSE INSTALLATION SCRIPT
--
-- This script is responsible to create procedures and is used for both new and 
-- upgrade installations. Tables are created by ENABLER.SQL
--
-- The order of procedures here is based on the order they were added - this allows for easier
-- comparison between versions of this file - do not sort the contents of this file.
-- 
-- $Header: /Enabler/Data Model/DBU 4.0/LOAD.SQL 64    11/16/18 2:48p Markt $
--

print '------------------------------------------------------------'
print 'Loading Enabler Database stored procedures...'
print CONVERT(varchar,getdate(), 121)
go

---------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'sp_log_patch' AND type = 'P')
   DROP PROCEDURE sp_log_patch
go

print 'Dropping sp_log_patch'
go


---------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'sp_log_delivery' AND type = 'P')
	DROP PROCEDURE sp_log_delivery
go

print 'Creating sp_log_delivery'
go


-- ##SUMMARY <p><font color="red"><b>FOR INTERNAL USE ONLY</b></font></p> <p>The SP_LOG_DELIVERY procedure logs details of a pump delivery</p>
--
-- ##REMARKS <p>This procedure is used by Pump Server every time a delivery at a pump is completed. </p>
-- ##REMARKS <p>This routine inserts the delivery into the Hose_Delivery table and updates the hose and 
-- ##REMARKS tank totals (history) tables accordingly.</p>
--
-- ##RETURNS Returns the ID of the Hose_Delivery row inserted, using the @ID output parameter.
CREATE PROCEDURE sp_Log_Delivery
    @id int OUTPUT ,                 -- ##PARAM @id           the <tt>Delivery_ID</tt> (primary key) of the row added to the <tt>Hose_Delivery</tt> table to store this data
    @hose_id int ,                   -- ##PARAM @hose_id      id of hose that made the delivery 
    @type tinyint ,                  -- ##PARAM @type         the delivery type 
    @price_level smallint ,          -- ##PARAM @price_level  the price level that the delivery was made at
    @sell_price decimal(9,3) ,       -- ##PARAM @sell_price   the unit sell price of the delivery 
    @value decimal(11,2) ,           -- ##PARAM @value        the total sell price of the delivery 
    @volume decimal (9,3) ,          -- ##PARAM @volume       the total volume of the delivery 
    @state tinyint ,                 -- ##PARAM @state        the state of the pump at the end of the delivery 
    @reserved_by int ,               -- ##PARAM @reserved_by  who reserved the pump for this delivery, or -1 
    @attendant_id int ,              -- ##PARAM @attendant_id the ID of the attendant 
    @volume_total decimal( 13 , 2 ) ,-- ##PARAM @volume_total the volume electronic total on the pump  
    @money_total decimal( 13 , 2 ) , -- ##PARAM @money_total  the money electronic total on the pump  
    @volume2 decimal (9,3)           -- ##PARAM @volume2      the total second (blenders only) volume of the delivery 
AS

DECLARE @buy_price decimal(12,4) ,   -- the unit cost price of the delivery 
    @tank_id int ,                   -- the id of the tank the supplied this delivery
    @tank2_id int ,                  -- the id of the second tank ( blenders only ) 
    @pvt_id int ,                    -- unique id for pvt record 
    @tank_capacity decimal(12,4),
    @tank_theo_volume decimal(15,4)

BEGIN 

   /* generate a private ID for this delivery 
   ** determine which tank this delivery came From 
   ** and get the cost price of the delivery */

   BEGIN TRANSACTION 

   SELECT @id = -1 
   /* update the theoretical and electronic meters for this hose */
   UPDATE hoses
      SET volume_total = @volume_total ,
          money_total  = @money_total ,
          theoretical_total = theoretical_total + @volume 
   WHERE hose_id = @hose_id 

   /* this may have been just a change in the meters so bail out now */
   IF @VOLUME = 0 
   BEGIN 
      COMMIT TRANSACTION 
      RETURN 
   END 

   SELECT @id        = ( SELECT MAX( delivery_id ) + 1 FROM hose_delivery ) , 
      @tank_id   = ( SELECT tank_id FROM hoses WHERE hose_id = @hose_id ) ,
      @tank2_id   = ( SELECT tank2_id FROM hoses WHERE hose_id = @hose_id ) 

   SELECT @buy_price = ( SELECT average_cost FROM tanks WHERE tank_id = @tank_id )  

   IF @id IS NULL SELECT @id = 1 

   /* insert the delivery into the hose_delivery table */

   INSERT INTO hose_delivery 
      ( delivery_id , 
        hose_id , 
        completed_ts ,
        delivery_type , 
        del_sell_price , 
        del_cost_price ,
        delivery_value ,
        delivery_volume , 
        delivery_state ,
        price_level , 
        reserved_by , 
        attendant_id ,
        delivery2_volume ,
        hose_meter_volume ,
        hose_meter_value ) 
   VALUES 
      ( @id ,
        @hose_id ,
        getdate() ,
        @type ,
        @sell_price ,
        @buy_price ,
        @value ,
        @volume ,
        @state ,
        @price_level ,
        @reserved_by ,
        @attendant_id ,
        @volume2 , 
        @volume_total ,
        @money_total ) 

   /* if this tank is conencted to another (manifolded) then adjust volume in connected tank */
   IF ( SELECT tank_connection_type_id FROM tanks WHERE tank_id = @tank_id  ) > 1 
        SELECT @tank_id = ( SELECT strapped_tank_id FROM tanks WHERE tank_id = @tank_id ) 
   IF ( SELECT tank_connection_type_id FROM tanks WHERE tank_id = @tank2_id  ) > 1 
        SELECT @tank2_id = ( SELECT strapped_tank_id FROM tanks WHERE tank_id = @tank2_id ) 
	

   SELECT @tank_capacity    =  ( SELECT capacity FROM tanks WHERE tank_id = @tank_id ),
          @tank_theo_volume =  ( SELECT theoretical_volume FROM tanks WHERE tank_id = @tank_id )

   If ( @tank_theo_volume - @volume + @volume2 ) > ( 0 - @tank_capacity)
   BEGIN

   /* update the theoritical tank level for this delivery */
   UPDATE tanks 
      SET theoretical_volume = theoretical_volume - @volume + @volume2
      WHERE tank_id = @tank_id 
        
   END
   ELSE
   BEGIN
  	/* update the theoritical tank level for this delivery */
	UPDATE tanks 
		SET theoretical_volume = (0 - @tank_capacity)
	 WHERE tank_id = @tank_id 
   END	

   SELECT @tank_capacity    =  ( SELECT capacity FROM tanks WHERE tank_id = @tank2_id ),
          @tank_theo_volume =  ( SELECT theoretical_volume FROM tanks WHERE tank_id = @tank2_id )

   If ( @tank_theo_volume - @volume2 ) > ( 0 - @tank_capacity)
   BEGIN		

   /* update the theoritical tank level for this delivery */
   UPDATE tanks 
      SET theoretical_volume = theoretical_volume - @volume2
   WHERE tank_id = @tank2_id 
   END
   ELSE
   BEGIN
	/* update the theoritical tank level for this delivery */
	UPDATE tanks 
   		SET theoretical_volume = (0 - @tank_capacity)
 	 WHERE tank_id = @tank2_id 
   END

   /* if PVT totalling is turned on then update the PVT totals */
   IF ( SELECT pvt_on FROM global_settings ) <> 0 
   BEGIN 
      /* close off any open PVT records for this hose with a different price */
      /* cause code 1 is price change */
      UPDATE PVT 
         SET PVT_cause_code = 1 , 
             PVT_stop_time = getdate() 
         WHERE PVT_cause_code IS NULL AND 
               hose_id = @hose_id AND 
               PVT_price > 0 AND 
                  PVT_price <> @sell_price 

      /* determine if there are any records open for this hose */
      IF ( SELECT COUNT(*) 
             FROM PVT 
             WHERE hose_id = @hose_id AND 
                   PVT_cause_code is NULL ) = 0 
      BEGIN 

           /* if not create one for this hose and price */
           SELECT @pvt_id = ( SELECT MAX( pvt_id ) + 1 FROM PVT )
           IF @PVT_id IS NULL SELECT @PVT_id = 1 

           INSERT INTO PVT 
              ( PVT_id , 
                hose_id , 
                PVT_start_time , 
                PVT_Price ) 
           VALUES 
              ( @pvt_id , 
                @hose_id , 
                getdate() , 
                @sell_price ) 

      END 
   
      /* update the STM totals */ 
      UPDATE PVT 
         SET PVT_Price = @sell_price ,
             PVT_Quantity = PVT_Quantity + 1 , 
             PVT_Volume = PVT_Volume + @volume , 
             PVT_Value = PVT_Value + @value 
         WHERE hose_id = @hose_id AND 
             PVT_cause_code is NULL 

   END  
 
   /* Calls another stored procedure, allowing clients to write their own user-defined hook */
   if EXISTS  (SELECT null FROM SYSOBJECTS WHERE NAME = 'sp_post_delivery' AND XTYPE = 'P')
      IF (@id > -1)
         EXEC ('sp_post_delivery ' + @id)      

   COMMIT TRANSACTION 

END
go 




---------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'sp_log_tank_testtransfer' AND type = 'P')
	DROP PROCEDURE sp_Log_Tank_TestTransfer
go


-- ##SUMMARY <p>The SP_LOG_TANK_TESTTRANSFER procedure is provided to update Tank History when tank transfer records are entered to facilitate wet stock management.</p>
--
-- ##REMARKS <p>The Wet Stock (Fuel Reconciliation) functionality in Enabler provides recording of tank movements and losses.
-- ##REMARKS This routine is a hook provided to create a Tank_Transfer row using data from a test delivery record (row in 
-- ##REMARKS Hose_Delivery table). The new row inserted will be added to the currently open wet stock period (day).</p>
-- ##REMARKS <p>The created row should have the From_Tank_ID column set based on the hose where the delivery was done, 
-- ##REMARKS but the To_Tank_ID will be set to the same tank, and will need to be edited to ensure the data is correct.</p>
--
-- ##RETURNS No return data.
CREATE PROCEDURE sp_Log_Tank_TestTransfer
	@id int                    	   	   -- ##PARAM @id unique key for delivery 
AS
BEGIN 
		
	/* Test Transfer Flag set? */
	DECLARE @flag INT
 	SET @flag = (SELECT TOP 1 Map_Test_Delivery_To_Tank_Transfer FROM Global_Settings)
 	IF (@flag IS NULL) OR (@flag = 0)
	BEGIN
		PRINT 'Map_Test_Delivery_To_Tank_Transfer not set'		
		RETURN
 	END

	/* Look for an open Day Period */
 	DECLARE @opendayperiod INT
 	DECLARE @tanktransferid INT
 	SET @opendayperiod = (SELECT TOP 1 Period_ID FROM Periods WHERE Period_Type=2 And Period_State=1.0)
 	IF (@opendayperiod IS NULL) OR (@opendayperiod = 0)
 	BEGIN
		PRINT 'Missing Day Period!'
		RETURN
 	END

	-- Determine if this is a postmix delivery
	DECLARE @postMixDel tinyint
	IF (SELECT tank2_id FROM hoses h, hose_delivery hd WHERE delivery_id = @id AND h.hose_id = hd.hose_id) IS NULL
		SET @postMixDel = 0
	ELSE
		SET @postMixDel = 1
			 
	/* Create the test transfer details */
 	DECLARE @tankid int
 	DECLARE @deliveryvolume decimal(12,4)

	DECLARE @tanktransferid2 int
	DECLARE @deliveryvolume2 decimal(12,4)
	DECLARE @tankid2 int

	SET @tanktransferid = (SELECT MAX(tank_transfer_id)+1 FROM Tank_Transfer)
	IF @tanktransferid IS NULL
	BEGIN
		SET @tanktransferid = 1
	END

	SET @tankid = (SELECT tank_id FROM hoses h, hose_delivery hd WHERE delivery_id = @id AND hd.hose_id = h.hose_id)	

	IF @postMixDel = 0
	BEGIN
		-- Normal delivery
		SET @deliveryvolume = (SELECT delivery_volume FROM hose_delivery WHERE delivery_id=@id)
 		
	END
	ELSE
	BEGIN
		-- Postmix

	   	-- Transfered Fuel 
		SET @deliveryvolume = (SELECT delivery1_volume FROM hose_delivery WHERE delivery_id=@id)

		-- Transfered Lubricant
		SET @deliveryvolume2 = (SELECT delivery2_volume FROM hose_delivery WHERE delivery_id=@id)
		SET @tankid2 = (SELECT tank2_id FROM hoses h, hose_delivery hd WHERE delivery_id = @id AND hd.hose_id = h.hose_id)
	END
	
 	IF (@deliveryvolume IS NULL) OR (@tankid IS NULL)
	BEGIN
		IF @postMixDel = 1
			PRINT 'Missing PostMix Delivery Details for Grade1 - Del ID ' + CONVERT(varchar(20), @id)
		ELSE
			PRINT 'Missing Delivery Details Del ID ' + CONVERT(varchar(20), @id)
		RETURN
	END


	IF @postMixDel = 1 AND ((@deliveryvolume2 IS NULL) OR (@tankid2 IS NULL))
	BEGIN
		PRINT 'Missing PostMix Delivery Details for Grade2 - Del ID ' + CONVERT(varchar(20), @id)
		RETURN
	END

	/* Insert it */
	IF @deliveryvolume > 0 
	BEGIN
		INSERT INTO Tank_Transfer 
		 		( Tank_Transfer_ID,
		 		From_Tank_ID,
		 		To_Tank_ID,
		 		Period_ID,
		 		Transfer_Date_Time,
		 		Record_Entry_TS,
		 		Transfer_Volume,
		 		Tank_Movement_Type_ID,
		 		Delivery_ID,	
				Transfer_Doc_Ref, 
				Transfer_Detail )
		 	VALUES
		 		(@tanktransferid,
		 		@tankid,
		 		@tankid,
		 		@opendayperiod,
		 		getdate(),
		 		getdate(),
		 		@deliveryvolume,
		 		2,	-- TestTransfer
		 		@id,
				'',
				'')
	END

	IF @postMixDel = 1 AND @deliveryvolume2 > 0 
	BEGIN
		SET @tanktransferid = (SELECT MAX(tank_transfer_id)+1 FROM Tank_Transfer)
		IF @tanktransferid IS NULL
		BEGIN
			SET @tanktransferid = 1
		END

			INSERT INTO Tank_Transfer 
		 		( Tank_Transfer_ID,
		 		From_Tank_ID,
		 		To_Tank_ID,
		 		Period_ID,
		 		Transfer_Date_Time,
		 		Record_Entry_TS,
		 		Transfer_Volume,
		 		Tank_Movement_Type_ID,
				Delivery_ID,	
				Transfer_Doc_Ref, 
				Transfer_Detail )
		 	VALUES
		 		(@tanktransferid,
		 		@tankid2,
		 		@tankid2,
		 		@opendayperiod,
		 		getdate(),
		 		getdate(),
		 		@deliveryvolume2,
		 		2,	-- TestTransfer
		 		@id,
				'',
				'')
	END
END		 
GO




---------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'sp_reinstate_tank_testtransfer' AND type = 'P')
	DROP PROCEDURE sp_reinstate_tank_testtransfer
go


CREATE PROCEDURE sp_Reinstate_Tank_TestTransfer
	@id int                    	   	   -- ##PARAM @id unique key for delivery 
AS
BEGIN 
		
	/* No checks required. Always delete the tank transfer entry! */
	--DECLARE @flag INT
 	--SET @flag = (SELECT TOP 1 Map_Test_Delivery_To_Tank_Transfer FROM Global_Settings)
 	--IF (@flag IS NULL) OR (@flag = 0)
	--BEGIN
	--	PRINT 'Map_Test_Delivery_To_Tank_Transfer not set'		
	--	RETURN
 	--END

	/* Look for an open Day Period */
 	DECLARE @opendayperiod INT
 	DECLARE @tanktransferid INT
 	SET @opendayperiod = (SELECT TOP 1 Period_ID FROM Periods WHERE Period_Type=2 And Period_State=1.0)
 	IF (@opendayperiod IS NULL) OR (@opendayperiod = 0)
 	BEGIN
		PRINT 'Missing Day Period!'
		RETURN
	END 

	/* Lookup the test transfer entry in the current day period */
 	SET @tanktransferid = ( SELECT TOP 1 Tank_Transfer_ID FROM Tank_Transfer 
		WHERE Delivery_ID = @id 
		  AND Period_ID = @opendayperiod 
		  AND From_Tank_ID = To_Tank_ID )
	IF @tanktransferid IS NULL
	BEGIN
		PRINT 'No matching Tank Transfer entry!'
		RETURN
	END

	/* Delete it! */
	DELETE FROM Tank_Transfer WHERE Tank_Transfer_ID=@tanktransferid

	-- There may be a second transfer for postmix test deliveries involving two tanks 

	SET @tanktransferid = ( SELECT TOP 1 Tank_Transfer_ID FROM Tank_Transfer 
		WHERE 
		Delivery_ID=@id AND 
		Period_ID=@opendayperiod And 
		From_Tank_ID=To_Tank_ID )
	IF @tanktransferid IS NOT NULL
		DELETE FROM Tank_Transfer WHERE Tank_Transfer_ID=@tanktransferid


END
GO

---------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Update_postmix_delivery' AND type = 'P')
	DROP PROCEDURE Update_Postmix_Delivery
go

print 'Creating Update_postmix_delivery'
go

/*
** UPDATE_POSTMIX_DELIVERY stored procedure 
**   - called FROM sp_update_delivery
**   - Updates Hose_PostMix_History table for PostMix deliveries.
**   - Currently PostMix base grade history details for PostPay, Monitor, Driveoff and Test Deliveries are recorded   
*/
CREATE PROCEDURE Update_Postmix_Delivery
    @result int OUTPUT ,
    @baseGradeNumber int, 	-- ##PARAM @baseGradeNumber  1 or 2 - indicating the update is either for the 1st or 2nd base grade
    @id int ,            	-- ##PARAM @id               Delivery_ID of Hose_Delivery 
    @type tinyint ,      	-- ##PARAM @type             New delivery type
    @prevType tinyint,		-- ##PARAM @prevType         Previous delivery type
    @increment int       	-- ##PARAM @increment        Indicates whether totals should be incremented or decremented
AS
	DECLARE @m int
  	DECLARE @modType int
	DECLARE @value decimal(15,4)
	DECLARE @volume decimal(15,4)
	DECLARE @price decimal(15,4)
	DECLARE @attendantID int
BEGIN

	/* check that the delivery type is valid for a cleared delivery */
   	SELECT @result = -1 

   	IF @type < 5 OR @type > 15
      		RETURN  

   	/* check to see if the delivery ID can be located , if not bail out */
   	IF ( SELECT COUNT(*) FROM hose_delivery WHERE delivery_id = @id ) < 1 
      		RETURN

	/* Base grade number must be 1 OR 2 */
	IF @baseGradeNumber < 1 OR @baseGradeNumber > 2
	BEGIN
		print '@baseGradeNumber must be either 1 OR 2 - postmix hose history will not be updated.'
		RETURN
	END	

   	IF @increment IS NULL SELECT @increment = 1 
   		SELECT @m = @increment

	IF @baseGradeNumber = 1
	BEGIN
		SET @value = (SELECT delivery1_value FROM hose_delivery WHERE delivery_id = @id)
	        SET @volume = (SELECT delivery1_volume FROM hose_delivery WHERE delivery_id = @id) 
		SET @price = (SELECT grade1_price FROM hose_delivery WHERE delivery_id = @id) 
	END
	ELSE
	BEGIN
		SET @value = (SELECT delivery2_value FROM hose_delivery WHERE delivery_id = @id)
	        SET @volume = (SELECT delivery2_volume FROM hose_delivery WHERE delivery_id = @id) 
		SET @price = (SELECT grade2_price FROM hose_delivery WHERE delivery_id = @id) 
	END

   	BEGIN TRANSACTION
		

	IF @m >= 0
        	SELECT @modType = @type
   	ELSE
        	SELECT @modType = @prevType	
	
   
	IF @modType = 5                -- postpay delivery 

     	 	UPDATE hose_postmix_history 
         		SET postpay_quantity                    = postpay_quantity + (@m * 1) ,
             		postpay_volume                   	= postpay_volume + (@m * @volume) ,
             		postpay_value                    	= postpay_value + (@m * @value) ,
             		postpay_cost                     	= postpay_cost + (@m * (@price * @volume))
         	FROM hose_delivery hd, hose_postmix_history hph , periods p
         	WHERE  	hd.delivery_id                 = @id AND
			hph.base_grade_number	       = @baseGradeNumber AND
                	hph.hose_id                    = hd.hose_id  AND	
                	hph.period_id                  = p.period_id AND 
                	p.period_state                 = 1.0 

   	ELSE IF @modType = 6         -- monitor delivery 

      		UPDATE hose_postmix_history 
         		SET monitor_quantity                 = monitor_quantity + (@m * 1) ,
             		monitor_volume                   = monitor_volume + @volume ,
             		monitor_value                    = monitor_value + @value ,
             		monitor_cost                     = monitor_cost + (@price * @volume)
        	FROM hose_delivery hd, hose_postmix_history hph , periods p
         	WHERE  	hd.delivery_id                 = @id AND
			hph.base_grade_number	       = @baseGradeNumber AND
                	hph.hose_id                    = hd.hose_id  AND	
                	hph.period_id                  = p.period_id AND 
                	p.period_state                 = 1.0  

   	ELSE IF @modType = 11     -- test delivery 

         	UPDATE hose_postmix_history 
            		SET test_del_quantity            = test_del_quantity + (@m * 1) ,
                	test_del_volume              = test_del_volume + (@m * @volume)
            	FROM hose_delivery hd, hose_postmix_history hph , periods p
         	WHERE  	hd.delivery_id                 = @id AND
			hph.base_grade_number	       = @baseGradeNumber AND
                	hph.hose_id                    = hd.hose_id  AND	
                	hph.period_id                  = p.period_id AND 
                	p.period_state                 = 1.0 

   	ELSE IF @modType = 12     -- drive off delivery 

      		UPDATE hose_postmix_history 
         		SET driveoffs_quantity         = driveoffs_quantity + (@m * 1) ,
             		driveoffs_volume           = driveoffs_volume + (@m * @volume) ,
             		driveoffs_value            = driveoffs_value + (@m * @value) ,
             		driveoffs_cost             = driveoffs_cost + (@m * (@price * @volume))
         	FROM hose_delivery hd, hose_postmix_history hph , periods p
         	WHERE  	hd.delivery_id                 = @id AND
			hph.base_grade_number	       = @baseGradeNumber AND
                	hph.hose_id                    = hd.hose_id  AND	
                	hph.period_id                  = p.period_id AND 
                	p.period_state                 = 1.0    

   	ELSE IF @modType = 13         -- attendant delivery 
      	BEGIN 
         	UPDATE hose_postmix_history 
            		SET monitor_quantity         = monitor_quantity + (@m * 1) ,
                	monitor_volume           = monitor_volume + (@m * @volume) ,
                	monitor_value            = monitor_value + (@m * @value) ,
                	monitor_cost             = monitor_cost + (@m * (@price * @volume)) 
            	FROM hose_delivery hd, hose_postmix_history hph , periods p
         	WHERE  	hd.delivery_id                 = @id AND
			hph.base_grade_number	       = @baseGradeNumber AND
                	hph.hose_id                    = hd.hose_id  AND	
                	hph.period_id                  = p.period_id AND 
                	p.period_state                 = 1.0 

	  	IF @baseGradeNumber = 1
		BEGIN
          		UPDATE Attendant_history
            			SET  Attendant_Quantity1 = Attendant_Quantity1 + (@m * 1) ,
                 		Attendant_Volume1 = Attendant_Volume1 + (@m * @volume) ,
                 		Attendant_Value1 = Attendant_Value1 + (@m * @value) 
            		FROM
                 		Hose_Delivery
                 		INNER JOIN Attendant_history ON (Hose_Delivery.Hose_ID = Attendant_history.Hose_ID)
                 		INNER JOIN Attendant_period ON (Attendant_history.Att_Period_ID = Attendant_period.Att_Period_ID)
            		WHERE
                 		Hose_Delivery.Delivery_ID = @id AND 
						Hose_Delivery.Attendant_ID = Attendant_History.Attendant_ID AND
                 		Attendant_Period.Att_Period_State = 1.0  
		END
		ELSE
		BEGIN
			UPDATE Attendant_history
            			SET  Attendant_Quantity2 = Attendant_Quantity2 + (@m * 1) ,
                 		Attendant_Volume2 = Attendant_Volume2 + (@m * @volume) ,
                 		Attendant_Value2 = Attendant_Value2 + (@m * @value)
            		FROM
                 		Hose_Delivery
                 		INNER JOIN Attendant_history ON (Hose_Delivery.Hose_ID = Attendant_history.Hose_ID)
                 		INNER JOIN Attendant_period ON (Attendant_history.Att_Period_ID = Attendant_period.Att_Period_ID)
            		WHERE
                 		Hose_Delivery.Delivery_ID = @id AND 
						Hose_Delivery.Attendant_ID = Attendant_History.Attendant_ID AND
                 		Attendant_Period.Att_Period_State = 1.0  
		END		
      	END

   	/* If an attendant is logged on to the pump, subtract the delivery FROM its attendant POS totals */
   	/* if its either any of the following: */
   	IF @modType = 11 OR -- test delivery
       @modType = 12 OR -- drive off
       @modType = 14    -- offline
   	BEGIN
   	
   		-- Only update if we have an attendant associated with the delivery. 
   		SET @attendantID = (SELECT Attendant_ID FROM Hose_Delivery WHERE Delivery_ID = @id)
   		
   		IF @attendantID IS NOT NULL
   		BEGIN 
			IF @baseGradeNumber = 1
			BEGIN
				UPDATE Attendant_history
	   				SET Quantity_Total1    = Attendant_history.Quantity_Total1 - 1 ,
	       				Volume_Total1      = Attendant_history.Volume_Total1 - @volume ,
	       				Value_Total1       = Attendant_history.Value_total1 - @value
	  			FROM Hose_Delivery
	       				INNER JOIN Attendant_history ON (Hose_Delivery.Hose_ID = Attendant_history.Hose_ID)
	       				INNER JOIN Attendant_period  ON (Attendant_history.Att_Period_ID = Attendant_period.Att_Period_ID)
	 			WHERE Hose_Delivery.Delivery_ID = @id 
	   				AND Hose_Delivery.Attendant_ID = Attendant_History.Attendant_ID
	   				AND Attendant_Period.Att_Period_State = 1.0
			END
			ELSE
			BEGIN
				UPDATE Attendant_history
	   				SET Quantity_Total2    = Attendant_history.Quantity_Total2 - 1 ,
	       				Volume_Total2      = Attendant_history.Volume_Total2 - @volume ,
	       				Value_Total2       = Attendant_history.Value_total2 - @value
	  			FROM Hose_Delivery
	       				INNER JOIN Attendant_history ON (Hose_Delivery.Hose_ID = Attendant_history.Hose_ID)
	       				INNER JOIN Attendant_period  ON (Attendant_history.Att_Period_ID = Attendant_period.Att_Period_ID)
	 			WHERE Hose_Delivery.Delivery_ID = @id 
	   				AND Hose_Delivery.Attendant_ID = Attendant_History.Attendant_ID
	   				AND Attendant_Period.Att_Period_State = 1.0
			END
		END
	END

	COMMIT TRANSACTION

	SELECT @result = 1


END
go

---------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'sp_update_delivery' AND type = 'P')
	DROP PROCEDURE sp_update_delivery
go

print 'Creating sp_Update_Delivery'
go

/*
** SP_UPDATE_DELIVERY stored procedure 
**   - Superceeds sp_clear_delivery which still exists for backwards compatibility
**   with old pump server code.  New pump servers call this procedure directly.
**   - Procedure is called by the pump server when a delivery is cleared or
**   reinstated by a terminal. 
**   - The appropriate totals are updated depending on the type of the delivery
**   and the totals may be descremented it -1 is passed as the increment param.
*/
CREATE PROCEDURE sp_Update_Delivery
    @result int OUTPUT , 
    @id int ,            -- ##PARAM @id          ID of delivery 
    @type tinyint ,      -- ##PARAM @type        Delivery type
    @terminal_id int,    -- ##PARAM @terminal_id ID of clearing terminal
    @increment int,       -- ##PARAM @increment   Indicates whether totals should be incremented OR decremented
    @paymentTypeID int,	 -- ##PARAM @paymentTypeID Indicate the payment type if this is an attednant delivery
    @cashPaymentType int -- ##PARAM @cashPaymentType Indicate the payment type is a cash payment type
AS
  DECLARE @m int
  DECLARE @modType int
  DECLARE @postMixDel tinyint
  DECLARE @attendantID int
  DECLARE @value decimal(15,4)
  DECLARE @volume decimal(15,4)
BEGIN 

   /* check that the delivery type is valid for a cleared delivery */
   SELECT @result = -1 
   IF @type < 5 OR @type > 15
      RETURN  

   /* check to see if the delivery ID can be located , if not bail out */
   IF ( SELECT COUNT(*) FROM hose_delivery WHERE delivery_id = @id ) < 1 
      RETURN  
	
   SELECT @result = -2

   IF @increment IS NULL SELECT @increment = 1 
   SELECT @m = @increment
   print ' increment ' + STR(@m)

   BEGIN TRANSACTION 

   IF (SELECT tank2_id FROM hoses h, hose_delivery hd WHERE delivery_id = @id AND h.hose_id = hd.hose_id) is NULL
   	SET @postmixDel = 0
   ELSE
	SET @postmixDel = 1

   IF @m >= 0
        SELECT @modType = @type
   ELSE
        SELECT @modType = (SELECT delivery_type FROM hose_delivery WHERE delivery_id = @id)

   print ' type changed to ' + STR(@type) + '  totals updated for type ' + STR(@modType)

   /* update the actual delivery item to reflect the new type etc */
   UPDATE hose_delivery 
      SET Delivery_Type = @type , 
          Cleared_By = @terminal_id , 
          Cleared_Date_Time = getdate() 
      WHERE delivery_id = @id       

   /* now update the hose history records, for the all open periods for this hose */
   IF @modType = 5                -- postpay delivery 

      UPDATE hose_history 
         SET postpay_quantity                 = postpay_quantity + (@m * 1) ,
             postpay_volume                   = postpay_volume + (@m * delivery_volume) ,
             postpay_value                    = postpay_value + (@m * delivery_value) ,
             postpay_cost                     = postpay_cost + (@m * (del_cost_price * delivery_volume))
         FROM hose_delivery hd, hose_history hh , periods p
         WHERE  hd.delivery_id                = @id AND
                hh.hose_id                    = hd.hose_id  AND 
                hh.period_id                  = p.period_id AND 
                p.period_state                = 1.0 

   ELSE IF @modType = 6         -- monitor delivery 

      UPDATE hose_history 
         SET monitor_quantity                 = monitor_quantity + (@m * 1) ,
             monitor_volume                   = monitor_volume + delivery_volume ,
             monitor_value                    = monitor_value + delivery_value ,
             monitor_cost                     = monitor_cost + del_cost_price * delivery_volume 
         FROM hose_delivery hd, hose_history hh , periods p
         WHERE  hd.delivery_id                = @id AND
                hh.hose_id                    = hd.hose_id  AND 
                hh.period_id                  = p.period_id AND 
                p.period_state                = 1.0 

   ELSE IF @modType = 7       -- preauth delivery 

      UPDATE hose_history 
         SET preauth_quantity                 = preauth_quantity + (@m * 1) ,
             preauth_volume                   = preauth_volume + (@m * delivery_volume) ,
             preauth_value                    = preauth_value + (@m * delivery_value) ,
             preauth_cost                     = preauth_cost + (@m * (del_cost_price * delivery_volume)) 
         FROM hose_delivery hd, hose_history hh , periods p
         WHERE  hd.delivery_id                = @id AND
                hh.hose_id                    = hd.hose_id  AND 
                hh.period_id                  = p.period_id AND 
                p.period_state                = 1.0 

   ELSE IF @modType = 8       -- prepay delivery 

      UPDATE hose_history 
         SET prepay_quantity                 = prepay_quantity + (@m * 1) ,
             prepay_volume                   = prepay_volume + (@m * delivery_volume) ,
             prepay_value                    = prepay_value + (@m * delivery_value) ,
             prepay_cost                     = prepay_cost + (@m * (del_cost_price * delivery_volume))
         FROM hose_delivery hd, hose_history hh , periods p
         WHERE  hd.delivery_id               = @id AND
                hh.hose_id                   = hd.hose_id  AND 
                hh.period_id                 = p.period_id AND 
                p.period_state               = 1.0 

   ELSE IF @modType = 9     -- prepay refund delivery 

      UPDATE hose_history 
         SET prepay_refund_qty               = prepay_refund_qty + (@m * 1) ,
             prepay_refund_val               = prepay_refund_val + (@m * delivery_value) 
         FROM hose_delivery hd, hose_history hh , periods p
         WHERE  hd.delivery_id               = @id AND
                hh.hose_id                   = hd.hose_id  AND 
                hh.period_id                 = p.period_id AND 
                p.period_state               = 1.0 

   ELSE IF @modType = 10     -- prepay refund lost delivery 

      UPDATE hose_history 
         SET prepay_rfd_lst_qty              = prepay_rfd_lst_qty + (@m * 1) ,
             prepay_rfd_lst_val              = prepay_rfd_lst_val + (@m * delivery_value )
         FROM hose_delivery hd, hose_history hh , periods p
         WHERE  hd.delivery_id               = @id AND
                hh.hose_id                   = hd.hose_id  AND 
                hh.period_id                 = p.period_id AND 
                p.period_state               = 1.0 

   ELSE IF @modType = 11     -- test delivery 

      BEGIN 

         UPDATE hose_history 
            SET test_del_quantity            = test_del_quantity + (@m * 1) ,
                test_del_volume              = test_del_volume + (@m * delivery_volume )
            FROM hose_delivery hd, hose_history hh , periods p
            WHERE  hd.delivery_id            = @id AND
                   hh.hose_id                = hd.hose_id  AND 
                   hh.period_id              = p.period_id AND 
                   p.period_state            = 1.0 

        /* lets assume that the test delivery was returned to the tank AND update 
        ** the level accordingly */

	IF @postMixDel = 0
	BEGIN
		-- Normal delivery
         	UPDATE tanks 
            		SET theoretical_volume           = theoretical_volume + (@m * hd.delivery_volume )
            		FROM hose_delivery hd, tanks t , hoses h 
         	WHERE  hd.delivery_id               = @id AND
                	h.hose_id                    = hd.hose_id  AND 
                	h.tank_id                    = t.tank_id 
	END
	ELSE
	BEGIN
		-- PostMix delivery
		-- Grade 1
         	UPDATE tanks 
            		SET theoretical_volume           = theoretical_volume + (@m * hd.delivery1_volume )
            		FROM hose_delivery hd, tanks t , hoses h 
         	WHERE  hd.delivery_id               = @id AND
                	h.hose_id                    = hd.hose_id  AND 
                	h.tank_id                    = t.tank_id 
		
		-- Grade 2
         	UPDATE tanks 
            		SET theoretical_volume           = theoretical_volume + (@m * hd.delivery2_volume )
            		FROM hose_delivery hd, tanks t , hoses h 
         	WHERE  hd.delivery_id               = @id AND
                	h.hose_id                    = hd.hose_id  AND 
                	h.tank2_id                    = t.tank_id
	END		

	/* Insert a test transfer entry */
	EXEC sp_log_tank_testtransfer @id

      END 

   ELSE IF @modType = 12     -- drive off delivery 
   BEGIN
      UPDATE hose_history 
         SET driveoffs_quantity         = driveoffs_quantity + (@m * 1) ,
             driveoffs_volume           = driveoffs_volume + (@m * delivery_volume) ,
             driveoffs_value            = driveoffs_value + (@m * delivery_value) ,
             driveoffs_cost             = driveoffs_cost + (@m * (del_cost_price * delivery_volume))
         FROM hose_delivery hd, hose_history hh , periods p
         WHERE  hd.delivery_id          = @id AND
                hh.hose_id              = hd.hose_id  AND 
                hh.period_id            = p.period_id AND 
                p.period_state          = 1.0    
      print ' drive off totals updated? '
   END
   ELSE IF @modType = 13         -- attendant delivery 
   
      BEGIN 
         UPDATE hose_history 
            SET monitor_quantity         = monitor_quantity + (@m * 1) ,
                monitor_volume           = monitor_volume + (@m * delivery_volume) ,
                monitor_value            = monitor_value + (@m * delivery_value) ,
                monitor_cost             = monitor_cost + (@m * (del_cost_price * delivery_volume)) 
            FROM hose_delivery hd, hose_history hh , periods p
            WHERE  hd.delivery_id        = @id AND
                   hh.hose_id            = hd.hose_id  AND 
                   hh.period_id          = p.period_id AND 
                   p.period_state        = 1.0 

          UPDATE Attendant_history
            SET  Attendant_Quantity = Attendant_Quantity + (@m * 1) ,
                 Attendant_Volume = Attendant_Volume + (@m * delivery_volume) ,
                 Attendant_Value = Attendant_Value + (@m * delivery_value)
            FROM
                 Hose_Delivery
                 INNER JOIN Attendant_history ON (Hose_Delivery.Hose_ID = Attendant_history.Hose_ID)
                 INNER JOIN Attendant_period ON (Attendant_history.Att_Period_ID = Attendant_period.Att_Period_ID)
            WHERE
                 Hose_Delivery.Delivery_ID = @id AND 
				 Hose_Delivery.Attendant_ID = Attendant_History.Attendant_ID AND
                 Attendant_Period.Att_Period_State = 1.0     
	

	IF @paymentTypeID IS NOT NULL
	print ' calling update amount ' 
		BEGIN
			-- Call sp_att_update_amount to update the Attendant_Period_History table
			SET @attendantID = ( SELECT Attendant_ID FROM Hose_Delivery WHERE Hose_Delivery.Delivery_ID = @id )

			IF @attendantID IS NULL 
				BEGIN
					PRINT 'Unable to find the attendant ID'
					SELECT @result = -3
					ROLLBACK TRANSACTION 
					RETURN
				END
			ELSE
				BEGIN
					DECLARE @att_output int

					SELECT @value = (SELECT Delivery_Value FROM Hose_Delivery WHERE Delivery_ID = @id)
					SELECT @volume = (SELECT Delivery_Volume FROM Hose_Delivery WHERE Delivery_ID = @id)

					EXEC sp_att_update_amount @att_output OUTPUT, @attendantID , @value,  @volume, @paymentTypeID, @cashPaymentType, @m
	
					IF @att_output < 0
					BEGIN
						PRINT 'SP Update Delivery error updating attendant amount: ' + STR(@att_output)
						SELECT @result = -4
						ROLLBACK TRANSACTION
						RETURN
					END

			
				END
			--END IF
		END
	
	END

   ELSE IF @modType = 14         -- offline delivery 

      UPDATE hose_history 
         SET offline_quantity                 = offline_quantity + (@m * 1) ,
             offline_volume                   = offline_volume + (@m * delivery_volume) ,
             offline_value                    = offline_value + (@m * delivery_value) ,
             offline_cost                     = offline_cost + (@m * del_cost_price * delivery_volume) 
         FROM hose_delivery hd, hose_history hh , periods p
         WHERE  hd.delivery_id                = @id AND
                hh.hose_id                    = hd.hose_id  AND 
                hh.period_id                  = p.period_id AND 
                p.period_state                = 1.0 

   /* If an attendant is logged on to the pump, subtract the delivery FROM its attendant POS totals */
   /* if its either any of the following: */
   IF ( @modType = 11 OR -- 1. test delivery;
		@modType = 12 OR -- 2. drive off;
		@modType = 14 )  -- 3. offline delivery 
   BEGIN
   
		SET @attendantID = ( SELECT Attendant_ID FROM Hose_Delivery WHERE Hose_Delivery.Delivery_ID = @id )
		
		IF @attendantID IS NOT NULL
		BEGIN 
			UPDATE Attendant_history
			   SET Quantity_Total    = Attendant_history.Quantity_Total - 1 ,
				   Volume_Total      = Attendant_history.Volume_Total - delivery_volume ,
				   Value_Total       = Attendant_history.Value_total - delivery_value
			  FROM Hose_Delivery
				   INNER JOIN Attendant_history ON (Hose_Delivery.Hose_ID = Attendant_history.Hose_ID)
				   INNER JOIN Attendant_period  ON (Attendant_history.Att_Period_ID = Attendant_period.Att_Period_ID)
			 WHERE  Hose_Delivery.Delivery_ID = @id AND
					Hose_Delivery.Attendant_ID = Attendant_History.Attendant_ID AND
					Attendant_Period.Att_Period_State = 1.0
		END
	
   END

   /* if this is not a test delivery then update the deliveries totals for the tank history records */
   IF @modType NOT IN ( 9 /* prepay refund */, 10 /* lost prepay refund */, 11 /* test delivery */ )
   BEGIN

	IF @postmixDel = 0 
	BEGIN
		-- StANDard delivery
      		UPDATE tank_history 
         		SET Hose_Del_Quantity     = Hose_Del_Quantity+ (@m * 1) ,
             		Hose_Del_Volume           = Hose_Del_Volume + (@m * delivery_volume) ,
             		Hose_Del_Value            = Hose_Del_Value  + (@m * delivery_value) ,
             		Hose_Del_Cost             = Hose_Del_Cost   + (@m * del_cost_price * delivery_volume) 
         	FROM hose_delivery hd, hoses h , tank_history th , periods p
         	WHERE  	hd.delivery_id  = @id AND
                       	h.hose_id       = hd.hose_id  AND 
                	h.tank_id       = th.tank_id  AND 
                	th.period_id    = p.period_id AND 
                	p.period_state  = 1.0
	END
	ELSE
	BEGIN
		-- PostMix Delivery	
		-- Base grade 1
		UPDATE tank_history 
         		SET Hose_Del_Quantity     = Hose_Del_Quantity+ (@m * 1) ,
             		Hose_Del_Volume           = Hose_Del_Volume + (@m * delivery1_volume) ,
             		Hose_Del_Value            = Hose_Del_Value  + (@m * delivery1_value) ,
             		Hose_Del_Cost             = Hose_Del_Cost   + (@m * grade1_price * delivery1_volume) 
         	FROM hose_delivery hd, hoses h , tank_history th , periods p
         	WHERE  hd.delivery_id  = @id AND
                	h.hose_id       = hd.hose_id  AND 
                	h.tank_id      = th.tank_id  AND 
                	th.period_id    = p.period_id AND 
                	p.period_state  = 1.0

		-- Base grade 2
		UPDATE tank_history 
         		SET Hose_Del_Quantity     = Hose_Del_Quantity+ (@m * 1) ,
             		Hose_Del_Volume           = Hose_Del_Volume + (@m * delivery2_volume) ,
             		Hose_Del_Value            = Hose_Del_Value  + (@m * delivery2_value) ,
             		Hose_Del_Cost             = Hose_Del_Cost   + (@m * grade2_price * delivery2_volume) 
         	FROM hose_delivery hd, hoses h , tank_history th , periods p
         	WHERE  hd.delivery_id  = @id AND
                	h.hose_id       = hd.hose_id  AND 
                 	h.tank2_id      = th.tank_id  AND 
                	th.period_id    = p.period_id AND 
                	p.period_state  = 1.0
	END
   END

   IF @postmixDel = 1
   BEGIN
	-- Update postMix history details
	-- Base grade 1
	DECLARE @output int
   	EXEC update_postmix_delivery @output, 1, @id, @type, @modType, @increment
        IF @output < 0 
	BEGIN	
		ROLLBACK TRANSACTION
	        RETURN 
	END
	ELSE
	BEGIN
		-- Base grade 2
		EXEC update_postmix_delivery @output, 2, @id, @type,@modType, @increment
		IF @output < 0 
		BEGIN
			ROLLBACK TRANSACTION
	        	RETURN 
		END
	END
   END
        
   COMMIT TRANSACTION

   SELECT @result = 1 

END 
go





---------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'sp_clear_delivery' AND type = 'P')
	DROP PROCEDURE sp_Clear_Delivery
go

print 'Creating sp_Clear_Delivery'
go

/*
** SP_CLEAR_DELIVERY stored procedure - NOW OBSOLETE
** is call by the pump server when a delivery is cleared FROM the system, ie. is taken 
** by a POS or card terminal.
** The appropriate totals are update dated depending on the type of the delivery 
** This procedure is provided for backward compatibility only.
*/
CREATE PROCEDURE sp_Clear_Delivery 
    @result int OUTPUT , 
    @id int ,              -- ##PARAM @id          ID of delivery 
    @type tinyint ,        -- ##PARAM @type        Delivery type 
    @terminal_id int       -- ##PARAM @terminal_id ID of clearing terminal
AS
  DECLARE @clr_del_output int
BEGIN 

   /* check that the delivery type is valid for a cleared delivery */
   SELECT @result = -1 
   IF @type < 5 OR @type > 14
      RETURN     

   EXEC sp_update_delivery @clr_del_output, @id, @type, @terminal_id, 1

   SELECT @result = @clr_del_output
END
go

---------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'sp_log_event' AND type = 'P')
   DROP PROCEDURE sp_Log_Event
go

print 'Creating sp_Log_Event'
go

-- ##SUMMARY Called by the Enabler Pump Server or integrator applications to add a record to the Event Journal.
--
-- ##REMARKS <p>The Enabler Pump Server uses this procedure to log events occuring at automated devices (e.g. Pumps).</p>
-- ##REMARKS <p>Integrator applications may also use this procedure to log events for management or diagnostic purposes.</p>
--
-- ##RETURNS The ID of the row inserted, returned in the @ID parameter.
CREATE PROCEDURE sp_Log_Event
    @id int OUTPUT ,         -- ##PARAM @ID            ID of the event record created.
    @device_type smallint ,  -- ##PARAM @Device_Type   Value indicating the type of device the event occurred at.
    @device_id int ,         -- ##PARAM @Device_ID     Where relevant the ID of the device generating the event.
    @device_number int ,     -- ##PARAM @Device_Number The logical number of the device.
    @event_type int ,        -- ##PARAM @Event_Type    The Enabler internal Event type
    @desc nvarchar(320)      -- ##PARAM @Desc          Human readable text including description of the event or additional information.
AS
BEGIN 
   BEGIN TRANSACTION 

   INSERT INTO event_journal
      ( Device_Type ,
        Device_ID ,
        Device_number ,
        Event_Time_Stamp ,
        Event_Type ,
        Description ) 
   VALUES 
      ( @device_type ,
        @device_id ,
        @device_number ,
        getdate() ,
        @event_type ,
        @desc ) 

   SELECT @ID = (SELECT scope_identity())

   COMMIT TRANSACTION 

END 
go



--------------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'sp_close_pvt' AND type = 'P')
   DROP PROCEDURE sp_close_pvt
go

print 'Creating sp_Close_PVT'
go

-- ##SUMMARY <p><font color="red"><b>FOR INTERNAL USE ONLY</b></font></p> <p>Called by the Enabler Pump Server to close open PVT records.</p>
--
-- ##REMARKS 
--
-- ##RETURNS No return data.
CREATE PROCEDURE sp_Close_PVT
    @Cause_Code int   -- ##PARAM @Cause_Code Code indicating the reason for closing the open PVT records
AS

BEGIN 

   BEGIN TRANSACTION 

   /* set the cause code and close time for all open records */
   UPDATE PVT
      SET PVT_cause_code = @cause_code ,
          PVT_stop_time = getdate() 
      WHERE PVT_cause_code is NULL 
        
   COMMIT TRANSACTION 

END 
go 

---------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'populate_history_tables' AND type = 'P')
   DROP PROCEDURE populate_history_tables
go

print 'Creating populate_history_tables'
go

-- ##SUMMARY <p>Called by SP_CLOSE_PERIOD_RES to ensure period records are open for each period type.</p>
--
-- ##REMARKS <p>Creates history rows with the starting values for the new reporting period.</p>
--
-- ##RETURNS No return data.
CREATE PROCEDURE populate_history_tables 
	@Period_ID int = -1
AS 
BEGIN 

	IF( @Period_ID <> -1 )
	BEGIN
		INSERT INTO hose_history ( Hose_ID , 
			Period_ID ,  
			Open_Meter_Value  , 
			Open_Meter_Volume ,
			Open_Volume_Turnover_Correction,
			Open_Money_Turnover_Correction,
			Open_Volume_Turnover_Correction2 )
		SELECT 
			hose_id , 
			@Period_ID , 
			money_total ,
			volume_total ,
			Volume_Total_Turnover_Correction ,
			Money_Total_Turnover_Correction ,
			Volume_Total2_Turnover_Correction 
		FROM Hoses
		WHERE Deleted = 0
	END
	ELSE
	BEGIN
		INSERT INTO hose_history 
			( Hose_ID , 
			Period_ID ,  
			Open_Meter_Value  , 
			Open_Meter_Volume ,
			Open_Volume_Turnover_Correction,
			Open_Money_Turnover_Correction,
			Open_Volume_Turnover_Correction2 )
		SELECT 
			hose_id , 
			Period_ID , 
			money_total ,
			volume_total ,
			Volume_Total_Turnover_Correction ,
			Money_Total_Turnover_Correction ,
			Volume_Total2_Turnover_Correction 
		FROM Hoses, Periods
		WHERE Deleted = 0 AND Period_state = 1.0
			  AND Period_ID NOT IN (SELECT Period_ID FROM Hose_History, Hoses WHERE Hose_History.Hose_ID = Hoses.Hose_ID)
	END

	IF( @Period_ID <> -1 )
	BEGIN
		-- PostMix History for Grade1 Base Grade
		INSERT INTO hose_postmix_history 
		       ( Hose_ID , 
		       Period_ID , 
		       Base_Grade_Number,	
		       Open_Meter_Value  , 
		       Open_Meter_Volume , 
		       Open_Volume_Turnover_Correction,
		       Open_Money_Turnover_Correction	)
		SELECT hose_id ,
		      @Period_ID,
		       1,
		       IsNull(money_total1,0),
		       IsNull(volume_total1,0),
		       0 ,        -- Turnover correction for PostMix hose Grade1 not available since meters are calculated AND already turnover corrected
		       0 
		 FROM Hoses h, Grades
		WHERE h.Deleted = 0
		  AND grades.grade_id = h.grade_ID
		  AND grades.deleted = 0
		  AND grade1_ID IS NOT NULL
	END
	ELSE
	BEGIN
		INSERT INTO hose_postmix_history 
		(	Hose_ID , 
			Period_ID , 
			Base_Grade_Number,
			Open_Meter_Value  , 
			Open_Meter_Volume , 
			Open_Volume_Turnover_Correction,
			Open_Money_Turnover_Correction	)
		SELECT  hose_id ,
			Period_ID,
			1,
			IsNull(money_total1,0),
			IsNull(volume_total1,0),
			0 ,	-- Turnover correction for PostMix hose Grade1 not available since meters are calculated AND already turnover corrected
			0 
		FROM Hoses h, Periods, Grades
		WHERE h.Deleted = 0
		  AND Period_state = 1 
		  AND Period_ID NOT IN (SELECT Period_ID FROM hose_postmix_history, Hoses WHERE hose_postmix_history.Hose_ID = Hoses.Hose_ID)
		  AND grades.grade_id = h.grade_ID
		  AND grades.deleted = 0
		  AND grade1_ID IS NOT NULL
	END

	IF( @Period_ID <> -1 )
	BEGIN
		-- PostMix History for Grade2 Base Grade
		-- Money turnover correction for PostMix hose Grade2 not available since money meter is calculated AND already turnover corrected
		INSERT INTO hose_postmix_history
		(	Hose_ID ,
			Period_ID ,
			Base_Grade_Number,
			Open_Meter_Value  ,
			Open_Meter_Volume ,
			Open_Volume_Turnover_Correction,
			Open_Money_Turnover_Correction	)
		SELECT hose_id ,
		       @Period_ID,
		       2,
		       IsNull(money_total2,0),
		       IsNull(volume_total2,0),
		       Volume_Total2_Turnover_Correction ,
		       0 	-- Money turnover correction (not available)
		 FROM Hoses h, Grades
		WHERE h.Deleted = 0 
		  AND grades.grade_id = h.grade_ID
		  AND grades.deleted = 0
		  AND grade2_ID is not null
	END
	ELSE
	BEGIN
		INSERT INTO hose_postmix_history 
		(	Hose_ID , 
			Period_ID ,
			Base_Grade_Number,
			Open_Meter_Value  , 
			Open_Meter_Volume , 
			Open_Volume_Turnover_Correction,
			Open_Money_Turnover_Correction	)
		SELECT 
			hose_id ,
			Period_ID, 
			2,
			IsNull(money_total2,0),
			IsNull(volume_total2,0),
			Volume_Total2_Turnover_Correction ,
			0
		  FROM Hoses h, Periods, Grades
		 WHERE h.Deleted = 0
		   AND Period_state = 1
		   AND Period_ID NOT IN (SELECT Period_ID FROM hose_postmix_history, Hoses WHERE hose_postmix_history.Hose_ID = Hoses.Hose_ID) 
		   AND grades.grade_id = h.grade_ID
		   AND grades.deleted = 0
		   AND grade2_ID IS NOT NULL
	END

	IF( @Period_ID <> -1 )
	BEGIN
		-- open up new records for this period for all installed tanks
		INSERT INTO tank_history 
		  (	Tank_ID , 
			Period_ID ,  
			Open_Gauge_Volume ,
			Open_Theo_Volume ,
			Open_Dip_Volume ,
			Open_Water_Volume ,
			Open_Gauge_TC_Volume,
			Open_Fuel_Density,
			Open_Fuel_Temp,
			Open_Tank_Probe_Status_ID,
			Open_Tank_Delivery_State_ID,
			Open_Pump_Delivery_State,
			Open_Gauge_TC_Volume_Flag )
		SELECT 
			  tank_id , 
			  @Period_ID , 
			  Gauge_Volume ,
			  Theoretical_Volume ,
			  Dip_Volume ,
			  Water_Volume ,
			  Gauge_TC_Volume,
			  Density ,
			  Temperature ,
			  Tank_Probe_Status_ID,
			  Tank_Delivery_State_ID,
			  Pump_Delivery_State,
			  (SELECT ISNULL(SUM(Tank_Gauge_Type.Gauge_TC_Volume_Flag),0)
			     FROM Tanks, Tank_Gauge, Tank_Gauge_Type
			    WHERE Tanks.Tank_Gauge_ID = Tank_Gauge.Tank_Gauge_ID
			      AND Tank_Gauge.Tank_Gauge_Type_ID = Tank_Gauge_Type.Tank_Gauge_Type_ID )
		  FROM Tanks
		 WHERE Deleted = 0 
	END
	ELSE
	BEGIN
		INSERT INTO tank_history 
		  ( Tank_ID , 
			Period_ID ,  
			Open_Gauge_Volume ,
			Open_Theo_Volume ,
			Open_Dip_Volume ,
			Open_Water_Volume ,
			Open_Gauge_TC_Volume,
			Open_Fuel_Density,
			Open_Fuel_Temp,
			Open_Tank_Probe_Status_ID,
			Open_Tank_Delivery_State_ID,
			Open_Pump_Delivery_State )
		 SELECT 
			  tank_id , 
			  Period_ID , 
			  Gauge_Volume ,
			  Theoretical_Volume ,
			  Dip_Volume ,
			  Water_Volume ,
			  Gauge_TC_Volume,
			  Density ,
			  Temperature ,
			  Tank_Probe_Status_ID,
			  Tank_Delivery_State_ID,
			  Pump_Delivery_State
		  FROM Tanks, Periods
		 WHERE Deleted = 0 AND Period_state = 1
			   AND Period_ID NOT IN (SELECT Period_ID FROM tank_history, Tanks WHERE tank_history.Tank_ID = Tanks.Tank_ID) 

	END

END
GO

---------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'sp_close_period' AND type = 'P')
   DROP PROCEDURE sp_Close_Period
go

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'sp_close_prd_res' AND type = 'P')
   DROP PROCEDURE sp_Close_Prd_Res
go

print 'Creating sp_Close_Prd_Res'
go


-- ##SUMMARY This stored procedure can be called to close/reopen periods by type, returning the Period_ID for the newly created Period record.
--
-- ##REMARKS <p>To faciliate reporting applications or data export processing, The Enabler database stores historic data 
-- ##REMARKS for a range of entities in the database. By default the Enabler database is configured with 3 report periods
-- ##REMARKS (Shift, Day and Month).</p>
-- ##REMARKS <p>For each of these periods a records are kept for each reporting entity (e.g. Hose). Activity for the
-- ##REMARKS object is accumulated in the appropriate total table (e.g. Hose_History).</p>
-- ##REMARKS <p>By calling this procedure, the currently open totals indicated by the <tt>@period_type</tt> parameter are
-- ##REMARKS closed (no longer accumulated), and new totals are started (from zero). This allow for built-in or custom reports 
-- ##REMARKS to be generated for Shift, Day or Month periods.</p>
-- ##REMARKS <p>This procedure performs the same function as <tt>dbo.sp_close_period</tt>, but returns the ID of the newly opened period record.</p>
--
-- ##RETURNS Returns the ID of the new period created via the @ID parameter.
CREATE PROCEDURE sp_Close_Prd_Res 
    @id int OUTPUT ,              -- ##PARAM @ID           Period_ID (PK) of the new row added to the <tt>Periods</tt> table
    @period_type int              -- ##PARAM @Period_Type  Reporting period type to close:<br>1=Shift<br>2=Day<br>3=Month
AS

DECLARE    
   @number int,                         -- period number
   @closing_period_id int,
   @grade1 int,
   @grade2 int

BEGIN 

   BEGIN TRANSACTION 

   /* whats the period to close - doing this separately is much more efficient */
   SELECT @closing_period_id = period_id FROM periods 
      WHERE Period_type = @period_type AND Period_state = 1.0 

   /* set the close meter values for all hose history records that belong */
   /* to the closing period */
   UPDATE Hose_history 
      SET Close_Meter_Value = h.money_total ,
          Close_Meter_Volume = h.volume_total ,
          Close_Volume_Turnover_Correction = h.Volume_Total_Turnover_Correction ,
          Close_Money_Turnover_Correction  = h.Money_Total_Turnover_Correction ,
          Close_Volume_Turnover_Correction2 = h.Volume_Total2_Turnover_Correction
      FROM Hoses h
      WHERE Hose_history.hose_id = h.hose_id AND
            Hose_History.period_id = @closing_period_id


	-- PostMix Volume1, Value1 and Value2 meters are calculated at the moment so
	-- turnover correction is set to zero.  
	-- PostMix history Grade1
	UPDATE Hose_postmix_history 
      	SET Close_Meter_Value = IsNull(h.money_total1,0) ,
          	Close_Meter_Volume = IsNull(h.volume_total1,0) ,
         	Close_Volume_Turnover_Correction = 0 ,
          	Close_Money_Turnover_Correction  = 0 
      	FROM Hoses h
		INNER JOIN Grades g on (h.grade_id = g.grade_id AND g.grade1_id is not null)
      	WHERE 	Hose_postmix_history.hose_id = h.hose_id AND
		Hose_postmix_history.base_grade_number = 1 AND
            	Hose_postmix_history.period_id = @closing_period_id

	-- PostMix History Grade2
	UPDATE Hose_postmix_history 
      	SET Close_Meter_Value = IsNull(h.money_total2,0) ,
          	Close_Meter_Volume = IsNull(h.volume_total2,0) ,
         	Close_Volume_Turnover_Correction = h.Volume_Total2_Turnover_Correction ,
          	Close_Money_Turnover_Correction  = 0 
      	FROM Hoses h
		INNER JOIN Grades g on (h.grade_id = g.grade_id AND g.grade2_id is not null)
      	WHERE 	Hose_postmix_history.hose_id = h.hose_id AND
		Hose_postmix_history.base_grade_number = 2 AND
            	Hose_postmix_history.period_id = @closing_period_id
	

   /* set the close tank values for all tank history records that belong */
   /* to the closing period */
   UPDATE Tank_history 
      SET Close_Gauge_Volume = t.Gauge_Volume ,
          Close_Theo_Volume = t.Theoretical_Volume ,
          Close_Dip_Volume = t.Dip_Volume ,
          Close_Water_Volume = t.Water_Volume ,
          Close_Gauge_TC_Volume = t.Gauge_TC_Volume ,
          Close_Fuel_Density = t.Density ,
          Close_Fuel_Temp = t.Temperature ,
          Close_Tank_Probe_Status_ID = t.Tank_Probe_Status_ID ,
          Tank_Readings_DT = t.Tank_Readings_DT,
		  Close_Tank_Delivery_State_ID = t.Tank_Delivery_State_ID,
		  Close_Pump_Delivery_State = t.Pump_Delivery_State,
		  Close_Gauge_TC_Volume_Flag = tgtype.Gauge_TC_Volume_Flag
      FROM tanks t
      LEFT OUTER JOIN Tank_Gauge tg ON t.tank_gauge_id = tg.tank_gauge_id 
      LEFT OUTER JOIN Tank_Gauge_Type tgtype ON tg.tank_gauge_type_id = tgtype.tank_gauge_type_id 
      WHERE tank_history.tank_id = t.tank_id AND
            tank_history.period_id = @closing_period_id
      
   /* close off the open period of this type */
   UPDATE Periods
      SET Period_state = 2 ,
          Period_Close_DT = getdate() 
      WHERE Period_id = @closing_period_id

   /* allocate a new period_id for this new period */
   SELECT @id = ( SELECT MAX( period_id ) + 1 FROM periods ) 
   IF @id IS NULL SELECT @id = 1 

   /* allocate new period number */
   SELECT @number = ( SELECT period_number + 1 FROM periods WHERE period_id = @closing_period_id )
   IF @number IS NULL SELECT @number = 1 

   /* create a new period of this type */
   INSERT INTO Periods 
      ( Period_ID ,
        Period_Type ,
        Period_Create_TS , 
        Period_State , 
        Period_number )
   VALUES
      ( @id ,
        @period_type , 
        getdate() ,
        1 , 
        @number ) 

	-- Populate the history tables for the new period ID
	EXEC Populate_History_Tables @id
         
   COMMIT TRANSACTION 

END 
GO



print 'Creating sp_close_period'
go

-- ##SUMMARY This stored procedure can be called to close/reopen periods by type, returning the Period_ID for the newly created Period record.
--
-- ##REMARKS <p>To faciliate reporting applications or data export processing, The Enabler database stores historic data 
-- ##REMARKS for a range of entities in the database. By default the Enabler database is configured with 3 report periods
-- ##REMARKS (Shift, Day and Month).</p>
-- ##REMARKS <p>For each of these periods a records are kept for each reporting entity (e.g. Hose). Activity for the
-- ##REMARKS object is accumulated in the appropriate total table (e.g. Hose_History).</p>
-- ##REMARKS <p>By calling this procedure, the currently open totals indicated by the <tt>@period_type</tt> parameter are
-- ##REMARKS closed (no longer accumulated), and new totals are started (from zero). This allow for built-in or custom reports 
-- ##REMARKS to be generated for Shift, Day or Month periods.</p>
-- ##REMARKS <p>This procedure performs the same function as <tt>dbo.sp_close_prd_res</tt>, but does not return any data.</p>
--
-- ##RETURNS The Period_ID of the newly opened period (the primary key for the Periods table).
CREATE PROCEDURE sp_Close_Period
    @period_type int   -- ##PARAM @Period_Type The reporting period type to close:<br>1=Shift<br>2=Day<br>3=Month
AS
DECLARE @id int 
BEGIN 
   EXEC sp_close_prd_res @id OUTPUT , @period_type
   RETURN @id 
END 
go 


---------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Clean_Historical_Data' AND type = 'P')
   DROP PROCEDURE Clean_Historical_Data
go

print 'Creating Clean_Historical_Data'
go

-- ##SUMMARY <p>The Clean_Historical_Data procedure provides data purging for historical data.</p>
--
-- ##REMARKS <p>This procedure implements the Enabler database purging functionality which is usually run by using the SP_CLEAN procedure. </p>
-- ##REMARKS <p>How long data is kept in the database is determined by the various 'Keep' fields in the Global_Settings table. </p>
--
-- ##RETURNS No return data.
CREATE PROCEDURE Clean_Historical_Data 
	@CurrDate DATE = NULL                   -- ##PARAM @currDate Current Date.	
AS
BEGIN
   IF @CurrDate IS NULL 
   BEGIN
     SET @CurrDate = GETDATE()
   END

   BEGIN TRANSACTION 
 
   /* remove old hose history records for all closed expired periods */
   DELETE FROM hose_history 
      FROM periods p , period_types pt 
      WHERE hose_history.period_id = p.period_id AND p.period_state = 2.0 AND p.period_type = pt.period_type AND 
      DateAdd( day , pt.Period_keep_days, p.Period_Close_DT ) < @CurrDate

   DELETE FROM hose_postmix_history 
      FROM periods p , period_types pt 
      WHERE hose_postmix_history.period_id = p.period_id AND p.period_state = 2.0 AND p.period_type = pt.period_type AND 
      DateAdd( day , pt.Period_keep_days, p.Period_Close_DT ) < @CurrDate

   /* remove old attendant history records for all closed expired periods */
   DELETE FROM attendant_history 
      FROM attendant_period ap 
      WHERE attendant_history.att_period_id = ap.att_period_id AND ap.att_period_state = 3.0 AND 
      DateAdd( day , ( SELECT Att_keep_days FROM global_settings ), ap.att_Period_Close_DT ) < @CurrDate

   /* remove old attendant safedrop records for all closed expired periods */
   DELETE FROM Attendant_Safedrop
      FROM attendant_period ap, attendant_period_history aph
      WHERE Attendant_Safedrop.attendant_period_history_id = aph.attendant_period_history_id  AND aph.att_period_id = ap.att_period_id AND ap.att_period_state = 3.0 AND 
      DateAdd( day , ( SELECT Att_keep_days FROM global_settings ), ap.att_Period_Close_DT ) < @CurrDate

   /* remove old attendant periods history records for all closed expired periods */
   DELETE FROM Attendant_Period_History
      FROM attendant_period ap 
      WHERE Attendant_Period_History.att_period_id = ap.att_period_id AND ap.att_period_state = 3.0 AND 
      DateAdd( day , ( SELECT Att_keep_days FROM global_settings ), ap.att_Period_Close_DT ) < @CurrDate

   /* remove old expired attendant_periods */
   DELETE FROM attendant_period 
      WHERE att_period_state = 3.0 AND 
      DateAdd( day , ( SELECT Att_keep_days FROM global_settings ), att_Period_Close_DT ) < @CurrDate

   /* remove old tank history records for all closed expired periods */
   DELETE FROM tank_history 
      FROM periods p , period_types pt 
      WHERE tank_history.period_id = p.period_id AND p.period_state = 2.0 AND p.period_type = pt.period_type AND 
      DateAdd( day , pt.Period_keep_days, p.Period_Close_DT ) < @CurrDate

   /* remove old tank history records for all closed expired periods */
   DELETE FROM tank_readings 
      FROM periods p , period_types pt 
     WHERE tank_readings.period_id = p.period_id 
       AND p.period_state = 2.0 
       AND p.period_type = pt.period_type 
       AND DateAdd( day , pt.Period_keep_days, p.Period_Close_DT ) < @CurrDate
	
   /* remove old tank losses from the tank_loss table */
   DELETE FROM tank_loss
      FROM periods p, period_types pt
     WHERE tank_loss.period_id = p.period_id
       AND p.period_state = 2.0
       AND p.period_type = pt.period_type
       AND DateAdd( day, pt.period_keep_days, p.Period_Close_DT ) < @CurrDate

   /* remove old tank transfers from the tank_transfer table */
   DELETE FROM tank_transfer
      FROM periods p, period_types pt
     WHERE tank_transfer.period_id = p.period_id
       AND p.period_state = 2.0
       AND p.period_type = pt.period_type
       AND DateAdd( day, pt.period_keep_days, p.Period_Close_DT ) < @CurrDate

   /* remove old detected tank deliveries */
   DELETE FROM tank_delivery_detected_delivery
     WHERE DateAdd( day , ( SELECT Tank_del_keep_days FROM global_settings ) , Record_Entry_TS ) < @CurrDate

   /* remove old tank deliveries from the tank_delivery table */
   DELETE FROM tank_delivery
      FROM periods p, period_types pt
     WHERE tank_delivery.period_id = p.period_id
       AND p.period_state = 2.0
       AND p.period_type = pt.period_type
       AND DateAdd( day, pt.period_keep_days, p.Period_Close_DT ) < @CurrDate
 
   DELETE FROM audittrace
     	WHERE DateDiff(day,UpdateDate,@CurrDate) >= 93

   /* finally remove old periods */
   DELETE FROM periods
      FROM period_types pt 
     WHERE period_state = 2.0 
       AND periods.period_type = pt.period_type 
       AND DateAdd( day , pt.Period_keep_days+1, Period_Close_DT ) < @CurrDate

   COMMIT TRANSACTION 

END 
go 

---------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Clean_Active_Data' AND type = 'P')
   DROP PROCEDURE Clean_Active_Data
go

print 'Creating Clean_Active_Data'
go

-- ##SUMMARY Procedure normally called as part of the scheduled daily backup, to purge old historic data.
--
-- ##REMARKS This procedure is intended to be used more frequently (for example on an hourly basis) to delete (purge) rows 
-- ##REMARKS from tables where many rows are normally appended each day. By doing this more frequently row and table
-- ##REMARKS locking can be avoided.
-- ##REMARKS EP-1791 issue with tank transfer rows being created while hose delivery being deleted, using @dateTime
--
CREATE PROCEDURE Clean_Active_Data 
    @rowCount int OUTPUT ,                  -- ##PARAM @rowCount indicates the number of rows removed.
    @rowLimit int,                          -- ##PARAM @rowLimit max. number of rows to delete.
	@CurrDate DATE = NULL                   -- ##PARAM @currDate Current Date.	
AS
BEGIN 

	IF @CurrDate IS NULL 
	BEGIN
		SET @CurrDate = GETDATE()
	END

	DECLARE @DelPurge TABLE
	(
		row_id int IDENTITY(1,1) PRIMARY KEY NOT NULL, 
		delivery_id int
	)
   
	/* How @DelPurge Deletion works:
		- Will only delete records with Delivery_IDs contained in @DelPurge.Delivery_ID.
		- Deletes & Commits in blocks of @rowLimit 
	*/   

	INSERT INTO @DelPurge (delivery_id) SELECT delivery_id FROM Hose_Delivery 
		WHERE DateAdd( day , ( SELECT Hose_del_keep_days FROM global_settings ) , Completed_TS ) < @CurrDate 
		ORDER BY delivery_id ASC 
		
	SET @rowCount = ( SELECT @@ROWCOUNT )

	/* Delay a bit for quarter */
	DECLARE @CommitWaitTime CHAR (8)
	SET @CommitWaitTime = '00:00:02' --Two seconds

	DECLARE @blockCounter int
	SET @blockCounter = 0
	
	WHILE @rowCount > @blockCounter 
	BEGIN
		BEGIN TRANSACTION 

		/* Tank transfer has a foreign key to hose delivery so update this table first */
		DELETE FROM tank_transfer FROM @DelPurge dp 
			WHERE Tank_Transfer.Delivery_ID = dp.Delivery_ID 
			AND dp.row_id BETWEEN @blockCounter AND @blockCounter + @rowLimit
				
		/* Remove Fuel_Transaction rows based on DelPurge.Delivery_Id*/
		DELETE FROM Fuel_Transaction FROM @DelPurge dp 
			WHERE Fuel_Transaction.Delivery_ID = dp.delivery_id 
			AND dp.row_id BETWEEN @blockCounter AND @blockCounter + @rowLimit
				
		/* Remove old hose deliveries FROM the hose deliveries table */
		DELETE FROM hose_delivery FROM @DelPurge dp 
			WHERE hose_delivery.Delivery_ID = dp.delivery_id 
			AND dp.row_id BETWEEN @blockCounter AND @blockCounter + @rowLimit

		/* @@ROWCOUNT will be based on records deleted from hose_delivery */
		SET @blockCounter = @blockCounter + ( SELECT @@ROWCOUNT )

		COMMIT TRANSACTION 
		WAITFOR DELAY @CommitWaitTime
	END
		
	DECLARE @allDone int

	/* Block deletion for Fuel_Transaction with no Hose_Delivery */
	SET @allDone = 99
	WHILE @allDone > 0
	BEGIN
		BEGIN TRANSACTION 
	
		;WITH PURGE_CTE AS
		(
			SELECT TOP(@rowLimit) *
			FROM [Fuel_Transaction] a
			WHERE a.Delivery_ID IS NULL 
			AND DateAdd( day , ( SELECT Hose_del_keep_days FROM global_settings ) , Created_DateTime ) < @CurrDate
			ORDER BY a.Transaction_ID ASC
		)
		DELETE FROM PURGE_CTE
		
		SET @allDone = ( SELECT @@ROWCOUNT )
		
		COMMIT TRANSACTION 
		WAITFOR DELAY @CommitWaitTime
	END
	
	/* Remove old events FROM Events_Journal */
	SET @allDone = 99
	WHILE @allDone > 0
	BEGIN
		BEGIN TRANSACTION 
		
		;WITH PURGE_CTE2 AS
		(
			SELECT TOP(@rowLimit) *
			FROM [event_journal] a
			WHERE DateAdd( day , ( SELECT Hose_del_keep_days FROM global_settings ) , Event_Time_Stamp ) < @CurrDate
			ORDER BY a.Event_ID ASC
		)
		DELETE FROM PURGE_CTE2

		SET @AllDone = ( SELECT @@ROWCOUNT )

		COMMIT TRANSACTION 
		WAITFOR DELAY @CommitWaitTime
	END

	SET ROWCOUNT 0

END 
go 

---------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'sp_clean' AND type = 'P')
   DROP PROCEDURE sp_Clean
go

print 'Creating sp_Clean'
go

-- ##SUMMARY Procedure normally called as part of the scheduled daily backup, is provided to purge old historic data.
--
-- ##REMARKS When run this procedure purges old records from the following tables based on the `keep` options in the <tt>Global_Settings</tt> table:<br>
-- ##REMARKS <ul>
-- ##REMARKS  <li>dbo.Attendant_History</li>
-- ##REMARKS  <li>dbo.Attendant_Period</li>
-- ##REMARKS  <li>dbo.Attendant_Period_History</li>
-- ##REMARKS  <li>dbo.Attendant_SafeDrop</li>
-- ##REMARKS  <li>dbo.Event_Journal</li>
-- ##REMARKS  <li>dbo.Hose_Delivery</li>
-- ##REMARKS  <li>dbo.Hose_History</li>
-- ##REMARKS  <li>dbo.Periods</li>
-- ##REMARKS  <li>dbo.Tank_Delivery</li>
-- ##REMARKS  <li>dbo.Tank_Loss</li>
-- ##REMARKS  <li>dbo.Tank_Transfer</li>
-- ##REMARKS  <li>dbo.Fuel_Transaction</li>
-- ##REMARKS </ul>
--
-- ##RETURNS No return data.
CREATE PROCEDURE sp_Clean 
	@CurrDate DATE = NULL                   -- ##PARAM @currDate Current Date.	
AS
BEGIN 
   IF @CurrDate IS NULL 
   BEGIN
     SET @CurrDate = GETDATE()
   END

   DECLARE @rowcount integer
   DECLARE @rowblocksize integer
   SET @rowblocksize = 500                    

   EXEC Clean_Active_Data @rowcount, @rowblocksize, @CurrDate
   EXEC Clean_Historical_Data @CurrDate
   
END 
go

---------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'sp_log_tanker_del' AND type = 'P')
	DROP PROCEDURE sp_Log_Tanker_Del
go

print 'Creating sp_Log_Tanker_Del'
go

-- ##SUMMARY <p>This procedure updates historic data to reflect a tank delivery record added or deleted by wet stock management application.</p>
--
-- ##REMARKS <p>This procedure <b>does not</b> add a row to the Tank_Delivery table. Instead it is called by the wet stock application after
-- ##REMARKS  adding or removing a row in the Tank_Delivery table. <tt>sp_log_tanker_del</tt> is responsible to:</p>
-- ##REMARKS <ul>
-- ##REMARKS  <li>Update the <tt>Tank_History</tt> table</li>
-- ##REMARKS  <li>Update average cost and theoretical volume figures in the <tt>Tanks</tt> table</li>
-- ##REMARKS  <li>If possible, link rows in <Tt>Tank_Delivery</tt> with matching rows in <tt>Tank_Delivery_Detected_Delivery</tt> 
-- ##REMARKS      table (deliveries detected by an Automatic Tank Gauge).</li>
-- ##REMARKS </ul>
--
-- ##RETURNS No return data.
CREATE      PROCEDURE sp_Log_Tanker_Del
	@Tank_ID          int ,          -- ##PARAM @Tank_ID          ID of tank that recieved the delivery 
	@Period_ID        int,           -- ##PARAM @period_ID        ID of the open period at the time the delivery was made
	@Volume           decimal(11,3), -- ##PARAM @Volume           Quantity of stock delivered (added) to the tank
	@Cost             decimal(11,4), -- ##PARAM @Cost             Per-unit cost of the stock added 
	@DelTime          datetime,      -- ##PARAM @DelTime          Date & time of the tanker delivery
	@DelNoteNum       nvarchar(10),  -- ##PARAM @DelNoteNum       Delivery note number or code
	@Tank_Delivery_ID int            -- ##PARAM @Tank_Delivery_ID ID of the tanker delivery 
                                     -- ##PARAM @Return_Value     None.
AS

DECLARE @old_volume            decimal(15,4),
	@detected_tank_delivery_id integer,
	@delivery_count            integer

BEGIN 

   BEGIN TRANSACTION 

   SELECT  @old_volume = ( SELECT theoretical_volume FROM tanks WHERE Tank_ID = @Tank_ID  ) 

   -- update the theoretical tank level for this delivery
   IF @old_volume <= 0 OR @old_volume + @volume = 0
     UPDATE tanks 
        SET Average_Cost	 = @cost ,
            theoretical_volume = theoretical_volume + @volume 
      WHERE Tank_ID = @Tank_ID 
   ELSE 
     UPDATE tanks 
        SET Average_Cost = ( @old_volume * Average_Cost + @volume * @cost ) 
                           / ( @old_volume + @volume ) , 
            theoretical_volume = theoretical_volume + @volume 
      WHERE Tank_ID = @Tank_ID 


   -- update the tank history period
   UPDATE tank_history 
      SET Tank_Del_Quantity = Tank_Del_Quantity + SIGN( @volume ) ,
          Tank_Del_Volume   = Tank_Del_Volume + @volume ,
          Tank_Del_Cost     = Tank_Del_Cost + @volume * @cost
     FROM tank_history 
    WHERE tank_id   = @tank_id
      AND period_id = @period_id 


   -- update the open theo volume for all tank history periods 
   -- WHERE the period open time is after or at the same 
   -- time as the tanker delivery time
   UPDATE tank_history 
      SET open_theo_volume = open_theo_volume + @volume 
     FROM tank_history TH, periods P 
    WHERE tank_id   = @tank_id
      AND TH.period_id = P.period_id
      AND P.Period_Create_TS >= @delTime 

   -- update the close theo volume for all tank history periods 
   -- WHERE the period is already closed and the period close time is after 
   -- or at the same time as the tanker delivery time or else the
   -- period is still open
   UPDATE tank_history 
      SET close_theo_volume = close_theo_volume + @volume 
     FROM tank_history TH, periods P 
    WHERE tank_id   = @tank_id
      AND TH.period_id = P.period_id
      AND (   (P.Period_Close_DT >= @delTime AND P.Period_State = 2 )
           OR (P.Period_State = 1))


   -- detected_tank_delivery 		= DTD
   -- tank_delivery_detected_delivery 	= TDDD
   -- tank_delivery	 		= TD
   
   -- Attempt to find a match between DTD/TDDD and TD,  if  we  find one
   -- update TDDD with Tank_Delivery_ID and Site_Delivery_ID information
   -- this joins DTD, TDDD & TD all together nicely.  
   -- If no match is found create a new row (this  would  happen  if the
   -- wrong delivery data is entered or delivery detection was  offline)

   -- Check first if we are are modifying an existing entry
   -- Note that Fuel Recon does not allow tank movements to be deleted
   -- or modified after they have been exported this SQL does not check the
   -- exported flag.  The behaviour for modifying tank movements after they
   -- have been exported has not been defined.  

   SELECT @delivery_count = (SELECT count(Tank_Delivery_ID) FROM Tank_Delivery_Detected_Delivery WHERE Tank_Delivery_ID = @tank_delivery_id)
   IF @delivery_count > 0
     BEGIN
	-- Should only be one record per tank delivery id, unless there 
        -- are left over entries FROM the old version of this sp which
        -- allowed multiple entries to be created in which case we can't 
        -- do anything.   
	IF @delivery_count = 1
	BEGIN
		-- delivery being deleted check
        	IF @volume < 0
			IF ( SELECT Detected_Tank_Delivery_ID FROM Tank_Delivery_Detected_Delivery WHERE Tank_Delivery_ID = @tank_delivery_id) > 0
				-- if a detected delivery entry exists update just the tank delivery id
				UPDATE Tank_Delivery_Detected_Delivery SET Tank_Delivery_ID = 0 WHERE Tank_Delivery_ID = @tank_delivery_id
			ELSE
				-- remove the whole record
				DELETE FROM Tank_Delivery_Detected_Delivery WHERE Tank_Delivery_ID = @tank_delivery_id
		ELSE
			-- update the tank delivery record
			UPDATE Tank_Delivery_Detected_Delivery SET Site_Delivery_ID = @delNoteNum WHERE Tank_Delivery_ID = @tank_delivery_id
	END
     END
   ELSE
     BEGIN
   	-- Get the detected tanker delivery based on the delivery time
  	 -- look for earliest detected tanker delivery whose start/end times
  	 -- wrap around the delTime of the Tanker Delivery
   	-- may be in TDDD already, in which case it will be updated
   	SET @detected_tank_delivery_id = 
     	(SELECT MIN(Detected_Tank_Delivery_ID) FROM Detected_Tank_Delivery
     	WHERE Start_Date_Time <= @delTime
      	AND End_Date_Time >= @delTime 
      	AND Tank_ID = @tank_id ) 

   
   	-- no detected delivery found
   	IF @detected_tank_delivery_id IS NULL SET @detected_tank_delivery_id = 0

   	-- no match found then add new row into Tanker_Delivery_Detected_Delivery 
   	IF @detected_tank_delivery_id = 0 
   	BEGIN
     		INSERT INTO Tank_Delivery_Detected_Delivery 
		(Tank_Delivery_ID, Detected_Tank_Delivery_ID, Site_Delivery_ID)
     		VALUES 
        	(@tank_delivery_id, @detected_tank_delivery_id, @delNoteNum)
   	END

   	-- NOTE: SP_LOG_DETECTED_TANK_DEL would have inserted the row that is
   	-- about to be updated. Updating Tank_Delivery_ID, Site_Delivery_ID. 
   	IF @detected_tank_delivery_id > 0 -- a match was found
   	BEGIN
     		UPDATE Tank_Delivery_Detected_Delivery 
     		SET Tank_Delivery_ID = @tank_delivery_id, Site_Delivery_ID = @delNoteNum
     		WHERE detected_tank_delivery_id = @detected_tank_delivery_id
   	END
     END
   

   COMMIT TRANSACTION 

END

GO

---------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'sp_zero_data' AND type = 'P')
   DROP PROCEDURE sp_Zero_Data
go

print 'Creating sp_Zero_Data'
go

/*
** SP_ZERO_DATA stored procedure 
** removes all deliveries and histories from the system - WILL DESTROY ALL DELIVERY HISTORY
** Most commonly used when commissioning a site, or resetting history for testing purposes
*/
CREATE PROCEDURE sp_Zero_Data
AS
BEGIN 

   BEGIN TRANSACTION 

   /* remove all tank history records  */
   DELETE FROM tank_history 

   /* remove all tank losses FROM the tank_loss table */
   DELETE FROM tank_loss
	
   /* remove all tank transfers FROM the tank_transfer table */
   DELETE FROM tank_transfer

   /* remove all rows from the fuel_transaction table */
   DELETE FROM Fuel_Transaction

   /* remove all tank transfers FROM the tank_transfer table */
   DELETE FROM tank_delivery

   /* remove all tank readings */
   DELETE FROM tank_readings
		
   /* remove all hose deliveries FROM the hose_deliveries table */
   DELETE FROM hose_delivery

   /* remove all hose history records  */
   DELETE FROM hose_history 

   /* remove all attendant safedrops */
   DELETE FROM Attendant_Safedrop

   /* remove all attendant period history records */
   DELETE FROM Attendant_Period_History

   /* remove all hose history records  */
   DELETE FROM attendant_history 

   /* remove all hose history records  */
   DELETE FROM attendant_period

   /* remove all period records */
   DELETE FROM periods

   /* remove all pvt records FROM the pvt table */
   DELETE FROM pvt 

   /* remove all events FROM the events_journal table */
   DELETE FROM event_journal 

   /* remove any tank strapping data */
   DELETE FROM Tank_Strapping 

   /* should we remove rows that are tagged as deleted :
    * DELETE FROM Hoses         WHERE Deleted = 1
    * DELETE FROM Pumps         WHERE Deleted = 1
    * DELETE FROM Grades        WHERE Deleted = 1
	* DELETE FROM Tanks         WHERE Deleted = 1
	* DELETE FROM Attendant     WHERE Deleted = 1
	* DELETE FROM Price_Profile WHERE Deleted = 1
   */
   
   /* clear any Attendant pump Logons */
   UPDATE Pumps SET Attendant_ID = NULL

   /* initialise the tank levels */
   UPDATE tanks 
      SET theoretical_volume = 0 ,
      average_cost = 0 

	/* remove all wetstock approval records */
	DELETE FROM Wetstock_approval

--	/* remove all tank_history_variance records */
--	DELETE FROM Tank_History_Variances

   COMMIT TRANSACTION 

END 
go 




---------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'sp_zero' AND type = 'P')
   DROP PROCEDURE sp_Zero
go

print 'Creating sp_Zero'
go

-- ##SUMMARY <p><font color="blue"><b>USE WITH CAUTION - WILL REMOVE HISTORIC DATA</b></font></p> <p>The <tt>sp_zero</tt> removes historic data and totals from the database ready for a trading to begin</p>
--
-- ##REMARKS <p>This procedure <b>removes all delivery, event and historic data</b> from the database. Once this data has been removed,
-- ##REMARKS new period totals for levels 1, 2, 3 and 4 are started (zero). Configuration of devices is not altered or removed.</p>
-- ##REMARKS <p>Where testing is required after a site has been configured but before the site begins trading, this procedure provides 
-- ##REMARKS a simple way to remove historic data generated during testing.</p>
--
-- ##RETURNS No return data.
CREATE PROCEDURE sp_Zero
                 -- #PARAM @Return_Value None.
AS
BEGIN 
   EXEC sp_zero_data

	/* create default open periods */
   EXEC sp_close_period 1 
   EXEC sp_close_period 2
   EXEC sp_close_period 3
   EXEC sp_close_period 4

END 
go 

---------------------------------------------------------------------------
--This stored procedure is used to delete tables which has delete TRIGGERS
--Oddly, tables with delete TRIGGERS only allows ONE record to be deleted at a time
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'sp_zap_table' AND type = 'P')
   DROP PROCEDURE sp_zap_table
go

print 'Creating sp_zap_table'
go

CREATE PROCEDURE sp_Zap_Table
	@Table_Name NVARCHAR(100),  -- Name of the table to remove delete tagged records from
    @Filter     NVARCHAR(100)   -- Filter
AS
BEGIN
   DECLARE @Count INT
   DECLARE @LastCount INT
   SET @Count = 1
   SET @LastCount = 11
   DECLARE @DYNSQL NVARCHAR(1000)

   PRINT 'Running sp_zap_table('+@Table_Name+','+@Filter+')'
   WHILE (@Count>=1)
   BEGIN
      SET @DYNSQL = 'SELECT @LastCount = COUNT(*) FROM '+@Table_Name+' '+@Filter
	  EXECUTE sp_executesql @DYNSQL, N'@LastCount INTEGER OUT', @LastCount OUT
	  SET @DYNSQL = 'DELETE FROM '+@Table_Name+' WHERE deleted = 1'
	  EXECUTE sp_executesql @DYNSQL
      SET @DYNSQL = 'SELECT @Count = COUNT(*) FROM '+@Table_Name+' '+@Filter
	  EXECUTE sp_executesql @DYNSQL, N'@Count INTEGER OUT', @Count OUT
      IF @Count = @LastCount
      BEGIN
          PRINT 'Record Count:'+Str(@Count)
          BREAK
      END
   END
END
GO


---------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'sp_zap' AND type = 'P')
   DROP PROCEDURE sp_Zap
go

print 'Creating sp_Zap'
go

/*
** SP_ZAP stored procedure 
*/
CREATE PROCEDURE sp_Zap 
AS
BEGIN 

   BEGIN TRANSACTION 

   PRINT 'Zapping Fuel_Transaction...'
   -- remove Fuel_Transaction rows for hoses have been deleted or
   -- that are connected to pumps that have been deleted. 
   DELETE FROM Fuel_Transaction WHERE Delivery_ID IN
   (SELECT Delivery_ID from Hose_Delivery WHERE Delivery_ID IN
      (SELECT hose_id FROM hoses JOIN pumps on pumps.pump_id = hoses.pump_id WHERE pumps.deleted = 1)
       OR hose_id IN
      (SELECT hose_id FROM hoses WHERE deleted = 1))

   PRINT 'Zapping Hose Delivery...'
   -- remove hose delivery for hoses have been deleted or
   -- that are connected to pumps that have been deleted. 
   DELETE FROM hose_delivery WHERE hose_id IN
  (SELECT hose_id FROM hoses JOIN pumps on pumps.pump_id = hoses.pump_id WHERE pumps.deleted = 1)
   OR hose_id IN
  (SELECT hose_id FROM hoses WHERE deleted = 1)

   PRINT 'Zapping Hose History...'
   -- remove hose hose history for hoses have been deleted or
   -- that are connected to pumps that have been deleted. 
   DELETE FROM hose_history WHERE hose_id IN
  (SELECT hose_id FROM hoses JOIN pumps on pumps.pump_id = hoses.pump_id WHERE pumps.deleted = 1)
   OR hose_id IN
  (SELECT hose_id FROM hoses WHERE deleted = 1)

    DELETE FROM hose_postmix_history WHERE hose_id IN
  (SELECT hose_id FROM hoses JOIN pumps on pumps.pump_id = hoses.pump_id WHERE pumps.deleted = 1)
   OR hose_id IN
  (SELECT hose_id FROM hoses WHERE deleted = 1)

   PRINT 'Zapping Tank Delivery...'
   -- remove tank delivery for tanks have been deleted OR 
   -- that contain a grade that has been deleted.
   DELETE FROM tank_delivery 
   WHERE tank_id IN
  (SELECT tank_id FROM tanks JOIN grades on grades.grade_id = tanks.grade_id WHERE grades.deleted = 1)
   OR tank_id IN
  (SELECT tank_id FROM tanks WHERE tanks.deleted = 1)

   PRINT 'Zapping Attendant History...'
   -- remove attendant_history for attendants that have been deleted
   DELETE FROM attendant_history WHERE attendant_id IN
   (SELECT attendant_id FROM attendant WHERE deleted = 1)

   PRINT 'Zapping Attendant Safe Drop...'
   -- remove attendant_safedrop for attendants that have been deleted
   DELETE FROM attendant_safedrop WHERE attendant_period_history_id IN
   (SELECT attendant_period_history_id 
   FROM attendant_period_history 
   JOIN attendant_period ON attendant_period.att_period_id = attendant_period_history.att_period_id 
   JOIN attendant ON attendant.attendant_id = attendant_period.attendant_id 
   WHERE deleted = 1)

   PRINT 'Zapping Attendant Period History...'
   -- remove attendant_period_history for attendants that have been deleted
   DELETE FROM attendant_period_history WHERE att_period_id IN
   (SELECT att_period_id FROM attendant_period 
   JOIN attendant ON attendant.attendant_id = attendant_period.attendant_id
   WHERE attendant.deleted = 1)

   PRINT 'Zapping Attendant Period...'
   -- delete attendant_period for attendants tagged as deleted
   DELETE FROM attendant_period WHERE attendant_id in
   (SELECT attendant_id FROM attendant WHERE deleted = 1)

   PRINT 'Zapping Tank History...'
   -- remove tank history for tanks have been deleted or
   -- that contain a grade that has been deleted.
   DELETE FROM tank_history 
   WHERE tank_id IN
   (SELECT tank_id FROM tanks JOIN grades on grades.grade_id = tanks.grade_id WHERE grades.deleted = 1)
   OR tank_id IN
   (SELECT tank_id FROM tanks WHERE tanks.deleted = 1)

   PRINT 'Zapping Tank Loss...'
   -- remove tank loss for tanks have been deleted or
   -- that contain a grade that has been deleted.
   DELETE FROM tank_loss
   WHERE tank_id IN
   (SELECT tank_id FROM tanks JOIN grades on grades.grade_id = tanks.grade_id WHERE grades.deleted = 1)
   OR tank_id IN
   (SELECT tank_id FROM tanks WHERE tanks.deleted = 1)

   PRINT 'Zapping Tank Transfer...'
   -- remove tank transfer for tanks have been deleted or
   -- that contain a grade that has been deleted.
   DELETE FROM tank_transfer
   WHERE to_tank_id IN
   (SELECT tank_id FROM tanks JOIN grades on grades.grade_id = tanks.grade_id WHERE grades.deleted = 1)
   OR to_tank_id IN
   (SELECT tank_id FROM tanks WHERE tanks.deleted = 1)

   PRINT 'Zapping Tank Readings...'
   -- remove tank readings entry
   DELETE FROM tank_readings
   WHERE Tank_ID IN
   (SELECT tank_id FROM tanks WHERE tanks.deleted = 1)
    
   PRINT 'Zapping Attendants...'
   -- remove deleted rows FROM the attendants table 
   --DELETE FROM attendant WHERE deleted = 1
   EXEC sp_zap_table 'Attendant',' WHERE Deleted=1'

   PRINT 'Zapping Hoses...'
   -- remove deleted rows FROM the hoses table
   --DELETE FROM hoses WHERE deleted = 1
   EXEC sp_zap_table 'Hoses',' WHERE Deleted=1'

   PRINT 'Zapping Hoses (checking with deleted Pumps)...'
   -- remove all hoses wherein pump is already deleted 
   --DELETE FROM hoses WHERE hoses.pump_id IN
   --(SELECT pump_id FROM pumps WHERE deleted = 1)
   EXEC sp_zap_table 'Hoses',' WHERE hoses.pump_id IN (SELECT pump_id FROM pumps WHERE deleted = 1)'

   PRINT 'Zapping Hoses (checking with Deleted Tanks)...'
   -- remove all hoses wherein tank is already deleted 
   --DELETE FROM hoses WHERE hoses.tank_id IN
   --(SELECT tank_id FROM tanks WHERE deleted = 1)
   EXEC sp_zap_table 'Hoses',' WHERE hoses.tank_id IN (SELECT tank_id FROM tanks WHERE deleted = 1)'

   PRINT 'Zapping Pumps...'
   -- remove deleted rows FROM the pumps table */
   -- DELETE FROM pumps WHERE deleted = 1
   EXEC sp_zap_table 'Pumps',' WHERE Deleted=1'

   PRINT 'Zapping Tanks...'
   --remove tanks that are deleted OR contain deleted grades */
   -- DELETE FROM tanks WHERE deleted = 1 
   --OR tanks.grade_id IN
   --(SELECT grade_id FROM grades WHERE deleted = 1)
   EXEC sp_zap_table 'tanks',' WHERE Deleted=1'

   PRINT 'Zapping Grades...'
   -- remove deleted rows FROM the grades table 
   --DELETE FROM grades WHERE deleted = 1
   --AND grades.grade_id IN
   --(SELECT grade_id FROM tanks WHERE deleted = 1)
   EXEC sp_zap_table 'Grades',' WHERE Deleted=1'

   PRINT 'Zapping Price Levels...'
   -- remove the price levels 
   DELETE FROM price_levels WHERE price_profile_id IN 
   (SELECT price_profile_id FROM price_profile WHERE deleted = 1)

   PRINT 'Zapping Price Profile...'
   -- remove deleted rows FROM the price_profile table (or which refers to deleted grades)*/
   --DELETE FROM price_profile WHERE deleted = 1 
   --OR price_profile.parent_grade_id IN
   --(SELECT grade_id FROM grades WHERE deleted = 1)
   EXEC sp_zap_table 'Price_Profile',' WHERE Deleted=1'

   PRINT 'Zapping Grade Post Mix Ratios...'
   -- remove rows FROM the Grade_PostMix_Ratio table WHERE its grade has been deleted*/
   DELETE FROM Grade_PostMix_Ratio WHERE Grade_ID IN (SELECT Grade_ID FROM Grades WHERE deleted = 1)

   COMMIT TRANSACTION

END 
go

---------------------------------------------------------------------------

IF EXISTS  (SELECT null FROM SYSOBJECTS WHERE NAME = 'sp_att_open_period_ex' AND XTYPE = 'P')
   DROP PROCEDURE sp_att_open_period_ex
Go

print 'Creating sp_att_open_period_ex'
go

CREATE PROCEDURE sp_att_open_period_ex
   @id int OUTPUT,      -- ##PARAM @id unique key for period
   @attendant_id int,   -- ##PARAM @attendant_id id of attendant logging on
   @pump_id      int    -- ##PARAM @Pump_ID id of pump for periods or  -1 for none 
AS

DECLARE	  
    @number int         -- unique key for period

BEGIN

   /* find the period for this logon */
   SELECT @id = ( SELECT att_period_id
                  FROM attendant_period 
                  WHERE @attendant_id = attendant_id AND
                        Att_Period_state = 1.0 ) 

   /* if there is none then lets make one */
   IF @id IS NULL
   BEGIN 

      /* allocate a new period_id for this new period */
      SELECT @id = ( SELECT MAX( att_period_id ) + 1 FROM attendant_period ) 
      IF @id IS NULL SELECT @id = 1 
      SELECT @number = ( SELECT MAX( att_period_number ) + 1 FROM attendant_period 
                         WHERE @attendant_id = attendant_id  )
      IF @number IS NULL SELECT @number = 1 

      /* create a new period of this type */
      INSERT INTO attendant_period
         ( att_period_ID ,
           attendant_id ,
           att_period_open_dt , 
           att_Period_State , 
           att_period_number )
      VALUES
         ( @id ,
           @attendant_id ,
           getdate() ,
           1 , 
           @number ) 
	END  

	IF @pump_id > 0 
	BEGIN
		   /* open up records for all the hoses on this pump if pump ID supplied */
		INSERT INTO attendant_history 
			( Hose_ID , 
			Att_Period_ID ,  
			Attendant_ID ) 
			SELECT 
			hose_id , 
			@id , 
			@attendant_id 
			FROM Hoses 
			WHERE pump_id = @pump_id AND hose_id not in (SELECT hose_id 
			FROM attendant_history WHERE Att_Period_ID = @id AND Attendant_ID = @attendant_id)
			AND Hoses.Deleted = 0
	END

END
go

---------------------------------------------------------------------------

IF EXISTS  (SELECT null FROM SYSOBJECTS WHERE NAME = 'sp_logon_att' AND XTYPE = 'P')
	DROP PROCEDURE sp_Logon_Att
go

print 'Creating sp_Logon_Att'
go

/* 
** SP_LOGON_ATT stored procedure (** Must remain backwards compatible **)
** Used by the Pump Server when attendant logon to a PUMP is done
*/
CREATE PROCEDURE sp_Logon_Att
    @id int OUTPUT ,           -- ##PARAM @ID unique key for period 
    @attendant_id int ,        -- ##PARAM @Attendant_ID id of attendant logging to pump 
    @pump_id int               -- ##PARAM @Pump_ID id of pump being logged on to 
AS

BEGIN 

   BEGIN TRANSACTION 

	-- Open Attendant period and create pump totals row, return @id
   	EXEC sp_att_open_period_ex @id OUTPUT, @attendant_id, @pump_id
 
   /* set the logged on flag in the open attendant_period record */
   UPDATE Attendant_Period
      SET Att_Logged_On = 1
      WHERE Att_Period_ID = @id

   /* log the attendant onto this pump */
   UPDATE Pumps
        SET attendant_id = @attendant_id
        WHERE Pump_id = @pump_id 

   COMMIT TRANSACTION 
END 
go




---------------------------------------------------------------------------

IF EXISTS  (SELECT null FROM SYSOBJECTS WHERE NAME = 'sp_att_modify_period' AND XTYPE = 'P')
	DROP PROCEDURE sp_Att_Modify_Period
go

print 'Creating sp_Att_Modify_Period'
go

-- ##SUMMARY Call this procedure to mark an Attendant's Period totals `closed` or `reconciled`.
--
-- ##REMARKS <p>Attendant periods are not dependant on the site-level shift, day and month periods. This procedure provides the 
-- ##REMARKS means to close an open attendant period, or to mark closed totals as reconciled (usually after the Attendant's 
-- ##REMARKS cash payments have been checked or auditied).</p>
-- ##REMARKS <p>This procedure is provided for both Enabler and Integrator applications to logoff or reconcile attendant totals.</p>
--
-- ##RETURNS No return data.
CREATE PROCEDURE sp_Att_Modify_Period
   @attendant_id int,   -- ##PARAM @Attendant_ID  ID of attendant to close period, or update period state.
   @new_state    int    -- ##PARAM @New_State     Target state for the Attendant's current period.<br>1=Open<br>2=Closed<br>3=Reconciled
                        -- ##PARAM @RETURN_VALUE  None.
AS
DECLARE @logged_on int
BEGIN

   IF @new_state = 2

     SELECT @logged_on = (SELECT Att_logged_On FROM Attendant_Period 
                          WHERE @attendant_id = attendant_id AND Att_Period_state = 1.0 )

     IF @logged_on = 0 
     BEGIN
       /* close off the open attendant report */
       UPDATE Attendant_Period
          SET Att_Period_state = 2 ,
              Att_Period_Close_DT = getdate() 
          WHERE @attendant_id = attendant_id AND
                Att_Period_state = 1.0 
     END
   ELSE
     UPDATE Attendant_Period
        SET Att_Period_state = @new_State
        WHERE @attendant_id = attendant_id AND
              Att_Period_state > 1.0 

END
go


---------------------------------------------------------------------------

IF EXISTS  (SELECT null FROM SYSOBJECTS WHERE NAME = 'sp_logoff_att_all' AND XTYPE = 'P')
	DROP PROCEDURE sp_logoff_att_all
go

print 'Creating sp_logoff_att_all'
go

/*
** SP_LOGOFF_ATT stored procedure (** Must retain functional backwards 
** compatible with sp_logoff_att **) Used by the Pump Server when an Attendant 
** logoff is done
*/
CREATE PROCEDURE sp_logoff_att_all
    @pump_count int OUTPUT ,        -- ##PARAM @pump_count count of the pumps logged off
    @attendant_id int ,             -- ##PARAM @attendant_id id of attendant logging to pump 
    @auto_close int                 -- ##PARAM @auto_close should be period be automatically closed (0=nope)
AS

BEGIN 
   BEGIN TRANSACTION 

   /* has to be done before calling sp_att_mody_period since it looks at this flag to */
   /* determine if it should close the period*/
   UPDATE Attendant_Period
      SET Att_Logged_On = 0
      WHERE Attendant_ID = @attendant_Id

   /* close off the open attendant report (for backwards compatibility) */
   IF @auto_close <> 0 
     EXEC sp_att_modify_period @attendant_Id, 2

   /* get a count of just how pumps WHERE assigned to this attendant */
   SELECT @pump_count = ( SELECT count(*) FROM Pumps WHERE attendant_ID = @attendant_id )

   /* log the attendant off all pumps */
   UPDATE Pumps
        SET attendant_id = NULL 
        WHERE attendant_id = @attendant_id

   COMMIT TRANSACTION 

END 
go




---------------------------------------------------------------------------

IF EXISTS  (SELECT null FROM SYSOBJECTS WHERE NAME = 'sp_logoff_att' AND XTYPE = 'P')
	DROP PROCEDURE sp_logoff_att
go

print 'Creating sp_logoff_att'
go

/*
** SP_LOGOFF_ATT stored procedure (** Must remain backwards compatible **)
** Used by the Pump Server when an Attendant logoff is done
*/
CREATE PROCEDURE sp_logoff_att
    @pump_count int OUTPUT ,       -- ##PARAM @pump_count count of the pumps logged off
    @attendant_id int              -- ##PARAM @attendant_id id of attendant logging to pump 
AS

BEGIN 

   BEGIN TRANSACTION 

   /* get a count of just how pumps WHERE assigned to this attendant */
   SELECT @pump_count = ( SELECT count(*) FROM Pumps WHERE attendant_ID = @attendant_id )

   EXEC sp_logoff_att_all @pump_count, @attendant_id, 1

   COMMIT TRANSACTION 

END 
go




---------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'sp_setup_tank' AND type = 'P')
	DROP PROCEDURE sp_setup_tank
go

print 'Creating sp_setup_tank'
go

/*
** SP_SETUP_TANK  stored procedure 
** Configures a tank - for use when configuring the system
*/
CREATE PROCEDURE sp_setup_tank 
    @result int OUTPUT ,                   -- ##PARAM @result value indicating the result
    @Tank_id int                           -- ##PARAM @Tank_id id of tank to setup 
AS

DECLARE    @Diameter decimal(10,4)  -- radius of tank 
DECLARE    @R        decimal(10,4)  -- radius of tank 
DECLARE    @R2       decimal(11,5)  -- radius squared 
DECLARE    @X        decimal(10,4)  -- difference between level and radius
DECLARE    @X2       decimal(11,5)  -- difference between level and radius
DECLARE    @L        decimal(10,4)  -- current level 
DECLARE    @Capacity decimal(12,4)  -- tank capacity 


BEGIN 
   SELECT @Diameter = ( SELECT Diameter FROM Tanks WHERE Tank_id = @tank_id ) 
   SELECT @Capacity = ( SELECT Capacity FROM Tanks WHERE Tank_id = @tank_id ) 
   /* it is very difficult to do this with a silly diameter for the tank */
   SELECT @result = -1 
   IF @Diameter = 0 or @Diameter > 20 or @Capacity = 0 
      RETURN 

   BEGIN TRANSACTION 
   DELETE FROM Tank_Strapping WHERE tank_id = @Tank_id 
   SELECT @R = @Diameter/2
   SELECT @R2 = @R*@R
   SELECT @L = 0.010 
   WHILE @L <= @Diameter 
   BEGIN
       SELECT @X = @L - @R 
       SELECT @X2 = @X * @X 
       INSERT INTO Tank_Strapping 
       ( Tank_Id , 
         strap_level , 
         level_passes , 
         strap_volume ) 
        VALUES ( @tank_id , 
                 @L , 
                 0 ,  
                 (( 3.1416 / 2  + ASIN(@X/@R) ) *@R2 + 
                 @X * SQRT(@R2 - @X2)) * @Capacity / 
                 ( 3.1416 * @R2 )  
               ) 
        SELECT @L = @L + 0.010 
        
   END
   COMMIT TRANSACTION 
   SELECT @result = 1 
END
go 




---------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'sp_adjust_strap' AND type = 'P')
   DROP PROCEDURE sp_adjust_strap
go

PRINT 'Creating sp_adjust_strap'
go

/*
** SP_ADJUST_STRAP stored procedure
**
*/
CREATE PROCEDURE sp_adjust_strap
    @Tank_id int ,          -- ##PARAM @Tank_id  id of tank to setup 
    @level   decimal(9,3) , -- ##PARAM @level    the level to update 
    @volume  decimal(11,3)  -- ##PARAM @volume   the new volume value for this strapping point

AS

DECLARE @Delta decimal(11,3) ,
    @OldVolume decimal(11,3) ,
    @dbg    varchar(80)

BEGIN 
   BEGIN TRANSACTION 

   SELECT @OldVolume = ( SELECT Strap_Volume 
                         FROM Tank_Strapping 
                         WHERE strap_level = @level AND @tank_id = Tank_id 
                       )

   SELECT @Delta = @Volume - @OldVolume 

   /* update this strapping point, and the number of adjusts done on it */
   UPDATE Tank_Strapping 
   SET strap_volume  = @Volume , 
       level_passes = level_passes + 1 
   WHERE strap_level = @level AND @tank_id = Tank_id 

   /* adjust all those above it by this amount */
   UPDATE Tank_Strapping 
   SET Strap_Volume = Strap_Volume + @Delta 
   WHERE strap_level > @level AND @tank_id = Tank_id 

   COMMIT TRANSACTION 
END 
go 



---------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'sp_log_auto_del' AND type = 'P')
	DROP PROCEDURE sp_log_auto_del
go

print 'Creating sp_log_auto_del'
go

CREATE PROCEDURE sp_log_auto_del   
    @DeliveryID int OUTPUT ,
    @tank_id         int ,        -- ##PARAM @tank_id            The ID of the tank receiving delivery
    @Volume         decimal(11,3) -- ##PARAM @Volume theoretical Volume of added to the tank
AS
BEGIN
   BEGIN TRANSACTION 
   SELECT @DeliveryID = ( SELECT Max( Tank_Delivery_id )+ 1 FROM TANK_DELIVERY )
   IF @DeliveryID IS NULL SELECT @DeliveryID = 1 
   INSERT INTO TANK_DELIVERY
   ( Tank_Delivery_id , Tank_id , Drop_Date_Time , Drop_Volume_Theo ) 
   VALUES ( @DeliveryID , @tank_id , getdate() , @Volume ) 
   COMMIT TRANSACTION 
END 
go




---------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'sp_del_hose' AND type = 'P')
	DROP PROCEDURE sp_del_hose
go

print 'Creating sp_del_hose'
go

CREATE PROCEDURE sp_del_hose
    @hose_id int 
AS 
BEGIN 
   BEGIN TRANSACTION 
        -- we no longer actually remove the history because by breaking the link
        -- via the deleted field we are effectively making the history disappear
        UPDATE hoses SET deleted = 1 WHERE hose_id = @hose_id
   COMMIT TRANSACTION 
END 
go




---------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'sp_del_tank' AND type = 'P')
	DROP PROCEDURE sp_del_tank
go

print 'Creating sp_del_tank'
go

CREATE PROCEDURE sp_del_tank
    @tank_id int  -- 
AS 
BEGIN 
    BEGIN TRANSACTION 
	-- first check that no hoses are associated with this tank
	-- we no longer actually remove the history because by breaking the link
	-- via the deleted field we are effectively making the history disappear
	IF NOT EXISTS (SELECT 1 FROM hoses WHERE tank_id = @tank_id AND deleted = 0)
		UPDATE tanks SET deleted = 1, Tank_Gauge_ID = NULL WHERE tank_id = @tank_id
	ELSE
		RAISERROR ('Cannot delete tank, hoses still linked!',18,1) 
	COMMIT TRANSACTION 
END 
go




---------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'sp_check_prices' AND type = 'P')
   DROP PROCEDURE sp_check_prices
go

print 'Creating sp_check_prices'
go

/*
** SP_CHECK_PRICES stored procedure
** check price profiles for scheduled grade price changes
** @count parameter indicates the number of grades WHERE a scheduled price change is due
*/
CREATE PROCEDURE sp_check_prices
    @count int OUTPUT                 -- number of grades affected
AS
BEGIN
	declare @GradeID int -- variable that goes through all grade IDs in iteration, starting FROM the min Grade ID, end the max Grade ID
	declare @GradeIDMAX int -- largest grade ID
	declare @NumberOfRecord int -- temp variable for counting purpose
	declare @CurrentST datetime -- will store the start time of the currently used price profile of a grade
	declare @ActiveProfileDeleted int
	declare @NewPriceProfile int	

	SELECT @GradeID = min(grade_id) FROM grades
	SELECT @GradeIDMAX = max(grade_id) FROM grades
	SELECT @count = 0

	--BEGIN Transaction
	WHILE @GradeID <= @GradeIDMAX
	BEGIN
		SELECT @NumberOfRecord = count(*) FROM Grades WHERE Grade_ID = @GradeID AND deleted = 0-- get the number of grade with this id (should be either 0 or 1)
		If @NumberOfRecord > 0 -- Grade with this ID exist!
		BEGIN
			-- get the number of price profile associated with this grade.
			SELECT @NumberOfRecord = count(*) FROM Price_Profile WHERE Parent_Grade_ID = @GradeID AND deleted = 0
			IF @NumberOfRecord > 0 -- This should always happen, if not happens means error in Database
			BEGIN
				SET @ActiveProfileDeleted = 0
				-- Required to initialize. Otherwise if resulting query is NULL, then NULL is not assigned TO @CurrentST
				SET @CurrentST = NULL
				-- Get the Start Time of the price profile that is being used by this grade.
				SELECT @CurrentST = Scheduled_ST FROM Price_Profile WHERE Price_Profile_ID = ( SELECT Price_Profile_ID FROM Grades WHERE Grade_ID = @GradeID AND deleted = 0 ) AND deleted = 0
				IF (@CurrentST is NULL)
				BEGIN
					-- Warning: No Active Profile for the Grade!
					SET @ActiveProfileDeleted = 1
				END
				IF (@ActiveProfileDeleted = 0)
				BEGIN
					SELECT @NumberOfRecord = count(*) FROM Price_Profile 
				                          WHERE Parent_Grade_ID = @GradeID  -- All price profiles associated with this grade and
				                            AND Scheduled_ST <= getdate()  -- Start times are in the past
				                            AND Scheduled_ST > @CurrentST -- Start times are newer than the start time of current price profile
                                            AND deleted = 0
					IF @NumberOfRecord > 0 -- Grade Profile update required
					BEGIN
					UPDATE Grades -- Among all the filtered candidate price profiles, we finally choose the one with newest start time.
					   SET Price_Profile_ID = ( SELECT TOP 1 Price_Profile_ID 
					                              FROM Price_Profile 
					                             WHERE Scheduled_ST = ( SELECT max( Scheduled_ST ) -- newest one
					                                                      FROM Price_Profile 
					                                                     WHERE Parent_Grade_ID = @GradeID
					                                                       AND Scheduled_ST <= getdate()
					                                                       AND Scheduled_ST > @CurrentST 
					                                                       AND deleted = 0 )
					                               AND Parent_Grade_ID = @GradeID 
					                               AND deleted = 0 ) -- in case that other price profile got same start time
					   WHERE Grade_ID = @GradeID
					
					SELECT @count = @count + 1 -- count the change
					END
				END
				ELSE
				BEGIN
					-- No Active Profile for the Grade? Look for an alternative Price Profile
					SET @NewPriceProfile = NULL
					SET @NewPriceProfile = ( SELECT TOP 1 Price_Profile_ID 
					                              FROM Price_Profile 
					                             WHERE Scheduled_ST = ( SELECT max( Scheduled_ST ) -- newest one
					                                                      FROM Price_Profile 
					                                                     WHERE Parent_Grade_ID = @GradeID
					                                                       AND deleted = 0 )
					                               AND Parent_Grade_ID = @GradeID 
					                               AND deleted = 0 ) 
					IF ( @NewPriceProfile IS NOT NULL )
					BEGIN
					-- The Active Profile has been deleted. Update and find the newest one
					UPDATE Grades SET Price_Profile_ID=@NewPriceProfile WHERE Grade_ID = @GradeID
					SELECT @count = @count + 1 -- count the change					
					END
				END

			END
		END
		-- proceed to the next grade
		SELECT @GradeID = @GradeID + 1
	END
	--Commit Transaction
END
go



---------------------------------------------------------------------------

IF EXISTS  (SELECT null FROM SYSOBJECTS WHERE NAME = 'sp_att_open_period' AND XTYPE = 'P')
   DROP PROCEDURE sp_att_open_period
Go

print 'Creating sp_att_open_period'
go

CREATE PROCEDURE sp_att_open_period
   @id int OUTPUT,      -- ##PARAM @ID unique key for period 
   @attendant_id int,   -- ##PARAM @attendant_id id of attendant logging on
   @pump_id      int    -- ##PARAM @Pump_ID id of pump for periods or  -1 for none 
AS

BEGIN

	BEGIN TRANSACTION 

	-- Open Attendant period and create pump totals row, return @id
	EXEC sp_att_open_period_ex @id OUTPUT, @attendant_id, @pump_id
 
	COMMIT TRANSACTION 
END
go


---------------------------------------------------------------------------

IF EXISTS  (SELECT null FROM SYSOBJECTS WHERE NAME = 'sp_att_save_amount' AND XTYPE = 'P')
	DROP PROCEDURE sp_att_save_amount
go

print 'Creating sp_att_save_amount'
go

/*
** SP_ATT_SAVE_AMOUNT stored procedure 
** Used by the Pump Server to save an newly entered amount
*/
CREATE PROCEDURE sp_att_save_amount
    @result int OUTPUT ,        -- ##PARAM @result       result
    @attendant_id int,          -- ##PARAM @attendant_id Internal ID of attendant 
    @amount_type int,     	    -- ##PARAM @amount_type  Type of payment to update (1=initial float, 2=safe drop, 3=amount counted)
    @payment_type int,          -- ##PARAM @payment_type Integrator defined payment type
    @amount decimal(12,3)	    -- ##PARAM @amount       Money amount entered
AS
 DECLARE @att_period_id int,
         @history_id int
BEGIN 

   BEGIN TRANSACTION 

   SELECT @result = -1 

   -- find the current att period id
   SELECT @att_period_id = ( SELECT att_period_id
                  FROM attendant_period 
                  WHERE @attendant_id = attendant_id AND
                        Att_Period_state <= 2.0 ) 

   IF @att_period_id is NULL
   BEGIN
		-- uh oh?
		print 'error no att period id'
		SELECT @result = -2
		COMMIT TRANSACTION
		RETURN
   END

   -- ensure that an Attendant_period_history record is open
   SELECT @history_id = ( SELECT attendant_period_history_id
                  FROM attendant_period_history
                  WHERE att_period_id = @att_period_id AND
                        payment_type_Id = @payment_type )

   IF @history_id is NULL
   BEGIN
	INSERT INTO attendant_period_history ( att_period_id, payment_type_id )
             VALUES ( @att_period_id, @payment_type )
        SELECT @history_ID = (SELECT attendant_period_history_id FROM attendant_period_History 
                              WHERE att_period_id = @att_period_id 
                              AND payment_type_Id = @payment_type )   
   END

   -- save the amount

   IF @amount_type = 1	-- initial float
   BEGIN
        UPDATE attendant_period_history
           SET att_period_history_initial_float = @amount
         WHERE att_period_id = @att_period_id AND
               payment_type_id = @payment_type
   END   
   ELSE IF @amount_type = 2  -- safe drop
   BEGIN
        INSERT INTO Attendant_Safedrop (Attendant_Period_History_ID, Att_Safedrop_DateTime, Att_Safedrop_Amount )
          VALUES ( @history_id, getdate(), @amount )
   END
   ELSE IF @amount_Type = 3  -- amount counted
   BEGIN
        UPDATE attendant_period_history
           SET att_period_history_amount_counted = @amount
         WHERE att_period_id = @att_period_id AND
               payment_type_id = @payment_type   
  END

  SELECT @result = 1

  COMMIT TRANSACTION 

END 
go

---------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'sp_log_detected_tank_del' AND type = 'P')
   DROP PROCEDURE sp_log_detected_tank_del
go

print 'Creating sp_log_detected_tank_del'
go

/*
** SP_LOG_DETECTED_TANK_DEL stored procedure
** record a tank delivery detected by the ATG
*/
CREATE PROCEDURE sp_log_detected_tank_del
	@DeliveryID        int OUTPUT ,
	@tank_id           int ,         -- tank receiving delivery
	@Product_Code      nvarchar(10), 
	-- start
	@Start_Date_Time   datetime,
	@Start_Volume      decimal(15,4),
	@Start_TC_Volume   decimal(15,4),
	@Start_Water       decimal(15,4),
	@Start_Temperature decimal(8,4),
	@Start_Height      decimal(8,4),
	-- end
	@End_Date_Time     datetime,
	@End_Volume        decimal(15,4),
	@End_TC_Volume     decimal(15,4),
	@End_Water         decimal(15,4),
	@End_Temperature   decimal(8,4),
	@End_Height        decimal(8,4)
AS
BEGIN
   BEGIN TRANSACTION
   SELECT @DeliveryID = ( SELECT Max( Detected_Tank_Delivery_ID )+ 1 FROM DETECTED_TANK_DELIVERY )
   IF @DeliveryID IS NULL SELECT @DeliveryID = 1
   INSERT INTO DETECTED_TANK_DELIVERY
   ( Detected_Tank_Delivery_ID ,
     Tank_id ,
     Product_Code,
     -- start
     Start_Date_Time,
     Start_Volume,
     Start_TC_Volume,
     Start_Water,
     Start_Temperature,
     Start_Height,
     -- end
     End_Date_Time,
     End_Volume,
     End_TC_Volume,
     End_Water,
     End_Temperature,
     End_Height
   )
   VALUES
   (
     @DeliveryID ,
     @tank_id ,
     @Product_Code,
     -- start
     @Start_Date_Time,
     @Start_Volume,
     @Start_TC_Volume,
     @Start_Water,
     @Start_Temperature,
     @Start_Height,
     -- end
     @End_Date_Time,
     @End_Volume,
     @End_TC_Volume,
     @End_Water,
     @End_Temperature,
     @End_Height
   )

declare @NextSiteDeliveryID int

     -- check if there was a delivery done in the past 30 minutes	
     SET @NextSiteDeliveryID = (SELECT MAX(site_delivery_id) FROM tank_delivery_detected_delivery tddd
     join detected_tank_delivery dtd on tddd.detected_tank_delivery_id = dtd.detected_tank_delivery_id
     WHERE end_date_time >= dateadd(minute,-30,getdate()) )

     -- if no delivery was done in past 30 mins
     -- attempt to get max site_delivery_id (and imcrement by 1)	
     IF @NextSiteDeliveryID IS NULL 
     BEGIN
	SET @NextSiteDeliveryID = (SELECT MAX(Site_Delivery_ID) +1
        FROM tank_delivery_detected_delivery )
     END

     -- if there was no existing site_delivery_id to increment
     -- then set the variable to 1
     IF @NextSiteDeliveryID IS NULL SELECT @NextSiteDeliveryID = 1
		
     -- insert into tank_delivery_detected_delivery

     INSERT INTO TANK_DELIVERY_DETECTED_DELIVERY
   (
     Site_Delivery_ID,
     Tank_Delivery_ID,
     Detected_Tank_Delivery_ID,
     Exported
    )
    VALUES
    (
     @NextSiteDeliveryID,
     0,
     @DeliveryID,
     0
    )

   COMMIT TRANSACTION
END
go


---------------------------------------------------------------------------

IF EXISTS ( SELECT name FROM sysobjects WHERE name = 'sp_check_detected_tank_del' AND type = 'P' )
	DROP PROCEDURE sp_check_detected_tank_del
go

print 'Creating sp_check_detected_tank_del'
go

-- ##SUMMARY <p><font color="red"><b>FOR INTERNAL USE ONLY</b></font></p> <p>The SP_CHECK_DETECTED_TANK_DEL procedure is called by pump server when a tanker delivery is detected.</p>
--
-- ##REMARKS <p>This routine is responsible for checking if the given delivery FROM the ATG 
-- ##REMARKS is new. If it is not previously recorded, it is added to the Detected_Tank_Delivery table. 
-- ##REMARKS The primary reason for this checking is to avoid recording duplicates.</p>
-- ##REMARKS <p>The @was_new out parameter indicates whether the delivery was a new one.</p>
CREATE PROCEDURE sp_check_detected_tank_del
	@Delivery_ID          int OUTPUT ,   -- ##PARAM @Delivery_ID       Indicates the ID of the row created.
	@tank_id              int ,          -- ##PARAM @Tank_ID           Indicates the tank where the fuel was added - based on the current tank probe configuration.
	@Product_Code         nvarchar(10),  -- ##PARAM @Product_Code      Product code for the tank as reported by the Automatic Tank Gauge (info only).
	-- start
	@Start_Date_Time      datetime,      -- ##PARAM @Start_Date_Time   Date and Time when the ATG detected increasing product level (tanker delivery starting)
	@Start_Volume         decimal(15,4), -- ##PARAM @Start_Volume      Gross Product Volume GOV for tank when tanker delivery started.
	@Start_TC_Volume      decimal(15,4), -- ##PARAM @Start_TC_Volume   GSV for tank when tanker delivery started.
	@Start_Water          decimal(15,4), -- ##PARAM @Start_Water       Water volume when tanker delivery started.
	@Start_Temperature    decimal(8,4),  -- ##PARAM @Start_Temperature Product temperature when tanker delivery started.
	@Start_Height         decimal(8,4),  -- ##PARAM @Start_Height      Product height when tanker delivery started.
	-- end
	@End_Date_Time        datetime,      -- ##PARAM @End_Date_Time     Date and Time when the ATG detected product level stabilised (tanker delivery finished)
	@End_Volume           decimal(15,4), -- ##PARAM @End_volume        GOV for tank when tanker delivery started.
	@End_TC_Volume        decimal(15,4), -- ##PARAM @End_TC_Volume     
	@End_Water            decimal(15,4), -- ##PARAM @End_Water         
	@End_Temperature      decimal(8,4),  -- ##PARAM @End_Temperature   
	@End_Height           decimal(8,4),  -- ##PARAM @End_Height        

	@was_new              int OUTPUT     -- ##PARAM @was_new           Output parameter, has value of 1 if the delivery was new and was logged.
AS
BEGIN
	SELECT @Delivery_ID = 
	  ( SELECT Detected_Tank_Delivery_ID 
		FROM DETECTED_TANK_DELIVERY
		WHERE Tank_ID = @Tank_ID 
		  AND Start_Date_Time = @Start_Date_Time
		  AND End_Date_Time = @End_Date_Time )

	IF @Delivery_ID IS NOT NULL 
	BEGIN
		-- Delivery already logged, so no need to log it.
		-- This is normal, since the pump server will now send us 
		-- every gauge delivery every time it polls the gauge, 
		-- and it's up to us to check if it's new or not
		-- This allows us to catch all deliveries regardless of timing.
		SELECT @Was_New = 0
		RETURN
	END

	-- Delivery is new, so log it

	SELECT @Was_New = 1

	EXEC sp_log_detected_tank_del
		@Delivery_ID OUTPUT, -- note when CALLING we must also identify this as output
		@tank_id ,
		@Product_Code,
		-- start
		@Start_Date_Time,
		@Start_Volume,
		@Start_TC_Volume,
		@Start_Water,
		@Start_Temperature,
		@Start_Height,
		-- end
		@End_Date_Time,
		@End_Volume,
		@End_TC_Volume,
		@End_Water,
		@End_Temperature,
		@End_Height

END
go

---------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'fn_trim_decimal')
	DROP FUNCTION fn_trim_decimal
go

print 'Creating fn_trim_decimal_value'
go


/*
** FN_TRIM_DECIMAL is called by SP_LOG_DELIVERY_EX so that passed values that exceeds
** maximum values can be trimmed, to avoid that SP to issue exception error
** This fixes Spot #6532 and #7436
*/

CREATE FUNCTION fn_trim_decimal( 
        @column_name      varchar(35),
    	@table_name       varchar(35),
    	@parameter_value decimal(38,4))
RETURNS decimal(38,4)

AS
BEGIN
	DECLARE    
	@precision int,                        -- holds the number of digits declared for the field  
 	@scale int,                            -- the number of digits after decimal point
	@leftpart varchar(34),                 -- the digits at the left of the decimal point
   	@rightpart varchar(4),                 -- the digits at the right of the decimal point
   	@max_string_value varchar(38),         -- string version of the maximum value
   	@max_decimal_value decimal(38,4),      -- decimal version of the maximum value
   	@final_string_value varchar(38),       -- string version of the trimmed  value
	@target_length int,                    -- target length of the trimmed value
	@start_digit_position int,             -- starting position of the large value to be trimmed
 	@converted_string_value varchar(38),   -- holds the string version of the converted value
 	@updated_value decimal(38,4)           -- holds the trimmed decimal value

	-- get the precision and scale of the passed decimal value 
	SET @precision = (SELECT COLUMNPROPERTY( OBJECT_ID(@table_name),@column_name,'PRECISION'))
	SET @scale = (SELECT COLUMNPROPERTY( OBJECT_ID(@table_name),@column_name,'SCALE'))
	
	-- determine the target length of the trimmed value 
	SET @target_length = @precision + 1 -- this includes the decimal point .
	
	-- determine the maximum value 
	SET @leftpart= REPLICATE('9',@precision-@scale)
	SET @rightpart=REPLICATE('9',@scale)
	SET @max_string_value = @leftpart+'.'+@rightpart
	SET @max_decimal_value = convert(decimal(38,4),@max_string_value)
	
	-- just set the return value to the default which is the passed value 
	SET @updated_value = @parameter_value

	-- now check if the passed value exceeds the maximum value 
        IF @parameter_value > @max_decimal_value 
	BEGIN
		-- trim the extra digits at the left and convert it back to decimal
		SET @converted_string_value = convert(varchar(38),@parameter_value)
		SET @start_digit_position =(len(@converted_string_value)-@target_length)+1
		SET @final_string_value = SUBSTRING(@converted_string_value,@start_digit_position,@target_length)
		SET @updated_value=convert(decimal(38,4),@final_string_value)
	END
	RETURN @updated_value
END 
GO


---------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'sp_log_delivery_ex' AND type = 'P')
	DROP PROCEDURE sp_log_delivery_ex
go

print 'Creating sp_log_delivery_ex'
go

-- ##SUMMARY <p><font color="red"><b>FOR INTERNAL USE ONLY</b></font></p> <p>The SP_LOG_DELIVERY_EX procedure is called by the pump server everytime a delivery is completed</p>
--
-- ##REMARKS <p>This routine inserts the delivery into the hose_delivery table and updates the hose and tank totals to reflect the volume
-- ##REMARKS of fuel delivered (including blending data)</p>
CREATE PROCEDURE sp_log_delivery_ex
	@id int OUTPUT ,                   -- ##PARAM @id            <tt>Delivery_ID</tt> of the row inserted into the <tt>Hose_Delivery</tt> table.
	@hose_id int ,                     -- ##PARAM @hose_id       ID of hose that has delivered fuel.
	@type tinyint ,                    -- ##PARAM @type          Delivery type 
	@price_level smallint ,            -- ##PARAM @price_level   Price level that the delivery was made at
	@sell_price decimal(12,4) ,        -- ##PARAM @sell_price    Unit sell price of the delivery 
	@value decimal(38,4) ,             -- ##PARAM @value         Total sell price of the delivery as displayed at the pump.
	@volume decimal (38,4) ,           -- ##PARAM @volume        Total quantity/volume of the delivery 
	@state tinyint ,                   -- ##PARAM @state         State of the pump when the delivery ended.
	@reserved_by int ,                 -- ##PARAM @reserved_by   The Terminal that reserved the pump for this delivery, or -1 
	@attendant_id int ,                -- ##PARAM @attendant_id  ID of any attendant associated with the delivery.
	@volume_total decimal(38,4) ,      -- ##PARAM @volume_total  Volume/Quantity electronic total reported by the pump at the end of the delivery.
	@money_total decimal(38,4) ,       -- ##PARAM @money_total   Money electronic total reported by the pump at the end of the delivery.
	@volume2 decimal(38,4),            -- ##PARAM @volume2       Contribution to the volume/quantity from the second base grade (blenders only)
	@volume_total2 decimal(38,4) ,     -- ##PARAM @volume_total2 The 2nd base grade volume/quantity electronic total/meter on the hose. Zero for non-blending hoses.
	@money_total2 decimal(38,4) ,      -- ##PARAM @money_total2  The 2nd base grade money electronic total on the hose. Zero for non-blending hoses.
	@blend_ratio decimal(8,4),         -- ##PARAM @blend_ratio   the blend ratio used in the delivery. Zero for non-blending hoses.
	@auth_ref int,                     -- ##PARAM @auth_ref      authorization reference (reserved)
	@trans_id int,                     -- ##PARAM @trans_id      transaction id (reserved)
	@volume_total_Turnover_Correction decimal(38,4) ,   -- ##PARAM @volume_total_Turnover_Correction  the calculated volume total turnover for this hose
	@money_total_Turnover_Correction decimal(38,4) ,    -- ##PARAM @money_total_Turnover_Correction   the calculated money total turnover for this hose
	@volume_total2_Turnover_Correction decimal(38,4) ,  -- ##PARAM @volume_total2_Turnover_Correction the calculated volume total turnover for this hose
	@volume_total_state int ,				   -- ##PARAM @volume_total_state            Reading status of the volume/quantity electronic total/meter.
	@money_total_state int ,				   -- ##PARAM @money_total_state             Reading status of the money electronic total/meter.
	@volume_total2_state int ,         -- ##PARAM @volume_total2_state   Reading status of the volume/quantity electronic total/meter for the second base grade
	@value1 decimal(38,4),             -- ##PARAM @value1 the value amount of the 1st base grade FROM the delivery - if post-mix blending is used 
	@volume1 decimal(38,4),            -- ##PARAM @volume1 the volume amount of the 1st base grade FROM the delivery - if post-mix blending is used
	@value2 decimal(38,4),             -- ##PARAM @value2 the value amount of the 2nd base grade FROM the delivery - if post-mix blending is used 	
	@volume_total1 decimal(38,4) ,     -- ##PARAM @volume_total1 the 1st base grade (fuel) volume electronic total on the hose - if post-mix blending is used
	@money_total1 decimal(38,4) ,      -- ##PARAM @money_total1 the 1st base grade (fuel) money electronic total on the hose  - if post-mix blending is used
	@grade1_price decimal(12,4) ,      -- ##PARAM @grade1_price Unit sell price of the 1st base grade, or zero for non-blending hoses.
	@grade2_price decimal(12,4)        -- ##PARAM @grade2_price Unit sell price of the 2nd base grade, or zero for non-blending hoses.

AS

DECLARE 
	@buy_price decimal(12,4),          -- the unit cost price of the delivery 
	@tank_id int ,                     -- the id of the tank the supplied this delivery
	@tank2_id int ,                    -- the id of the second tank ( blenders only ) 
	@pvt_id int,                       -- unique id for pvt record 
	@updated_value decimal(38,4),      -- trimmed decimal value of the passed parameter
	@tank_theo_volume decimal(15,4),
	@tank_capacity decimal(12,4)

BEGIN 

	/* generate a private ID for this delivery 
	** determine which tank this delivery came FROM 
	** and get the cost price of the delivery */

	BEGIN TRANSACTION 

	/* Trim pump-based passed values to avoid exception error */	
	
	SET @value  		= (SELECT dbo.fn_trim_decimal('delivery_value','hose_delivery',@value))
	SET @volume 		= (SELECT dbo.fn_trim_decimal('delivery_volume','hose_delivery',@volume))
	SET @volume_total 	= (SELECT dbo.fn_trim_decimal('hose_meter_volume','hose_delivery',@volume_total))
	SET @money_total	= (SELECT dbo.fn_trim_decimal('hose_meter_value','hose_delivery',@money_total))
	SET @volume2		= (SELECT dbo.fn_trim_decimal('delivery2_volume','hose_delivery',@volume2))
	SET @volume_total2	= (SELECT dbo.fn_trim_decimal('hose_meter_volume2','hose_delivery',@volume_total2))
	SET @money_total2	= (SELECT dbo.fn_trim_decimal('hose_meter_value2','hose_delivery',@money_total2))
	SET @volume_total_Turnover_Correction	= (SELECT dbo.fn_trim_decimal('volume_total_Turnover_Correction','hoses',@volume_total_Turnover_Correction))
	SET @money_total_Turnover_Correction	= (SELECT dbo.fn_trim_decimal('money_total_Turnover_Correction','hoses',@money_total_Turnover_Correction ))
	SET @volume_total2_Turnover_Correction  = (SELECT dbo.fn_trim_decimal('volume_total2_Turnover_Correction','hoses',@volume_total2_Turnover_Correction))
	SET @value1  = (SELECT dbo.fn_trim_decimal('delivery1_value','hose_delivery',@value1))
	SET @volume1  = (SELECT dbo.fn_trim_decimal('delivery1_volume','hose_delivery',@volume1))
	SET @value2  = (SELECT dbo.fn_trim_decimal('delivery2_value','hose_delivery',@value2))
	SET @volume_total1  = (SELECT dbo.fn_trim_decimal('hose_meter_volume1','hoses',@volume_total1))
	SET @money_total1  = (SELECT dbo.fn_trim_decimal('hose_meter_value1','hoses',@money_total1))
	SET @blend_ratio  = (SELECT dbo.fn_trim_decimal('blend_ratio','hose_delivery',@blend_ratio))
	
	SELECT @id = -1 

	/* Prepay refunds are deliveries made up by Enabler, should not update hoses*/
	IF @Type <> 4 /* Available Prepay Refund */
	BEGIN

		/* AVAILABLE_PREPAY_REFUND_DELIVERY or Type 4 should not update any of this */
		/* update the theoretical and electronic meters for this hose */
		UPDATE hoses  
		   SET volume_total       = @volume_total ,
		       money_total        = @money_total ,
		       theoretical_total  = theoretical_total + @volume , 
		       volume_total2      = @volume_total2 ,
		       money_total2       = @money_total2 ,
		       theoretical_total2 = theoretical_total2 + @volume2,
	       	       volume_total1	  = @volume_total1,
		       money_total1	  = @money_total1	
		   WHERE hose_id = @hose_id 

		UPDATE hoses  
			SET volume_total_Turnover_Correction = @volume_total_Turnover_Correction,
		      money_total_Turnover_Correction = @money_total_Turnover_Correction,
		      volume_total2_Turnover_Correction = @volume_total2_Turnover_Correction 
		   	WHERE hose_id = @hose_id 

		/* register only valid meter error states */
		IF @volume_total_state>0
		BEGIN
			UPDATE Hoses
			   SET volume_total_state_ID=@volume_total_state
		 	 	WHERE hose_id = @hose_id 
		END
		IF @money_total_state>0
		BEGIN
			UPDATE Hoses
			   SET money_total_state_id=@money_total_state
		 	 	WHERE hose_id = @hose_id 
		END		
		IF @volume_total2_state>0
		BEGIN
			UPDATE Hoses
			   SET volume_total2_state_id=@volume_total2_state
		 	 	WHERE hose_id = @hose_id 
		END		

		/* this may have been just a change in the meters so bail out now */
		IF @TYPE = 0 
		BEGIN 
			COMMIT TRANSACTION 
			RETURN 
		END 
	END

	SELECT @id       = ( SELECT MAX( delivery_id ) + 1 FROM hose_delivery ) , 
	       @tank_id  = ( SELECT tank_id FROM hoses WHERE hose_id = @hose_id ) ,
	       @tank2_id = ( SELECT tank2_id FROM hoses WHERE hose_id = @hose_id ) 

	SELECT @buy_price = ( SELECT average_cost FROM tanks WHERE tank_id = @tank_id )  

	IF @id IS NULL SELECT @id = 1 

	/* insert the delivery into the hose_delivery table */

	INSERT INTO hose_delivery 
		( delivery_id , 
		  hose_id , 
		  completed_ts ,
		  delivery_type , 
		  del_sell_price , 
		  del_cost_price ,
		  delivery_value ,
		  delivery_volume , 
		  delivery_state ,
		  price_level , 
		  reserved_by , 
		  attendant_id ,
		  delivery2_volume ,
		  hose_meter_volume ,
		  hose_meter_value  , 
		  hose_meter_volume2 ,
		  hose_meter_value2,
		  blend_ratio,
       		  delivery1_value,
		  delivery1_volume,
		  delivery2_value,
		  hose_meter_volume1, 
		  hose_meter_value1,
		  grade1_price,
		  grade2_price	) 
	VALUES 
		( @id ,
		  @hose_id ,
		  getdate() ,
		  @type ,
		  @sell_price ,
		  @buy_price ,
		  @value ,
		  @volume ,
		  @state ,
		  @price_level ,
		  @reserved_by ,
		  @attendant_id ,
		  @volume2 , 
		  @volume_total ,
		  @money_total  , 
		  @volume_total2 ,
		  @money_total2,
		  @blend_ratio,
		  @value1,
       		  @volume1, 
		  @value2,
		  @volume_total1,
		  @money_total1,
		  @grade1_price,
		  @grade2_price	) 

	IF @Type = 4 /* Available Prepay Refund */
	BEGIN
		/* Nothing further to do for prepay refunds, which are not real deliveries */
		COMMIT TRANSACTION
		RETURN
	END

   /* if this tank is conencted to another (manifolded) then adjust volume in connected tank */
   IF ( SELECT tank_connection_type_id FROM tanks WHERE tank_id = @tank_id  ) > 1 
        SELECT @tank_id = ( SELECT strapped_tank_id FROM tanks WHERE tank_id = @tank_id ) 
   IF ( SELECT tank_connection_type_id FROM tanks WHERE tank_id = @tank2_id  ) > 1 
        SELECT @tank2_id = ( SELECT strapped_tank_id FROM tanks WHERE tank_id = @tank2_id ) 

	SELECT @tank_capacity 	 =  ( SELECT capacity FROM tanks WHERE tank_id = @tank_id ),
	       @tank_theo_volume =  ( SELECT theoretical_volume FROM tanks WHERE tank_id = @tank_id )

	If ( @tank_theo_volume - @volume + @volume2 ) > ( 0 - @tank_capacity)
   	BEGIN
		/* update the theoritical tank level for this delivery */
		UPDATE tanks 
		   SET theoretical_volume = theoretical_volume - @volume + @volume2
		 WHERE tank_id = @tank_id 	
	END
	ELSE
	BEGIN
		/* update the theoritical tank level for this delivery */
		UPDATE tanks 
	   		SET theoretical_volume = (0 - @tank_capacity)
	 	 WHERE tank_id = @tank_id 
	END

	SELECT @tank_capacity 	 =  ( SELECT capacity FROM tanks WHERE tank_id = @tank2_id ),
	       @tank_theo_volume =  ( SELECT theoretical_volume FROM tanks WHERE tank_id = @tank2_id )

	If ( @tank_theo_volume - @volume2 ) > ( 0 - @tank_capacity)
   	BEGIN		
		/* update the theoretical tank level for this delivery */
		UPDATE tanks 
	   		SET theoretical_volume = theoretical_volume - @volume2
	 	 WHERE tank_id = @tank2_id 
	END
	ELSE
	BEGIN
		/* update the theoretical tank level for this delivery */
		UPDATE tanks 
	   		SET theoretical_volume = (0 - @tank_capacity)
	 	 WHERE tank_id = @tank2_id 
	END

	/* if PVT totalling is turned on then update the PVT totals */
	IF ( SELECT pvt_on FROM global_settings ) <> 0 
	BEGIN 
		/* close off any open PVT records for this hose with a different price */
		/* cause code 1 is price change */
		UPDATE PVT 
		   SET PVT_cause_code = 1 , 
		       PVT_stop_time = getdate() 
		 WHERE PVT_cause_code IS NULL
		   AND hose_id = @hose_id  
		   AND PVT_Price_Level = @Price_Level 
		   AND PVT_price > 0 
		   AND PVT_price <> @sell_price

		/* determine if there are any records open for this hose */
		IF ( SELECT COUNT(*) FROM PVT 
		      WHERE hose_id = @hose_id
		        AND PVT_Price_Level = @Price_Level
		        AND PVT_cause_code is NULL ) = 0 
		BEGIN 

			/* if not create one for this hose and price */
			SELECT @PVT_id = ( SELECT MAX( PVT_id ) + 1 FROM PVT )

			IF @PVT_id IS NULL 
				SELECT @PVT_id = 1 

			INSERT INTO PVT 
				( PVT_id , 
				  hose_id , 
				  PVT_start_time , 
				  PVT_Price,
			    PVT_Price_Level ) 
			VALUES 
				( @pvt_id , 
				  @hose_id , 
				  getdate() , 
				  @sell_price ,
			    @Price_Level ) 
		END 
   
		/* update the PVT totals */ 
		UPDATE PVT 
		   SET PVT_Quantity = PVT_Quantity + 1 , 
		       PVT_Volume = PVT_Volume + @volume , 
		       PVT_Value = PVT_Value + @value 
		 WHERE hose_id = @hose_id
		   AND PVT_Price_Level = @Price_Level
		   AND PVT_cause_code is NULL 

	END  

	/* If an attendant is logged on to the pump, add delivery to its totals */
	UPDATE Attendant_history
	   SET Quantity_Total    = Attendant_history.Quantity_Total + 1 ,
	       Volume_Total      = Attendant_history.Volume_Total + @volume ,
	       Value_Total       = Attendant_history.Value_Total + @value,
	       Volume_Total1      = Attendant_history.Volume_Total1 + @volume1 ,
	       Value_Total1       = Attendant_history.Value_Total1 + @value1,
	       Volume_Total2      = Attendant_history.Volume_Total2 + @volume2,
	       Value_Total2       = Attendant_history.Value_Total2 + @value2
	  FROM Hose_Delivery
	       INNER JOIN Attendant_history ON (Hose_Delivery.Hose_ID = Attendant_history.Hose_ID)
	       INNER JOIN Hoses             ON (Hose_Delivery.Hose_ID = Hoses.Hose_ID)
	       INNER JOIN Pumps             ON (Hoses.Pump_ID = Pumps.Pump_ID)
	       INNER JOIN Attendant_period  ON (Attendant_history.Att_Period_ID = Attendant_period.Att_Period_ID)
	 WHERE Hose_Delivery.Delivery_ID = @id 
	   AND Pumps.Attendant_ID = Attendant_History.Attendant_ID
	   AND Attendant_Period.Att_Period_State = 1.0

	/* Calls another stored procedure, allowing clients to write their own user-defined hook */
	IF EXISTS (SELECT NULL FROM SYSOBJECTS WHERE NAME = 'sp_post_delivery' AND XTYPE = 'P')
		IF (@id > -1)
			EXEC ('sp_post_delivery ' + @id)      

	COMMIT TRANSACTION 

END
GO




---------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'sp_log_tank_loss' AND type = 'P')
   DROP PROCEDURE sp_log_tank_loss
go

print 'Creating sp_log_tank_loss'
go

-- ##SUMMARY <p>The SP_LOG_TANK_LOSS procedure is provided to update Tank History when tank loss records are entered to facilitate wet stock management.</p>
--
-- ##REMARKS <p>The Wet Stock (Fuel Reconciliation) functionality in Enabler provides recording of tank movements and losses.
-- ##REMARKS This routine is a hook provided to update history data after a tank_loss row has been inserted (or updated).</p>
-- ##REMARKS <p>When an existing row is edited, this procedure should be called twice; first to undo the previous loss 
-- ##REMARKS (negative value of old volume value), second to re-do the loss entry (positive volume of the fuel lost from the tank).</p>
--
-- ##RETURNS No return data
CREATE PROCEDURE sp_Log_Tank_Loss
	@Tank_id   int,           -- ##PARAM @Tank_ID   ID of tank that had a loss
	@Period_id int,           -- ##PARAM @Period_ID ID of the day period when this loss happened
	@volume    decimal(15,4), -- ##PARAM @Volume    Volume of wet stock lost
	@doc_ref   nchar(10),     -- ##PARAM @Doc_Ref   Document reference or tracking number
	@detail    nchar(40),     -- ##PARAM @Detail    Notes describing the tank loss
	@lossTime  datetime       -- ##PARAM @LossTime  Date and time when the loss happened
AS
DECLARE
	@tank_capacity decimal(12,4),
	@tank_theo_volume decimal(15,4)

BEGIN 

   BEGIN TRANSACTION 
   
   SELECT @tank_capacity    =  ( SELECT capacity FROM tanks WHERE tank_id = @tank_id ),
          @tank_theo_volume =  ( SELECT theoretical_volume FROM tanks WHERE tank_id = @tank_id )

   If ( @tank_theo_volume - @volume ) > ( 0 - @tank_capacity)
   BEGIN
	/* update the theoretical tank level for this delivery */
   UPDATE tanks 
      SET theoretical_volume = theoretical_volume - @volume
    WHERE Tank_ID = @Tank_id
   END
   ELSE
   BEGIN
  	/* update the theoretical tank level for this delivery */
	UPDATE tanks 
		SET theoretical_volume = (0 - @tank_capacity)
	 WHERE tank_id = @tank_id 
   END	
   
   -- update all the open tank history records necessary for the tank ID.
   UPDATE tank_history 
      SET Tank_Loss_Quantity = Tank_Loss_Quantity + SIGN( @volume ),
          Tank_Loss_Volume   = Tank_Loss_Volume + @volume
     FROM tank_history 
    WHERE tank_id   = @Tank_id
      AND period_id = @Period_id


   -- update the open theo volume for all tank history periods 
   -- WHERE the period open time is after or at the same 
   -- time as the loss time
   UPDATE tank_history 
      SET open_theo_volume = open_theo_volume - @volume 
     FROM tank_history TH, periods P 
    WHERE tank_id   = @tank_id
      AND TH.period_id = P.period_id 
      AND P.Period_Create_TS >= @lossTime 

   -- update the close theo volume for all tank history periods where:
   -- the period is closed and the close time is after or at the same time as the loss
   -- OR the period is still open
   UPDATE tank_history 
      SET close_theo_volume = close_theo_volume - @volume
     FROM tank_history TH, periods P 
    WHERE tank_id   = @tank_id
      AND TH.period_id = P.period_id 
      AND (   (P.Period_Close_DT >= @lossTime AND P.Period_State = 2 )
           OR (P.Period_State = 1))
             
   COMMIT TRANSACTION 

END
go




---------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'sp_log_tank_transfer' AND type = 'P')
   DROP PROCEDURE sp_log_tank_transfer
go

print 'Creating sp_log_tank_transfer'
go


-- ##SUMMARY <p>The SP_LOG_TANK_TRANSFER procedure is provided to update Tank History when tank loss records are entered to facilitate wet stock management.</p>
--
-- ##REMARKS <p>The Wet Stock (Fuel Reconciliation) functionality in Enabler provides recording of tank movements and losses.
-- ##REMARKS This routine is a hook provided to update history data after a tank_transfer row has been inserted (or updated).</p>
-- ##REMARKS <p>When an existing row is edited, this procedure should be called twice; first to undo the previously entered transfer data
-- ##REMARKS (negative value of old volume value), second to re-do the loss entry (positive volume of the fuel transfer from the tank).</p>
--
CREATE PROCEDURE sp_Log_Tank_Transfer
	@From_Tank_ID int ,          -- ##PARAM @From_Tank_id ID of tank that the transfer came from
	@To_Tank_ID   int ,          -- ##PARAM @To_Tank_ID   ID of tank that received the transfer
	@Period_ID    int,           -- ##PARAM @Period_ID    ID of the period this transfer was done in
	@Volume       decimal(15,4), -- ##PARAM @Volume       Volume of stock transferred
	@Doc_Ref      nchar(10),     -- ##PARAM @Doc_Ref      Doc ref
	@Detail       nchar(40),     -- ##PARAM @Detail       Description
	@TransferTime datetime       -- ##PARAM @TransferTime Date and time of the tank transfer
                                 -- ##PARAM @Return_Value Nothing.
AS
DECLARE
	@tank_capacity    decimal(12,4),
	@tank_theo_volume decimal(15,4)

BEGIN 

   BEGIN TRANSACTION 
   SELECT @tank_capacity    =  ( SELECT capacity FROM tanks WHERE tank_id = @From_Tank_ID ),
          @tank_theo_volume =  ( SELECT theoretical_volume FROM tanks WHERE tank_id = @From_Tank_ID )

   If ( @tank_theo_volume - @volume ) > ( 0 - @tank_capacity)
   BEGIN
   
   -- For the From Tank we will subtract for tank volume being transferred out.
   UPDATE tanks 
      SET theoretical_volume = theoretical_volume - @volume
    WHERE Tank_ID = @From_Tank_ID
   END
   ELSE
   BEGIN
  	/* update the theoretical tank level for this delivery */
	UPDATE tanks 
		SET theoretical_volume = (0 - @tank_capacity)
	 WHERE tank_id = @From_Tank_ID 
   END
   
   SELECT @tank_capacity    =  ( SELECT capacity FROM tanks WHERE tank_id = @To_Tank_ID ),
          @tank_theo_volume =  ( SELECT theoretical_volume FROM tanks WHERE tank_id = @To_Tank_ID )

   If ( @tank_theo_volume - @volume ) > ( 0 - @tank_capacity)
   BEGIN
   
   -- For the To Tank we will subtract for tank volume being transferred out.
   UPDATE tanks 
      SET theoretical_volume = theoretical_volume + @volume
    WHERE Tank_ID = @To_Tank_ID
   END
   ELSE
   BEGIN
  	/* update the theoretical tank level for this delivery */
	UPDATE tanks 
		SET theoretical_volume = (0 - @tank_capacity)
	 WHERE tank_id = @To_Tank_ID 
   END
	

   -- update all the open tank history records necessary for the
   -- From tank ID. The FROM tank will be subtracted.
   UPDATE tank_history 
      SET Tank_Transfer_Out_Quantity = Tank_Transfer_Out_Quantity + SIGN( @volume ) ,
          Tank_Transfer_Out_Volume   = Tank_Transfer_Out_Volume + @volume
     FROM tank_history 
    WHERE tank_id   = @From_Tank_id
      AND period_id = @Period_id

   -- update all the open tank history records necessary for the
   -- To tank ID
   UPDATE tank_history 
      SET Tank_Transfer_In_Quantity = Tank_Transfer_In_Quantity + SIGN( @volume ),
          Tank_Transfer_In_Volume   = Tank_Transfer_In_Volume + @volume
     FROM tank_history 
    WHERE tank_id   = @To_Tank_id
      AND period_id = @Period_id 

 
   -- Increase the open theo volume for all the to-tank history periods 
   -- WHERE the period open time is after or at the same 
   -- time as the tank transfer time
   UPDATE tank_history 
      SET open_theo_volume = open_theo_volume + @volume 
     FROM tank_history TH, periods P 
    WHERE tank_id   = @To_Tank_id
      AND TH.period_id = P.period_id
      AND P.Period_Create_TS >= @transferTime 

   -- Increase the close theo volume for all the to-tank history periods 
   -- WHERE the period is already closed and the period close time is after 
   -- or at the same time as the tank transfer time or else the
   -- period is still open
   UPDATE tank_history 
      SET close_theo_volume = close_theo_volume + @volume 
     FROM tank_history TH, periods P 
    WHERE tank_id   = @To_Tank_id
      AND TH.period_id = P.period_id
      AND (   (P.Period_Close_DT >= @transferTime AND P.Period_State = 2 )
           OR (P.Period_State = 1))

   -- Decrease the open theo volume for all the from-tank history periods 
   -- WHERE the period open time is after or at the same 
   -- time as the tank transfer time
   UPDATE tank_history 
      SET open_theo_volume = open_theo_volume - @volume 
     FROM tank_history TH, periods P 
    WHERE tank_id   = @from_tank_id
      AND TH.period_id = P.period_id
      AND P.Period_Create_TS >= @transferTime 

   -- Decrease the close theo volume for all the to-tank history periods 
   -- WHERE the period is already closed and the period close time is after 
   -- or at the same time as the tank transfer time or else the
   -- period is still open
   UPDATE tank_history 
      SET close_theo_volume = close_theo_volume - @volume
     FROM tank_history TH, periods P 
    WHERE tank_id   = @from_tank_id
      AND TH.period_id = P.period_id
      AND (   (P.Period_Close_DT >= @transferTime AND P.Period_State = 2 )
           OR (P.Period_State = 1))
             
   COMMIT TRANSACTION 

END
go




---------------------------------------------------------------------------

IF EXISTS  (SELECT null FROM SYSOBJECTS WHERE NAME = 'sp_logoff_att_pump' AND XTYPE = 'P')
	DROP PROCEDURE sp_logoff_att_pump
go

print 'Creating sp_logoff_att_pump'
go

/*
** SP_LOGOFF_ATT_PUMP stored procedure 
** Used by the Pump Server when an Attendant logoff FROM a PUMP is done
*/
CREATE PROCEDURE sp_logoff_att_pump
    @pump_count int OUTPUT ,        -- count of the pumps logged off
    @attendant_id int,              -- id of attendant logging to pump 
    @pump_id int		    -- id of pump being logged off from
AS

BEGIN 

   BEGIN TRANSACTION 

   /* log the attendant off all pumps */
   UPDATE Pumps
        SET attendant_id = NULL 
        WHERE attendant_id = @attendant_id AND pump_id = @pump_id

   /* get a count of just how pumps WHERE assigned to this attendant */
   SELECT @pump_count = ( SELECT count(*) FROM Pumps WHERE attendant_ID = @attendant_id )

   IF @pump_count = 0
     UPDATE Attendant_Period
        SET Att_Logged_On = 0
        WHERE Attendant_ID = @attendant_Id AND Att_Logged_On > 0

   COMMIT TRANSACTION 

END 
go




---------------------------------------------------------------------------

IF EXISTS  (SELECT null FROM SYSOBJECTS WHERE NAME = 'sp_logon_att_site' AND XTYPE = 'P')
	DROP PROCEDURE sp_logon_att_site
go

print 'Creating sp_logon_att_site'
go

/*
** SP_LOGON_ATT_SITE stored procedure 
** Used by the Pump Server when attendant logon to the SITE is done
*/
CREATE PROCEDURE sp_logon_att_site
    @id int OUTPUT ,                -- ##PARAM @id unique key for period 
    @attendant_id int               -- ##PARAM @attendant_id id of attendant logging to pump 
AS

BEGIN 

   BEGIN TRANSACTION 

	-- Open Attendant period , return @id
 	EXEC sp_att_open_period_ex @id OUTPUT, @attendant_id, -1

   UPDATE Attendant_Period
      SET Att_Logged_On = 1
      WHERE Att_Period_ID = @id

   COMMIT TRANSACTION 
END 
go

---------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'reinstate_postmix_delivery' AND type = 'P')
	DROP PROCEDURE reinstate_postmix_delivery
go

print 'Creating reinstate_postmix_delivery'
go

/*
** Reinstate_postmix_delivery stored procedure
** Designed to be called FROM sp_reinstate_delivery
** Only has the purpose of updating the relevant hose_postmix_history tables. 
*/
CREATE PROCEDURE reinstate_postmix_delivery
		@reinstate_result  smallint OUTPUT, 
		@baseGradeNumber   tinyint,
		@id                int,
		@Previous_Del_Type tinyint
AS
	DECLARE @value decimal(15,4)
	DECLARE @volume decimal(15,4)
	DECLARE @price decimal(15,4)
BEGIN

		-- check to see if the delivery ID can be located , if not bail out
	SELECT @reinstate_result = -1

	IF NOT EXISTS ( SELECT delivery_id FROM hose_delivery WHERE delivery_id = @id )
		RETURN 

	IF @baseGradeNumber  < 1 OR @baseGradeNumber > 2
	BEGIN
		PRINT '@baseGradeNumber must be 1 or 2. Hose_PostMix_History will not be updated'
	        RETURN
	END	

	-- make sure the delivery in question is currently cleared 
	-- (it is not valid to reinstate a current, stacked or reinstated delivery)
	SELECT @reinstate_result = -2
	IF @Previous_Del_Type in (1,2,3,4,15)
		RETURN

	IF @baseGradeNumber = 1
	BEGIN
		SET @value = (SELECT delivery1_value FROM hose_delivery WHERE delivery_id = @id)
	        SET @volume = (SELECT delivery1_volume FROM hose_delivery WHERE delivery_id = @id) 
		SET @price = (SELECT grade1_price FROM hose_delivery WHERE delivery_id = @id) 
	END
	ELSE
	BEGIN
		SET @value = (SELECT delivery2_value FROM hose_delivery WHERE delivery_id = @id)
	        SET @volume = (SELECT delivery2_volume FROM hose_delivery WHERE delivery_id = @id) 
		SET @price = (SELECT grade2_price FROM hose_delivery WHERE delivery_id = @id) 
	END


	BEGIN TRANSACTION   

		
		-- decrement all the open period totals this delivery was previously associated with

		IF @Previous_Del_Type = 5                -- postpay delivery 

			UPDATE hose_postmix_history 
         		SET postpay_quantity                    = postpay_quantity - 1 ,
             			postpay_volume                   	= postpay_volume - @volume ,
             			postpay_value                    	= postpay_value - @value ,
             			postpay_cost                     	= postpay_cost- (@price * @volume)
         		FROM hose_delivery hd, hose_postmix_history hph , periods p
         		WHERE  	hd.delivery_id                 = @id AND
				hph.base_grade_number	       = @baseGradeNumber AND
                		hph.hose_id                    = hd.hose_id  AND	
                		hph.period_id                  = p.period_id AND 
                		p.period_state                 = 1.0 


		ELSE IF @Previous_Del_Type = 6         -- monitor delivery 

			UPDATE hose_postmix_history 
         			SET monitor_quantity             = monitor_quantity - 1 ,
             			monitor_volume                   = monitor_volume - @volume ,
             			monitor_value                    = monitor_value - @value ,
             			monitor_cost                     = monitor_cost - (@price * @volume)
        		FROM hose_delivery hd, hose_postmix_history hph , periods p
         		WHERE  	hd.delivery_id                 = @id AND
				hph.base_grade_number	       = @baseGradeNumber AND
                		hph.hose_id                    = hd.hose_id  AND	
                		hph.period_id                  = p.period_id AND 
                		p.period_state                 = 1.0 

		ELSE IF @Previous_Del_Type = 11     -- test delivery 

			UPDATE hose_postmix_history 
            			SET test_del_quantity            = test_del_quantity - 1 ,
                		test_del_volume              = test_del_volume - @volume
            		FROM hose_delivery hd, hose_postmix_history hph , periods p
         		WHERE  	hd.delivery_id                 = @id AND
				hph.base_grade_number	       = @baseGradeNumber AND
                		hph.hose_id                    = hd.hose_id  AND	
                		hph.period_id                  = p.period_id AND 
                		p.period_state                 = 1.0

		ELSE IF @Previous_Del_Type = 12     -- drive off delivery 
			UPDATE hose_postmix_history 
         			SET driveoffs_quantity         = driveoffs_quantity - 1 ,
             			driveoffs_volume           = driveoffs_volume - @volume ,
             			driveoffs_value            = driveoffs_value - @value ,
             			driveoffs_cost             = driveoffs_cost - (@price * @volume)
         		FROM hose_delivery hd, hose_postmix_history hph , periods p
         		WHERE  	hd.delivery_id                 = @id AND
				hph.base_grade_number	       = @baseGradeNumber AND
                		hph.hose_id                    = hd.hose_id  AND	
                		hph.period_id                  = p.period_id AND 
                		p.period_state                 = 1.0  
  

		ELSE IF @Previous_Del_Type = 13         -- attendant delivery 
		BEGIN 

			UPDATE hose_postmix_history 
            			SET monitor_quantity         = monitor_quantity - 1 ,
                		monitor_volume           = monitor_volume - @volume ,
                		monitor_value            = monitor_value - @value ,
                		monitor_cost             = monitor_cost - (@price * @volume) 
            		FROM hose_delivery hd, hose_postmix_history hph , periods p
         		WHERE  	hd.delivery_id                 = @id AND
				hph.base_grade_number	       = @baseGradeNumber AND
                		hph.hose_id                    = hd.hose_id  AND	
                		hph.period_id                  = p.period_id AND 
                		p.period_state                 = 1.0 

	  		IF @baseGradeNumber = 1
			BEGIN
          			UPDATE attendant_history 
				   SET attendant_quantity1         = attendant_quantity1 - 1 ,
				       attendant_volume1           = attendant_volume1 -  @volume ,
				       attendant_value1            = attendant_value1 - @value
				  FROM hose_delivery hd, 
				       attendant_history ah , 
				       attendant_period ap
				WHERE  hd.delivery_id          = @id AND
				       hd.attendant_id         = ah.attendant_id AND 
				       hd.hose_id              = ah.hose_id AND 
			 	      ap.att_period_id        = ah.att_period_id AND 
			 	      ( ap.att_period_state     = 1.0 OR
                        	         ap.att_period_state     = 2.0 )
			END
			ELSE
			BEGIN
				UPDATE attendant_history 
			 	  SET attendant_quantity2         = attendant_quantity2 - 1 ,
			 	      attendant_volume2           = attendant_volume2 -  @volume ,
				       attendant_value2            = attendant_value2 - @value
				  FROM hose_delivery hd, 
				       attendant_history ah , 
			     	  attendant_period ap
				WHERE  hd.delivery_id          = @id AND
			 	      hd.attendant_id         = ah.attendant_id AND 
				       hd.hose_id              = ah.hose_id AND 
			 	      ap.att_period_id        = ah.att_period_id AND 
			  	     ( ap.att_period_state     = 1.0 OR
                          	       ap.att_period_state     = 2.0 )
			END			

		END

	COMMIT TRANSACTION 

	SELECT @reinstate_result = 1 

END
go


---------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'sp_reinstate_delivery' AND type = 'P')
	DROP PROCEDURE sp_reinstate_delivery
go

print 'Creating sp_reinstate_delivery'
go

/*
** SP_REINSTATE_DELIVERY stored procedure
** search for and update a previously cleared delivery to be a memory (uncleared) delivery
*/
CREATE PROCEDURE sp_reinstate_delivery
	@id                int           OUTPUT,
	@pump_id           int           OUTPUT, 
	@hose_id           int           OUTPUT, 
	@delivery_type     tinyint       OUTPUT,
	@price_level       smallint      OUTPUT, 
	@del_sell_price    decimal(12,4) OUTPUT, 
	@delivery_value    decimal(12,4) OUTPUT, 
	@delivery_volume   decimal(12,4) OUTPUT,
	@reserved_by       int           OUTPUT,
	@Delivery2_volume  decimal(12,4) OUTPUT, 
	@Hose_meter_volume decimal(15,4) OUTPUT, 
	@Hose_meter_value  decimal(15,4) OUTPUT, 
	@Attendant_id      int           OUTPUT,
	@reinstate_result  int           OUTPUT,
	@Previous_Del_Type tinyint       OUTPUT,  -- the type of the delivery before it was reinstated
	@Hose_meter_volume2 decimal(15,4) OUTPUT, 
	@Hose_meter_value2  decimal(15,4) OUTPUT,
	@blend_ratio	   decimal(8,4)	 OUTPUT,
	@auth_Ref	   int           OUTPUT,
	@transaction_ID	   int           OUTPUT,
	@delivery1_value   decimal(12,4) OUTPUT, 
	@delivery1_volume  decimal(12,4) OUTPUT,
	@delivery2_value   decimal(12,4) OUTPUT,
	@Hose_meter_volume1 decimal(15,4) OUTPUT, 
	@Hose_meter_value1  decimal(15,4) OUTPUT,
	@grade1_price	   decimal(12,4) OUTPUT,
	@grade2_price	   decimal(12,4) OUTPUT,
	@payment_type_id int

AS
DECLARE @postMixDel smallint
DECLARE @hoseID int
BEGIN

	-- check to see if the delivery ID can be located , if not bail out
	SELECT @reinstate_result = -1
	IF ( SELECT COUNT(*) FROM hose_delivery WHERE delivery_id = @id ) < 1 
		RETURN  

	SELECT @Previous_Del_Type = delivery_type 
	  FROM hose_delivery 
	 WHERE delivery_id = @id

	-- make sure the delivery in question is currently cleared 
	-- (it is not valid to reinstate a current, stacked or reinstated delivery)
	SELECT @reinstate_result = -2
	IF @Previous_Del_Type in (1,2,3,4,15)
		RETURN 	

	-- ok we have confirmed that this delivery exists and can be reinstated
	BEGIN TRANSACTION

		SET @hoseID = (SELECT hose_id FROM hose_delivery WHERE delivery_id = @id)

		IF (SELECT tank2_id FROM hoses h, hose_delivery hd WHERE delivery_id = @id AND h.hose_id = hd.hose_id) is not NULL
		BEGIN
   			SET @postmixDel = 1
		END
   		ELSE
		BEGIN
			SET @postmixDel = 0
		END
	

		-- set the delivery to type REINSTATED, but leave the rest as-is
		UPDATE hose_delivery 
		   SET Previous_Delivery_Type = delivery_type ,
		       Delivery_Type = 15 
		 WHERE delivery_id = @id       

		-- decrement all the open period totals this delivery was previously associated with

		IF @Previous_Del_Type = 5                -- postpay delivery 

			UPDATE hose_history 
			   SET postpay_quantity   = postpay_quantity - 1 ,
			       postpay_volume     = postpay_volume - delivery_volume ,
			       postpay_value      = postpay_value - delivery_value ,
			       postpay_cost       = postpay_cost - (del_cost_price * delivery_volume)
			  FROM hose_delivery hd, 
			       hose_history hh , 
			       periods p
			 WHERE hd.delivery_id     = @id AND
			       hh.hose_id         = hd.hose_id  AND 
			       hh.period_id       = p.period_id AND 
			       p.period_state     = 1.0 

		ELSE IF @Previous_Del_Type = 6         -- monitor delivery 

			UPDATE hose_history 
			   SET monitor_quantity                 = monitor_quantity - 1 ,
			       monitor_volume                   = monitor_volume - delivery_volume ,
			       monitor_value                    = monitor_value - delivery_value ,
			       monitor_cost                     = monitor_cost - (del_cost_price * delivery_volume)
			  FROM hose_delivery hd, 
			       hose_history hh , 
			       periods p
			 WHERE hd.delivery_id                = @id AND
			       hh.hose_id                    = hd.hose_id  AND 
			       hh.period_id                  = p.period_id AND 
			       p.period_state                = 1.0 

		ELSE IF @Previous_Del_Type = 7       -- preauth delivery 

			UPDATE hose_history 
			   SET preauth_quantity                 = preauth_quantity - 1 ,
			       preauth_volume                   = preauth_volume - delivery_volume ,
			       preauth_value                    = preauth_value - delivery_value ,
			       preauth_cost                     = preauth_cost - (del_cost_price * delivery_volume)
			  FROM hose_delivery hd, 
			       hose_history hh , 
			       periods p
			 WHERE hd.delivery_id                = @id AND
			       hh.hose_id                    = hd.hose_id  AND 
			       hh.period_id                  = p.period_id AND 
			       p.period_state                = 1.0 

		ELSE IF @Previous_Del_Type = 8       -- prepay delivery 

			UPDATE hose_history 
			   SET prepay_quantity                 = prepay_quantity - 1 ,
			       prepay_volume                   = prepay_volume - delivery_volume,
			       prepay_value                    = prepay_value - delivery_value ,
			       prepay_cost                     = prepay_cost - (del_cost_price * delivery_volume)
			  FROM hose_delivery hd, 
			       hose_history hh , 
			       periods p
			 WHERE hd.delivery_id               = @id AND
			       hh.hose_id                   = hd.hose_id  AND 
			       hh.period_id                 = p.period_id AND 
			       p.period_state               = 1.0 

		ELSE IF @Previous_Del_Type = 9     -- prepay refund delivery 

			UPDATE hose_history 
			   SET prepay_refund_qty               = prepay_refund_qty - 1 ,
			       prepay_refund_val               = prepay_refund_val - delivery_value 
			  FROM hose_delivery hd, 
			       hose_history hh , 
			       periods p
			 WHERE hd.delivery_id               = @id AND
			       hh.hose_id                   = hd.hose_id  AND 
			       hh.period_id                 = p.period_id AND 
			       p.period_state               = 1.0 

		ELSE IF @Previous_Del_Type = 10     -- prepay refund lost delivery 

			UPDATE hose_history 
			   SET prepay_rfd_lst_qty              = prepay_rfd_lst_qty - 1 ,
			       prepay_rfd_lst_val              = prepay_rfd_lst_val - delivery_value
			  FROM hose_delivery hd, 
			       hose_history hh , 
			       periods p
			 WHERE hd.delivery_id               = @id AND
			       hh.hose_id                   = hd.hose_id  AND 
			       hh.period_id                 = p.period_id AND 
			       p.period_state               = 1.0 

		ELSE IF @Previous_Del_Type = 11     -- test delivery 
		BEGIN 
			UPDATE hose_history 
			   SET test_del_quantity            = test_del_quantity - 1 ,
			       test_del_volume              = test_del_volume - delivery_volume 
			  FROM hose_delivery hd , 
			       hose_history hh , 
			       periods p
			 WHERE hd.delivery_id            = @id AND
			       hh.hose_id                = hd.hose_id  AND 
			       hh.period_id              = p.period_id AND 
			       p.period_state            = 1.0 

       -- here we assume that the test deliveries are returned to the tank and update 

			IF @postMixDel = 0
			BEGIN
				-- Normal delivery
         			UPDATE tanks 
            				SET theoretical_volume           = theoretical_volume - hd.delivery_volume 
            			FROM hose_delivery hd, tanks t , hoses h 
         			WHERE  hd.delivery_id               = @id AND
                		h.hose_id                    = hd.hose_id  AND 
                		h.tank_id                    = t.tank_id 
			END
			ELSE
			BEGIN
				-- PostMix delivery
				-- Grade 1
         			UPDATE tanks 
            			SET theoretical_volume           = theoretical_volume - hd.delivery1_volume 
            			FROM hose_delivery hd, tanks t , hoses h 
         			WHERE  hd.delivery_id               = @id AND
                		h.hose_id                    = hd.hose_id  AND 
                		h.tank_id                    = t.tank_id 
		
				-- Grade 2
         			UPDATE tanks 
            			SET theoretical_volume           = theoretical_volume - hd.delivery2_volume 
            			FROM hose_delivery hd, tanks t , hoses h 
         			WHERE  hd.delivery_id               = @id AND
                		h.hose_id                    = hd.hose_id  AND 
                		h.tank2_id                    = t.tank_id
			END		
			

			-- reinstate the tank test transfer entry too
			EXEC sp_reinstate_tank_testtransfer @id 
		END 

		ELSE IF @Previous_Del_Type = 12     -- drive off delivery 
		BEGIN
			UPDATE hose_history 
			   SET driveoffs_quantity         = driveoffs_quantity - 1 ,
			       driveoffs_volume           = driveoffs_volume - delivery_volume ,
			       driveoffs_value            = driveoffs_value - delivery_value ,
			       driveoffs_cost             = driveoffs_cost - (del_cost_price * delivery_volume)
			  FROM hose_delivery hd, 
			       hose_history hh , 
			       periods p
			 WHERE hd.delivery_id          = @id AND
			       hh.hose_id              = hd.hose_id  AND 
			       hh.period_id            = p.period_id AND 
			       p.period_state          = 1.0    
		END

		ELSE IF @Previous_Del_Type = 13         -- attendant delivery 
		BEGIN 

			UPDATE hose_history 
			   SET monitor_quantity         = monitor_quantity - 1 ,
			       monitor_volume           = monitor_volume - delivery_volume ,
			       monitor_value            = monitor_value - delivery_value ,
			       monitor_cost             = monitor_cost - (del_cost_price * delivery_volume)
			  FROM hose_delivery hd, 
			       hose_history hh , 
			       periods p
			 WHERE hd.delivery_id        = @id AND
			       hh.hose_id            = hd.hose_id  AND 
			       hh.period_id          = p.period_id AND 
			       p.period_state        = 1.0 

			UPDATE attendant_history 
			   SET attendant_quantity         = attendant_quantity - 1 ,
			       attendant_volume           = attendant_volume - delivery_volume ,
			       attendant_value            = attendant_value - delivery_value
			  FROM hose_delivery hd, 
			       attendant_history ah , 
			       attendant_period ap
			WHERE  hd.delivery_id          = @id AND
			       hd.attendant_id         = ah.attendant_id AND 
			       hd.hose_id              = ah.hose_id AND 
			       ap.att_period_id        = ah.att_period_id AND 
			       ( ap.att_period_state     = 1.0 OR
                                 ap.att_period_state     = 2.0 )


			SELECT @attendant_id = attendant_id,
				@delivery_value    = delivery_value,
		       	@delivery_volume   = delivery_volume
			  FROM hose_delivery WHERE delivery_id = @id

			--  PRINT 'Start rollback attendant '+STR(@attendant_id)+' amount with value ' + STR(@delivery_value) + ' volume:' + STR(@delivery_volume)
			IF @attendant_id IS NULL 
				BEGIN
					PRINT 'Unable to find the attendant ID'
					SELECT @reinstate_result = -3
					ROLLBACK TRANSACTION 
					RETURN
				END
			ELSE
				BEGIN 
		            DECLARE @att_output int = 1
	
					EXEC sp_att_update_amount @att_output OUTPUT, @attendant_id , @delivery_value, @delivery_volume, @payment_type_id, NULL, -1
					 
					IF @att_output < 0
					BEGIN
						PRINT 'Reinstate error updating attendant amount: ' + STR(@att_output)
						SELECT @reinstate_result = -4
						ROLLBACK TRANSACTION
						RETURN
					END
				END 
		END --  @Previous_Del_Type = 13         -- attendant delivery

		ELSE IF @Previous_Del_Type = 14         -- offline delivery 
		BEGIN

			UPDATE hose_history 
			   SET offline_quantity                 = offline_quantity - 1 ,
			       offline_volume                   = offline_volume - delivery_volume ,
			       offline_value                    = offline_value - delivery_value ,
			       offline_cost                     = offline_cost - (del_cost_price * delivery_volume) 
			  FROM hose_delivery hd, hose_history hh , periods p
			 WHERE hd.delivery_id                = @id AND
			       hh.hose_id                    = hd.hose_id  AND 
			       hh.period_id                  = p.period_id AND 
			       p.period_state                = 1.0 

		END

		-- if this is not a test delivery then update the deliveries totals for the tank history records

		IF @Previous_Del_Type <> 11         -- test delivery
		BEGIN

			IF @postmixDel = 0 
			BEGIN
				-- Standard delivery
      				UPDATE tank_history 
			   	SET Hose_Del_Quantity         = Hose_Del_Quantity - 1 ,
			       		Hose_Del_Volume           = Hose_Del_Volume - delivery_volume ,
			       		Hose_Del_Value            = Hose_Del_Value  - delivery_value ,
			       		Hose_Del_Cost             = Hose_Del_Cost   - (del_cost_price * delivery_volume) 
			  	FROM hose_delivery hd, hoses h , tank_history th , periods p
			 	WHERE hd.delivery_id  = @id
			   		AND h.hose_id       = hd.hose_id
			   		AND h.tank_id       = th.tank_id
			   		AND th.period_id    = p.period_id
			   		AND p.period_state  = 1.0 
			END	
			ELSE
			BEGIN
				-- PostMix Delivery	
				-- Base grade 1
				UPDATE tank_history 
         			SET Hose_Del_Quantity     = Hose_Del_Quantity - 1 ,
             				Hose_Del_Volume           = Hose_Del_Volume - delivery1_volume ,
             				Hose_Del_Value            = Hose_Del_Value  - delivery1_value ,
             				Hose_Del_Cost             = Hose_Del_Cost   - grade1_price * delivery1_volume 
         			FROM hose_delivery hd, hoses h , tank_history th , periods p
         			WHERE  hd.delivery_id  = @id AND
                			h.hose_id       = hd.hose_id  AND 
                			h.tank_id      = th.tank_id  AND 
                			th.period_id    = p.period_id AND 
                			p.period_state  = 1.0

				-- Base grade 2
				UPDATE tank_history 
         			SET Hose_Del_Quantity     = Hose_Del_Quantity - 1 ,
             				Hose_Del_Volume           = Hose_Del_Volume - delivery2_volume ,
             				Hose_Del_Value            = Hose_Del_Value  - delivery2_value ,
             				Hose_Del_Cost             = Hose_Del_Cost   - grade2_price * delivery2_volume
         			FROM hose_delivery hd, hoses h , tank_history th , periods p
         			WHERE  hd.delivery_id  = @id AND
                			h.hose_id       = hd.hose_id  AND 
                 			h.tank2_id      = th.tank_id  AND 
                			th.period_id    = p.period_id AND 
                			p.period_state  = 1.0
			END
   		END

   		IF @postmixDel = 1
   		BEGIN
			-- Update postMix history details
			-- Base grade 1
			DECLARE @output int
   			EXEC reinstate_postmix_delivery @output, 1, @id, @Previous_Del_Type
        		IF @output < 0 
			BEGIN	
				ROLLBACK TRANSACTION
	        		RETURN 
			END
			ELSE
			BEGIN
				-- Base grade 2
				EXEC reinstate_postmix_delivery @output, 2, @id, @Previous_Del_Type
				IF @output < 0 
				BEGIN
					ROLLBACK TRANSACTION
	        			RETURN 
				END
			END
		END
 	
			   

		-- ok now get the details of the delivery to return to the Pump Server
		SELECT @pump_id           = pump_id 
		  FROM hose_delivery hd, 
		       hoses h 
		 WHERE hd.hose_id         = h.hose_id 
		   AND hd.delivery_id     = @id
		   PRINT 'Get all data herer'
		SELECT 	@hose_id           = hose_id,
		       	@price_level       = price_level,
		       	@del_sell_price    = del_sell_price,
		       	@delivery_value    = delivery_value,
		       	@delivery_volume   = delivery_volume,
		       	@reserved_by       = reserved_by,
		       	@delivery2_volume  = delivery2_volume,
		       	@hose_meter_volume = hose_meter_volume,
		       	@hose_meter_value  = hose_meter_value,
		       	@attendant_id      = attendant_id,
		       	@Delivery_Type     = delivery_type,	
			@hose_meter_volume2 = hose_meter_volume2,
		       	@hose_meter_value2  = hose_meter_value2,
		 	@blend_ratio	   = blend_ratio,
			@auth_ref	   = auth_ref,
			@transaction_id	   = transaction_id,
			@delivery1_value   = delivery1_value, 
			@delivery1_volume  = delivery1_volume,
			@delivery2_value   = delivery2_value,
			@hose_meter_volume1 = hose_meter_volume1,
		       	@hose_meter_value1  = hose_meter_value1,
			@grade1_price	   = grade1_price,
			@grade2_price	   = grade2_price
		  FROM hose_delivery 
		 WHERE delivery_id = @id

		-- make sure we don't return a null value here...
		IF @attendant_id is null 
			SELECT @attendant_id = -1

		IF @transaction_id is null
			SELECT @transaction_id = -1

		IF @auth_ref is null
			SELECT @auth_ref = -1

			PRINT 'Finished all'
	COMMIT TRANSACTION 

	SELECT @reinstate_result = 1 

END
go


--------------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'DoesFieldExist' AND type = 'P')
   DROP PROCEDURE DoesFieldExist
go

CREATE PROCEDURE DoesFieldExist
	@Tab char(100),
	@Fld char(100)
AS
DECLARE @RetCode int
BEGIN
	SET @RetCode = 0
	IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @Tab)
	BEGIN
		IF (SELECT count(column_name) ReqC FROM INFORMATION_SCHEMA.COLUMNS WHERE column_name = @Fld AND TABLE_NAME = @Tab) > 0
		BEGIN
			print 'Table ' + RTRIM(@Tab) + ' Column ' + RTRIM(@Fld) + ' exists'
			SET @RetCode = 1
		END
	END
	RETURN @RetCode
END
GO


--------------------------------------------------------------------------------

print 'Removing sp_update_tank_gauge_id_of_tanks'
-- TODO: To upgrade old versions to v4 we'll need to write a pre-Enabler.SQL script to
--       save data in old fields to a temporary location, and then re-use them here
go

IF EXISTS (SELECT name FROM SYSOBJECTS WHERE NAME = 'SP_Update_Tank_Gauge_ID_Of_Tanks' AND TYPE = 'P')
BEGIN
	DROP PROCEDURE SP_Update_Tank_Gauge_ID_Of_Tanks
END
GO

--CREATE PROCEDURE SP_Update_Tank_Gauge_ID_Of_Tanks
--AS
--BEGIN
--IF EXISTS( SELECT * FROM Tanks WHERE Tank_Type in (2,3,4) AND Tank_Gauge_ID is NULL)
--BEGIN
--	DECLARE	@Global_Tank_Gauge_Type INT
--	DECLARE	@Global_Tank_Gauge_Pars CHAR(100)
--	DECLARE @Protocol_ID INT
--	DECLARE	@Loop_ID INT
--	DECLARE @Loop_Name CHAR(50)
--	PRINT 'Gauged Tanks Found...'
--
--	SET @Global_Tank_Gauge_Type = (SELECT TOP 1 Tank_Gauge_Type FROM Global_Settings)
--	SET @Global_Tank_Gauge_Pars = (SELECT TOP 1 Tank_Gauge_Pars FROM Global_Settings)
--	-- Tank Type Set?
--	IF @Global_Tank_Gauge_Type IS NOT NULL AND @Global_Tank_Gauge_Type IN (1,2,3,4,5)
--	BEGIN
--		PRINT 'Tank Gauge Type'
--		PRINT @Global_Tank_Gauge_Type
--		SET @Protocol_ID = (SELECT TOP 1 Protocol_ID FROM Tank_Gauge_Type WHERE Tank_Gauge_Type_ID = @Global_Tank_Gauge_Type)
--		PRINT 'Required Protocol is:'
--		PRINT @Protocol_ID
--		SET @Loop_ID = (SELECT TOP 1 Loop_ID FROM Loops WHERE Protocol_ID = @Protocol_ID)
--		-- Existing Tank Loop?
--		IF @Loop_ID IS NULL 
--		BEGIN
--			IF len(@Global_Tank_Gauge_Pars) <> 0
--			BEGIN
--				PRINT 'Creating Extended Loop Entry...'
--				SET @Loop_ID=(SELECT MAX(Loop_ID)+1 FROM Loops)
--				SET @Loop_Name='Port '+STR(@Loop_ID,1)
--				INSERT INTO Loops (Loop_ID,Protocol_ID,Port_Assign,Port_Name,Connection_Type,Settings) VALUES
--					(@Loop_ID,@Protocol_ID,@Loop_ID,@Loop_Name,1,@Global_Tank_Gauge_Pars)
--			END
--			ELSE
--			BEGIN
--				PRINT 'Creating Loop Entry...'				
--				-- IFSF? Enable loop IFSF loop
--				IF @Protocol_ID = 9
--				BEGIN					
--					SET @Loop_ID=5
--				END
--				ELSE
--				-- Find Next Available loop
--				BEGIN
--					SET @Loop_ID=(SELECT TOP 1 Loop_ID FROM Loops WHERE Loop_ID<5 AND Protocol_ID=11)
--				END
--				IF @Loop_ID IS NOT NULL
--				BEGIN
--					UPDATE Loops SET Protocol_ID = @Protocol_ID WHERE Loop_ID=@Loop_ID
--				END
--			END
--		END
--		IF @Loop_ID IS NOT NULL
--		BEGIN
--			PRINT 'Loop Match Found...'
--			DECLARE @Max_Tank_Gauge_ID INT
--			SET @Max_Tank_Gauge_ID =(SELECT TOP 1 Tank_Gauge_ID FROM Tank_Gauge WHERE Loop_ID=@Loop_ID)
--			IF @Max_Tank_Gauge_ID IS NULL
--			BEGIN
--				PRINT 'Creating Tank Gauge...'
--				SET @Max_Tank_Gauge_ID = (SELECT MAX(Tank_Gauge_ID)+1 FROM Tank_Gauge)
--				IF @Max_Tank_Gauge_ID IS NULL 
--					SET @Max_Tank_Gauge_ID =1
--				INSERT INTO Tank_Gauge (Tank_Gauge_ID, Name, Tank_Gauge_Type_ID, Tank_Gauge_Number, Loop_ID, Polling_Address)
--				VALUES (@Max_Tank_Gauge_ID, '', @Global_Tank_Gauge_Type, @Max_Tank_Gauge_ID, @Loop_ID, @Max_Tank_Gauge_ID)
--			END
--			PRINT 'Tank_Gauge_ID:'
--			PRINT @Max_Tank_Gauge_ID
--			PRINT 'Updating Tank_Gauge_ID of Tanks...'
--			UPDATE Tanks SET Tank_Gauge_ID=@Max_Tank_Gauge_ID WHERE Tank_Type in (2,3,4) AND Tank_Gauge_ID is NULL
--		END
--		ELSE
--		BEGIN
--			PRINT 'Cannot Create Loop Entry'
--		END
--	END
--END
--END
--GO


--------------------------------------------------------------------------------
If EXISTS (SELECT NAME FROM sysobjects WHERE NAME = 'Populate_Enabler_Site_Setting' AND TYPE = 'p')
  DROP PROCEDURE Populate_Enabler_Site_Setting
GO
print 'Creating Populate_Enabler_Site_Setting'
go

-- =============================================================
-- Procedure Populate_Enabler_Site_Setting
-- Inserts or Updates records based on the action_type parameter 

-- NOTE: The Mandatory parameters are: @action_type
-- =============================================================
CREATE PROCEDURE Populate_Enabler_Site_Setting
	@action_type         char, 
	@site_name           nchar(30) = NULL,
	@site_profile_id     int = NULL, 
	@pump_stack_size     int = NULL,   -- deprecated
	@prepay_reserved_to  int = NULL, 
	@prepay_refund_to    int = NULL, 
	@prepay_taken_to     int = NULL, 
	@preauth_rsvd_to     int = NULL, 
	@authorized_timeout  nchar(10)= NULL, 
	@monitor_del_to      nchar(10) = NULL, 
	@pvt_on              nchar(40) = NULL, 
	@delivery_idle_to    char(255) = NULL, 
	@tank_gauge_type     int = NULL,  -- deprecated
	@tank_gauge_pars     int = NULL,  -- deprecated
	@event_keep_days     int = NULL, 
	@hose_del_keep_days  int = NULL, 
	@tank_del_keep_days  int = NULL,   
	@max_dels_in_prog    int = NULL,  -- deprecated
	@attendant_support   int = NULL,
	@att_keep_days       int = NULL, 
	@delivery_age_to     int = NULL, 
	@tank_dips           int = NULL, 
	@tank_drops          int = NULL, 
	@pump_meters         int = NULL,  
	@delivering_nr_to    int = NULL, 
	@prepay_refund_type  int = NULL, 
	@auto_modes_on       int = NULL, 
	@recon_edits_allowed int = NULL, 
	@recon_report_format int = NULL, 
	@recon_export_type   int = NULL, 
	@recon_export_mandatory int = NULL, 
	@clear_att_dels      int = NULL, 
	@price_level_control int = NULL,

	-- these are not yet implemented
	@Minimum_Etotal_Diff  decimal(5,3) = NULL,
	@Map_Test_Delivery_To_Tank_Transfer  smallint = NULL,
	@Use_Hose_Turn_Over  smallint = NULL,
	@Approval_Required_for_FuelRecon smallint = NULL,
	@Can_Disable_Hoses_By_Grade   bit = NULL,
	@Disable_Hose_During_Delivery bit = NULL,
	@Backup_Files        smallint = NULL,
	@Backup_Time         datetime = NULL,
	@Can_Disable_Hoses_By_Tank       bit = NULL,
	@Disable_Tank_On_Level_Low_Alarm bit = NULL,
	@Disable_Tank_On_Tanker_Delivery bit = NULL,
	@Auto_PostMix_Price  bit = NULL,
	@Tagging_Support     smallint = NULL,
	@Price_Calc_Decimals smallint = NULL,
	@Price_Calc_Round_Type smallint = NULL,
	@Fallback_State      smallint = NULL,
	@reserve_to          smallint = NULL
	
AS

DECLARE @record_inserted int
DECLARE @site_id int

BEGIN
	-- Standard logging
	PRINT 'Procedure: Populate_Enabler_Site_Setting, key field: site_id, action type: ' + @action_type   

	-- Validate all parameters
	IF @action_type NOT IN ('I','U','P') 
		BEGIN
			PRINT 'Error in parameter @action_type, ' + @action_type + ' is not a valid option'
			RETURN
		END 

	SET @site_id = (SELECT site_id FROM global_settings WHERE site_id = 1)

	IF @site_id IS NULL
		IF (@action_type = 'U')
  			BEGIN
				PRINT 'Row 1 in global_settings does not exist'
				RETURN
  			END
	ELSE  
  		SET @site_id = 1
	  
	-- Validation
	
	IF @site_profile_id IS NOT NULL
		BEGIN
			IF (SELECT COUNT(*) FROM Site_Profile WHERE Site_Profile_ID = @site_profile_id) = 0
			BEGIN
				PRINT 'Error - an invalid @Site_Profile_ID was supplied'
				RETURN
			END
		END

	IF @pvt_on IS NOT NULL
		BEGIN
			IF NOT (@pvt_on = 0 OR @pvt_on = 1)
				BEGIN
					PRINT 'Error in parameter @pvt_on - must be 0 (FALSE) or 1 (TRUE)'
					RETURN
				END
		END

	IF @attendant_support IS NOT NULL
		BEGIN
			IF NOT (@attendant_support = 0 OR @attendant_support = 1)
				BEGIN
					PRINT 'Error in parameter @attendant_support - must be 0 (FALSE) or 1 (TRUE)'
					RETURN
				END
		END

	IF @tank_dips IS NOT NULL
		BEGIN
			IF NOT (@tank_dips = 0 OR @tank_dips = 1)
				BEGIN
					PRINT 'Error in parameter @tank_dips - must be 0 (FALSE) or 1 (TRUE)'
					RETURN
				END
		END

	IF @tank_drops IS NOT NULL
		BEGIN
			IF NOT (@tank_drops = 0 OR @tank_drops = 1)
				BEGIN
					PRINT 'Error in parameter @tank_drops - must be 0 (FALSE) or 1 (TRUE)'
					RETURN
				END
		END

	IF @pump_meters IS NOT NULL
		BEGIN
			IF NOT (@pump_meters = 0 OR @pump_meters = 1)
				BEGIN
					PRINT 'Error in parameter @pump_meters - must be 0 (FALSE) or 1 (TRUE)'
					RETURN
				END
		END

	IF @auto_modes_on IS NOT NULL
		BEGIN
			IF NOT (@auto_modes_on = 0 OR @auto_modes_on = 1)
				BEGIN
					PRINT 'Error in parameter @auto_modes_on - must be 0 (FALSE) or 1 (TRUE)'
					RETURN
				END
		END

	IF @recon_edits_allowed IS NOT NULL
		BEGIN
			IF NOT (@recon_edits_allowed = 0 OR @recon_edits_allowed = 1)
				BEGIN
					PRINT 'Error in parameter @recon_edits_allowed - must be 0 (FALSE) or 1 (TRUE)'
					RETURN
				END
		END

	IF @recon_export_mandatory IS NOT NULL
		BEGIN
			IF NOT (@recon_export_mandatory = 0 OR @recon_export_mandatory = 1)
				BEGIN
					PRINT 'Error in parameter @recon_export_mandatory - must be 0 (FALSE) or 1 (TRUE)'
					RETURN
				END
		END

	IF @clear_att_dels IS NOT NULL
		BEGIN
			IF NOT (@clear_att_dels = 0 OR @clear_att_dels = 1)
				BEGIN
					PRINT 'Error in parameter @clear_att_dels - must be 0 (FALSE) or 1 (TRUE)'
					RETURN
				END
		END

	IF @price_level_control IS NOT NULL
		BEGIN
			IF NOT (@price_level_control = 0 OR @price_level_control = 1)
				BEGIN
					PRINT 'Error in parameter @price_level_control - must be 0 (FALSE) or 1 (TRUE)'
					RETURN
				END
		END

	-- All parameters have now been validated
	
	BEGIN TRANSACTION
	-- Insert only: action_type = 'I'
	-- Update only: action_type = 'U'
	-- Populate   : action_type = 'P'
	
	SET @Record_Inserted = 0
	
	-- Determine if record already exists	
	IF (( SELECT COUNT(site_id)
		FROM global_settings
	        WHERE site_id = 1 )= 0 )
	BEGIN
		PRINT 'Record does not exist'
	               
		IF( @action_type = 'U' )
		BEGIN
			ROLLBACK TRANSACTION
			RETURN -- Update only nothing else to do since record does not exist
		END
	               	-- Insert record
		PRINT 'Inserting record'
		INSERT INTO global_settings( site_id, site_profile_id 	) 
		VALUES ( @site_id, 1 )
	               
        SET @record_inserted = 1 
	               
        PRINT 'Record inserted'
	END
	ELSE
		PRINT 'Record already exists'	

	-- If action_type is insert only then we only update the 
	-- record if a record has been inserted
	IF( @action_type = 'I' AND @record_inserted = 0)
		BEGIN
		        ROLLBACK TRANSACTION
		        RETURN
		END
	-- Update record
	PRINT 'Updating record'
	
	-- Update optional fields, but only if their respective parameters
	-- were passed in e.g. they are not null

	IF @site_name IS NOT NULL
	BEGIN
		PRINT 'updating @site_name'
		UPDATE global_settings SET site_name = @site_name WHERE site_id = @site_id 
	END

	IF @site_profile_id IS NOT NULL 
		BEGIN
			PRINT 'updating @site_profile_id'
	        UPDATE global_settings SET site_profile_id = @site_profile_id WHERE site_id = @site_id
		END

--	IF @pump_stack_size IS NOT NULL 
--		BEGIN
--			PRINT 'updating @pump_stack_size'
--	        UPDATE global_settings SET pump_stack_size = @pump_stack_size WHERE site_id = @site_id
--		END

	IF @prepay_reserved_to IS NOT NULL 
		BEGIN
			PRINT 'updating @prepay_reserved_to'
	        UPDATE global_settings SET prepay_reserved_to = @prepay_reserved_to WHERE site_id = @site_id
		END

	IF @prepay_refund_to IS NOT NULL 
		BEGIN
			PRINT 'updating @prepay_refund_to'
	        UPDATE global_settings SET prepay_refund_to = @prepay_refund_to WHERE site_id = @site_id
		END

	IF @prepay_taken_to IS NOT NULL 
		BEGIN
			PRINT 'updating @prepay_taken_to'
	        UPDATE global_settings SET prepay_taken_to = @prepay_taken_to WHERE site_id = @site_id
		END

	IF @prepay_reserved_to IS NOT NULL 
		BEGIN
			PRINT 'updating @prepay_reserved_to'
	        UPDATE global_settings SET prepay_reserved_to = @prepay_reserved_to WHERE site_id = @site_id
		END

	IF @authorized_timeout IS NOT NULL 
		BEGIN
			PRINT 'updating @authorized_timeout'
	        UPDATE global_settings SET authorized_timeout = @authorized_timeout WHERE site_id = @site_id
		END

	IF @monitor_del_to IS NOT NULL 
		BEGIN
			PRINT 'updating @monitor_del_to'
	        UPDATE global_settings SET monitor_del_to = @monitor_del_to WHERE site_id = @site_id
		END

	IF @pvt_on IS NOT NULL 
		BEGIN
			PRINT 'updating @pvt_on'
	        UPDATE global_settings SET pvt_on = @pvt_on WHERE site_id = @site_id
		END

	IF @delivery_idle_to IS NOT NULL 
		BEGIN
			PRINT 'updating @delivery_idle_to'
	        UPDATE global_settings SET delivery_idle_to = @delivery_idle_to WHERE site_id = @site_id
		END

--	IF @tank_gauge_type IS NOT NULL 
--		BEGIN
--			PRINT 'updating @tank_gauge_type'
--			UPDATE global_settings SET tank_gauge_type = @tank_gauge_type WHERE site_id = @site_id
--		END	
--
--	IF @tank_gauge_pars IS NOT NULL 
--		BEGIN
--			PRINT 'updating @tank_gauge_pars'
--	        UPDATE global_settings SET tank_gauge_pars = @tank_gauge_pars WHERE site_id = @site_id
--		END	

	IF @event_keep_days IS NOT NULL 
		BEGIN
			PRINT 'updating @event_keep_days'
	        UPDATE global_settings SET event_keep_days = @event_keep_days WHERE site_id = @site_id
		END	

	IF @hose_del_keep_days IS NOT NULL 
		BEGIN
			PRINT 'updating @hose_del_keep_days'
	        UPDATE global_settings SET hose_del_keep_days = @hose_del_keep_days WHERE site_id = @site_id
		END	

	IF @tank_del_keep_days IS NOT NULL 
		BEGIN
			PRINT 'updating @tank_del_keep_days'
	        UPDATE global_settings SET tank_del_keep_days = @tank_del_keep_days WHERE site_id = @site_id
		END	

--	IF @max_dels_in_prog IS NOT NULL 
--		BEGIN
--			PRINT 'updating @max_dels_in_prog'
--	        UPDATE global_settings SET max_dels_in_prog = @max_dels_in_prog WHERE site_id = @site_id
--	END	

	IF @attendant_support IS NOT NULL 
		BEGIN
			PRINT 'updating @attendant_support'
	        UPDATE global_settings SET attendant_support = @attendant_support WHERE site_id = @site_id
		END	

	IF @att_keep_days IS NOT NULL 
		BEGIN
			PRINT 'updating @att_keep_days'
	        UPDATE global_settings SET att_keep_days = @att_keep_days WHERE site_id = @site_id
		END	

	IF @delivery_age_to IS NOT NULL 
		BEGIN
			PRINT 'updating @delivery_age_to'
	        UPDATE global_settings SET delivery_age_to = @delivery_age_to WHERE site_id = @site_id
		END	

	IF @preauth_rsvd_to IS NOT NULL 
           -- this variable is used here to update Preauth Authorised Timeout
		BEGIN
			PRINT 'updating @preauth_rsvd_to'
	        UPDATE global_settings SET preauth_rsvd_to = @preauth_rsvd_to WHERE site_id = @site_id
		END	

	IF @tank_dips IS NOT NULL 
		BEGIN
			PRINT 'updating @tank_dips'
	        UPDATE global_settings SET tank_dips = @tank_dips WHERE site_id = @site_id
		END

	IF @tank_drops IS NOT NULL 
		BEGIN
			PRINT 'updating @tank_drops'
	        UPDATE global_settings SET tank_drops = @tank_drops WHERE site_id = @site_id
		END

	IF @pump_meters IS NOT NULL 
		BEGIN
			PRINT 'updating @pump_meters'
	        UPDATE global_settings SET pump_meters = @pump_meters WHERE site_id = @site_id
		END

	IF @delivering_nr_to IS NOT NULL 
		BEGIN
			PRINT 'updating @delivering_nr_to'
	        UPDATE global_settings SET delivering_nr_to = @delivering_nr_to WHERE site_id = @site_id
		END

	IF @prepay_refund_type IS NOT NULL 
		BEGIN
			PRINT 'updating @prepay_refund_type'
	        UPDATE global_settings SET prepay_refund_type = @prepay_refund_type WHERE site_id = @site_id
		END

	IF @auto_modes_on IS NOT NULL 
		BEGIN
			PRINT 'updating @auto_modes_on'
	        UPDATE global_settings SET auto_modes_on = @auto_modes_on WHERE site_id = @site_id
		END

	IF @recon_edits_allowed IS NOT NULL 
		BEGIN
			PRINT 'updating @recon_edits_allowed'
	        UPDATE global_settings SET recon_edits_allowed = @recon_edits_allowed WHERE site_id = @site_id
		END

	IF @recon_report_format IS NOT NULL 
		BEGIN
			PRINT 'updating @recon_report_format'
	        UPDATE global_settings SET recon_report_format = @recon_report_format WHERE site_id = @site_id
		END

	IF @recon_export_type IS NOT NULL 
		BEGIN
			PRINT 'updating @recon_export_type'
	        UPDATE global_settings SET recon_export_type = @recon_export_type WHERE site_id = @site_id
		END

	IF @recon_export_mandatory IS NOT NULL 
		BEGIN
			PRINT 'updating @recon_export_mandatory'
	        UPDATE global_settings SET recon_export_mandatory = @recon_export_mandatory WHERE site_id = @site_id
		END

	IF @clear_att_dels IS NOT NULL 
		BEGIN
			PRINT 'updating @clear_att_dels'
	        UPDATE global_settings SET clear_att_dels = @clear_att_dels WHERE site_id = @site_id
		END

	IF @price_level_control IS NOT NULL 
		BEGIN
			PRINT 'updating @price_level_control'
	        UPDATE global_settings SET price_level_control = @price_level_control WHERE site_id = @site_id
		END  
 	  
	PRINT 'Record updated'
	
	COMMIT TRANSACTION
END
GO



--------------------------------------------------------------------------------

IF EXISTS (SELECT NAME FROM sysobjects WHERE NAME = 'Populate_Grade' AND TYPE = 'p')
  DROP PROCEDURE Populate_Grade
GO

-- Procedure Populate_Grade
-- Inserts or Updates records based on the action_type parameter 

-- NOTE: The mandatory parameters are: @action_type, @grade_name

CREATE PROCEDURE Populate_Grade
	@action_type 		char, 
	@grade_name 		nchar(10) = NULL,
	@price_profile_id 	int = NULL,
	@grade_description 	nvarchar(80) = NULL,
	@allocation_limit	decimal(11,4) = NULL,
	@alloc_limit_type 	int = NULL,
	@oil_company_code 	char(19) = NULL,
	@tax_link 		int = NULL, 
	@group_link 		int = NULL, 
	@delivery_timeout 	int = NULL, 
	@price_pole_segment 	int = NULL, 
	@grade_type 		int = NULL, 
	@grade1_id 		int = NULL, 
	@grade2_id 		int = NULL,
	@blend_ratio 		decimal(8,4) = NULL, 
	@grade_number		int = NULL, 
	@min_price 		decimal(12,4) = NULL, 
	@max_price 		decimal(12,4) = NULL, 
	@loss_tolerance  	decimal(6,4) = NULL, 
	@gain_tolerance  	decimal(6,4) = NULL,
	@dont_create_profile    smallint = NULL,
	@use_grade_number	smallint=NULL
AS

DECLARE @record_inserted int
DECLARE @grade_id int
DECLARE @grade_id_exist smallint

BEGIN
	-- Standard logging
	PRINT 'Procedure: Populate_Grade, key field: grade_id, action type: ' + @action_type   

	-- Validate all parameters
	IF @action_type NOT IN ('I','U','P') 
		BEGIN
			PRINT 'Error in parameter @action_type, ' + @action_type + ' is not a valid option'
			RETURN
		END 

	IF @grade_name IS NULL
		BEGIN
			PRINT 'Error in parameter @grade_name is mandatory'
			RETURN
		END

	IF @price_profile_id IS NULL
		BEGIN
			PRINT 'Error in parameter @price_profile_id is mandatory'
			RETURN
		END

	IF (@use_grade_number is not null) 
	BEGIN
		SET @grade_id_exist = (SELECT TOP 1 grade_id FROM grades WHERE grade_number = @grade_number)
		SET @grade_id = @grade_id_exist
	END
	ELSE
	BEGIN
		SET @grade_id_exist = (SELECT TOP 1 grade_id FROM grades WHERE grade_name = @grade_name)
		SET @grade_id = @grade_id_exist
	END

	IF @grade_id_exist IS NULL
		IF (@action_type = 'U')
  			BEGIN
				PRINT 'Error in parameter @grade_name, ' + @grade_name + 'does not exist'
				RETURN
  			END
	ELSE  
  		SET @grade_id = (SELECT MAX(grade_id) + 1 FROM grades)
	    IF @grade_id is null
          BEGIN
             SET @grade_id = 1
          END

	-- All parameters have now been validated
	
	BEGIN TRANSACTION

        
        IF (@dont_create_profile is null)
        BEGIN
	-------------------------------------------------
	-- Create a new Price Profiles for this new grade
	-------------------------------------------------
	
	IF (SELECT count(price_profile_id) FROM price_profile WHERE Price_Profile_Name = @oil_company_code) = 0
	BEGIN
		SET @price_profile_id = (SELECT MAX(Price_Profile_ID) + 1 FROM Price_Profile)
	
		print 'creating new price_profile ' + @oil_company_code

		INSERT INTO Price_Profile (Price_Profile_ID, Price_Profile_Name, Scheduled_ST, Parent_Grade_ID)
		VALUES (@price_profile_id, @oil_company_code, GETDATE(), @price_profile_id)
		
	END
	-----------------------------------------------
        END
	

	-- Insert only: action_type = 'I'
	-- Update only: action_type = 'U'
	-- Populate   : action_type = 'P'
	
	SET @Record_Inserted = 0
	
	-- Determine if record already exists	
	IF (@grade_id_exist is null)		
	BEGIN
		PRINT 'Record does not exist'
	               
	        IF( @action_type = 'U' )
		BEGIN
			ROLLBACK TRANSACTION
	                RETURN -- Update only nothing else to do since record does not exist
		END
	               	-- Insert record
	        PRINT 'Inserting record'
	        INSERT INTO grades
			(
			grade_id,
			price_profile_id
			
			) 
		VALUES ( 
			@grade_id,
			@price_profile_id
			)
	               
	        SET @record_inserted = 1 
	               
	        PRINT 'Record inserted'
	END
	ELSE
		PRINT 'Record already exists'	

	-- If action_type is insert only then we only update the 
	-- record if a record has been inserted
	IF( @action_type = 'I' AND @record_inserted = 0)
		BEGIN
		        ROLLBACK TRANSACTION
		        RETURN
		END
	-- Update record
	PRINT 'Updating record'
	
	-- Always update Mandatory fields 
	UPDATE grades SET
	        grade_name = @grade_name
	WHERE grade_id = @grade_id
	
	-- Update optional fields, but only if their respective parameters
	-- were passed in e.g. they are not null 

	IF @grade_description IS NOT NULL 
		BEGIN
			PRINT 'updating @grade_description'
		        UPDATE grades SET grade_description = @grade_description WHERE grade_id = @grade_id
		END	

	IF @allocation_limit IS NOT NULL 
		BEGIN
			PRINT 'updating @allocation_limit'
		        UPDATE grades SET allocation_limit = @allocation_limit WHERE grade_id = @grade_id
		END

	IF @alloc_limit_type IS NOT NULL 
		BEGIN
			PRINT 'updating @alloc_limit_type'
		        UPDATE grades SET alloc_limit_type = @alloc_limit_type WHERE grade_id = @grade_id
		END  

	IF @oil_company_code IS NOT NULL 
		BEGIN
			PRINT 'updating @oil_company_code'
		        UPDATE grades SET oil_company_code= @oil_company_code WHERE grade_id = @grade_id
		END  
	
	IF @tax_link IS NOT NULL 
		BEGIN
			PRINT 'updating @tax_link'
		        UPDATE grades SET tax_link = @tax_link WHERE grade_id = @grade_id
		END
	
	IF @group_link IS NOT NULL 
		BEGIN
			PRINT 'updating @group_link'
		        UPDATE grades SET group_link = @group_link WHERE grade_id = @grade_id
		END	

	IF @delivery_timeout IS NOT NULL 
		BEGIN
			PRINT 'updating @delivery_timeout' 
		        UPDATE grades SET delivery_timeout = @delivery_timeout WHERE grade_id = @grade_id
		END

	IF @price_pole_segment IS NOT NULL 
		BEGIN
			PRINT 'updating @price_pole_segment' 
		        UPDATE grades SET price_pole_segment = @price_pole_segment WHERE grade_id = @grade_id
		END

	IF @grade_type IS NOT NULL 
		BEGIN
			PRINT 'updating @grade_type' 
		        UPDATE grades SET grade_type = @grade_type WHERE grade_id = @grade_id
		END

	IF @grade1_id IS NOT NULL 
		BEGIN
			PRINT 'updating @grade1_id' 
		        UPDATE grades SET grade1_id = @grade1_id WHERE grade_id = @grade_id
		END	

	IF @grade2_id IS NOT NULL 
		BEGIN
			PRINT 'updating @grade2_id' 
		        UPDATE grades SET grade2_id = @grade2_id WHERE grade_id = @grade_id
		END

	IF @blend_ratio IS NOT NULL 
		BEGIN
			PRINT 'updating @blend_ratio' 
		        UPDATE grades SET blend_ratio = @blend_ratio WHERE grade_id = @grade_id
		END

	IF @grade_number IS NOT NULL 
		BEGIN
			PRINT 'updating @grade_number' 
		        UPDATE grades SET grade_number = @grade_number WHERE grade_id = @grade_id
		END	

	IF @min_price IS NOT NULL 
		BEGIN
			PRINT 'updating @min_price' 
		        UPDATE grades SET min_price = @min_price WHERE grade_id = @grade_id
		END

	IF @max_price IS NOT NULL 
		BEGIN
			PRINT 'updating @max_price' 
		        UPDATE grades SET max_price = @max_price WHERE grade_id = @grade_id
		END

	IF @loss_tolerance IS NOT NULL 
		BEGIN
			PRINT 'updating @loss_tolerance' 
		        UPDATE grades SET loss_tolerance = @loss_tolerance WHERE grade_id = @grade_id
		END

	IF @gain_tolerance IS NOT NULL 
		BEGIN
			PRINT 'updating @gain_tolerance' 
		        UPDATE grades SET gain_tolerance = @gain_tolerance WHERE grade_id = @grade_id
		END 	

	PRINT 'Record updated'
	
	COMMIT TRANSACTION
END
GO



--------------------------------------------------------------------------------

IF EXISTS (SELECT NAME FROM sysobjects WHERE NAME = 'Populate_Tank' AND TYPE = 'p')
  DROP PROCEDURE Populate_Tank
GO


-- =============================================================
-- Procedure Populate_Tank
--   Inserts or updates records based on the 
--   action_type parameter
-- =============================================================
CREATE PROCEDURE Populate_Tank
        @action_type char(1),
        @tank_number int,
        @grade_id int,
        @tank_name nvarchar(30),
        @capacity int,
        @physical_label char(30) = NULL,
        @tank_desc nvarchar(80) = NULL,
        @low_vol_alarm int = NULL,
        @low_vol_warn int = NULL,
        @high_vol_alarm int = NULL,
        @high_vol_warn int = NULL,
        @high_water_alarm int = NULL,
        @high_temperature int = NULL,
        @low_temperature int = NULL,
        @loss_tolerance_vol int = NULL,
        @gain_tolerance_vol int = NULL

AS

DECLARE @record_inserted int
DECLARE @new_id int
 
BEGIN

  -- Standard logging
  PRINT 'Procedure: Populate_Tank, key field: Tank_Number ' + LTRIM(Str(@tank_Number)) + ', action type: ' + @action_type   

  -- Validate parameters
  IF ( (SELECT COUNT(Grade_ID) FROM Grades WHERE Grade_ID = @grade_ID) = 0 )
  BEGIN
	print ' Error - Invalid Grade_Id for Tank Number ' + Str(@tank_Number)
	RETURN
  END

  IF (@capacity = 0 )
  BEGIN
    print ' Error - Capactiy must be greater than zero'
    RETURN
  END

  IF @low_vol_alarm IS NOT NULL AND @low_vol_warn IS NOT NULL
  BEGIN
     IF  @low_vol_warn < @low_vol_alarm 
     BEGIN
	    print ' Error - Low Volume Alarm must be lower than Low Volume Warning'
        RETURN
     END
  END

  IF @high_vol_alarm IS NOT NULL AND @high_vol_alarm > @capacity
  BEGIN
     print ' Error - High Volume Alarm must be lower than the tank Capacity'
     RETURN
  END

  IF @high_vol_alarm IS NOT NULL AND @high_vol_warn IS NOT NULL
  BEGIN
     IF  @high_vol_warn > @high_vol_alarm 
     BEGIN
	    print ' Error - High Volume Warning must be lower than High Volume Alarm'
        RETURN
     END
  END

  IF @high_temperature IS NOT NULL AND @low_temperature IS NOT NULL
  BEGIN
     IF @low_temperature >= @high_temperature 
     BEGIN
        print ' Error - Low Tempurature must be lower than High Temperature'
        RETURN
     END
  END


  -- All parameters validated

  BEGIN TRANSACTION
       -- Insert only: action_type = 'I'
       -- Update only: action_type = 'U'
       -- Populate (: action_type = 'P'

       SET @Record_Inserted = 0

       -- Determine if record already exists	
       IF (( SELECT COUNT(tank_number) 
           FROM tanks
           WHERE tank_number = @tank_number) = 0 )
       BEGIN
               PRINT 'Record does not exist'
               
               IF( @action_type = 'U' )
		       BEGIN
                   ROLLBACK TRANSACTION
                   RETURN -- Update only nothing else to do since record does not exist
               END

               -- Insert record
               PRINT 'Inserting record'
               
	       -- Automatically generate a new id field
		SELECT @new_id = (SELECT max(tank_id) +1 FROM tanks)
        IF (@new_id is null)
         BEGIN
            SET @new_id = 1
         END   
		-- Insert record
		insert INTO tanks (tank_id, grade_id, tank_name, tank_number, capacity ) 
			values (@new_id, @grade_id, @tank_name, @tank_number, @capacity )
		print ' Tank inserted'

               SET @record_inserted = 1
               
               PRINT 'Record inserted'
       END

       -- If action_type is insert only then we only update the 
       -- record if a record has been inserted
       IF( @action_type = 'I' AND @record_inserted = 0)
	   BEGIN
		  print 'Record update not required'
		  ROLLBACK TRANSACTION
          RETURN
	   END

       -- Update record
       PRINT 'Updating record'

       -- Always update mandatory fields 
       UPDATE tanks SET
              grade_id = @grade_id,
              tank_name = @tank_name,
	      capacity = @capacity
       WHERE  tank_number = @tank_number
              
       -- Update optional fields only if the passed in parameter
       -- if not null 
       IF @physical_label IS NOT NULL
              UPDATE Tanks SET
                     physical_label = @physical_label
              WHERE tank_number = @tank_number

	   IF @tank_desc IS NOT NULL
			  UPDATE Tanks SET
                     tank_description = @tank_desc
              WHERE tank_number = @tank_number

	   IF @low_vol_alarm IS NOT NULL
			  UPDATE Tanks SET
                     low_volume_alarm = @low_vol_alarm
              WHERE tank_number = @tank_number

	   IF @low_vol_warn IS NOT NULL
			  UPDATE Tanks SET
                     low_volume_warning = @low_vol_warn
              WHERE tank_number = @tank_number

	   IF @high_vol_alarm IS NOT NULL
			  UPDATE Tanks SET
                     hi_volume_alarm = @high_vol_alarm
              WHERE tank_number = @tank_number

	   IF @high_vol_warn IS NOT NULL
			  UPDATE Tanks SET
                     hi_volume_warning = @high_vol_warn
              WHERE tank_number = @tank_number

	   IF @high_water_alarm IS NOT NULL
			  UPDATE Tanks SET
                     hi_water_alarm = @high_water_alarm
              WHERE tank_number = @tank_number

	   IF @high_temperature IS NOT NULL
			  UPDATE Tanks SET
                     hi_temperature = @high_temperature
              WHERE tank_number = @tank_number

	   IF @low_temperature IS NOT NULL
			  UPDATE Tanks SET
                     low_temperature = @low_temperature
              WHERE tank_number = @tank_number

	   IF @loss_tolerance_vol IS NOT NULL
			  UPDATE Tanks SET
                     loss_tolerance_vol = @loss_tolerance_vol
              WHERE tank_number = @tank_number

	   IF @gain_tolerance_vol IS NOT NULL
			  UPDATE Tanks SET
                     gain_tolerance_vol = @gain_tolerance_vol
              WHERE tank_number = @tank_number

       PRINT 'Record updated'

       COMMIT TRANSACTION
END
go



--------------------------------------------------------------------------------
IF EXISTS (SELECT NAME FROM sysobjects WHERE NAME = 'Populate_Hose' AND TYPE = 'p')
  DROP PROCEDURE Populate_Hose
GO


-- Procedure Populate_Hose
-- Inserts or updates records based on the 
-- action_type parameter 
CREATE  PROCEDURE Populate_Hose
		@action_type char,
		@logical_number smallint,
		@hose_number smallint,
		@grade_name char(30),
		@tank_name char(30)

	
	
AS

DECLARE @grade_id smallint
DECLARE @tank_id smallint
DECLARE @record_inserted int
DECLARE @hose_id smallint
DECLARE @pump_id smallint

BEGIN

  -- Standard logging
 PRINT 'Procedure: Populate_Hose, key field: Logical_Number action type:' + @action_type   
 
  BEGIN TRANSACTION
       -- Insert only: action_type = 'I'
       -- Update only: action_type = 'U'
       -- Populate (: action_type = 'P'
	SET @record_inserted=0

 SET @pump_id = (SELECT TOP 1 pump_id FROM pumps WHERE logical_number = @logical_number)
 SET @grade_id = (SELECT TOP 1 grade_id FROM grades WHERE grade_name=@grade_name)
 SET @tank_id = (SELECT TOP 1 tank_id FROM tanks WHERE tank_name = @tank_name)

	
 IF (@pump_id is null)
 BEGIN
	PRINT 'Pump logical number does not exist in Pumps table'
	ROLLBACK TRANSACTION
	RETURN
 END
	
 IF (@grade_id is null)
 BEGIN
	PRINT 'Invalid grade name'
	ROLLBACK TRANSACTION
	RETURN
 END

 IF (@tank_id is null)
 BEGIN
	PRINT 'Invalid tank name'
	ROLLBACK TRANSACTION
	RETURN
 END
       -- Determine if record already exists	
 SET @hose_id = (SELECT  TOP 1 hose_id FROM hoses WHERE pump_id=@pump_id AND hose_number= @hose_number)

       IF ( @hose_id is null )
       BEGIN
               PRINT 'Record does not exist'
               
               IF( @action_type = 'U' )
		BEGIN
		   ROLLBACK TRANSACTION
                   RETURN -- Update only nothing else to do since record does not exist
		END
	       SET @hose_id = (SELECT MAX(hose_id) + 1 FROM hoses)
           IF (@hose_id is null )
            BEGIN
                SET @hose_id = 1
            END
               -- Insert record
               PRINT 'Inserting record'
		-- insert mandatory fields
               INSERT INTO hoses
                      (hose_id,pump_id,hose_number,grade_id,tank_id)
               VALUES (@hose_id,@pump_id,@hose_number,@grade_id,@tank_id)

	       SET @record_inserted=1
               
               PRINT 'Record inserted'
      	       
       END
       IF (@action_type = 'I' AND @record_inserted = 0 )
	BEGIN
		ROLLBACK TRANSACTION
		RETURN
	END
	IF (@record_inserted=0)
	BEGIN
		-- Always update mandatory fields 
		PRINT 'Updating mandatory fields'
		UPDATE hoses SET
		    grade_id = @grade_id,  
		    tank_id =  @tank_id  
		WHERE hose_id = @hose_id
	END
		     	  
       COMMIT TRANSACTION
END
GO


IF EXISTS (SELECT NAME FROM sysobjects WHERE NAME = 'Populate_Pump' AND TYPE = 'p')
  DROP PROCEDURE Populate_Pump
GO


-- Procedure Populate_Pumps
-- Inserts or updates records based on the 
-- action_type parameter 
CREATE  PROCEDURE Populate_Pump
		@action_type char,
		@logical_number smallint,
		@pump_name nvarchar(80)=null,
		@polling_address smallint=null,
		@pump_type_id smallint,
		@pump_loop_id smallint=null
		
		
	
AS

DECLARE @pump_id int
DECLARE @record_inserted int

 
BEGIN

  -- Standard logging
 PRINT 'Procedure: Populate_Pump, key field: Logical_Number action type:' + @action_type   
 
  BEGIN TRANSACTION
       -- Insert only: action_type = 'I'
       -- Update only: action_type = 'U'
       -- Populate (: action_type = 'P'
	SET @record_inserted=0

       SET @pump_id = (SELECT pump_id FROM pumps WHERE logical_number=@logical_number)

       -- Determine if record already exists	
       IF ( @pump_id is null )
       BEGIN
               PRINT 'Record does not exist'
               
               IF( @action_type = 'U' )
		BEGIN
		   ROLLBACK TRANSACTION
                   RETURN -- Update only nothing else to do since record does not exist
		END
	       SET @pump_id = (SELECT MAX(pump_id) + 1 FROM pumps)
               -- Insert record
               PRINT 'Inserting record'
		-- insert mandatory fields
               INSERT INTO pumps
                      (pump_id,logical_number,pump_type_id,pump_name)
               VALUES (@pump_id,@logical_number,@pump_type_id,@pump_name)

	       SET @record_inserted=1
               
               PRINT 'Record inserted'
	       
       END
       IF (@action_type = 'I' AND @record_inserted = 0 )
	BEGIN
		ROLLBACK TRANSACTION
		RETURN
	END
	IF (@record_inserted=0)
	BEGIN
		-- Always update mandatory fields 
		PRINT 'Updating mandatory fields'
		UPDATE pumps SET
			logical_number 	    = @logical_number,
			pump_type_id   	    = @pump_type_id
		WHERE  pump_id = @pump_id
	
			
	END
			       	  
	PRINT 'Updating optional fields'
	
	IF (@pump_name is not null)
		UPDATE pumps SET
			pump_name= @pump_name,
			polling_address =@polling_address
		WHERE pump_id = @pump_id
    			     	
	
       COMMIT TRANSACTION
END
GO


IF EXISTS (SELECT NAME FROM sysobjects WHERE NAME = 'Populate_Price_Level_Type' AND TYPE = 'p')
  DROP PROCEDURE Populate_Price_Level_Type
GO

print 'Creating Populate_Price_Level_Type'
go

-- Procedure Populate_Price_Level_Type
-- Inserts or Updates records based on the action_type parameter 

CREATE PROCEDURE Populate_Price_Level_Type
	@action_type char,
	@price_level int,
	@level_name nchar(30) = NULL, 
	@level_description nvarchar(80) = NULL
AS

DECLARE @record_inserted int


BEGIN
	-- Standard logging
	PRINT 'Procedure: Populate_Price_Level, key field: Price_Level, action type: ' + @action_type   

	-- Validate all parameters
	IF @action_type NOT IN ('I','U','P') 
		BEGIN
			PRINT 'Error in parameter @action_type, ' + @action_type + ' is not a valid option'
			RETURN
		END 

	IF @price_level IS NULL
		BEGIN
			PRINT 'Error - @price_level is mandatory'
			RETURN
		END
	

	-- All parameters have now been validated
	
	BEGIN TRANSACTION
	-- Insert only: action_type = 'I'
	-- Update only: action_type = 'U'
	-- Populate   : action_type = 'P'
	
	SET @Record_Inserted = 0
	
	-- Determine if record already exists	
	IF (( SELECT COUNT(price_level)
		FROM price_level_types   
	        WHERE price_level = @price_level)= 0 )
	BEGIN
		PRINT 'Record does not exist'
	               
	        IF( @action_type = 'U' )
		BEGIN
			ROLLBACK TRANSACTION
			RETURN -- Update only nothing else to do since record does not exist
		END
	               	-- Insert record
	        PRINT 'Inserting record'
	        INSERT INTO price_level_types ( price_level ) VALUES ( @price_level )
	               
	        SET @record_inserted = 1 
	               
	        PRINT 'Record inserted'
	END
	ELSE
		PRINT 'Record already exists'	

	-- If action_type is insert only then we only update the 
	-- record if a record has been inserted
	IF( @action_type = 'I' AND @record_inserted = 0)
		BEGIN
		        ROLLBACK TRANSACTION
		        RETURN
		END
	-- Update record
	PRINT 'Updating record'
	
	-- Always update Mandatory fields 
	UPDATE Price_Level_Types SET
	        level_name = @level_name
	WHERE price_level = @price_level
	
	-- Update optional fields, but only if their respective parameters
	-- were passed in e.g. they are not null 

	IF @level_description IS NOT NULL 
		BEGIN
			PRINT 'updating @level_description' 
		        UPDATE Price_Level_Types SET level_description = @level_description WHERE price_level = @price_level
		END
	     	  
	PRINT 'Record updated'
	
	COMMIT TRANSACTION
END
GO


	
--------------------------------------------------------------------------------


IF EXISTS (SELECT NAME FROM sysobjects WHERE NAME = 'Populate_Site_Profile' AND TYPE = 'p')
  DROP PROCEDURE Populate_Site_Profile
GO

-- Procedure Populate_Site_Profile
-- Inserts or Updates records based on the action_type parameter 

-- NOTE: The mandatory parameters are: @action_type, @site_profile_name

CREATE PROCEDURE Populate_Site_Profile
	@action_type 		     char, 
	@site_profile_name	     nchar(30), 
	@site_profile_desc	     nchar(80) = NULL, 
	@start_time	             int = NULL, 
	@valid_days              nchar(20) = NULL, 
	@site_profile_number     int = NULL, 
	@use_site_profile_number smallint =NULL
AS

DECLARE @record_inserted int
DECLARE @site_profile_id int
DECLARE @site_profile_id_exist int

BEGIN
	-- Standard logging
	PRINT 'Procedure: Populate_Site_Profile, key field: site_profile_name, action type: ' + @action_type   

	-- Validate all parameters
	IF @action_type NOT IN ('I','U','P') 
		BEGIN
			PRINT 'Error in parameter @action_type, ' + @action_type + ' is not a valid option'
			RETURN
		END 

	IF @site_profile_name IS NULL
		BEGIN
			PRINT 'Error in parameter @site_profile_name is Mandatory'
			RETURN
		END

	IF (@use_site_profile_number is not null)
	BEGIN
		SET @site_profile_id_exist = (SELECT TOP 1 site_profile_id FROM site_profile WHERE site_profile_number = @site_profile_number)
		SET @site_profile_id = @site_profile_id_exist
	END
	ELSE
	BEGIN
		SET @site_profile_id_exist = (SELECT TOP 1 site_profile_id FROM site_profile WHERE site_profile_name = @site_profile_name)
		SET @site_profile_id = @site_profile_id_exist
	END

	IF @site_profile_id IS NULL
		IF (@action_type = 'U')
  			BEGIN
				PRINT 'Error in parameter @site_profile_name, ' + @site_profile_name + ' not matched for update'
				RETURN
  			END
	ELSE  
  		SET @site_profile_id = (SELECT MAX(site_profile_id) + 1 FROM site_profile)
	  
	-- validate columns
	
	BEGIN TRANSACTION
	-- Insert only: action_type = 'I'
	-- Update only: action_type = 'U'
	-- Populate   : action_type = 'P'
	
	SET @Record_Inserted = 0
	
	-- Determine if record already exists	
	IF (@site_profile_id_exist is null)
	BEGIN
		PRINT 'Record does not exist'
	               
		IF( @action_type = 'U' )
		BEGIN
			ROLLBACK TRANSACTION
			RETURN -- Update only nothing else to do since record does not exist
		END
		-- Insert record
		PRINT 'Inserting record'
		INSERT INTO site_profile ( site_profile_id,site_profile_name ) 
		VALUES ( @site_profile_id,@site_profile_name )
	               
		SET @record_inserted = 1 
	               
		PRINT 'Record inserted'
	END
	ELSE
		PRINT 'Record already exists'	

	-- If action_type is insert only then we only update the 
	-- record if a record has been inserted
	IF( @action_type = 'I' AND @record_inserted = 0)
		BEGIN
		        ROLLBACK TRANSACTION
		        RETURN
		END
	-- Update record
	PRINT 'Updating record'
	
	-- Always update mandatory fields 
	UPDATE site_profile SET
	        site_profile_name = @site_profile_name
	WHERE site_profile_id = @site_profile_id
	
	-- Update optional fields, but only if their respective parameters
	-- were passed in e.g. they are not null 

	IF @site_profile_desc IS NOT NULL 
		BEGIN
			PRINT 'updating @site_profile_desc'
			UPDATE site_profile SET site_profile_desc = @site_profile_desc WHERE site_profile_id = @site_profile_id
		END	

	PRINT 'Record updated'
	
	COMMIT TRANSACTION
END
GO


--- stored proc to create roles based access required for PCI-DSS compliance

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
		SET @logname = @hostname + '\' + @GroupName
	END
	ELSE
	BEGIN	
		SET @logname =  @ServerName + '\'+ @GroupName
	END
	--PRINT 'creating login name and role  for ' + logname	
	IF NOT EXISTS (SELECT NAME FROM sysusers WHERE NAME = @RoleDesc) 	
	BEGIN
		EXEC sp_addrole @RoleDesc
		EXEC sp_revokelogin @logname
		EXEC sp_grantlogin @logname
		-- creating the login name (for current database)
		EXEC sp_revokedbaccess @logname
		EXEC sp_grantdbaccess @logname, NULL
		EXEC sp_addrolemember @RoleDesc, @logname
		EXEC sp_defaultdb @logname,'EnablerDB'
	END
END
GO





--------------------------------------------------------------------------------

-- Drop this since this will be replaced by the triggers of EnbCOnfigX
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Tanks_Trigger' AND type = 'TR')
	DROP TRIGGER Tanks_Trigger
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Tank_History_Trigger' AND type = 'TR')
	DROP TRIGGER Tank_History_Trigger
GO

-- ##SUMMARY <p>Tank_History_Trigger is a trigger on INSERT and UPDATE of the Tank_History Table.</p>
--
-- ##REMARKS <p>Provided to validate manually entered Dip_Fuel_Temp data against the temperature
-- ##REMARKS thresholds set in Tanks.Hi_Temperature and Tanks.Low_Temperature.</p>
CREATE TRIGGER  Tank_History_Trigger ON Tank_History
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @temphigh int
	DECLARE @templow int
	DECLARE @temp int
	DECLARE @tankid int

	SET @temp = (SELECT TOP 1 Dip_Fuel_Temp FROM INSERTED) 
	SET @tankid = (SELECT TOP 1 Tank_ID FROM INSERTED)  
	SET @temphigh = (SELECT TOP 1 Hi_Temperature FROM Tanks WHERE Tank_ID=@tankid) 
	SET @templow = (SELECT TOP 1 Low_Temperature FROM Tanks WHERE Tank_ID=@tankid) 

	IF ((@templow>0 AND @temp<@templow) OR 
		(@temphigh>0 AND @temp>@temphigh))
	BEGIN
		RAISERROR ('Dip_Fuel_Temp<Tanks.Low_Temperature OR Dip_Fuel_Temp>Hi_Temperature!',18,1)
		ROLLBACK
	END
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Tank_Loss_Trigger' AND type = 'TR')
	DROP TRIGGER Tank_Loss_Trigger
GO

-- ##SUMMARY <p>Tank_Loss_Trigger is a trigger on INSERT and UPDATE of the Tank_Loss Table.</p>
--
-- ##REMARKS <p>Provided to validate movement types for new or updated rows of the table.</p>
CREATE TRIGGER Tank_Loss_Trigger ON Tank_Loss
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @movement int	
	SET @movement= (SELECT TOP 1 Tank_Movement_Type_ID FROM INSERTED)
	IF (@movement< 4 OR @movement>7)
	BEGIN
		RAISERROR ('Tank_Loss.Tank_Movement_Type_ID may only be ProductUplift, WaterUplift, Empty!',18,1)
		ROLLBACK
	END
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Tank_Delivery_Trigger' AND type = 'TR')
	DROP TRIGGER Tank_Delivery_Trigger
GO

CREATE TRIGGER Tank_Delivery_Trigger ON Tank_Delivery
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @movement int	
	SET @movement= (SELECT TOP 1 Tank_Movement_Type_ID FROM INSERTED)
	IF (@movement<>1 AND @movement<>7)
	BEGIN
		RAISERROR ('Tank_Delivery.Tank_Movement_Type_ID may only be Delivery!',18,1)
		ROLLBACK
	END
END
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Tank_Transfer_Trigger' AND type = 'TR')
	DROP TRIGGER Tank_Transfer_Trigger
GO

CREATE TRIGGER Tank_Transfer_Trigger ON Tank_Transfer
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @movement int	
	SET @movement= (SELECT TOP 1 Tank_Movement_Type_ID FROM INSERTED)
	IF (@movement < 2 OR @movement>3)
	BEGIN
		RAISERROR ('Tank_Transfer.Tank_Movement_Type_ID may only be TestTransfer or TanktoTank!',18,1)
		ROLLBACK
	END
END
GO


IF EXISTS (SELECT name FROM SYSOBJECTS WHERE NAME = 'Enforce_Ratios' AND TYPE = 'P')
BEGIN
	DROP PROCEDURE Enforce_Ratios
END
GO

CREATE PROCEDURE Enforce_Ratios
AS
BEGIN
	-- This stored procedure ensures that the ratios in the Grade_PostMix_Ratios table matches
	-- what is in the price_levels table

	DECLARE @GradeID Int

	-- declare and open a cursor that consists of all the grades that are the variable ratio type
	DECLARE grades_cursor CURSOR FAST_FORWARD FOR SELECT grade_id FROM Grades WHERE Grade_ID in (SELECT Grade_ID FROM Grade_PostMix_Ratio) AND deleted = 0 AND grade_type = 3 
	OPEN grades_cursor

	-- Loop through the existing price profiles
	FETCH NEXT FROM grades_cursor INTO @GradeID
	WHILE @@Fetch_status = 0
	BEGIN
		DECLARE @MaxPriceLevel int
		DECLARE @PriceLevelIndex int
		DECLARE @PriceProfileID int

		DECLARE @MaxRatioIndex int
		DECLARE @RatioIndex int

		-- open a cursor that consist of all the price profiles that are associated with this grade
		DECLARE blend_ratio_price_profile_cursor 
		 CURSOR FAST_FORWARD FOR 
		 SELECT price_profile_id 
		   FROM price_profile 
		  WHERE deleted = 0 
		    AND parent_grade_id = @GradeID

		OPEN blend_ratio_price_profile_cursor

		-- Loop through the existing price profiles
		FETCH NEXT FROM blend_ratio_price_profile_cursor INTO @PriceProfileID
		WHILE @@Fetch_status = 0
		BEGIN
				-- Loop through all the price levels
				SET @PriceLevelIndex = 1
				SET @MaxPriceLevel = (SELECT MAX(Price_Level)FROM Price_Levels WHERE Price_Profile_ID = @PriceProfileID)
				
				WHILE @PriceLevelIndex <= @MaxPriceLevel
				BEGIN
					SET @RatioIndex = 1
					SET @MaxRatioIndex = (SELECT MAX(Ratio_index)FROM Grade_Postmix_Ratio WHERE Grade_ID = @GradeID)
					
					-- Loop through all the ratio indexes
					WHILE @RatioIndex <= @MaxRatioIndex
					BEGIN
						IF EXISTS(SELECT Price_Profile_ID FROM Price_Levels WHERE Price_Profile_ID = @PriceProfileID AND Price_Level = @PriceLevelIndex AND Price_Index = @RatioIndex)
						BEGIN
							-- Row exists so update it
							UPDATE Price_Levels 
							   SET Price_Ratio = (SELECT Ratio FROM Grade_PostMix_Ratio WHERE Grade_ID = @GradeID AND Ratio_Index = @RatioIndex)
							WHERE Price_Profile_ID = @PriceProfileID 
							  AND Price_Index = @RatioIndex 
							  AND Price_Level = @PriceLevelIndex
						END
						ELSE
						BEGIN
							-- Row does not exist so insert it
							-- Note a zero price is entered
							INSERT INTO Price_Levels (Price_Level, Price_Profile_ID, Grade_Price, Price_Index, Price_Ratio) 
							SELECT @PriceLevelIndex, @PriceProfileID, 0, @RatioIndex, Ratio 
							  FROM Grade_PostMix_Ratio 
							 WHERE Ratio_Index = @RatioIndex 
							   AND Grade_ID = @GradeID
						END
						SET @RatioIndex = @RatioIndex + 1
					END
					
					SET @PriceLevelIndex = @PriceLevelIndex + 1
				END

				FETCH NEXT FROM blend_ratio_price_profile_cursor INTO @PriceProfileID
		END
	     
		DEALLOCATE blend_ratio_price_profile_cursor

		-- Delete any price levels that don't have a matching entry in the Grade_PostMix_ratio table 
		delete pl FROM price_levels pl
			inner join price_profile pp on pp.price_profile_id = pl.price_profile_id
			WHERE pp.parent_grade_id = @GradeID 
			AND pl.Price_index not in (SELECT ratio_index FROM grade_postmix_ratio WHERE grade_id = @GradeID)
		
		FETCH NEXT FROM grades_cursor INTO @GradeID
	END

	DEALLOCATE grades_cursor
	     
END
GO


print 'Creating Apply_Post_Mix_Price'
go

IF EXISTS  (SELECT name FROM sysobjects WHERE name = 'Apply_Post_Mix_Price' AND type = 'p')
   DROP PROCEDURE Apply_Post_Mix_Price
go

CREATE PROCEDURE Apply_Post_Mix_Price
	@PostMixPriceProfileID int,
	@Grade1PriceProfileID int,
	@Grade2PriceProfileID int,
	@PriceLevel int = -1
As
BEGIN

	IF( @PriceLevel < 0 )
	BEGIN

		-- Apply prices for all price levels
		-- Get the price levels and call this stored procedure again passing in the level

		DECLARE price_level_cursor CURSOR FAST_FORWARD FOR SELECT Price_Level FROM Price_Level_Types 
		OPEN price_level_cursor
		FETCH NEXT FROM price_level_cursor INTO @PriceLevel
		WHILE @@Fetch_status = 0
		BEGIN
			EXEC Apply_Post_Mix_Price @PostMixPriceProfileID, @Grade1PriceProfileID,@Grade2PriceProfileID,@PriceLevel
			FETCH NEXT FROM price_level_cursor INTO @PriceLevel
		END
		DEALLOCATE price_level_cursor

	END
	ELSE
	BEGIN 
		-- Have a specified price level.  Proceed to calculate price

		-- Find Grade 1 price
		DECLARE @Grade1Price AS money
		SET @Grade1Price = (SELECT Grade_Price FROM Price_Levels WHERE Price_Profile_ID = @Grade1PriceProfileID AND Price_Level = @PriceLevel)
		IF( @Grade1Price IS NULL)
		BEGIN
			PRINT('No price for Grade 1 price profile ' + convert(varchar,@Grade1PriceProfileID) + ', Level ' + convert(varchar,@PriceLevel) + '. Post-mix pricing will not be applied')
			RETURN
		END 
	
		-- Find Grade 2 price
		DECLARE @Grade2Price AS money
		SET @Grade2Price = (SELECT Grade_Price FROM Price_Levels WHERE Price_Profile_ID = @Grade2PriceProfileID AND Price_Level = @PriceLevel )
		IF( @Grade2Price IS NULL)
		BEGIN
			PRINT('No price for Grade 2 price profile ' + convert(varchar,@Grade2PriceProfileID) + ', Level ' + convert(varchar,@PriceLevel) + '. Post-mix pricing will not be applied')
			RETURN
		END
	
		-- Determine post-mix ratio type
		DECLARE @RatioType AS smallint
		DECLARE @GradeID AS int
		SET @GradeID = (SELECT Parent_Grade_ID FROM Price_Profile WHERE Price_Profile_ID = @PostMixPriceProfileID)
		SET @RatioType = (SELECT Grade_Type FROM Grades WHERE Grade_ID = @GradeID AND deleted = 0)
		
		DECLARE @PostMixPrice AS money
		DECLARE @Ratio AS float

		DECLARE @RoundType as smallint
		DECLARE @RoundDecimals as smallint

		SET @RoundType = (SELECT Price_Calc_Round_Type FROM Global_Settings)

		-- Round Type = 0 = Round 
		-- Round Type = 1 = Truncate

		SET @RoundDecimals = (SELECT Price_Calc_Decimals FROM Global_Settings)

	
		IF(@RatioType = 2)
		BEGIN
			-- Fixed Ratio
			-- Get ratio amount
			SET @Ratio = (SELECT Blend_Ratio FROM Grades WHERE Price_Profile_ID = @PostMixPriceProfileID AND deleted = 0) 
	
			-- Calculate post-mix price
			IF(@Ratio = 0)
				SET @PostMixPrice = @Grade1Price  -- No Grade 2 component
			ELSE 
				SET @PostMixPrice = ( @Grade1Price * ((100-@Ratio)/100) + ( @Grade2Price * (@Ratio/100)))


			SET @PostMixPrice = ROUND(@PostMixPrice, @RoundDecimals, @RoundType)
			
			-- Save new price
			Update Price_Levels SET Grade_Price = @PostMixPrice WHERE Price_Profile_ID = @PostMixPriceProfileID AND Price_Level = @PriceLevel
	
		END
		ELSE IF(@RatioType = 3)
		BEGIN
			-- Variable ratio.  Need to update all ratios at the specified price level
			DECLARE ratio_cursor CURSOR FAST_FORWARD FOR SELECT Price_Ratio FROM Price_Levels WHERE Price_Profile_ID = @PostMixPriceProfileID AND Price_Level = @PriceLevel 
			
			OPEN ratio_cursor
			FETCH NEXT FROM ratio_cursor INTO @Ratio 
			WHILE @@Fetch_status = 0
			BEGIN
				IF(@Ratio = 0)
					SET @PostMixPrice = @Grade1Price  -- No Grade 2 component
				ELSE 
					SET @PostMixPrice = ( @Grade1Price * ((100-@Ratio)/100) + ( @Grade2Price * (@Ratio/100)))
				
				SET @PostMixPrice = ROUND(@PostMixPrice, @RoundDecimals, @RoundType)

				-- Save new price
				Update Price_Levels SET Grade_Price = @PostMixPrice WHERE Price_Profile_ID = @PostMixPriceProfileID AND Price_Level = @PriceLevel AND Price_Ratio = @Ratio
	
				FETCH NEXT FROM ratio_cursor INTO @Ratio
			END
	
			DEALLOCATE ratio_cursor
	
		END
		ELSE
		BEGIN
			-- Should never happen 
			PRINT('Non-postmix ratio type for post-mix price profile ' + convert(varchar,@PostMixPriceProfileID) + '. Post-mix pricing will not be applied')
			RETURN
		END

	END

END
go


print 'Creating Check_Post_Mix_Pricing'
go

IF EXISTS  (SELECT name FROM sysobjects WHERE name = 'Check_Post_Mix_Pricing' AND type = 'p')
   DROP PROCEDURE Check_Post_Mix_Pricing
go

CREATE PROCEDURE Check_Post_Mix_Pricing
	@PriceProfileID int = -1,
	@PriceLevel int = -1
as
BEGIN

	IF @PriceProfileID < 0 
		BEGIN
		-- Check post-mix pricing for all price profiles
		-- No need to check all, just get the price profile IDs linked to any "Grade 1" grade IDs
		DECLARE grade_1_price_profile_cursor CURSOR FAST_FORWARD FOR SELECT Price_Profile_ID FROM Grades WHERE Grade_ID in (SELECT Grade1_ID FROM Grades WHERE Grade1_ID IS not NULL AND deleted = 0 group by Grade1_ID) AND deleted = 0
		OPEN grade_1_price_profile_cursor

		FETCH NEXT FROM grade_1_price_profile_cursor INTO @PriceProfileID
		WHILE @@Fetch_status = 0
		BEGIN
			-- Call this stored procedure again, passing in all the price profile IDs to check
			EXEC Check_Post_Mix_Pricing @PriceProfileID, @PriceLevel
			FETCH NEXT FROM grade_1_price_profile_cursor INTO @PriceProfileID
		END
		
		DEALLOCATE grade_1_price_profile_cursor
	END
	ELSE
	BEGIN
		DECLARE @PostMixGradeID AS int
		DECLARE @PostMixPriceProfileID AS int

		DECLARE @Grade1ID AS int
		DECLARE @Grade1PriceProfileID AS int
		DECLARE @Grade1Type AS int		

		DECLARE @Grade2ID AS int
		DECLARE @Grade2PriceProfileID AS int
	    	DECLARE @Grade2Type AS int
		
		-- Get the grade ID linked to this price profile 
		DECLARE @GradeID AS int
		SET @GradeID = (SELECT Parent_Grade_ID FROM Price_Profile WHERE Price_Profile_ID = @PriceProfileID AND deleted = 0)

		-- Is this a base grade or a post-mix grade?
		DECLARE @GradeType AS int
		SET @GradeType = (SELECT Grade_Type FROM Grades WHERE Grade_ID = @GradeID AND deleted = 0)
		
		IF( @GradeType = 1 )
		BEGIN
			-- Potential base grade
			-- Now find if this Grade ID is a base grade for any post-mix grades
			-- Note that this assumes that a base grade will either be a Grade 1 or a Grade 2 base grade but not both
			SET @Grade1ID = (SELECT Grade1_ID FROM Grades WHERE Grade1_ID = @GradeID  AND deleted = 0 AND (grade_type = 2 OR grade_type = 3) group by Grade1_ID )
			SET @Grade2ID = (SELECT Grade2_ID FROM Grades WHERE Grade2_ID = @GradeID  AND deleted = 0 AND (grade_type = 2 OR grade_type = 3) group by Grade2_ID)
		END
		ELSE IF ( @GradeType = 2 OR @GradeType = 3)
		BEGIN
			-- Post-mix grade
			SET @Grade1ID = (SELECT Grade1_ID FROM Grades WHERE Grade_ID = @GradeID  AND deleted = 0 AND (grade_type = 2 OR grade_type = 3) )
			SET @Grade2ID = (SELECT Grade2_ID FROM Grades WHERE Grade_ID = @GradeID  AND deleted = 0 AND (grade_type = 2 OR grade_type = 3) )
			

			IF( @Grade1ID IS NULL OR @Grade2ID IS NULL)
			BEGIN
				PRINT('One or more base grades missing FROM post-mix grade ID ' + convert(varchar,@GradeID) + '. Post-mix pricing will not be applied')
				RETURN
			END
		END
		ELSE
		BEGIN
			PRINT('Unknown grade type for Grade ID ' + convert(varchar,@GradeID) + '. Post-mix pricing will not be applied')
			RETURN
		END

		IF( @GradeType = 2 OR @GradeType = 3)
		BEGIN
			-- Post-mix grade price update is required
			SET @PostMixPriceProfileID = (SELECT Price_Profile_ID FROM Grades WHERE Grade_ID = @GradeID AND deleted = 0) 
			SET @Grade1PriceProfileID = (SELECT Price_Profile_ID FROM Grades WHERE Grade_ID = @Grade1ID AND deleted = 0) 
			SET @Grade2PriceProfileID = (SELECT Price_Profile_ID FROM Grades WHERE Grade_ID = @Grade2ID AND deleted = 0) 
			SET @Grade1Type = (SELECT Grade_Type FROM Grades WHERE Grade_ID = @Grade1ID AND deleted = 0) 
			SET @Grade2Type = (SELECT Grade_Type FROM Grades WHERE Grade_ID = @Grade2ID AND deleted = 0) 
			IF ( @Grade1Type <> 1 OR @Grade2Type <> 1)
			BEGIN
				PRINT('Grade1 or Grade2 is not a based grade!')
				RETURN
			END

			EXEC Apply_Post_Mix_Price @PostMixPriceProfileID, @Grade1PriceProfileID,@Grade2PriceProfileID,@PriceLevel
		END
		ELSE IF( @Grade1ID IS not NULL)
		BEGIN
			-- We have a price change on a grade that is the "Grade 1" base grade for at least one post-mix grade
			SET @Grade1PriceProfileID = (SELECT Price_Profile_ID FROM Grades WHERE Grade_ID = @Grade1ID AND deleted = 0 )

			-- Find all the active Post-Mix grade price profiles linked to this base grade

			DECLARE price_profile_cursor1 CURSOR FAST_FORWARD FOR SELECT Price_Profile_ID, Grade2_ID FROM Grades WHERE Grade1_ID = @Grade1ID AND deleted = 0 AND (grade_type = 2 OR grade_type = 3)
			OPEN price_profile_cursor1

			FETCH NEXT FROM price_profile_cursor1 INTO @PostMixPriceProfileID, @Grade2ID 
			WHILE @@Fetch_status = 0
			BEGIN
				IF( @Grade2ID IS NULL )
				BEGIN
					PRINT('No Grade 2 ID for post-mix price profile ' + convert(varchar,@PostMixPriceProfileID) + '. Post-mix pricing will not be applied')
					DEALLOCATE price_profile_cursor1
					RETURN
				END 

				-- Get Grade 2 price profile ID
				SET @Grade2PriceProfileID = (SELECT Price_Profile_ID FROM Grades WHERE Grade_ID = @Grade2ID AND deleted = 0 )

				-- Call stored procedure to calculate price
				EXEC Apply_Post_Mix_Price @PostMixPriceProfileID, @Grade1PriceProfileID,@Grade2PriceProfileID,@PriceLevel

				FETCH NEXT FROM price_profile_cursor1 INTO @PostMixPriceProfileID, @Grade2ID 
			END
			DEALLOCATE price_profile_cursor1
			
		END
		ELSE IF( @Grade2ID IS not null )
		BEGIN

			-- We have a price change on a grade that is the "Grade 2" base grade for at least one post-mix grade
			SET @Grade2PriceProfileID = (SELECT Price_Profile_ID FROM Grades WHERE Grade_ID = @Grade2ID AND deleted = 0)

			-- Find all the active Post-Mix grade price profiles linked to this base grade

			DECLARE price_profile_cursor2 CURSOR FAST_FORWARD FOR SELECT Price_Profile_ID, Grade1_ID FROM Grades WHERE Grade2_ID = @Grade2ID AND deleted = 0 AND (grade_type = 2 OR grade_type = 3)
			OPEN price_profile_cursor2

			FETCH NEXT FROM price_profile_cursor2 INTO @PostMixPriceProfileID, @Grade1ID 
			WHILE @@Fetch_status = 0
			BEGIN
				IF( @Grade1ID IS NULL )
				BEGIN
					PRINT('No Grade 1 ID for post-mix price profile ' + convert(varchar,@PostMixPriceProfileID) + '. Post-mix pricing will not be applied')
					DEALLOCATE price_profile_cursor2
					RETURN
				END 
				
				-- Get Grade 1 price profile ID
				SET @Grade1PriceProfileID = (SELECT Price_Profile_ID FROM Grades WHERE Grade_ID = @Grade1ID AND deleted = 0)

				EXEC Apply_Post_Mix_Price @PostMixPriceProfileID, @Grade1PriceProfileID,@Grade2PriceProfileID,@PriceLevel

				FETCH NEXT FROM price_profile_cursor2 INTO @PostMixPriceProfileID, @Grade1ID 
			END
			DEALLOCATE price_profile_cursor2
	
		END
		ELSE
		BEGIN
			PRINT('There are no blend grades with a base grade linking to price profile ' + convert(varchar,@PriceProfileID))
		END
			    
	END

END
go

print 'Creating Enforce_Price_Levels'
go

IF EXISTS  (SELECT name FROM sysobjects WHERE name = 'Enforce_Price_Levels' AND type = 'P')
   DROP PROCEDURE Enforce_Price_Levels
go

CREATE PROCEDURE Enforce_Price_Levels
	@PriceProfileID int = -1,
	@PriceLevel int = -1
AS
BEGIN

	DECLARE @DefaultPrice money
	SET @DefaultPrice = 1	

	IF @PriceProfileID >= 0 
	BEGIN

		IF NOT EXISTS (SELECT Price_Profile_ID FROM Price_Profile WHERE 	Price_Profile_ID = @PriceProfileID) 
		BEGIN
			PRINT 'Price Profile ID ' + convert(varchar, @PriceProfileID) + ' does not exist. Price levels for this ID will not be enforced'
			RETURN
		END

		IF( @PriceLevel < 0 )
		BEGIN
			-- All price levels
			DECLARE price_level_cursor CURSOR FAST_FORWARD FOR SELECT price_level FROM price_level_types 

			OPEN price_level_cursor

			FETCH NEXT FROM price_level_cursor INTO @PriceLevel
			WHILE @@Fetch_status = 0
			BEGIN
				-- Only insert a price level if one does not already exist
				IF NOT EXISTS (SELECT Price_profile_ID FROM Price_Levels WHERE Price_Profile_ID = @PriceProfileID AND Price_level = @PriceLevel)
				BEGIN
					INSERT Price_Levels values (@PriceLevel,@PriceProfileID,@DefaultPrice, 1, 0)
				END
				FETCH NEXT FROM price_level_cursor INTO @PriceLevel
			END
		
			DEALLOCATE price_level_cursor
		END
		ELSE
		BEGIN
			IF NOT EXISTS (SELECT Price_Level FROM Price_Level_Types WHERE Price_Level = @PriceLevel) 
			BEGIN
				PRINT 'Enforce Price Levels: Price_Level ' + convert(varchar, @PriceLevel) + ' does not exist. Price levels for Price Profile ID ' + convert(varchar, @PriceProfileID) + ' will not be enforced'
				RETURN
			END

			IF NOT EXISTS (SELECT Price_profile_ID FROM Price_Levels WHERE Price_Profile_ID = @PriceProfileID AND Price_level = @PriceLevel)
			BEGIN
				INSERT Price_Levels values (@PriceLevel,@PriceProfileID,@DefaultPrice, 1, 0)
			END

		END

	END
	ELSE
	BEGIN
	
		-- Price Profile ID is -1 which means check all price_profiles

		DECLARE price_profile_cursor CURSOR FAST_FORWARD FOR SELECT price_profile_id FROM price_profile WHERE deleted = 0 

		OPEN price_profile_cursor

		-- Loop through the existing price profiles
		FETCH NEXT FROM price_profile_cursor INTO @PriceProfileID
		WHILE @@Fetch_status = 0
		BEGIN
			-- Reccurse back on ourselves actually insert the price levels if necessary
			EXEC Enforce_Price_Levels @PriceProfileID, @PriceLevel
			FETCH NEXT FROM price_profile_cursor INTO @PriceProfileID
		END
	
		DEALLOCATE price_profile_cursor
	END
END
go



print 'Creating TG_Auto_PostMix_Price_Global'
go

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'TG_Auto_PostMix_Price_Global' AND type = 'TR')
    	DROP TRIGGER TG_Auto_PostMix_Price_Global
GO

CREATE TRIGGER TG_Auto_PostMix_Price_Global ON Global_Settings
FOR UPDATE 
AS
BEGIN
	IF UPDATE(Auto_PostMix_Price)
	BEGIN
		DECLARE @PostMixSetting AS smallint
		SET @PostMixSetting = (SELECT Auto_PostMix_Price FROM GLOBAL_SETTINGS)
		IF @PostMixSetting = 1
		BEGIN
			EXEC Enforce_Price_Levels
			EXEC Enforce_Ratios	
		END
	END
END
Go


print 'Creating TG_Enforce_Price_Levels'
go

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'TG_Enforce_Price_Levels' AND type = 'TR')
    	DROP TRIGGER TG_Enforce_Price_Levels
GO

CREATE TRIGGER TG_Enforce_Price_Levels ON Price_Profile
FOR INSERT 
AS
BEGIN
	/* previously this was only done for when the Global_Settings.Auto_PostMix_Price feature was on,
	 * from v4 onwards this is ALWAYS done to keep price profiles consistent */
	DECLARE @Price_Profile_ID int
	SET @Price_Profile_ID = (SELECT Price_Profile_ID FROM Inserted)
	EXEC Enforce_Price_Levels @Price_Profile_ID
END
Go


print 'Creating TG_Grade_PostMix_Enforce_Ratios'
go

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'TG_Grade_Postmix_Enforce_Ratios' AND type = 'TR')
BEGIN
	DROP TRIGGER TG_Grade_Postmix_Enforce_Ratios
END
ELSE
BEGIN
	-- Before we add a trigger check if any existing ratios needs to be migrated to the new grade_postmix_table
	DECLARE @PriceProfileID Int
	DECLARE @GradeID Int

	-- Get all price profiles linked to blended grades
	DECLARE RatioMigrate_cursor CURSOR FAST_FORWARD FOR SELECT price_profile_id, grade_id FROM grades WHERE (grade_type = 2 OR grade_type = 3) AND deleted = 0  
	OPEN RatioMigrate_cursor

	FETCH NEXT FROM RatioMigrate_cursor INTO @PriceProfileID, @GradeID
	WHILE @@Fetch_status = 0
	BEGIN
		DECLARE @PriceIndex smallint
		DECLARE @PriceRatio float

		-- Get all price indexes and ratios for the blended grade. Order by price level
		DECLARE RatioMigratePriceLevels_cursor 
		 CURSOR FAST_FORWARD FOR 
		 SELECT price_index, price_ratio 
		   FROM price_levels 
		  WHERE price_profile_id = @PriceProfileID 
		  ORDER BY price_level

		OPEN RatioMigratePriceLevels_cursor

		FETCH NEXT FROM RatioMigratePriceLevels_cursor INTO @PriceIndex, @PriceRatio
		WHILE @@Fetch_status = 0
		BEGIN
			-- Only insert if the price_index and ratio does not already exist.  
			IF NOT EXISTS (SELECT grade_id FROM grade_postmix_ratio WHERE grade_id = @GradeID AND Ratio_Index = @PriceIndex )
			BEGIN
				PRINT 'Grade ID: ' + CONVERT(varchar, @GradeID) + ' - Adding Price Index: ' + CONVERT(varchar, @PriceIndex) + ', Ratio: ' + CONVERT(varchar, @PriceRatio) + ' to Grade_PostMix_Ratio table'
				INSERT Grade_PostMix_Ratio (Grade_ID, Ratio_Index, Ratio) VALUES (@GradeID, @PriceIndex, @PriceRatio)
			END
			
			FETCH NEXT FROM RatioMigratePriceLevels_cursor INTO @PriceIndex, @PriceRatio
		END

		DEALLOCATE RatioMigratePriceLevels_cursor

		FETCH NEXT FROM RatioMigrate_cursor INTO @PriceProfileID, @GradeID
	END

	DEALLOCATE RatioMigrate_cursor

	-- Call enforce ratios to ensure everything is now consistent
	EXEC enforce_ratios

END
GO


print 'Creating TG_Enforce_Ratios'
go

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'TG_Enforce_Ratios' AND type = 'TR')
    	DROP TRIGGER TG_Enforce_Ratios
GO

CREATE TRIGGER TG_Enforce_Ratios ON Grade_PostMix_Ratio
FOR INSERT, UPDATE, DELETE 
AS
BEGIN
	EXEC Enforce_Ratios 
END
Go


print 'Creating TG_Grades_Check_Post_Mix_Pricing'
go

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'TG_Grades_Check_Post_Mix_Pricing' AND type = 'TR')
    	DROP TRIGGER TG_Grades_Check_Post_Mix_Pricing
GO

CREATE TRIGGER TG_Grades_Check_Post_Mix_Pricing ON Grades
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @PostMixSetting AS smallint
	SET @PostMixSetting = (SELECT Auto_PostMix_Price FROM 	Global_Settings)
	IF (@PostMixSetting = 1)
	BEGIN

		IF((SELECT Count(Grade_ID) FROM Inserted) > 1 )
		BEGIN
			-- More then one item in the price_levels table has been updated at once
			-- Rather then putting logice to go through all the combinations
			-- just check all active price profiles.
			Exec Check_Post_Mix_Pricing
		END
		ELSE
		BEGIN 
			DECLARE @GradeType AS int
			DECLARE @CheckPrices AS smallint
			SET @CheckPrices = 0 

			SET @GradeType = (SELECT Grade_Type FROM Inserted)
	
			-- Post-Mix and Base Grade price profile updates check
			IF( UPDATE(Price_Profile_ID)) SET @CheckPrices = 1  

			-- Post-Mix only grade1_Id or Grade2_ID update check
			IF((UPDATE(Grade1_ID) OR UPDATE(Grade2_ID)) AND ( @GradeType = 2 OR @GradeType = 3 ))SET @CheckPrices = 1 

			-- Post-Mix fixed ratio only update check
			IF( UPDATE(Blend_Ratio) AND @GradeType = 2 )SET @CheckPrices = 1  
	
			IF( @CheckPrices = 1)
			BEGIN
				DECLARE @PriceProfileID AS int
				SET @PriceProfileID = (SELECT Price_Profile_ID FROM Inserted) 
				EXEC Check_Post_Mix_Pricing @PriceProfileID 
			END
		END	
	END
END
GO


print 'Creating TG_Price_Levels_Check_Post_Mix_Pricing'
go

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'TG_Price_Levels_Check_Post_Mix_Pricing' AND type = 'TR')
    	DROP TRIGGER TG_Price_Levels_Check_Post_Mix_Pricing
GO

CREATE TRIGGER TG_Price_Levels_Check_Post_Mix_Pricing ON Price_Levels
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @PostMixSetting AS smallint
	SET @PostMixSetting = (SELECT Auto_PostMix_Price FROM Global_Settings)
	IF (@PostMixSetting = 1)
	BEGIN
		DECLARE @GradeType AS int
		DECLARE @CheckPrices AS smallint

		SET @CheckPrices = 0 

		IF((SELECT Count(Price_Profile_ID) FROM Inserted) > 1 )
		BEGIN
			-- More then one item in the price_levels table has been updated at once
			-- Rather then putting logice to go through all the combinations
			-- just check all active price profiles.
			Exec Check_Post_Mix_Pricing
		END
		ELSE
		BEGIN 
			DECLARE @PriceProfileID AS int
			DECLARE @GradeID AS int

			SET @PriceProfileID = (SELECT Price_Profile_ID FROM Inserted)
			SET @GradeID = (SELECT Parent_Grade_ID FROM Price_Profile WHERE Price_Profile_ID = @PriceProfileID)
			SET @GradeType = (SELECT Grade_Type FROM Grades WHERE Grade_ID = @GradeID AND deleted = 0)

			-- Base grade only price update check
			IF (UPDATE(Grade_Price) AND @GradeType = 1 ) SET @CheckPrices = 1   
			
			-- Post-mix only price_ratio update check
			IF (UPDATE(Price_Ratio) AND ( @GradeType = 2 OR @GradeType = 3  ))SET @CheckPrices = 1 

			IF( @CheckPrices = 1)
			BEGIN
				DECLARE @PriceLevel AS int
	
				SET @PriceProfileID = (SELECT Price_Profile_ID FROM Inserted)
				SET @PriceLevel = (SELECT Price_Level FROM Inserted) 
				EXEC Check_Post_Mix_Pricing @PriceProfileID, @PriceLevel 
			END
		END	
	END
END
GO


-- Stored procs for addressing Spot #1263 (autoinsert hose/tank history records) are in DBU400.SQL
--------------------------------------------------------------------------------

print 'Removing SP_Update_Tank_Type_ID_Of_Tanks (now obsolete)'
go

IF EXISTS (SELECT name FROM SYSOBJECTS WHERE NAME = 'SP_Update_Tank_Type_ID_Of_Tanks' AND TYPE = 'P')
BEGIN
	DROP PROCEDURE SP_Update_Tank_Type_ID_Of_Tanks
END
GO


--Stored proc for automatically adding history records for new hoses/tanks. 


print 'Creating SP_Update_Tank_History'
go

IF EXISTS (SELECT null FROM SYSOBJECTS WHERE NAME = 'SP_Update_Tank_History' AND XTYPE = 'P')
BEGIN
	DROP PROCEDURE SP_Update_Tank_History
END
GO

CREATE PROCEDURE SP_Update_Tank_History
AS
BEGIN
	-- update closing tank dips. required by SIRA report
	UPDATE Tank_History SET close_dip_type_id=1 WHERE ISNULL(close_dip_type_id,0)=0 AND Period_ID in (SELECT Period_ID FROM Periods WHERE Period_Type=2)
END
GO



print 'Creating SP_Update_Global_Settings'
go

IF EXISTS (SELECT null FROM SYSOBJECTS WHERE NAME = 'SP_Update_Global_Settings' AND XTYPE = 'P')
BEGIN
	DROP PROCEDURE SP_Update_Global_Settings
END
GO

CREATE PROCEDURE SP_Update_Global_Settings
AS
DECLARE @dbversion int,
@reportformattype int
BEGIN
	SET @dbversion = (SELECT VERSION FROM DBVersion)
	-- running on pre-WSR database?
	IF @dbversion < 400
	BEGIN
		-- setup the new report type
		SET @reportformattype = ( SELECT TOP 1 Recon_Report_Format From Global_Settings )

		-- no global_settings yet? just return. populate will insert the default report type
		IF ISNULL(@reportformattype,-1)=-1
			RETURN

		IF @reportformattype = 0
		BEGIN
			PRINT 'Reconciliation Report type updated'
			UPDATE Global_Settings SET Recon_Report_Format = 2
		END
	END
END
GO


-- tweak the global settings and drop the Stored procedure
EXEC SP_Update_Global_Settings
print 'Removing SP_Update_Global_Settings'
DROP PROCEDURE SP_Update_Global_Settings
go


print 'Creating ADD_PROTOCOL'
go

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'add_protocol' AND type = 'P')
   drop procedure add_protocol
go

CREATE PROCEDURE ADD_PROTOCOL
	@RELEASED	  smallint,
	@PROT_TYPE        smallint,
	@PROT_NAME        CHAR(40),
	@PROT_ID          int,
	@DRIVER_CLASS     CHAR(40),
	@INTER_POLL_DELAY smallint,
	@POLL_TYPE        smallint,
	@LINE_CONTROL     tinyint,
	@BAUD_DIVISOR     smallint,
	@PROT_DESC        CHAR(80),
	@OUTBOARD_PROT    smallint
AS
DECLARE @already_added	  smallint
BEGIN
  -- If a protocol is set to 0 it is not yet released and should 
  -- not be installed on a site
  IF @RELEASED = 0
	RETURN

  BEGIN TRANSACTION 
  SET @PROT_NAME = LEFT(@PROT_NAME,30)
  SET @PROT_DESC = LEFT(@PROT_DESC,80)
  SET @DRIVER_CLASS = LTRIM(RTRIM(@DRIVER_CLASS))

  print 'Protocol: ' + RTRIM(cast( @PROT_ID as char )) + ' ' + @PROT_NAME

  IF ( SELECT count(Protocol_ID) FROM Pump_Protocol WHERE Protocol_ID = @PROT_ID  ) < 1
  BEGIN
	-- add new record
	print 'Adding new protocol'
     	INSERT INTO pump_protocol
		( protocol_id, Protocol_Name, Protocol_Desc, Driver_Class_ID )
		VALUES (@PROT_ID, @PROT_NAME, '', '' )
  END

  -- update the protocol type id
  IF ( SELECT count(Column_Name) From INFORMATION_SCHEMA.COLUMNS where column_name = 'Protocol_Type_ID' AND TABLE_NAME = 'Pump_Protocol' ) >= 1
  BEGIN
    IF ( @PROT_ID not in (11))
	BEGIN
	-- prevent parse error if field is not there
      DECLARE @ProtTypeSQL VARCHAR(256)
   	  SELECT @ProtTypeSQL = 'UPDATE Pump_Protocol SET Protocol_Type_id = ' + CONVERT(VARCHAR, @PROT_TYPE)+ ' WHERE Protocol_ID = ' + CONVERT(VARCHAR, @PROT_ID) 
      EXEC (@ProtTypeSQL)
	END
  END

  -- update the outboard protocol
  IF ( SELECT count(Column_Name) From INFORMATION_SCHEMA.COLUMNS where column_name = 'Outboard_Protocol' AND TABLE_NAME = 'Pump_Protocol' ) >= 1
  BEGIN
	-- prevent parse error if field is not there
	DECLARE @OutProtSQL VARCHAR(256)
	SELECT @OutProtSQL = 'UPDATE Pump_Protocol SET Outboard_Protocol = ' + CONVERT(VARCHAR, @OUTBOARD_PROT) + ' WHERE Protocol_ID = ' + CONVERT(VARCHAR, @PROT_ID)
	EXEC (@OutProtSQL)
  END

  -- Now update the main part of the record
  UPDATE pump_protocol 
  SET Protocol_Name    = @PROT_NAME, 
    Protocol_Desc      = @PROT_DESC, 
    Inter_Poll_Delay   = @INTER_POLL_DELAY, 
    Poll_Type          = @POLL_TYPE, 
    Line_Control       = @LINE_CONTROL, 
    Baud_Divisor_latch = @BAUD_DIVISOR
  WHERE protocol_id = @PROT_ID

  -- tank drivers only get a class id for enabler v3.50+
  IF @PROT_TYPE = 2
  BEGIN
    IF ( SELECT count(Column_Name) From INFORMATION_SCHEMA.COLUMNS where column_name = 'Tank_Gauge_id' AND TABLE_NAME = 'Tank_Gauge' ) >= 1
    BEGIN
      -- Enabler version 3.50+ so we need the driver class id for Tank Gauge protocols
      UPDATE pump_protocol SET
        Driver_Class_ID    = @DRIVER_CLASS
      WHERE protocol_id = @PROT_ID
    END
    ELSE
    BEGIN
      -- older Enabler versions use the Tank Gauge code in PSRVR
      UPDATE pump_protocol SET
        Driver_Class_ID    = ''
      WHERE protocol_id = @PROT_ID
    END
  END
  ELSE
  BEGIN
    UPDATE pump_protocol SET
      Driver_Class_ID    = @DRIVER_CLASS
    WHERE protocol_id = @PROT_ID
  END
  
  COMMIT TRANSACTION 
END
go

print 'Creating ADD_PUMP_TYPE'
go

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'ADD_PUMP_TYPE' AND type = 'P')
   drop procedure ADD_PUMP_TYPE
go

CREATE PROCEDURE ADD_PUMP_TYPE
	@Pump_Type_ID	  int,
	@Pump_Type_Name	  char(40),
	@Protocol_ID	  int,
	@Poll_Response_TO smallint,
	@Max_No_Responses smallint,
	@Inter_Char_TO	  smallint,
	@Polling_Rate	  smallint,
	@Has_Lights	  smallint,
	@Has_Preset       smallint,
	@Max_Price_Levels smallint,
	@Max_Hoses	  smallint,
	@Is_a_blender	  smallint = 0.0,
	@Running_Total_PR smallint = 0.0,
	@Default_Display_Type int = 0.0,
	@Multiplier_Support smallint = 0,
	@Supports_Tag_Reader smallint = 0
AS

DECLARE @Single_Hose_Auth smallint

BEGIN

  -- Dont try to add a pump type for a Protocol_Id that may not have been released 
  -- or had a problem being installed
  IF ( SELECT count(Protocol_ID) FROM Pump_Protocol WHERE Protocol_ID = @Protocol_ID  ) < 1
	RETURN

  BEGIN TRANSACTION 

  SET @Pump_Type_Name = LEFT(@Pump_Type_Name,30)

  PRINT 'Pump Type: ' + RTRIM(cast( @Pump_Type_ID as char )) + ' ' + @Pump_Type_Name

  IF ( SELECT count(Pump_Type_ID) FROM Pump_Type WHERE Pump_Type_ID = @Pump_Type_ID  ) < 1
  BEGIN
	-- add new record
	print 'Adding new record for pump type ' + RTRIM(cast( @Pump_Type_ID as char ))
        INSERT INTO pump_type 
	       ( pump_type_id, pump_type_name, protocol_id, pump_type_desc, inter_char_timeout, value_format, volume_format, price_format )
        VALUES
               ( @Pump_Type_ID, '', 11, NULL, 0, '', '', '' )
  END

  -- First we update mandatory fields which have been in the database forever

  UPDATE Pump_Type
     SET Pump_Type_Name     = @Pump_Type_Name,
	 Protocol_ID        = @Protocol_ID,
	 Poll_Response_TO   = @Poll_Response_TO,
	 Max_No_Responses   = @Max_No_Responses,
	 Inter_Char_Timeout = @Inter_Char_TO,
	 Polling_Rate       = @Polling_Rate,
	 Has_Lights         = @Has_Lights,
	 Has_Preset         = @Has_Preset,
	 Max_Price_Levels   = @Max_Price_Levels,
	 Max_Hoses          = @Max_Hoses
   WHERE Pump_Type_ID       = @Pump_Type_ID

  -- Next we update optional fields which have been recently added (may not be present)

  -- update the is a blender field
  IF ( SELECT count(Column_Name) From INFORMATION_SCHEMA.COLUMNS where column_name = 'Is_A_Blender' AND TABLE_NAME = 'Pump_Type' ) >= 1
  BEGIN
      -- prevent parse error if field is not there
      DECLARE @IsBlenderSQL VARCHAR(256)
      SELECT @IsBlenderSQL = 'UPDATE Pump_Type SET Is_A_Blender = ' + CONVERT(VARCHAR, @Is_A_Blender)+ ' WHERE Pump_Type_ID = ' + CONVERT(VARCHAR, @Pump_Type_ID) 
      EXEC (@IsBlenderSQL)
  END

  -- update the running total poll rate field
  IF ( SELECT count(Column_Name) From INFORMATION_SCHEMA.COLUMNS where column_name = 'Running_Total_PR' AND TABLE_NAME = 'Pump_Type' ) >= 1
  BEGIN
      -- prevent parse error if field is not there
      DECLARE @RTRateSQL VARCHAR(256)
      SELECT @RTRateSQL = 'UPDATE Pump_Type SET Running_Total_PR = ' + CONVERT(VARCHAR, @Running_Total_PR)+ ' WHERE Pump_Type_ID = ' + CONVERT(VARCHAR, @Pump_Type_ID) 
      EXEC (@RTRateSQL)
  END

  -- update the default display type field
  IF ( SELECT count(Column_Name) From INFORMATION_SCHEMA.COLUMNS where column_name = 'Default_Display_Type' AND TABLE_NAME = 'Pump_Type' ) >= 1
  BEGIN
      -- prevent parse error if field is not there
      DECLARE @DefaultSQL VARCHAR(256)
      SELECT @DefaultSQL = 'UPDATE Pump_Type SET Default_Display_Type = ' + CONVERT(VARCHAR, @Default_Display_Type)+ ' WHERE Pump_Type_ID = ' + CONVERT(VARCHAR, @Pump_Type_ID) 
      EXEC (@DefaultSQL)
  END

  -- update the single hose auth field
  IF ( SELECT count(Column_Name) From INFORMATION_SCHEMA.COLUMNS where column_name = 'Single_Hose_Auth' AND TABLE_NAME = 'Pump_Type' ) >= 1
  BEGIN
      -- prevent parse error if field is not there
      DECLARE @SingleSQL VARCHAR(256)
      SELECT @SingleSQL = 'UPDATE Pump_Type SET Single_Hose_Auth = ' + CONVERT(VARCHAR, @Single_Hose_Auth)+ ' WHERE Pump_Type_ID = ' + CONVERT(VARCHAR, @Pump_Type_ID) 
      EXEC (@SingleSQL)
  END

  -- update the multiplier support field
  IF ( SELECT count(Column_Name) From INFORMATION_SCHEMA.COLUMNS where column_name = 'Multiplier_Support' AND TABLE_NAME = 'Pump_Type' ) >= 1
  BEGIN
      -- prevent parse error if field is not there
      DECLARE @MultiplierSQL VARCHAR(256)
      SELECT @MultiplierSQL = 'UPDATE Pump_Type SET Multiplier_Support = ' + CONVERT(VARCHAR, @Multiplier_Support)+ ' WHERE Pump_Type_ID = ' + CONVERT(VARCHAR, @Pump_Type_ID) 
      EXEC (@MultiplierSQL)
  END
  
  -- update the tagging support field
  IF ( SELECT count(Column_Name) From INFORMATION_SCHEMA.COLUMNS where column_name = 'Supports_Tag_Reader' AND TABLE_NAME = 'Pump_Type' ) >= 1
  BEGIN
      -- prevent parse error if field is not there
      DECLARE @TaggingSupportSQL VARCHAR(256)
      SELECT @TaggingSupportSQL = 'UPDATE Pump_Type SET Supports_Tag_Reader = ' + CONVERT(VARCHAR, @Supports_Tag_Reader)+ ' WHERE Pump_Type_ID = ' + CONVERT(VARCHAR, @Pump_Type_ID) 
      EXEC (@TaggingSupportSQL)
  END

  COMMIT TRANSACTION 
END
go


PRINT 'Creating Get_Max_Value'
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Get_Max_Value' AND type = 'P')
   DROP PROCEDURE Get_Max_Value
go


-- ##SUMMARY <p>The Get_Max_Value procedure provides a parameterised way to get the maximum value in a table column.</p>
--
-- ##REMARKS <p>Useful if you want to determine the maximum value in a table.</p>
CREATE PROCEDURE Get_Max_Value
    @TableName		varchar(100), -- ##PARAM @TableName The name of the table to search.
    @FieldName		varchar(100)  -- ##PARAM @FieldName The name of the column (field) to search.
                                  -- ##PARAM @RETURN_VALUE None.

AS
BEGIN
	DECLARE @dynsql NVARCHAR(200)
	SET @dynsql = 'SELECT  ISNULL(MAX(ISNULL([' + @FieldName + '],0)),0) FROM [' + @TableName + '] '
	EXEC sp_executesql @dynsql 
END 
GO


IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Price_Level_Type_Trigger' AND type = 'TR')
	DROP TRIGGER Price_Level_Type_Trigger
GO

-- ##SUMMARY <p>The Price_Level_Type_Trigger procedure ensures grade price_profiles have prices for all price_levels setup in the database.</p>
--
-- ##REMARKS <p>This Trigger is executed whenever rows are inserted into the Price_Level_Type table (which defines the grade 'price levels' which can be used for pump pricing and authorisation).</p>
--
CREATE TRIGGER  Price_Level_Type_Trigger ON Price_Level_Types
-- ##PARAM @RETURN_VALUE None.
FOR INSERT
AS
BEGIN
	/* check that Price_Profiles have rows for all price levels (including this new one) */
	EXEC Enforce_Price_Levels -1, -1
END
GO


PRINT 'Creating Add_Price_Level_Type'
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Add_Price_Level_Type' AND type = 'P')
   DROP PROCEDURE Add_Price_Level_Type
go

-- ##SUMMARY <p>The Add_Price_Level_Type procedure adds grade price level types to the database.</p>
--
-- ##REMARKS <p>This procedure is provided to simplify the process of adding price level types. </p>
-- ##REMARKS <p>When called this routine will either inserts a new row OR update any existing row 
-- ##REMARKS (matched based on Price_Level parameter).</p>
--
CREATE PROCEDURE Add_Price_Level_Type
    @PriceLevel             int,         -- ##PARAM @PriceLevel            Primary key for the price level row
    @PriceLevelName         nchar(30),   -- ##PARAM @PriceLevelName        Logical name for the price level. e.g. Cash
    @PriceLevelDescription  nvarchar(80) -- ##PARAM @PriceLevelDescription Description of the price level
                                         -- ##PARAM @RETURN_VALUE None.
AS
BEGIN
	IF NOT EXISTS ( SELECT * from Price_Level_Types WHERE Price_Level = @PriceLevel )
	BEGIN
		print 'Adding new price level record'
		INSERT INTO Price_Level_Types ( Price_Level, Level_Name, Level_Description ) 
		VALUES ( @PriceLevel, @PriceLevelName, @PriceLevelDescription )
		/* this will fire the trigger on the table which calls Enforce_Price_Levels */
	END
	ELSE
	BEGIN
		print 'Updating existing price level record'
		UPDATE Price_Level_Types
		   SET Level_Name        = @PriceLevelName,
		       Level_Description = @PriceLevelDescription
		 WHERE Price_Level       = @PriceLevel
	END
END 
GO


-- This store procedure will be called in multiple places: sp_log_delivery_ex, sp_update_delivery,and sp-reinstate_delivery
-- Creating Update Attendant Period History EP-2475
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'sp_att_update_amount' AND type ='P')
	DROP PROCEDURE sp_att_update_amount
GO

print 'Creating sp_att_update_amount'
GO

CREATE PROCEDURE sp_att_update_amount
	@result int OUTPUT, 
	@attendant_id int,
	@value decimal(15,4),
	@volume decimal(15,4),
	@paymenttypeid int,
	@cashPaymentType int,
	@orientation int
AS
	DECLARE @att_period_id int,
	@rowCount int,
	@valueAmount decimal(15,4),
	@volumeAmount decimal(15,4)
BEGIN
	
	BEGIN TRANSACTION

	SELECT @att_period_id = ( SELECT att_period_id FROM Attendant_Period 
	WHERE Attendant_ID = @attendant_id 
	AND Att_Period_State <= 2.0 )

	IF @att_period_id is NULL
	BEGIN
		SELECT @result = -1
		ROLLBACK TRANSACTION
		RETURN
	END

	IF @paymenttypeid > 10
	BEGIN
		SELECT @result = -2
		ROLLBACK TRANSACTION
		RETURN 
	END

	-- find the correct payment type data
	-- MAKE SURE THE PAYMENT TYPE EXISTS
	
	SELECT @rowCount = ( SELECT COUNT(*) FROM Attendant_Period_History 
	WHERE Payment_Type_ID = @paymenttypeid AND Att_Period_ID = @att_period_id)

	IF @rowCount = 0 
	BEGIN 
		-- ADD THE MISSING PAYMENT TYPE 
		INSERT INTO Attendant_Period_History (Att_Period_ID, Payment_Type_ID) 
		VALUES (@att_period_id, @paymenttypeid)
	END

	-- UPDATE THE RECORD

	SET @valueAmount = 0
	SET @volumeAmount = 0
	
	SELECT @valueAmount = Att_Value_Total, @volumeAmount = Att_Volume_Total
	FROM Attendant_Period_History 
	WHERE  Payment_Type_ID = @paymenttypeid AND Att_Period_ID = @att_period_id 

	SET @valueAmount = @valueAmount + (@orientation * @value)
	SET @volumeAmount = @volumeAmount + (@orientation * @volume)
	
	--UPDATE Attendant_Period_History SET 
	IF @cashPaymentType IS NULL
		BEGIN
			UPDATE Attendant_Period_History SET Att_Value_Total = @valueAmount, 
			Att_Volume_Total = @volumeAmount  
			WHERE Payment_Type_ID = @paymenttypeid AND Att_Period_ID = @att_period_id
		END
	ELSE
		BEGIN
			UPDATE Attendant_Period_History SET Att_Value_Total = @valueAmount, 
			Att_Volume_Total = @volumeAmount, Cash_Payment_Type = @cashPaymentType 
			WHERE Payment_Type_ID = @paymenttypeid AND Att_Period_ID = @att_period_id
		END

	SELECT @result = 1

	COMMIT TRANSACTION
	
END
GO

-- This store procedure is used to migrate V3 deliveries to V4
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Create_Transaction_From_Delivery' AND type ='P')
	DROP PROCEDURE Create_Transaction_From_Delivery
GO

print 'Creating Create_Transaction_From_Delivery'
GO

CREATE PROCEDURE Create_Transaction_From_Delivery
	@delivery_ID  int,
	@reference    NCHAR(32)
AS
BEGIN
	DECLARE @TransID as int

	-- Create a Transaction fo a specific delivery ID
	-- If Transaction alrady exist with delivery ID it will do nothing
	-- Call passing delivery_ID and a Client Reference for Transaction 

	if ( SELECT Count(Delivery_ID) from Fuel_Transaction WHERE @delivery_ID = Delivery_ID  ) < 1
	BEGIN
		SET @TransID = (SELECT MAX(Transaction_ID) + 1 FROM Fuel_Transaction)
		if  (@TransID is NULL ) SET @TransID = 1

		INSERT INTO Fuel_Transaction (Transaction_ID, Delivery_ID, Attendant_ID, State,  Created_DateTime, Pump_ID, Authorisation_Reason, Completion_Reason, Client_Reference)
		SELECT   @TransID, Delivery_ID, Attendant_ID, 7, Cleared_Date_Time, h.Pump_ID, 1, 3, @reference
		FROM    Hose_Delivery as hd 
		LEFT JOIN Hoses AS h ON hd.Hose_ID = h.Hose_ID
		WHERE  delivery_ID = @delivery_ID
	END
	ELSE
		PRINT 'Transaction already exists with delivery_id:' + RTRIM(cast(  @delivery_ID as char ))

END
GO

----------------------------------------------------------------------------------------------------------------------

-- This store procedure is used to migrate V3 deliveries to V4
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'Create_Transactions_From_Deliveries' AND type ='P')
	DROP PROCEDURE Create_Transactions_From_Deliveries
GO

print 'Creating Create_Transactions_From_Deliveries'
GO

CREATE PROCEDURE Create_Transactions_From_Deliveries
	@reference    NCHAR(32)
As
BEGIN
	DECLARE @Delivery_ID as int

	-- Create a transaction for all deliveries without a transaction
	-- Used when upgrading from V3 to V4
	-- Call passing the transaction client Reference, i.e 'V3 Migration'

	DECLARE deliveries_cursor CURSOR FAST_FORWARD FOR 
			SELECT hd.Delivery_ID
			FROM Hose_Delivery AS hd 
			LEFT OUTER JOIN Fuel_Transaction AS ft ON ft.Delivery_ID = hd.Delivery_ID
			WHERE   (ft.Delivery_ID IS NULL)

	OPEN deliveries_cursor
	FETCH NEXT FROM deliveries_cursor INTO @Delivery_ID
	WHILE @@Fetch_status = 0
	BEGIN
		EXEC Create_Transaction_From_Delivery @Delivery_ID, @reference
		FETCH NEXT FROM deliveries_cursor INTO @Delivery_ID
	END
	DEALLOCATE deliveries_cursor

END
GO


-- set Enabler DB version
update DBVersion SET Version = 501
go

print CONVERT(varchar,getdate(), 121)
print 'Load completed'
go


