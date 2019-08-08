function tankGaugeOnload() {
    tankGaugeTypeChange();
    tankGaugePortChange();
    document.getElementById("Tank_Gauge_Type_ID").onchange = tankGaugeTypeChange;
    document.getElementById("Loop_ID").onchange = tankGaugePortChange;
}

function tankGaugeTypeChange() {
    var tankGaugeType = document.getElementById("Tank_Gauge_Type_ID");
    var selectedTankGaugeTypeID = tankGaugeType.options[tankGaugeType.selectedIndex].value;

    var tick = "&radic;";
    var featuresTable = document.getElementById("Features");

    for (index = 0; index < featuresTable.rows.length; index++) {
        if (tankTypes[selectedTankGaugeTypeID][index] != 0) {
            featuresTable.rows[index].cells[1].innerHTML = tick;
        }
        else {
            featuresTable.rows[index].cells[1].innerHTML = "";
        }
    }
}

function tankGaugePortChange() {
    var tankGaugePort = document.getElementById("Loop_ID");
    var tanksTypeOptions = document.getElementById("Tank_Gauge_Type_ID");
    var selectedProtocol = tankGaugePort.options[tankGaugePort.selectedIndex].value;
    var selectedTankGaugeTypeID = tanksTypeOptions.options[tanksTypeOptions.selectedIndex].value;
    // Re populate the tank gauge field

    tanksTypeOptions.options.length = 0; // Remove all the options

    var exists = false;
    for (var index = 0; index < IFSFprotocol.length; index++) {
        if (IFSFprotocol[index]) {
            if (IFSFprotocol[index] == selectedProtocol) {
                exists = true;
            }
        }
    }
    
    for (num in tankTypes) {
        var tankTypeName = tankTypes[num][5];
        
        if (exists) {
            if (num == 5) {
                AppendOption(tanksTypeOptions, tankTypeName, num, null, null);
            }
        }
        else {
            if (num != 5) {
                if (selectedTankGaugeTypeID == num) {
                    AppendOption(tanksTypeOptions, tankTypeName, num, selectedTankGaugeTypeID, true);
                }
                else {
                    AppendOption(tanksTypeOptions, tankTypeName, num, null, null);
                }
            }
        }
    }
    
    var tankGaugeDetails = document.getElementById("Details");
    if (exists) {
        tankGaugeDetails.rows[5].style.display = '';
        tankGaugeTypeChange();
    }
    else {
        tankGaugeDetails.rows[5].style.display = 'none';
        tankGaugeTypeChange();
    }
}
