var datePickerDivID = "datepicker";

var dayArray = new Array('Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa');
var weekdayArray = new Array("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday");
var monthArray = new Array('January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December');
var dateSeparator = "/";
var dateFormat = "mdy";
var Today = "*Today*";
var Close = "X";

var LimitStart = false;
var startDay;
var startMonth;
var startYear;

var LimitEnd = false;
var endDay;
var endMonth;
var endYear;

function setWeekDayStrings(Sun, Mon, Tue, Wed, Thu, Fri, Sat) {
    weekdayArray = new Array(Sun, Mon, Tue, Wed, Thu, Fri, Sat);
}

function setDayStrings(Su, Mo, Tu, We, Th, Fr, Sa) {
    dayArray = new Array(Su, Mo, Tu, We, Th, Fr, Sa);
}

function setMonthStrings(Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec) {
    monthArray = new Array(Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec);
}

function setDateSeparator(separator) {
    dateSeparator = separator;
}

function setDateFormat(format) {
    dateFormat = format;
}

function setTodayString(today) {
    Today = today;
}

function setCloseString(close) {
    Close = close;
}

function setStartDate(StartDate) {
    LimitStart = true;
    var strtDate = getFieldDate(StartDate);
    startDay = strtDate.getDate();
    startMonth = strtDate.getMonth();
    startYear = strtDate.getFullYear();
}

function setEndDate(EndDate) {
    LimitEnd = true;
    var enDate = getFieldDate(EndDate);
    endDay = enDate.getDate();
    endMonth = enDate.getMonth();
    endYear = enDate.getFullYear();
}

function closeAllDatePickers() {
	
	var allDatePickers;
	
	// find all date pickers on the page and hide any that are visible
	allDatePickers = document.querySelectorAll("div.dpDIV");
	for (var i = 0; i < allDatePickers.length; i++) {
		var pickerDiv = allDatePickers[i];
		pickerDiv.style.visibility = "hidden";
		pickerDiv.style.display = "none";
	}
}

function displayDatePicker(e) {

    var targ;
    var dateTextField;
    var dateInputField;
    
	closeAllDatePickers();
	
	// now display the one just clicked
	if (!e)
        e = window.event;
    if (e.target)
        targ = e.target;
    else if (e.srcElement)
        targ = e.srcElement;
    if (targ.nodeType == 3)
        targ = targ.parentNode;
	
    dateTextField = targ.id;
    dateInputField = dateTextField.substring(0, dateTextField.indexOf("Text")); // remove the suffix Text

    var targetDateField = document.getElementsByName(dateInputField)[0];

    var dt = getFieldDate(targetDateField.value);

    // move the datepicker div to the proper x,y coordinate and toggle the visiblity
    var pickerDiv = document.getElementById(datePickerDivID + e.target.id);
    pickerDiv.style.visibility = (pickerDiv.style.visibility == "visible" ? "hidden" : "visible");
    pickerDiv.style.display = (pickerDiv.style.display == "block" ? "none" : "block");

    // draw the datepicker table
    refreshDatePicker(targ.id, dt.getFullYear(), dt.getMonth(), dt.getFullYear(), dt.getMonth(), dt.getDate());
}

