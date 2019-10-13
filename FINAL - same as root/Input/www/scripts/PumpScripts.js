window.onload = function() {
    var hdnHoseNum = document.getElementById("hdnHoseNumber");
    var numberOfHoses = $('#Hoses tr').length - 1;
    hdnHoseNum.setAttribute("value", numberOfHoses);
}

function PumpsPageOnloadEvent() {
    if (document.getElementById) {
        //PortChange();
        document.getElementById("Loop_ID").onchange = PortChange;
        document.getElementById("Value_Decimals").onchange = MultiplierSetting;
        document.getElementById("Price_Decimals").onchange = MultiplierSetting;
        document.getElementById("Pump_Type_ID").onchange = PumpTypeChange;
        document.getElementById("Pump_Price_Multiplier").onchange = MultiplierChange;
        AssignHoseTableChange();
        PortChange();
        // Set the default tanks and grades.
        var selectedtypeindex = document.getElementById("Pump_Type_ID").value;
        var hoseTable = document.getElementById("Hoses");
        var gradeOptions = document.getElementsByName("Grade_ID");
        var tank2Options = document.getElementsByName("Tank2_ID");
        var tank1Options = document.getElementsByName("Tank_ID");
        for (var rowindex = 1; rowindex < hoseTable.rows.length; rowindex++) {
            var tableRow = hoseTable.rows[rowindex];
            var hoseBlendType = pumptypes[selectedtypeindex][3];
            var gradeID = hoses[rowindex][0];
            var tank1ID = hoses[rowindex][1];
            var tank1Index = GetTankIndex(tank1ID);
            var gradeIndex = GetGradeIndex(gradeID);
            tank1Options[rowindex - 1][tank1Index].selected = true;
            gradeOptions[rowindex - 1][gradeIndex].selected = true;
            tableRow.cells[2].innerHTML = grades[gradeIndex][0];
            if (hoseBlendType == '1') {
                // Set the tank 2
                if (hoses[rowindex][2] != '') {
                    var tank2ID = hoses[rowindex][2] - 1;
                    var tank2Index = GetTankID(tank2ID);
                    tank2Options[rowindex - 1][tank2Index].selected = true;
                }
            }
        }
    }
}

// get the array index of the tank matching tankID parameter
function GetTankIndex(tankID) {
    for (var index = 0; index < tanks.length; index++) {
        if (tanks[index][3] == tankID) {
            return index;
        }
    }
    // could not find a match
    return -1;
}

// get the array index of the grade matching gradeID parameter
function GetGradeIndex(gradeID) {
    for (var index = 0; index < grades.length; index++) {
        if (grades[index][2] == gradeID) {
            return index;
        }
    }
    // could not find a match
    return -1;
}

