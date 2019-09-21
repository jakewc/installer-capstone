function WetstockTableChange() 
{
    var thisTable = document.getElementById("Pumps_Grid");
    for (r = 0; r < thisTable.rows.length; ++r) {
        // The Header row or the selected row?
        if ( r == 0 ||
			thisTable.rows[r].cells[0].childNodes[0].data == document.WetstockPumpDataForm.Pump_List.value) {
		    // Display this row
            thisTable.rows[r].style.display = '';

            // Hide the Pump_ID
            thisTable.rows[r].cells[0].style.display = 'none';
            // Display the Hose_Number, Grade_Name
            thisTable.rows[r].cells[1].style.display = '';
            thisTable.rows[r].cells[2].style.display = '';
            // Basic view
            if (document.WetstockPumpDataForm.Wetstock_Data_Filter.selectedIndex == 0) {
                // Turnover correction fields are disabled
                thisTable.rows[r].cells[6].style.display = 'none';
                thisTable.rows[r].cells[7].style.display = 'none';
            }
            else {
                thisTable.rows[r].cells[6].style.display = '';
                thisTable.rows[r].cells[7].style.display = '';
            }

            // Turnover correction view
            if (document.WetstockPumpDataForm.Wetstock_Data_Filter.selectedIndex == 1) {
                // Volume, Money, Mechanical are disabled
                thisTable.rows[r].cells[3].style.display = 'none';
                thisTable.rows[r].cells[4].style.display = 'none';
                thisTable.rows[r].cells[5].style.display = 'none';
            }
            else {
                thisTable.rows[r].cells[3].style.display = '';
                thisTable.rows[r].cells[4].style.display = '';
                thisTable.rows[r].cells[5].style.display = '';
            }

			thisTable.rows[r].cells[8].style.display = '';

			// move to next row
			continue;
        } // end of selected row

        // Hide the other rows
        thisTable.rows[r].style.display = 'none';
    }
};

function WetstockTableOnLoad() {
    if (document.getElementById) {
        document.getElementById("Wetstock_Data_Filter").onchange = WetstockTableChange;
        document.getElementById("Pump_List").onchange = WetstockTableChange;
        WetstockTableChange();
        //WetstockTableChange();
    }
};
