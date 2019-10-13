function CalculateVar() {
    document.getElementById('Dispatched_Volume').onchange = AutoCalculateVars;
    document.getElementById('Drop_Volume').onchange = AutoCalculateVars;
    document.getElementById('Dispatched_Vol_At_Ref_Temp').onchange = AutoCalculateVars;
    document.getElementById('Received_Vol_At_Ref_Temp').onchange = AutoCalculateVars;
    AutoCalculateVars();
}

function AutoCalculateVars() {
    var dispatchedVolume = document.getElementById('Dispatched_Volume').value;
    var receivedVolume = document.getElementById('Drop_Volume').value;
    var disVolAtRefTemp = document.getElementById('Dispatched_Vol_At_Ref_Temp').value;
    var recVolAtRefTemp = document.getElementById('Received_Vol_At_Ref_Temp').value;

    // Process Strings before Convert to int or double
    // 50,000.00 -> 50000.00
    var GroupSep = "\\" + CurrencyGroupSeparator; // just in case we need remove "." from the currency
    var currencyGroupSep = new RegExp(GroupSep, 'g');

    dispatchedVolume = dispatchedVolume.replace(currencyGroupSep, "");
    receivedVolume = receivedVolume.replace(currencyGroupSep, "");
    disVolAtRefTemp = disVolAtRefTemp.replace(currencyGroupSep, "");
    recVolAtRefTemp = recVolAtRefTemp.replace(currencyGroupSep, "");
    

    // Process decimal point to .
    // 5000,00 -> 5000.00

    var DecimalSep = "\\" + CurrencyDecimalSeparator; // just in case we need remove "." from the decimal
    var currencyDecimalSep = new RegExp(DecimalSep, 'g');

    dispatchedVolume = dispatchedVolume.replace(currencyDecimalSep, ".");
    receivedVolume = receivedVolume.replace(currencyDecimalSep, ".");
    disVolAtRefTemp = disVolAtRefTemp.replace(currencyDecimalSep, ".");
    recVolAtRefTemp = recVolAtRefTemp.replace(currencyDecimalSep, ".");

    if (isNaN(dispatchedVolume) || isNaN(receivedVolume) || isNaN(disVolAtRefTemp) || isNaN(recVolAtRefTemp)) {
        dispatchedVolume = receivedVolume = disVolAtRefTemp = recVolAtRefTemp = 0;
    }

    // toFixed to keep decimals, otherwise the Number or parseFloat function will de something weired 
    // Like: 40000.09 - 50000 = -9999.910000000000000003 :)

    // Temperature Variance = Received Vol - Dispatched Vol + Displatched Vol at Ref Temperature - Received Vol at Ref Temperature
    document.getElementById('Temperature_Variance').value =
    (Number(receivedVolume) - Number(dispatchedVolume) + Number(disVolAtRefTemp) - Number(recVolAtRefTemp)).toFixed(3);

    // Variance at Ref Temp = recVolAtRefTemp - disVolAtRefTemp
    document.getElementById('Variance_At_Ref_Temp').value =
    (Number(recVolAtRefTemp) - Number(disVolAtRefTemp)).toFixed(3);

    // Total Variance = receivedVolume - dispatchedVolume
    document.getElementById('Total_Variance').value =
    (Number(receivedVolume) - Number(dispatchedVolume)).toFixed(3);

}

