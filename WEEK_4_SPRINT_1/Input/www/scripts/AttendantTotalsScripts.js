function AttendantTotalsPageOnloadEvent() {
    if (document.getElementById) {

        AttendantIDChange();
        document.getElementById("Attendant_ID").onchange = AttendantIDChange;
      
        
    }
}


function AttendantIDChange() {

    //Get the periods element
    var periods = document.getElementById("Att_Period_ID");

    //Get the period types element
    var attendantID = document.getElementById("Attendant_ID");

    // remember the value selected!
    var selectPeriodValue;
    if (periods.options.length > 0)
        selectPeriodValue = periods.options[periods.selectedIndex].value;
    // reset the list of periods!
    periods.options.length = 0;

    // For loop to iterate through all options in the local list..value
    for (var num = attendantPeriodsArray.length; num > 0; num--) {
        if (attendantPeriodsArray[num]) {
            //var type = attendantID.options[attendantID.selectedIndex];
            var id = attendantPeriodsArray[num][0];
            var selectattid = attendantID.options[attendantID.selectedIndex].value;
            var periodDisplay1 = attendantPeriodsArray[num][1];
            var periodDisplay2 = " - ";
            var periodDisplay3 = attendantPeriodsArray[num][2];
            var periodDisplay = periodDisplay1.concat(periodDisplay2, periodDisplay3);

            if (id == selectattid) {
                // ensure select value already selected!
                if (selectPeriodValue == num) {
                    AppendOption(periods, periodDisplay, num, null, true);
                }
                else {
                    AppendOption(periods, periodDisplay, num, null, null);
                }
            }
        }
    }
}
