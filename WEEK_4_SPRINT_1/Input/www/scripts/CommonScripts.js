var cb_timer;

function cb_GetUpdateDelayed() {
    cb_timer = setTimeout("cb_GetUpdate()", cb_callbackTime);
}

function cb_GetUpdate() {
    var jqxhr = $.ajax({
        cache: false,
        type: "GET",
        dataType: cb_dataType,
        data: { Ajax: "true" },
        url: cb_requestUrl
    })
    .done(function(resdata) {
        cb_done(resdata);
        cb_timer = setTimeout("cb_GetUpdate()", cb_callbackTime);
    })
    .fail(function() {
        cb_timer = setTimeout("cb_GetUpdate()", cb_callbackTime);
    });
}

$('.log').ajaxSuccess(function(e, xhr, settings) {
    if (settings.url == 'ajax/test.html') {
        $(this).text('Triggered ajaxSuccess handler. The ajax response was:'
                     + xhr.responseText);
    }
});

$(window).unload(function() {
    clearTimeout(cb_timer);
});

function getElementsByPartialName(tagName, partialName) {
    var retVal = new Array();
    var elems = document.getElementsByTagName(tagName);
    for (var i = 0; i < elems.length; i++) {
        var nameProp = elems[i].name;
        if (!(nameProp == null)) {
            var patt = /1/i;
            patt.compile(partialName);
            if (patt.exec(nameProp)) {
                retVal.push(elems[i]);
            }
        }
    }
    return retVal;
}

function getElementsByPartialID(tagName, partialID) {
    var retVal = new Array();
    var elems = document.getElementsByTagName(tagName);
    for (var i = 0; i < elems.length; i++) {
        var idProp = elems[i].id;
        if (!(idProp == null)) {
            var patt = /1/i;
            patt.compile(partialID);
            if (patt.exec(idProp)) {
                retVal.push(elems[i]);
            }
        }
    }
    return retVal;
}

function AppendOption(optionList, text, value, defaultSelected, selected) {
    //Option(text, value, (bool) defaultSelected, (bool) selected)
    try {
        optionList.options[optionList.options.length] = new Option(text, value, defaultSelected, selected);
    }
    catch (err) {
        optionList.options[optionList.options.length] = new Option(text);
    }
}

// EP-2220: Calling this function to adjust form width based on browser size
function AdjustWidth(tableName) {
    if (document.getElementById(tableName)) {
        var width = document.documentElement.clientWidth;
        // Minimum width is fix to 800 px
        if (width < 750) { 
	// change to 750 because of the scroll bar
            width = 750;
        }
        // Set to 95%, to leave some spaces between the form and the browser edge 
        document.getElementById(tableName).width = width * 0.95;
    }
}


function UpdateFieldsOnDisplay(controlArray) {

    var index;
    var select = document.getElementById(controlArray["SelectID"]);
    var data = controlArray["Data"];

    var currentData = data[select.selectedIndex];

    for (elementData in currentData) {
        var element = document.getElementById(elementData);
        var elementValue = currentData[elementData];
        switch (element.type) {
            case "text":
                element.value = elementValue;
                break;
            case "select-one":
                element.options.length = 0; // Remove all the items
                for (index = 0; index < elementValue.length; index++) {
                    var selected = elementValue[index]["Selected"];
                    if (selected == true) {
                        AppendOption(element, elementValue[index]["Name"], elementValue[index]["Value"], selected, true);
                    }
                    else {
                        AppendOption(element, elementValue[index]["Name"], elementValue[index]["Value"], null, null);
                    }
                }
                break;

            // If div , display on/off 

            // if check, on/off  

        }

    }
}
