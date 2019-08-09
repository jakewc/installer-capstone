function dateZoneOnload() {
    NtpSyncChange();

    document.getElementById("NtpSyncCheck").onchange = NtpSyncChange;
}

function NtpSyncChange() {
    var checked = document.getElementById("NtpSyncCheck").checked;
    var TimeZoneTable = document.getElementById("TIMEZONE_TABLE"); 

    if(checked) {
        TimeZoneTable.rows[2].style.display = '';
        TimeZoneTable.rows[3].style.display = '';
    }
    else {
        TimeZoneTable.rows[2].style.display = 'none';
        TimeZoneTable.rows[3].style.display = 'none';
    }
}
