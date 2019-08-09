function ActivationOnload() {
    $("#Customer").oninput = CustomerCodeChange;
}

function IsChecksumValid( CustomerCode )
{
		// Covert the customer code to upper case - validation is case insensitive
		var uppercaseCode = CustomerCode.toUpperCase();
		
		// Validate customer code has at least 3 identifying characters and a 2 digit CRC
		// The middle is made up of at least 1 random character
		if(uppercaseCode.length < 6) {
			return false;
		}
		
		// Save the check characters from the entered customer code
		var enteredCRC = uppercaseCode.substring(uppercaseCode.length-2,uppercaseCode.length);
		
		var asciiTotal = 0;
		var charValue = 0;
		
		// Loop through all characters except the last 2 check characters, and
		// add up the ascii values of each character.
		for ( i = 0; i < uppercaseCode.length-2; i++)
		{
			charValue = uppercaseCode.charCodeAt(i);
			asciiTotal = asciiTotal + charValue;
		}
					
		// Convert the ascii total value to HEX	
		var hexCRC = asciiTotal.toString(16);
		hexCRC = hexCRC.toUpperCase();

		// And then get the 2 least significant digits of the HEX value.
		var calculatedCRC = hexCRC.substring(hexCRC.length-2,hexCRC.length);
		
		// Compare the two CRCs to see if they match.
		if (calculatedCRC == enteredCRC) {
			return true;
		}

		return false;	
}

function CustomerCodeChange() {
	var self = document.getElementById("Customer");
	var code = self.value;
	code = code.toUpperCase();
	self.value = code;
	var LocationFieldset = document.getElementsByName("Location");
	var LocationDetailsTable = LocationFieldset[0].children[1];
	var IntegratorCodeRow = LocationDetailsTable.rows[0];
	if ( IntegratorCodeRow.childElementCount == 2 )
	{
		var newCell = IntegratorCodeRow.insertCell(2);
		newCell.align = "left";
	}
	var status = 0; // no code entered - no image
	indicatorCell = IntegratorCodeRow.cells[2];
	
	if ( code.length > 11 )
	{
		// check validity
		if( IsChecksumValid( code ) )
			status = 1;
		else
			status = 2;
	}
	else if ( code.length > 0 )
	{
		// check for invalid characters (e.g. #$@%)
		var containsInvalidCharacter = false;
		if ( !code.match(/^[0-9a-zA-Z]+$/) )
			status = 2; // contains invalid characters
		else
			status = 3; // some characters but not enough
	}
	else
		status = 0; // no code entered - no image

	
	switch ( status )
	{
	case 0:
		indicatorCell.innerHTML = '&nbsp;';
		break;
	case 1: // valid
		var img = document.createElement('img');
		img.src = "/images/GreenTickSmall.png";
		indicatorCell.innerHTML = '&nbsp;';
		indicatorCell.appendChild( img );
		break;
	case 2: // invalid
		var img = document.createElement('img');
		img.src = "/images/RedCrossSmall.png";
		indicatorCell.innerHTML = '&nbsp;';
		indicatorCell.appendChild( img );
		break;
	case 3: // incomplete
		var img = document.createElement('img');
		img.src = "/images/IncompleteSmall.png";
		indicatorCell.innerHTML = '&nbsp;';
		indicatorCell.appendChild( img );
		break;
	}
}