function PortChange() {
    var types = document.getElementById("Pump_Type_ID");
    var selectedportindex = document.getElementById("Loop_ID").value;
    var selectedtypeindex = types.value;
    var mechanicalindex = -1;
    
    // If the selected protocol equals the selected pump type protocol id then set the default flag
    //if ( protocolids[selectedportindex] == pumptypes[selectedtypeindex][1]){
    //  var defaultselect = true;
    //}
    // Clear all the currently selected options
    types.options.length = 0;
    // For loop to iterate through all options in the local list.
    for (var num = 0; num < pumptypes.length; num++) {
        if (pumptypes[num]) {
            // If the selected port protocol id equals this pump type protocol id
            if (protocolids[selectedportindex] == pumptypes[num][1]) {
                // If the default is selected and the current pump type id equals the selected id
                if (num == selectedtypeindex) {
                    try {
                        //Option(text, value, (bool) defaultSelected, (bool) selected)
                        types.options[types.options.length] = new Option(pumptypes[num][0], num, false, true);
                    }
                    catch (err) {
                        types.options[types.options.length] = new Option(pumptypes[num][0]);
                    }
                    types.options[types.options.length - 1].className = 'HighlightOption';
                }
                else {
                    try {
                        types.options[types.options.length] = new Option(pumptypes[num][0], num)
                    }
                    catch (err) {
                        types.options[types.options.length] = new Option(pumptypes[num][0])
                    }
                }
                //if(num == invalidType){
                //  types.options[types.options.length - 1].className = 'HighlightOption';
                //}
            }

            // the mechanical pump!
            if (pumptypes[num][1] == '11') {
                mechanicalindex = num;
            }
        }
    }

    // set Polling Address to next available
    var pump_ID = document.getElementsByName("Pump_ID")[0].value; // = '0' if adding a new pump
    if (pump_ID == "0") {
        var pollingAddress = document.getElementById("Pump_Polling");
        var x = pollingaddresses[selectedportindex];

        if (protocolids[selectedportindex] == 9) // IFSF
        {
            var pumpSide = document.getElementById("Pump_Side");
            var y = (x % 4);
            if (y == 0) {
                y = 4;
            }
            pumpSide.value = y;
            x = Math.floor((x - 1) / 4) + 1;
        }

        selectedtypeindex = types.value;
        pollingAddress.value = x;
    }

    // always add mechanical pump type into the list!
    if (mechanicalindex >= 0) {
        try {
            // if mechanicaltype is the selected index from the start?
            if (mechanicalindex == selectedtypeindex) {
                try {
                    //Option(text, value, (bool) defaultSelected, (bool) selected)
                    types.options[types.options.length] = new Option(pumptypes[mechanicalindex][0], mechanicalindex, false, true);
                }
                catch (err) {
                    types.options[types.options.length] = new Option(pumptypes[mechanicalindex][0]);
                }
                types.options[types.options.length - 1].className = 'HighlightOption';
            }
            else {
                try {
                    types.options[types.options.length] = new Option(pumptypes[mechanicalindex][0], mechanicalindex)
                }
                catch (err) {
                    types.options[types.options.length] = new Option(pumptypes[mechanicalindex][0])
                }
            }
        }
        catch (err) {
            types.options[types.options.length] = new Option(pumptypes[mechanicalindex][0])
        }
    }

    // L&TMPD = 62 IFSF = 9
    if (protocolids[selectedportindex] == 62 || protocolids[selectedportindex] == 9) {
        document.getElementById("Pump_Connections").rows[3].style.display = '';
    }
    else {
        document.getElementById("Pump_Connections").rows[3].style.display = 'none';
    }

    PumpTypeChange();
}

function PumpTypeChange() {
    MultiplierSetting();
    HoseTableChange();
    PumpSettings();
}

function PumpSettings() {
    var selectedtypeindex = document.getElementById("Pump_Type_ID").value;

    // mechanical pumps default to 0 polling Address!
    if (selectedtypeindex == '80') {
        var pollingAddress = document.getElementById("Pump_Polling");
        pollingAddress.value = "0";
    }

    // if rows.length > 5: Tag Setting is available 
    if (document.getElementById("Pump_Connections").rows.length > 5) {
        if (pumptypes[selectedtypeindex][4] > '0') {
            document.getElementById("Pump_Connections").rows[5].style.display = '';
        }
        else {
            document.getElementById("Pump_Connections").rows[5].style.display = 'none';
        }
        // EP-1619: Warning In PS.js when reading PumpSettings Page:
        // Totally 4-5 rows. depends on Tag Setting Rows[5] is Tag Setting
    }
}

function MultiplierSetting() {
    var selectedtypeindex = document.getElementById("Pump_Type_ID").value;
    var selectedpriceindex = document.getElementById("Price_Decimals").selectedIndex;
    var selectedvalueindex = document.getElementById("Value_Decimals").selectedIndex;
    var pumpDisplays = 'none';
    if (pumptypes[selectedtypeindex][2] == '1' || pumptypes[selectedtypeindex][2] == '2') {
        if (selectedpriceindex == 0 && selectedvalueindex == 0) {
            pumpDisplays = '';
            document.getElementById("Pump_Price_Multiplier").disabled = false;
            if (pumptypes[selectedtypeindex][2] == '1') {
                document.getElementById("Pump_Value_Multiplier").disabled = true;
            }
            else if (pumptypes[selectedtypeindex][2] == '2') {
                document.getElementById("Pump_Value_Multiplier").disabled = false;
            }
        }
    }
    document.getElementById("Pump_Displays").rows[3].style.display = pumpDisplays;
    document.getElementById("Pump_Displays").rows[4].style.display = pumpDisplays;

}

