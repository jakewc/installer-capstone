function TanksPageOnloadEvent(){
    TankTypeChange();
    SetTankStrappingOptions();
    document.getElementById("Tank_Type_ID").onchange = TankTypeChange;
    document.getElementById("Grade_ID").onchange = SetTankStrappingOptions;
    document.getElementById("Tank_Connection_Type_ID").onchange = SetTankStrappingOptions;
}

function TankTypeChange() {
    var TanksForm = document.getElementById("TanksForm");
    var TankGauge = document.getElementById("TankGaugesGroup");     
    var selectedType = document.getElementById("Tank_Type_ID").value;
    if(selectedType == 1) {
        TankGauge.style.display = 'none';
    }
    else {
        TankGauge.style.display = '';
    }
}

function SetTankStrappingOptions() {
    var gradeID = document.getElementById("Grade_ID");
    var manifoldType = document.getElementById("Tank_Connection_Type_ID");
    
    var selectedGradeID = gradeID.options[gradeID.selectedIndex].value;
    var selectedManifoldType = manifoldType.options[manifoldType.selectedIndex].value;

    var noOptions = true;

    var tanksOptions = document.getElementById("Strapped_Tank_ID");


    var selectedTankID = 0;
    
    // ES-1517
    if(tanksOptions.options[tanksOptions.selectedIndex]) // in case the "Strapped_Tank_ID" field doesn't exist
        selectedTankID = tanksOptions.options[tanksOptions.selectedIndex].value;
    
    tanksOptions.options.length = 0; // Remove all the options

    for (var num = 0; num < strappingTanks.length; num++) {
        if (strappingTanks[num]) {
            var tankgradeID = strappingTanks[num][0];
            var tankname = strappingTanks[num][1];

            if (tankgradeID == selectedGradeID) {
                noOptions = false;

                // ES-1517: Correct the mapping selected Tank ID
                if (num == selectedTankID)
                    AppendOption(tanksOptions, tankname, num, null, true);
                else
                    AppendOption(tanksOptions, tankname, num, null, null);
            }
         
        }
    }

    var strappingFieldset = document.getElementById("TankStrappingGroup");
    var strappingTable = document.getElementById("TankStrappingTable");     
    
    if (noOptions) {
        strappingFieldset.style.display = 'none';
    }
    else {
        strappingFieldset.style.display = '';
    }

    if (selectedManifoldType <= 1) {
        strappingTable.rows[1].style.display = 'none';
    }
    else {
        strappingTable.rows[1].style.display = '';
    }
}
