function FuelTransOnLoad() {
    document.getElementById("MoreFilter").onclick = MoreFilterCheck;

    MoreFilterCheck();
}             

/* Display/Hide more Report Filters */
function MoreFilterCheck() {
    var checked = document.getElementById("MoreFilter").checked;
    var FuelTransFilterTable = document.getElementById("ReportFilter");    
    if(checked)
    {
        FuelTransFilterTable.rows[2].style.display = '';	
        FuelTransFilterTable.rows[3].style.display = '';	
    }
    else
    {
	FuelTransFilterTable.rows[2].style.display = 'none';	
	FuelTransFilterTable.rows[3].style.display = 'none';
    }
}
