var selectedRow = 0;
var oldClassName = "";

function FuelReconOnloadEvent() {
    if (document.getElementById) {
        AssignTableEvents();
    }
}

function AssignTableEvents() {
    var table, r, c, row, cell;
    table = document.getElementById("Tanks_Grid");
    if(table && table.rows) {
        for(r = 0; r < table.rows.length; r++) {
            row = table.rows[r];
            // Hide the radio button
            row.cells[0].style.display = 'none';
            row.onmouseover = TROnMouseOver;
            row.onmouseout = TROnMouseOut;
            for (c = 1; c < row.cells.length; c++) {
                cell = row.cells[c];
                cell.onclick = TROnClick;
            }
        }
    }
}

function TROnMouseOver() {
    var table = document.getElementById("Tanks_Grid");
    if(table.rows[this.sectionRowIndex].className == 'evenRow') {
        table.rows[this.sectionRowIndex].className = 'hoverevenRow';
    }
    else if(table.rows[this.sectionRowIndex].className == 'oddRow') {
        table.rows[this.sectionRowIndex].className = 'hoveroddRow';
    }
    else if(table.rows[this.sectionRowIndex].className == 'selectedRow') {
        table.rows[this.sectionRowIndex].className = 'hoverselectedRow';
    }
}

function TROnMouseOut() {
    var table = document.getElementById("Tanks_Grid");
    if (table.rows[this.sectionRowIndex].className == 'hoverevenRow') {
        table.rows[this.sectionRowIndex].className = 'evenRow';
    }
    else if (table.rows[this.sectionRowIndex].className == 'hoveroddRow') {
        table.rows[this.sectionRowIndex].className = 'oddRow';
    }
    else if (table.rows[this.sectionRowIndex].className == 'hoverselectedRow') {
        table.rows[this.sectionRowIndex].className = 'selectedRow';
    }
}

function TROnClick(e) {
    var targ;
    if (!e)
        e = window.event;
    if (e.target)
        targ = e.target;
    else if (e.srcElement)
        targ = e.srcElement;
    if (targ.nodeType == 3)
        targ = targ.parentNode;

    targ.parentNode.cells[0].children[0].checked = true;

    var table = document.getElementById("Tanks_Grid");
    targ.parentNode.className = 'hoverselectedRow';

    for (r = 0; r < table.rows.length; r++) {
        if (r != targ.parentNode.rowIndex) {
            if (r % 2 > 0) {
                table.rows[r].className = 'evenRow';
            }
            else {
                table.rows[r].className = 'oddRow';
            }
        }
    }
}