function refreshDatePicker(dateFieldName, thisYear, thisMonth, year, month, day) {
    var thisDay = new Date();
    var selectedDay = new Date(year, month, day);

    if ((thisMonth >= 0) && (thisYear > 0)) {
        thisDay = new Date(thisYear, thisMonth, 1);
    } else {
        thisDay.setDate(1);
    }

    // the calendar will be drawn as a table
    // you can customize the table elements with a global CSS style sheet,
    // or by hardcoding style and formatting elements below
    var crlf = "\r\n";
    var TABLE = "<table cols=7 class='dpTable'>" + crlf;
    var xTABLE = "</table>" + crlf;
    var TR = "<tr class='dpTR'>";
    var TR_title = "<tr class='dpTitleTR'>";
    var TR_days = "<tr class='dpDayTR'>";
    var TR_closebutton = "<tr class='dpTodayButtonTR'>";
    var xTR = "</tr>" + crlf;
    var TD_space = "<td class='dpTD'>";
    var TD = "<td class='dpTD' onMouseOut='this.className=\"dpTD\";' onMouseOver='this.className=\"dpTDHover\";' ";    // leave this tag open, because we'll be adding an onClick event
    var TD_title = "<td colspan=5 class='dpTitleTD'>";
    var TD_buttons = "<td class='dpButtonTD'>";
    var TD_closebutton = "<td colspan=7 class='dpTodayButtonTD'>";
    var TD_days = "<td class='dpDayTD'>";
    var TD_invalid = "<td class='dpInvalidTD'>";
    var TD_selected = "<td class='dpDayHighlightTD' onMouseOut='this.className=\"dpDayHighlightTD\";' onMouseOver='this.className=\"dpTDHover\";' ";    // leave this tag open, because we'll be adding an onClick event
    var xTD = "</td>" + crlf;
    var DIV_title = "<div class='dpTitleText'>";
    var DIV_selected = "<div class='dpDayHighlight'>";
    var xDIV = "</div>";

    // start generating the code for the calendar table
    var html = TABLE;

    // this is the title bar, which displays the month and the buttons to
    // go back to a previous month or forward to the next month
    html += TR_title;
    html += TD_buttons + getButtonCode(dateFieldName, thisDay, -1, selectedDay, "&lt;") + xTD;
    html += TD_title + DIV_title + monthArray[thisDay.getMonth()] + " " + thisDay.getFullYear() + xDIV + xTD;
    html += TD_buttons + getButtonCode(dateFieldName, thisDay, 1, selectedDay, "&gt;") + xTD;
    html += xTR;

    // this is the row that indicates which day of the week we're on
    html += TR_days;
    for (i = 0; i < dayArray.length; i++)
        html += TD_days + dayArray[i] + xTD;
    html += xTR;

    // now we'll start populating the table with days of the month
    html += TR;

    // first, the leading blanks
    for (i = 0; i < thisDay.getDay(); i++)
        html += TD_space + "&nbsp;" + xTD;

    var todayDate = new Date();
    todayDay = todayDate.getDate();
    todayMonth = todayDate.getMonth();
    todayYear = todayDate.getFullYear();

    // Normal Date
    //<td class="dpTD" 
    //    onclick="updateDateField('01/01/2012', '0', '1', '0', '2012');"
    //    onmouseover="this.className="dpTDHover";"
    //    onmouseout="this.className="dpTD";">
    //DATE
    //</td>

    // Selected Date
    //<td class="dpDayHighlightTD"
    //    onclick="updateDateField('24/01/2012', '2', '24', '0', '2012');"
    //    onmouseover="this.className="dpTDHover";"
    //    onmouseout="this.className="dpDayHighlightTD";">
    //    <div class="dpDayHighlight">
    //    DATE
    //    </div>
    //</td>

    // Invalid Date
    //<td class="dpInvalidTD">
    //DATE
    //</td>

    // now, the days of the month
    do {
        dayNum = thisDay.getDate();
        monthNum = thisDay.getMonth();
        yearNum = thisDay.getFullYear();

        TD_onclick = " onclick=\"updateDateField('" + dateFieldName + "', '" + getDateString(thisDay) + "', '" + thisDay.getDay() + "', '" + thisDay.getDate() + "', '" + thisDay.getMonth() + "', '" + thisDay.getFullYear() + "');\">";

        var tablecell = TD + TD_onclick + dayNum + xTD;

        if (
                ((yearNum < startYear && LimitStart) || (yearNum > endYear && LimitEnd)) ||
                (((yearNum == startYear) && (monthNum < startMonth) && LimitStart) || ((yearNum == endYear) && (monthNum > endMonth) && LimitEnd)) ||
                (((yearNum == startYear) && (monthNum == startMonth) && (dayNum <= startDay) && LimitStart) || ((yearNum == endYear) && (monthNum == endMonth) && (dayNum >= endDay) && LimitEnd))
          ) {
            tablecell = TD_invalid + dayNum + xTD;
        }

        if ((yearNum == year) &&
            (monthNum == month) &&
            (dayNum == day)) {
            tablecell = TD_selected + TD_onclick + DIV_selected + dayNum + xDIV + xTD;
        }

        html += tablecell;

        //        if (LimitDates) {
        //            if (yearNum == startYear || yearNum == todayYear) {
        //                if ((monthNum == startMonth && yearNum == startYear) || (monthNum == todayMonth && yearNum == todayYear)) {
        //                    if ((dayNum > startDay && monthNum == startMonth) || (dayNum <= todayDay && monthNum == todayMonth)) {
        //                        if (dayNum == day)
        //                            html += TD_selected + TD_onclick + DIV_selected + dayNum + xDIV + xTD;
        //                        else
        //                            html += TD + TD_onclick + dayNum + xTD;
        //                    }
        //                    else {
        //                        html += TD_invalid + dayNum + xTD;
        //                    }
        //                }
        //                else if ((monthNum > startMonth && yearNum == startYear) || (monthNum < todayMonth && yearNum == todayYear)) {
        //                    if (dayNum == day)
        //                        html += TD_selected + TD_onclick + DIV_selected + dayNum + xDIV + xTD;
        //                    else
        //                        html += TD + TD_onclick + dayNum + xTD;
        //                }
        //                else {
        //                    html += TD_invalid + dayNum + xTD;
        //                }
        //            }
        //            else if (yearNum > startYear && yearNum < todayYear) {
        //                if (dayNum == day)
        //                    html += TD_selected + TD_onclick + DIV_selected + dayNum + xDIV + xTD;
        //                else
        //                    html += TD + TD_onclick + dayNum + xTD;
        //            }
        //            else {
        //                html += TD_invalid + dayNum + xTD;
        //            }
        //        }
        //        else {
        //            if (yearNum == todayYear) {
        //                if (monthNum == todayMonth) {
        //                    if (dayNum <= todayDay) {
        //                        if (dayNum == day)
        //                            html += TD_selected + TD_onclick + DIV_selected + dayNum + xDIV + xTD;
        //                        else
        //                            html += TD + TD_onclick + dayNum + xTD;
        //                    }
        //                    else {
        //                        html += TD_invalid + dayNum + xTD;
        //                    }
        //                }
        //                else if (monthNum < todayMonth) {
        //                    if (dayNum == day)
        //                        html += TD_selected + TD_onclick + DIV_selected + dayNum + xDIV + xTD;
        //                    else
        //                        html += TD + TD_onclick + dayNum + xTD;
        //                }
        //                else {
        //                    html += TD_invalid + dayNum + xTD;
        //                }
        //            }
        //            else if (yearNum < todayYear) {
        //                if (dayNum == day)
        //                    html += TD_selected + TD_onclick + DIV_selected + dayNum + xDIV + xTD;
        //                else
        //                    html += TD + TD_onclick + dayNum + xTD;
        //            }
        //            else {
        //                html += TD_invalid + dayNum + xTD;
        //            }
        //        }
        // if this is a Saturday, start a new row
        if (thisDay.getDay() == 6)
            html += xTR + TR;

        // increment the day
        thisDay.setDate(thisDay.getDate() + 1);
    } while (thisDay.getDate() > 1)

    // fill in any trailing blanks
    if (thisDay.getDay() > 0) {
        for (i = 7; i > thisDay.getDay(); i--)
            html += TD_space + "&nbsp;" + xTD;
    }
    html += xTR;

    // add a button to allow the user to close the calendar
    var today = new Date();
    html += TR_closebutton + TD_closebutton;
    //html += "<button class='dpTodayButton' onClick='refreshDatePicker(\"" + dateFieldName + "\");'>" + Today + "</button> ";
    html += "<input type='button' class='dpTodayButton' onclick='updateDateField(\"" + dateFieldName + "\",\"" + getDateString(todayDate) + "\",\"" + todayDate.getDay() + "\",\"" + todayDate.getDate() + "\",\"" + todayDate.getMonth() + "\",\"" + todayDate.getFullYear() + "\");' value=\"" + Today + "\">";
    html += "&nbsp;";
    html += "<input type='button' class='dpTodayButton' onClick='updateDateField(\"" + dateFieldName + "\");' value=\"" + Close + "\">";
    html += xTD + xTR;

    // and finally, close the table
    html += xTABLE;

    document.getElementById(datePickerDivID + dateFieldName).innerHTML = html;
}