function MultiplierChange() {
    var selectedpricemultindex = document.getElementById("Pump_Price_Multiplier").selectedIndex;
    var selectedtypeindex = document.getElementById("Pump_Type_ID").value;
    if (pumptypes[selectedtypeindex][2] == '1') {
        document.getElementById("Pump_Value_Multiplier").selectedIndex = selectedpricemultindex;
    }
}

function AssignHoseTableChange() {
    var tank = document.getElementsByName("Tank_ID");
    var grade = document.getElementsByName("Grade_ID");

    for (r = 0; r < tank.length; ++r) {
        tank[r].onchange = TankChange;
    }
    for (r = 0; r < grade.length; ++r) {
        grade[r].onchange = GradeChange;
    }
}

function TankChange(e) {
    var hoseTable = document.getElementById("Hoses");
    var selectedtypeindex = document.getElementById("Pump_Type_ID").value;
    if (pumptypes[selectedtypeindex][3] != '1') {
        var targ;
        if (!e)
            e = window.event;
        if (e.target)
            targ = e.target;
        else if (e.srcElement)
            targ = e.srcElement;
        if (targ.nodeType == 3)
            targ = targ.parentNode;
        // JIRA 403
        // ES-255 Tank ID Invalid Selection
        var gradeID = tanks[targ.selectedIndex][2];
        for (i = 0; i < grades.length; i++) {
            if (grades[i][2] == gradeID) {
                hoseTable.rows[targ.parentNode.parentNode.sectionRowIndex].cells[2].innerHTML = grades[i][0];
                break;
            }

        }
        var hoseoptions = document.getElementsByName("Grade_ID");
        hoseoptions[targ.parentNode.parentNode.sectionRowIndex - 1].selectedIndex = tanks[targ.selectedIndex][1];
    }
}

function GradeChange(e) {
    var hoseTable = document.getElementById("Hoses");
    var targ;
    if (!e)
        e = window.event;
    if (e.target)
        targ = e.target;
    else if (e.srcElement)
        targ = e.srcElement;
    if (targ.nodeType == 3)
        targ = targ.parentNode;

    var rowIndex = targ.parentNode.parentNode.sectionRowIndex;
    GradeChangeProcessing(rowIndex);
    hoseTable.rows[targ.parentNode.parentNode.sectionRowIndex].cells[2].innerHTML = grades[targ.selectedIndex][0];

}

