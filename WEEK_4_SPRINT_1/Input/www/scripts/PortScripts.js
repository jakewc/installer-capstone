function portsOnload() {
    var extendedPortsTable = document.getElementById("Extended_Ports");
    //document.forms[0].children[2].children[0].children[0].children[0].children[0].id
    //.children[0].children[1].cells[2].children[0].name
    //.children[0].rows
    for (index = 1; index < extendedPortsTable.rows.length; index++) {
        var tableRow = extendedPortsTable.rows[index];
        tableRow.cells[1].children[0].onchange = ProtocolChanged;
    }
}

function ProtocolChanged(e) {
    var extendedPortsTable = document.getElementById("Extended_Ports");
    var targ;
    if (!e)
        e = window.event;
    if (e.target)
        targ = e.target;
    else if (e.srcElement)
        targ = e.srcElement;
    if (targ.nodeType == 3)
        targ = targ.parentNode;

    var settings = protocolSettings[targ.options[targ.selectedIndex].value];
    if (settings == undefined) {
        settings = "";
    }
    extendedPortsTable.rows[targ.parentNode.parentNode.sectionRowIndex].cells[3].children[0].value = settings;
}