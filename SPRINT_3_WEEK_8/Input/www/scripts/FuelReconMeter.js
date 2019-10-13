function FuelReconMeterGridChange() 
{
    var thisTable = document.getElementById("PumpMetersGrid");
    for (r = 0; r < thisTable.rows.length; ++r) {
        // The Header row or the selected row?
        if ( r == 0 ||
		thisTable.rows[r].cells[0].childNodes[0].data == document.FuelReconMetersGrid.Pump_List.value) 
	{
		    // Display this row
            thisTable.rows[r].style.display = '';

            // Hide the Pump_ID and PUmp_Name
            thisTable.rows[r].cells[0].style.display = 'none';
            thisTable.rows[r].cells[1].style.display = 'none';
            thisTable.rows[r].cells[2].style.display = '';
            thisTable.rows[r].cells[3].style.display = '';
	    thisTable.rows[r].cells[4].style.display = '';
            thisTable.rows[r].cells[5].style.display = '';
            thisTable.rows[r].cells[6].style.display = '';

	    continue;
        } // end of selected row

        // Hide the other rows
        thisTable.rows[r].style.display = 'none';
    }
};

function FuelReconMeterOnLoad() {
    if (document.getElementById) {
        document.getElementById("Pump_List").onchange = FuelReconMeterGridChange;
        FuelReconMeterGridChange();
        //FuelReconMeterGridChange();
    }
};
