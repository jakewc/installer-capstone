function TagContListOnLoad() {
    if (document.getElementById) {
        AssignTableEvents();
    }
}

function AssignTableEvents() {
    var table, r, c, row, cell;
    table = document.getElementById("TagControllers_list");
    if (table && table.rows) {
        for (r = 0; r < table.rows.length; r++) {
            row = table.rows[r];
            row.onmouseover = TagReaderOnMouseOver;
            row.onmouseout = TagReaderOnMouseOut;
            for (c = 0; c < row.cells.length - 1; c++) {
                cell = row.cells[c];
                cell.onclick = TagReaderOnClick;
            }

            if (row.className == 'selectedRow') {
                TagReaderSelect(r);
            }
        }
    }
}

function TagReaderSelect(selectRdr) {
    var index, RdrDiv;

    for (index = 1; index < 10; index++) {
        RdrDiv = document.getElementById("Div_Rdr_" + index);
        if (RdrDiv == null) break;
        if (index == selectRdr) {
            RdrDiv.style.display = '';
        }
        else {
            RdrDiv.style.display = 'none';
        }
    }
}

function TagReaderOnMouseOver() {
    var table = document.getElementById("TagControllers_list");
    if (table.rows[this.sectionRowIndex].className == 'evenRow') {
        table.rows[this.sectionRowIndex].className = 'hoverevenRow';
    }
    else if (table.rows[this.sectionRowIndex].className == 'oddRow') {
        table.rows[this.sectionRowIndex].className = 'hoveroddRow';
    }
    else if (table.rows[this.sectionRowIndex].className == 'selectedRow') {
        table.rows[this.sectionRowIndex].className = 'hoverselectedRow';
    }
}

function TagReaderOnMouseOut() {
    var table = document.getElementById("TagControllers_list");
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


function TagReaderOnClickSelect(ID) {
    var table = document.getElementById("TagControllers_list");

    if (table && table.rows) {
        for (r = 1; r < table.rows.length; r++) {
            if (r == ID) {
                table.rows[r].className = 'selectedRow';
            }
            else {
                if (r % 2 == 0) {
                    table.rows[r].className = 'oddRow';
                }
                else {
                    table.rows[r].className = 'evenRow';
                }
            }
        }
    }
}

function TagReaderOnClick(e) {
    var targ;
    if (!e)
        e = window.event;
    if (e.target)
        targ = e.target;
    else if (e.srcElement)
        targ = e.srcElement;
    if (targ.nodeType == 3)
        targ = targ.parentNode;
    var ID = targ.parentNode.rowIndex;  // .cells[0].innerHTML;
    if (ID) {

        TagReaderSelect(ID);
        TagReaderOnClickSelect(ID);
    }
}