function TankTotalsPageOnloadEvent() {
    if (document.getElementById) {

        PeriodTypeChange();
        document.getElementById("Period_Type").onchange = PeriodTypeChange;
      
        
    }
}


function PeriodTypeChange() {
    
    //Get the periods element
    var periods = document.getElementById("Period_ID");
    
    //Get the period types element
    var periodtypes = document.getElementById("Period_Type");

    var selectIndex = periods.options[periods.selectedIndex].value;

    periods.options.length = 0;

    // For loop to iterate through all options in the local list..value
    for (var num = periodTypesArray.length; num > 0; num--) {
        if (periodTypesArray[num]) {
            //var type = periodtypes.options[periodtypes.selectedIndex];
            var type = periodTypesArray[num][0];
            var selectType = periodtypes.options[periodtypes.selectedIndex].value;
            var periodDisplay1 = periodTypesArray[num][1];
            var periodDisplay2 = " - ";
            var periodDisplay3 = periodTypesArray[num][2];
            var periodDisplay = periodDisplay1.concat(periodDisplay2, periodDisplay3);

            if (type == selectType) {
                if (selectIndex == num) {
                    AppendOption(periods, periodDisplay, num, null, true);
                }
                else {
                    AppendOption(periods, periodDisplay, num, null, null);
                }
            }
        }
    }
}