/**
Convenience function for writing the code for the buttons that bring us back or forward
a month.
*/
function getButtonCode(dateFieldName, dateVal, adjust, selectedDay, label) {
    var newMonth = (dateVal.getMonth() + adjust) % 12;
    var newYear = dateVal.getFullYear() + parseInt((dateVal.getMonth() + adjust) / 12);
    if (newMonth < 0) {
        newMonth += 12;
        newYear += -1;
    }

    return "<button class='dpButton' onClick='refreshDatePicker(\"" + dateFieldName + "\", " + newYear + ", " + newMonth + ", " + selectedDay.getFullYear() + ", " + selectedDay.getMonth() + ", " + selectedDay.getDate() + ");'>" + label + "</button>";
}


/**
Convert a JavaScript Date object to a string, based on the dateFormat and dateSeparator
variables at the beginning of this script library.
*/
function getDateString(dateVal) {
    var dayString = "00" + dateVal.getDate();
    var monthString = "00" + (dateVal.getMonth() + 1);
    dayString = dayString.substring(dayString.length - 2);
    monthString = monthString.substring(monthString.length - 2);

    var format;

    fArray = splitDateString(dateFormat);
    if (fArray) {
        first = fArray[0].charAt(0);
        middle = fArray[1].charAt(0);
        last = fArray[2].charAt(0);

        format = first.toUpperCase() + middle.toUpperCase() + last.toUpperCase();
    }
    switch (format) {
        case "YMD":
            return dateVal.getFullYear() + dateSeparator + monthString + dateSeparator + dayString;
        case "MDY":
            return monthString + dateSeparator + dayString + dateSeparator + dateVal.getFullYear();
        case "DYM":
            return dayString + dateSeparator + dateVal.getFullYear() + dateSeparator + monthString;
        case "MYD":
            return monthString + dateSeparator + dateVal.getFullYear() + dateSeparator + dayString;
        case "YDM":
            return dateVal.getFullYear() + dateSeparator + dayString + dateSeparator + monthString;
        case "DMY":
        default:
            return dayString + dateSeparator + monthString + dateSeparator + dateVal.getFullYear();
    }
}