/*
function AutoCalculateVars() {
    var dispatchedVolume = document.getElementById('Dispatched_Volume').value;
    var receivedVolume = document.getElementById('Drop_Volume').value;
    var disVolAtRefTemp = document.getElementById('Dispatched_Vol_At_Ref_Temp').value;
    var recVolAtRefTemp = document.getElementById('Received_Vol_At_Ref_Temp').value;


    // Process Strings before Convert to int or double
    // 50,000.00 -> 50000.00
    dispatchedVolume = dispatchedVolume.replace(/[,]/g, "");
    receivedVolume = receivedVolume.replace(/[,]/g, "");
    disVolAtRefTemp = disVolAtRefTemp.replace(/[,]/g, "");
    recVolAtRefTemp = recVolAtRefTemp.replace(/[,]/g, "");
    
    
    var tankDeliveryDetailsTable = document.getElementById('TankDeliveryDetails');


    // Initialize all input class to normal
    document.getElementById('Dispatched_Volume').className = DisplayStrings[4][0];
    document.getElementById('Drop_Volume').className = DisplayStrings[4][0];
    document.getElementById('Dispatched_Vol_At_Ref_Temp').className = DisplayStrings[4][0];
    document.getElementById('Received_Vol_At_Ref_Temp').className = DisplayStrings[4][0];

    if (isNaN(dispatchedVolume) || dispatchedVolume.length == 0) {
        tankDeliveryDetailsTable.rows[2].cells[2].innerHTML = DisplayStrings[6][0];
        document.getElementById('Dispatched_Volume').className = DisplayStrings[5][0];
        return;
    }
    else if (tankDeliveryDetailsTable.rows[2].cells[2].innerHTML != '')
    {return;}
    else {
        tankDeliveryDetailsTable.rows[2].cells[2].innerHTML = '';
        document.getElementById('Dispatched_Volume').className = DisplayStrings[4][0];
    }

    if (isNaN(receivedVolume) || receivedVolume.length == 0) {
        tankDeliveryDetailsTable.rows[3].cells[2].innerHTML = DisplayStrings[6][0];
        document.getElementById('Drop_Volume').className = DisplayStrings[5][0];
        return;
    }
    else if (tankDeliveryDetailsTable.rows[3].cells[2].innerHTML != '')
    { return; }
    else {
        tankDeliveryDetailsTable.rows[3].cells[2].innerHTML = '';
        document.getElementById('Drop_Volume').className = DisplayStrings[4][0];
    }

    if (isNaN(disVolAtRefTemp) || disVolAtRefTemp.length == 0) {
        tankDeliveryDetailsTable.rows[12].cells[2].innerHTML = DisplayStrings[6][0];
        document.getElementById('Dispatched_Vol_At_Ref_Temp').className = DisplayStrings[5][0];
        return;
    }
    else if (tankDeliveryDetailsTable.rows[12].cells[2].innerHTML != '')
    { return; }
    else {
        tankDeliveryDetailsTable.rows[12].cells[2].innerHTML = '';
        document.getElementById('Dispatched_Vol_At_Ref_Temp').className = DisplayStrings[4][0];
    }

    if (isNaN(recVolAtRefTemp) || recVolAtRefTemp.length == 0) {
        tankDeliveryDetailsTable.rows[13].cells[2].innerHTML = DisplayStrings[6][0];
        document.getElementById('Received_Vol_At_Ref_Temp').className = DisplayStrings[5][0];
        return;
    }
    else if (tankDeliveryDetailsTable.rows[13].cells[2].innerHTML != '')
    { return; }
    else {
        tankDeliveryDetailsTable.rows[13].cells[2].innerHTML = '';
        document.getElementById('Received_Vol_At_Ref_Temp').className = DisplayStrings[4][0];
    }



    // toFixed to keep decimals, otherwise the Number or parseFloat function will de something weired 
    // Like: 40000.09 - 50000 = -9999.910000000000000003 :)

    // Temperature Variance = Received Vol - Dispatched Vol + Displatched Vol at Ref Temperature - Received Vol at Ref Temperature
    document.getElementById('Temperature_Variance').value =
    (Number(receivedVolume) - Number(dispatchedVolume) + Number(disVolAtRefTemp) - Number(recVolAtRefTemp)).toFixed(3);
    
    // Variance at Ref Temp = recVolAtRefTemp - disVolAtRefTemp
    document.getElementById('Variance_At_Ref_Temp').value =
    (Number(recVolAtRefTemp) - Number(disVolAtRefTemp)).toFixed(3);
    
    // Total Variance = receivedVolume - dispatchedVolume
    document.getElementById('Total_Variance').value =
    (Number(receivedVolume) - Number(dispatchedVolume)).toFixed(3);

    var selectedTankID = document.getElementById("Tank_ID").value;
    
    for (i = 0; i < tanks.length; i++) {
        if (selectedTankID == Number(tanks[i][0])) {
            if (Number(receivedVolume) > Number(tanks[i][1])) {
                tankDeliveryDetailsTable.rows[3].cells[2].innerHTML = DisplayStrings[3][0] +": "+ tanks[i][1];
                document.getElementById('Drop_Volume').className = DisplayStrings[5][0];
                return;
            }
            if (Number(dispatchedVolume) > Number(tanks[i][1])) {
                tankDeliveryDetailsTable.rows[2].cells[2].innerHTML = DisplayStrings[3][0] +": "+ tanks[i][1];
                document.getElementById('Dispatched_Volume').className = DisplayStrings[5][0];
                return;
            }
        }
    }
    
}

function CapacityCheckLoss() {

    document.getElementById('Loss_Volume').onchange = CheckLoss;
    CheckLoss();
}


function CheckLoss()
{
    var selectedTankID = document.getElementById("Tank_ID").value;
    var lossVolume = document.getElementById("Loss_Volume").value;

    var tankLossDetailsTable = document.getElementById('TankLossDetails');
       
    // init the class
    tankLossDetailsTable.rows[2].cells[2].innerHTML = '';
    document.getElementById('Loss_Volume').className = DisplayStrings[4][0];
    
    lossVolume = lossVolume.replace(/[,]/g, "");
    if (isNaN(lossVolume)) {
        tankLossDetailsTable.rows[2].cells[2].innerHTML = DisplayStrings[6][0];
        document.getElementById('Loss_Volume').className = DisplayStrings[5][0];
        return;
    }
    else {
        tankLossDetailsTable.rows[2].cells[2].innerHTML = '';
        document.getElementById('Loss_Volume').className = DisplayStrings[4][0];
    }

    
    for (i = 0; i < tanks.length; i++) {
        if (selectedTankID == Number(tanks[i][0])) {
            if (Number(lossVolume) > Number(tanks[i][1])) {
                tankLossDetailsTable.rows[2].cells[2].innerHTML = DisplayStrings[3][0]+ ": " + tanks[i][1];
                document.getElementById('Loss_Volume').className = DisplayStrings[5][0];
                return;
            }
        }
    }
}

function CapacityCheckTransfer() {
    document.getElementById('Transfer_Volume').onchange = CheckTransfer;
    CheckTransfer();
    }
    
function CheckTransfer()
{
    var fromTankID = document.getElementById("From_Tank_ID").value;
    var toTankID = document.getElementById("To_Tank_ID").value;

    var transferVolume = document.getElementById("Transfer_Volume").value;

    var tankTransferDetailsTable = document.getElementById('TankTransferDetails');

    // Init
    tankTransferDetailsTable.rows[2].cells[2].innerHTML = '';
    document.getElementById('Transfer_Volume').className = DisplayStrings[4][0];

    transferVolume = transferVolume.replace(/[,]/g, "");

    if (isNaN(transferVolume)) {
        tankTransferDetailsTable.rows[2].cells[2].innerHTML = DisplayStrings[6][0];
        document.getElementById('Transfer_Volume').className = DisplayStrings[5][0];
        return;
    }
    else {
        tankTransferDetailsTable.rows[2].cells[2].innerHTML = '';
        document.getElementById('Transfer_Volume').className = DisplayStrings[4][0];
    }
    
    for (i = 0; i < tanks.length; i++) {
        if (fromTankID == Number(tanks[i][0])) {
            if (Number(transferVolume) > Number(tanks[i][1])) {
                tankTransferDetailsTable.rows[2].cells[2].innerHTML = DisplayStrings[1][0] + tanks[i][1];
                document.getElementById('Transfer_Volume').className = DisplayStrings[5][0];
                return;
            }
        }

        if (toTankID == Number(tanks[i][0])) {
            if (Number(transferVolume) > Number(tanks[i][1])) {
                tankTransferDetailsTable.rows[2].cells[2].innerHTML = DisplayStrings[2][0] + tanks[i][1];
                document.getElementById('Transfer_Volume').className = DisplayStrings[5][0];
                return;
            }
        }
    }
}
*/