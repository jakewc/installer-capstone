function rolesOnload() {
    document.getElementById("Role_USERS").onchange = userManagementChange;
    userManagementChange();
}

function userManagementChange() {
    var users = document.getElementById("Role_USERS");
    var configuration = document.getElementById("Role_CONFIGURATION");
    var support = document.getElementById("Role_SUPPORT");
    var reports = document.getElementById("Role_REPORTS");
    var fuelRecon = document.getElementById("Role_FUEL_RECON");
    var pricing = document.getElementById("Role_PRICING");
    var blocking = document.getElementById("Role_BLOCKING");
    var monitor = document.getElementById("Role_MONITOR");
    var monitor = document.getElementById("Role_MONITOR");
    var modechange = document.getElementById("Role_MODECHANGE");

    var selectedUsersManagement = users.options[users.selectedIndex].value;

    if (selectedUsersManagement == 2) {
        configuration.disabled = true;
        configuration.value = 2;
        support.disabled = true;
        support.value = 2;
        reports.disabled = true;
        reports.value = 2;
        fuelRecon.disabled = true;
        fuelRecon.value = 2;
        pricing.disabled = true;
        pricing.value = 2;
        blocking.disabled = true;
        blocking.value = 2;
        monitor.disabled = true;
        monitor.value = 2;
        modechange.disabled = true;
        modechange.value = 2;
    }
    else {
        configuration.disabled = false;
        support.disabled = false;
        reports.disabled = false;
        fuelRecon.disabled = false;
        pricing.disabled = false;
        blocking.disabled = false;
        monitor.disabled = false;
        modechange.disabled = false;
    }


}
