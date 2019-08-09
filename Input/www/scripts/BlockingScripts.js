function BlockingOnload() {
    document.getElementsByName("Device")[0].onchange = DeviceChange;
    DeviceChange();
}

function DeviceChange() {
    var device = document.getElementsByName("Device")[0];
    var selectedDevice = device.options[device.selectedIndex].value;

    switch(selectedDevice)
    {
    case "1":
        document.getElementById("GradeBlockingGroup").style.display = '';
        document.getElementById("TankBlockingGroup").style.display = 'none';
        document.getElementById("PumpBlockingGroup").style.display = 'none';
        document.getElementById("AttendantBlockingGroup").style.display = 'none';
      break;
    case "2":
        document.getElementById("GradeBlockingGroup").style.display = 'none';
        document.getElementById("TankBlockingGroup").style.display = '';
        document.getElementById("PumpBlockingGroup").style.display = 'none';
        document.getElementById("AttendantBlockingGroup").style.display = 'none';
      break;
    case "3":
        document.getElementById("GradeBlockingGroup").style.display = 'none';
        document.getElementById("TankBlockingGroup").style.display = 'none';
        document.getElementById("PumpBlockingGroup").style.display = '';
        document.getElementById("AttendantBlockingGroup").style.display = 'none';
        break;
    case "4":
        document.getElementById("GradeBlockingGroup").style.display = 'none';
        document.getElementById("TankBlockingGroup").style.display = 'none';
        document.getElementById("PumpBlockingGroup").style.display = 'none';
        document.getElementById("AttendantBlockingGroup").style.display = '';
        break;
    default:
        document.getElementById("GradeBlockingGroup").style.display = '';
        document.getElementById("TankBlockingGroup").style.display = '';
        document.getElementById("PumpBlockingGroup").style.display = '';
        document.getElementById("AttendantBlockingGroup").style.display = '';
    }
}

function BlockingHosesOnload() {
    document.getElementsByName("Pump")[0].onchange = PumpChange;
    PumpChange();
}

function PumpChange() {
    var pump = document.getElementsByName("Pump")[0];
    var selectedPump = pump.options[pump.selectedIndex].value;

    var pumpGroups = getElementsByPartialID("table", "PumpGroup");
    for (var pumpGroupIndex = 0; pumpGroupIndex < pumpGroups.length; pumpGroupIndex++) {
        if (pumpGroups[pumpGroupIndex]) {
            if (pumpGroups[pumpGroupIndex].id == "PumpGroup" + selectedPump ||
            selectedPump == 0) {
                pumpGroups[pumpGroupIndex].style.display = '';
            }
            else {
                pumpGroups[pumpGroupIndex].style.display = 'none';
            }
        }
    }
}