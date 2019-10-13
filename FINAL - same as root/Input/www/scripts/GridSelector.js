

// Assign Events to a grid
function EN_AssignTableEvents( GridName, selectedRow, JsonData ) {
    var table, r, c, row, cell;
    table = document.getElementById(GridName);

    $("#" + GridName).data(JsonData);
    
    if (table && table.rows) {
        for (r = 0; r < table.rows.length; r++) {
            row = table.rows[r];
            row.onmouseover = EN_GridOnMouseOver;
            row.onmouseout = EN_GridOnMouseOut;
            for (c = 0; c < row.cells.length; c++) {
                cell = row.cells[c];
                cell.onclick = EN_GridOnClick;
            }
        }
    }

    if (selectedRow > 0 && selectedRow < table.rows.length) {
        EN_GridOnClickSelect($("#" + GridName)[0], JsonData, selectedRow);
    }
}

function EN_GridOnMouseOver(e) {

    var table = EN_GetTable(e);
    if (table) {
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
}

function EN_GridOnMouseOut(e) {
    var table = EN_GetTable(e);
    if (table) {
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
}

function EN_GridOnClickSelect(table, contextData, rowIndex) {

    if (table && table.rows) {
        for (r = 1; r < table.rows.length; r++) {
            if (r == rowIndex) {
                table.rows[r].className = 'selectedRow';

                // Save index
                $("#" + table.id + "_index")[0].value = rowIndex.toString();
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


        var rowActions = contextData.RowActions[rowIndex - 1];
        var buttonList = contextData.ButtonList;

        // For each button in list
        for (i = 0; i < buttonList.length; i++) {
            var element = document.getElementById(buttonList[i]);
            if (element) {
                // Look up button value in rowActions to see if one present
                var action = rowActions[element.value];
                if (action ) {
                    element.disabled = false;
                    // Add link to button
                    element.name = action;  // value to post
                }
                else {
                    element.disabled = true;
                }
             }
        }
        
    }
}

function EN_GetRow(e) {
    var targ;
    if (!e)
        e = window.event;
    if (e.target)
        targ = e.target;
    else if (e.srcElement)
        targ = e.srcElement;
    if (targ.nodeType == 3)
        targ = targ.parentNode;
    return targ;
}

function EN_GetTable(e) {
    var targ = EN_GetRow(e);
    var Table = targ.parentNode.parentNode.parentNode;
    if (Table.tagName == 'TABLE') {
        return Table;
    }
}

function EN_GridOnClick(e) {
    var targ = EN_GetRow(e);
    var rowIndex = targ.parentNode.rowIndex;  
    if (rowIndex) {
        var Table = targ.parentNode.parentNode.parentNode;
        if ( Table ) {
            if (Table.tagName == 'TABLE') {
                var contextData = $("#" + Table.id).data();
                EN_GridOnClickSelect(Table, contextData, rowIndex);
            }
        }
    }
}