/**
Convert a string to a JavaScript Date object.
*/
function getFieldDate(dateString) {
    var dateVal;
    var dArray;
    var fArray;
    var d, m, y;
    var first, middle, last;

    try {
        dArray = splitDateString(dateString);
        if (dArray) {
            fArray = splitDateString(dateFormat);
            if (fArray) {
                first = fArray[0].charAt(0).toUpperCase();
                middle = fArray[1].charAt(0).toUpperCase();
                last = fArray[2].charAt(0).toUpperCase();
                switch (first) {
                    case "D":
                        d = parseInt(dArray[0], 10);
                        break;
                    case "Y":
                        y = parseInt(dArray[0], 10);
                        break;
                    case "M":
                    default:
                        m = parseInt(dArray[0], 10) - 1;
                        break;
                }
                switch (middle) {
                    case "M":
                        m = parseInt(dArray[1], 10) - 1;
                        break;
                    case "Y":
                        y = parseInt(dArray[1], 10);
                        break;
                    case "D":
                    default:
                        d = parseInt(dArray[1], 10);
                        break;
                }
                switch (last) {
                    case "D":
                        d = parseInt(dArray[2], 10);
                        break;
                    case "M":
                        m = parseInt(dArray[2], 10) - 1;
                        break;
                    case "Y":
                    default:
                        y = parseInt(dArray[2], 10);
                        break;
                }
                dateVal = new Date(y, m, d);
            }
        } else if (dateString) {
            dateVal = new Date(dateString);
        } else {
            dateVal = new Date();
        }
    } catch (e) {
        dateVal = new Date();
    }

    return dateVal;
}


/**
Try to split a date string into an array of elements, using common date separators.
If the date is split, an array is returned; otherwise, we just return false.
*/
function splitDateString(dateString) {
    var dArray;
    if (dateString.indexOf(dateSeparator) >= 0)
        dArray = dateString.split(dateSeparator);
    else
        dArray = false;

    return dArray;
}

/**
Update the field with the given dateFieldName with the dateString that has been passed,
and hide the datepicker. If no dateString is passed, just close the datepicker without
changing the field value.
**/

function updateDateField(divID, dateString, day, date, month, year) {
    var targetDateField = document.getElementById(divID);
   
    if (dateString) {
        // The hidden date
        var divLen = divID.length;
        document.getElementsByName(divID.slice(0, divLen - 4))[0].value = dateString;
        // The displayed date
        targetDateField.innerHTML = weekdayArray[day] + ",";
        fArray = splitDateString(dateFormat);
        if (fArray) {
            first = fArray[0].charAt(0).toUpperCase();
            middle = fArray[1].charAt(0).toUpperCase();
            last = fArray[2].charAt(0).toUpperCase();
            switch (first) {
                case "D":
                    if (date < 10) {
                        targetDateField.innerHTML = targetDateField.innerHTML + " 0" + date;
                    }
                    else {
                        targetDateField.innerHTML = targetDateField.innerHTML + " " + date;
                    }
                    break;
                case "Y":
                    targetDateField.innerHTML = targetDateField.innerHTML + " " + year;
                    break;
                case "M":
                default:
                    targetDateField.innerHTML = targetDateField.innerHTML + " " + monthArray[month];
                    break;
            }
            switch (middle) {
                case "M":
                    targetDateField.innerHTML = targetDateField.innerHTML + " " + monthArray[month];
                    break;
                case "Y":
                    targetDateField.innerHTML = targetDateField.innerHTML + " " + year;
                    break;
                case "D":
                default:
                    if (date < 10) {
                        targetDateField.innerHTML = targetDateField.innerHTML + " 0" + date;
                    }
                    else {
                        targetDateField.innerHTML = targetDateField.innerHTML + " " + date;
                    }
                    break;
            }
            switch (last) {
                case "D":
                    if (date < 10) {
                        targetDateField.innerHTML = targetDateField.innerHTML + " 0" + date;
                    }
                    else {
                        targetDateField.innerHTML = targetDateField.innerHTML + " " + date;
                    }
                    break;
                case "M":
                    targetDateField.innerHTML = targetDateField.innerHTML + " " + monthArray[month];
                    break;
                case "Y":
                default:
                    targetDateField.innerHTML = targetDateField.innerHTML + " " + year;
                    break;
            }
        }
    }

    var pickerDiv = document.getElementById(datePickerDivID + divID);
    pickerDiv.style.visibility = "hidden";
    pickerDiv.style.display = "none";

    targetDateField.focus();
}
