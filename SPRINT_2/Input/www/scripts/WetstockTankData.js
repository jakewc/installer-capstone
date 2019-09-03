// Spot #12520 added a deskTop judgement to correct Embedded WetStock display

function WetstockTableChange() 
{
    var thisTable = document.getElementById("Tanks_Grid");
    switch (document.WetstockTankDataForm.Wetstock_Data_Filter.selectedIndex) {
    // Basic View
        case 0:
            for (var r = 0; r < thisTable.rows.length; r++) {
                for (var j = 0; j < thisTable.rows[r].cells.length; j++) {
                    if (j > 4) {
                        thisTable.rows[r].cells[j].style.display = 'none';
                    }
                    else {
                        thisTable.rows[r].cells[j].style.display = '';
                    }              
                }
            }

            break;

    // Gauge View
        case 1:
            for (var r = 0; r < thisTable.rows.length; r++) {
                for (var j = 0; j < thisTable.rows[r].cells.length; j++) {
                    if (j > 1 && j < 5) {
                        thisTable.rows[r].cells[j].style.display = 'none';
                    }
                    else {
                        thisTable.rows[r].cells[j].style.display = '';
                    }
                }
            }
            break;

    // All fields
        case 2:
            for (var r = 0; r < thisTable.rows.length; r++) {
                for (var j = 0; j < thisTable.rows[r].cells.length; j++) {
                    thisTable.rows[r].cells[j].style.display = '';
                }
            }   
            break;
        default:
                alert("Invalid option");
        }
};	

function WetstockTableOnLoad() {
	if (document.getElementById)
    {
        document.getElementById("Wetstock_Data_Filter").onchange = WetstockTableChange;
	    WetstockTableChange();
    }
};
 
	
	