function GradeChangeProcessing(rowIndex) {
    var hoseTable = document.getElementById("Hoses");
    var selectedtypeindex = document.getElementById("Pump_Type_ID").value;
    var gradeOptions = document.getElementsByName("Grade_ID");
    var tank2Options = document.getElementsByName("Tank2_ID");
    var tanks1 = document.getElementsByName("Tank_ID")[rowIndex - 1];
    var tanks2 = document.getElementsByName("Tank2_ID")[rowIndex - 1];
    var selectedGradeIndex = gradeOptions[rowIndex - 1].selectedIndex;
    var gradeID = grades[selectedGradeIndex][2];
    var grade1ID = grades[selectedGradeIndex][3];
    var grade2ID = grades[selectedGradeIndex][4];

    // remember the selected drop down
    var tanks1selectedvalue = tanks1.value;
    var tanks2selectedvalue = tanks2.value;

    // Clear all the currently selected options
    tanks1.options.length = 0;
    tanks2.options.length = 0;

    // pump supporting blended hoses 
    if (pumptypes[selectedtypeindex][3] == '1') {
        var displayTank2 = 0;
        // hide the tank2 column!
        // - 1 on the rows length due to the header row
        for (var i = 0; i < hoseTable.rows.length - 1; i++) {

            if (grades[gradeOptions[i].selectedIndex][1] > 1) {
                displayTank2 = 1;
                tank2Options[i].style.display = '';
            }
            else {
                tank2Options[i].style.display = 'none';
            }
        }
        if (displayTank2 == 0) {
            for (r = 0; r < hoseTable.rows.length; ++r) {
                hoseTable.rows[r].cells[4].style.display = 'none';
            }
        }
        else {
            for (r = 0; r < hoseTable.rows.length; ++r) {
                hoseTable.rows[r].cells[4].style.display = '';
            }
        }
        // Rebuild the tank list!
        // For loop to iterate through all options in the local list.
        for (var num = 0; num < tanks.length; num++) {
            if (tanks[num]) {
                var tankgradeID = tanks[num][2];
                var tankname = tanks[num][0];
                var tankID = tanks[num][3];

                // tank1 grade1 match?
                if (tankgradeID == grade1ID) {
                    var selected = false;
                    if (tanks1selectedvalue == tanks[num][3]) {
                        selected = true;
                    }
                    AppendOption(tanks1, tankname, tankID, null, selected);
                }
                // tank2 grade2 match?
                if (tankgradeID == grade2ID) {
                    var selected = false;
                    if (tanks2selectedvalue == tanks[num][3]) {
                        selected = true;
                    }
                    AppendOption(tanks2, tankname, tankID, null, selected);
                }
                // both grades not set? just add
                if (grade1ID == "" && grade2ID == "") {
                    if (tankgradeID == gradeID) {
                        AppendOption(tanks1, tankname, tankID, null, null);
                    }
                }
            }
        }
    }
    // non blending pumps
    else {
        // if grade is currently a blend grade then adjust to a different grade.
        if (grades[selectedGradeIndex][1] != '1') {
            // search for anon blend grade
            for (var num = 0; num < gradeOptions[rowIndex - 1].options.length; num++) {
                if (gradeOptions[rowIndex - 1].options[num]) {
                    if (grades[num][1] == '1') {
                        gradeOptions[rowIndex - 1].options[num].selected = true;
                        hoseTable.rows[rowIndex].cells[2].innerHTML = grades[num][0];
                        break;

                    }
                }
            }
        }

        // Rebuild the tank list
        tanks1.options.length = 0;
        for (var num = 0; num < tanks.length; num++) {
            if (tanks[num]) {
                // ignore tanks with no grade
                if (tanks[num][1] == -1)
                    continue;
                // filter out Tanks with blended grades!	
                if (grades[tanks[num][1]][1] == 1) {
                    var selected = false;
                    if (tanks1selectedvalue == tanks[num][3]) {
                        selected = true;
                    }
                    AppendOption(tanks1, tanks[num][0], tanks[num][3], null, selected);
                }
            }
        }
    }
}

function HoseTableChange() {
    var hoseTable = document.getElementById("Hoses");
    var selectedtypeindex = document.getElementById("Pump_Type_ID").value;
    for (index = 0; index < hoseTable.rows.length; index++) {
        var tableRow = hoseTable.rows[index];
        if (pumptypes[selectedtypeindex][3] == '1') {
            tableRow.cells[1].style.display = '';
            tableRow.cells[2].style.display = 'none';
        }
        else {
            tableRow.cells[1].style.display = 'none';
            tableRow.cells[2].style.display = '';
            tableRow.cells[4].style.display = 'none';
        }
        if (index != 0) {
            GradeChangeProcessing(index);
        }
    }

    // do gradechange processing
    //for (index = 0; index < hoseTable.rows.length; index++) {
    //    if (index != 0) {
    //        GradeChangeProcessing(index);
    //    }
    //}

    var maxHoseNumber = pumptypes[selectedtypeindex][5];
    var msgRows = document.getElementById("HoseAlarm").rows;
    var warnMSG = msgRows[0].cells;
    var alarmMSG = msgRows[1].cells;

    warnMSG[0].innerHTML = warnMSG[0].innerHTML.replace(new RegExp("\[0-9\]", "gi"), maxHoseNumber);
    alarmMSG[0].innerHTML = alarmMSG[0].innerHTML.replace(new RegExp("\[0-9\]", "gi"), maxHoseNumber);

    if (hoseTable.rows.length - 1 < maxHoseNumber) {
        warnMSG[0].style.display = 'none';
        alarmMSG[0].style.display = 'none';
    }
    else
        if (hoseTable.rows.length - 1 == maxHoseNumber) {
        warnMSG[0].style.display = '';
        alarmMSG[0].style.display = 'none';
    }
    else if (hoseTable.rows.length - 1 > maxHoseNumber) {
        warnMSG[0].style.display = 'none';
        alarmMSG[0].style.display = '';
    }

}
