function siteModesEditOnLoad() {
    if (document.getElementById) {
        document.getElementById("Pump_Stacking").onchange = StackingChanged;
        document.getElementById("Pump_Auto_Stacking").onchange = AutoStackChanged;
        document.getElementById("Fallback_allow").onchange = FallbackChanged;
        document.getElementById("Fallback_automatic").onchange = FallbackChanged;
        document.getElementById("Allow_Postpay").onchange = PostPayChanged;
        document.getElementById("Auto_Authorise").onchange = AutoAuthoriseChanged;
        FallbackChanged();
        StackingChanged();
        AutoStackChanged();
        PostPayChanged();
        AutoAuthoriseChanged();
    }
}

function FallbackChanged() {
    var fallback = document.getElementById("Fallback_allow");
    var autoFallback = document.getElementById("Fallback_automatic");
    // If the fallback is off then hide the auto fallback and set it to the same value
    if (fallback.selectedIndex == 0) {
        autoFallback.selectedIndex = 0;
        document.getElementById("Options").rows[6].style.display = 'none';
    }
    else {
        document.getElementById("Options").rows[6].style.display = '';
    }
    // for this to be 1 the fallback must be 1
    if (autoFallback.selectedIndex == 1) {
        fallback.selectedIndex = 1;
    }
}

function StackingChanged() {
    var stacking = document.getElementById("Pump_Stacking");
    var autoStacking = document.getElementById("Pump_Auto_Stacking");
    if (stacking.selectedIndex == 0) {
        autoStacking.selectedIndex = 0;
        document.getElementById("Options").rows[3].style.display = 'none';
        document.getElementById("Options").rows[2].style.display = 'none'; // stack size
    }
    else if (stacking.selectedIndex == 2) // pump profile -> use site mode. EP-1423
    {
        document.getElementById("Options").rows[3].style.display = 'none'; // Auto Stacking. EP-1455
        document.getElementById("Options").rows[2].style.display = 'none'; // stack size
        autoStacking.selectedIndex = 2;                                    // force Auto Stack to Use Site Mode
    }
    else
    {
        document.getElementById("Options").rows[3].style.display = '';
        document.getElementById("Options").rows[2].style.display = ''; // stack size
    }
}

function AutoStackChanged() {
    var stacking = document.getElementById("Pump_Stacking");
    var autoStacking = document.getElementById("Pump_Auto_Stacking");
    if (autoStacking.selectedIndex == 1) {
        stacking.selectedIndex = 1;
        document.getElementById("Options").rows[2].style.display = '';
    }
}

function PostPayChanged() {
    var postPay = document.getElementById("Allow_Postpay");
    var autoAuth = document.getElementById("Auto_Authorise");
    if (postPay.selectedIndex == 0) {
        autoAuth.selectedIndex = 0;
    }

}

function AutoAuthoriseChanged() {
    var postPay = document.getElementById("Allow_Postpay");
    var autoAuth = document.getElementById("Auto_Authorise");
    if (autoAuth.selectedIndex == 1) {
        postPay.selectedIndex = 1;
    }
}


var pageURL = "";
var action = "";
var session = "";

function setPageURL(url) {
    pageURL = url;
}

function setAction(act) {
    action = act;
}

function setSession(sess) {
    session = sess;
}

function siteModesListOnLoad() {
    if (document.getElementById) {
        AssignTableEvents();
    }
}

function AssignTableEvents() {
    var table, r, c, row, cell;
    table = document.getElementById("SiteModeGrid");
    if (table && table.rows) {
        for (r = 0; r < table.rows.length; r++) {
            row = table.rows[r];
            row.cells[0].style.display = 'none';
            row.onmouseover = TROnMouseOver;
            row.onmouseout = TROnMouseOut;
            for (c = 1; c < row.cells.length - 2; c++) {
                cell = row.cells[c];
                cell.onclick = TROnClick;
            }
        }
    }
}

function TROnMouseOver() {
    var table = document.getElementById("SiteModeGrid");
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

function TROnMouseOut() {
    var table = document.getElementById("SiteModeGrid");
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
    var ID = targ.parentNode.cells[0].innerHTML;
    if (ID) {
        document.location.href = pageURL + action + ID + session;
    }
}