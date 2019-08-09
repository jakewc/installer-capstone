function eventsOnLoad() {
    var eventJournalTable = document.getElementById("EventJournalTable");

    // overriding whiteSpace property from 'std_table' css, for the description cell to wrap normally (overflowing previously)
    for (i = 0; i < eventJournalTable.rows.length; i++)
        eventJournalTable.rows[i].cells[3].style.whiteSpace = 'normal';

    eventJournalTable.style.tableLayout = 'fixed';
     
    document.getElementById("datefilter").onclick = FilterCheck;
    document.getElementsByName("DeviceType")[0].onchange = SetEventFilterRows;
    SetEventFilterRows();
}             
                              

function SetEventFilterRows()
{
    var EventFilterTable = document.getElementById("EventFilterTable");
    var selectedIndex = document.getElementById("DeviceType").selectedIndex;
    // hide all device specific rows (excluding DeviceTYpe and the Date/Apply Filter Button)
    for (r = 3; r < EventFilterTable.rows.length; ++r) {
        if ( (selectedIndex > 0 ) && ( r == selectedIndex+2 ) )
        {
            EventFilterTable.rows[selectedIndex+2].style.display = '';
        }
        else
        {
            EventFilterTable.rows[r].style.display = 'none';
        }
    }
    // now depending on device selected, turn on the RoW we need

    FilterCheck();
}

function FilterCheck() {
    var checked = document.getElementById("datefilter").checked;
    var EventFilterTable = document.getElementById("EventFilterTable");    
    if(checked)
    {
        EventFilterTable.rows[2].style.display = '';	
    }
    else
    {
	EventFilterTable.rows[2].style.display = 'none';
    }
}


