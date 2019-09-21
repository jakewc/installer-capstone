var timer;

$(document).ready(function() {
    GetUpdate(true);
    HighlightSelectedPump(); 
});

function GetUpdate(firstTime) {
    delay = 1000;
	// Need TabID to identify multiple open SiteMonitor pages. Each requires a separate server cache.
	var tabID = sessionStorage.tabID;
    param = "?tabID="+tabID;
	
    if (firstTime) {
        param += "&firstTime=1";
        delay = 2000; // allow time to draw all pumps initially
		tabID =sessionStorage.tabID = Math.random(); // force tabID value here, as Edge gives same ID on Right-Click > New Window.
    }

    var jqxhr = $.ajax({
        cache: false,
        type: "GET",
        dataType: "xml",
        url: "MonitorState.aspx" + param
    })
    .done(function(xml) {
        $(xml).find("Pump").each(function() {
            var id = $(this).attr("id");
            var content = $(this).text();
            $("#Pump_" + id).html(content);
        });
        $(xml).find("Tank").each(function() {
            var id = $(this).attr("id");
            var content = $(this).text();
            $("#Tank_" + id).html(content);
        });

        timer = setTimeout("GetUpdate()", delay);
    })
    .fail(function() {
        timer = setTimeout("GetUpdate()", delay);
    })
    .always(function() {
        DisableSelectedPumpActionsIfNotOnline();
    });
}

$(".log").ajaxSuccess(function(e, xhr, settings) {
    if (settings.url == "ajax/test.html") {
        $(this).text("Triggered ajaxSuccess handler. The ajax response was:"
                     + xhr.responseText);
    }
});

$(window).unload(function() {
    clearTimeout(timer);
});

function GetStoredPumpID() {
    var pumpIdStoreHdn = document.getElementById("hdnSelectedPump");
    if (pumpIdStoreHdn == null) return;
    var pumpIdStoredVal = pumpIdStoreHdn.getAttribute("Value"); // ie "Pump_x "
    return pumpIdStoredVal.replace(/\D/g, ""); // strip non-numerics;
}

function SendMonitorStateAJAXCommand(urlParams) {
    var jqxhr = $.ajax({
        cache: false,
        type: "GET",
        dataType: "xml",
        url: "MonitorState.aspx" + urlParams
    })
    .done()
    .fail();
}

function UnlockButtonClickAction() {
    var pumpId = GetStoredPumpID();
    window.location = "SiteMonitor.aspx?Action=Unlock&PumpId=" + pumpId;
}

function AllStopButtonClickAction() {
    SendMonitorStateAJAXCommand("?Action=AllStop");
}

function AuthButtonClickAction() {
    var pumpId = GetStoredPumpID();
    SendMonitorStateAJAXCommand("?Action=Auth&PumpId=" + pumpId);
}

function AuthCancelButtonClickAction() {
    var pumpId = GetStoredPumpID();
    SendMonitorStateAJAXCommand("?Action=AuthCancel&PumpId=" + pumpId);
}

function StopButtonClickAction() {
    var pumpId = GetStoredPumpID();
    SendMonitorStateAJAXCommand("?Action=Stop&PumpId=" + pumpId);
}

function PauseButtonClickAction() {
    var pumpId = GetStoredPumpID();
    SendMonitorStateAJAXCommand("?Action=Pause&PumpId=" + pumpId);
}

function ResumeButtonClickAction() {
    var pumpId = GetStoredPumpID();
    SendMonitorStateAJAXCommand("?Action=Resume&PumpId=" + pumpId);
}

function TestDeliveryButtonClickAction() {
    var pumpId = GetStoredPumpID();
    SendMonitorStateAJAXCommand("?Action=TestDelivery&PumpId=" + pumpId);
}

function DriveoffButtonClickAction() {
    var pumpId = GetStoredPumpID();
    SendMonitorStateAJAXCommand("?Action=Driveoff&PumpId=" + pumpId);
}

function EventsButtonClickAction() {
    var pumpId = GetStoredPumpID();
    window.location="Events.aspx?Action=Load_Pump_Event&Item=" + pumpId;
}

function DeliveriesButtonClickAction() {
    var pumpId = GetStoredPumpID();
    window.location = "DeliveryHistory.aspx?Action=Load_History&Item=" + pumpId;
}

function HighlightSelectedPump() {
    // obtain stored current pump id
    var pumpIdStoreHdn = document.getElementById("hdnSelectedPump");
    var pumpIdStoredVal = pumpIdStoreHdn.getAttribute("Value"); // ie "Pump_x "

    // get selected pump DIV
    var selectedDiv = document.getElementById(pumpIdStoredVal);
    
    // check if selectedDiv exists. Bug possible if a pumpid is put into the url that doesn't exist.
    if (selectedDiv == null) 
    {
        return;
    }
    
    var selectedDivName = selectedDiv.getAttribute("Name");
    selectedDiv = selectedDiv.parentElement;

    // Highlight DIV
    selectedDiv.setAttribute("Class", "SelectedPump");

    // Update Fieldset Legend text
    var PumpActionsFds = document.getElementById("Pump Actions");
    PumpActionsFds.getElementsByTagName("LEGEND")[0].innerHTML = selectedDivName; 
}

function DisableSelectedPumpActionsIfNotOnline()
{
    // obtain stored current pump id
    var pumpIdStoreHdn = document.getElementById("hdnSelectedPump");
    var pumpIdStoredVal = pumpIdStoreHdn.getAttribute("Value"); // ie "Pump_x "

    // get selected pump DIV
    var selectedDiv = document.getElementById(pumpIdStoredVal);
    
    // check if selectedDiv exists. Bug possible if a pumpid is put into the url that doesn't exist.
    if (selectedDiv == null) {
        return;
    }
    
    var selectedDivName = selectedDiv.getAttribute("Name");
    selectedDiv = selectedDiv.parentElement;
    
    var pumpActionFls = document.getElementById("Pump Actions");
    var pumpHTML = selectedDiv.innerHTML.toLowerCase();

    var disableIt = ((pumpHTML.includes("error")) || (pumpHTML.includes("notinstalled")));
    pumpActionFls.disabled = disableIt;
}

function PumpPanelClickAction(selectedPump) {
    // get selected pump DIV
    var selectedPumpDiv = document.getElementById(selectedPump);
    if (selectedPumpDiv == null) return;
    var selectedPumpName = selectedPumpDiv.getAttribute("Name");

    // get current (stored) pumpId
    var pumpIdStoreHdn = document.getElementById("hdnSelectedPump");
    var pumpIdStoredVal = pumpIdStoreHdn.getAttribute("Value"); // ie "Pump_x "

    if (selectedPump == pumpIdStoredVal) return; // No change, no action required.

    // get current Pump_x parent DIV
    var currentPumpDiv = document.getElementById(pumpIdStoredVal);

    // check if current pump exists. Bug possible if a pumpid is put into the url that doesn't exist.
    if (currentPumpDiv != null) 
    {
        currentPumpDiv = currentPumpDiv.parentElement;
        
        // Un-highlight current pump
        currentPumpDiv.setAttribute("Class", "Pump");
    }

    // Store selected "Pump_x"
    pumpIdStoreHdn.setAttribute("Name", selectedPumpName);
    pumpIdStoreHdn.setAttribute("Value", selectedPump);

    // Highlight selected pump
    HighlightSelectedPump();
    DisableSelectedPumpActionsIfNotOnline();
}


