function TerminalsOnload() {
    document.getElementById("Perm_CONNECT").onchange = connectionChange;
    connectionChange();
}

function connectionChange() {
    var connect = document.getElementById("Perm_CONNECT");
    var selectedConnect = connect.options[connect.selectedIndex].value;

    switch (selectedConnect)
    {
    case "0":
        document.getElementById("Perm_CONTROL").disabled=true;
        document.getElementById("Perm_CONFIGURE").disabled = true;
        document.getElementById("Perm_MODE").disabled = true;
        document.getElementById("Perm_PRICE").disabled = true;
      break;
    case "1":
    default:
      	if (document.getElementById("Perm_CONNECT").disabled == false)
	{
        	document.getElementById("Perm_CONTROL").disabled = false;
        	document.getElementById("Perm_CONFIGURE").disabled = false;
        	document.getElementById("Perm_MODE").disabled = false;
        	document.getElementById("Perm_PRICE").disabled = false;
	}
    }
}
