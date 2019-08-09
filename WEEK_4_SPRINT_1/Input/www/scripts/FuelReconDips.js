function ReadingValue1Change() 
{
    var checkbox = document.getElementById("save_reading1");
    if ( checkbox != null )
    {
	    checkbox.checked = 'true';
    }
};

function ReadingValue2Change() 
{
    var checkbox = document.getElementById("save_reading2");
    if ( checkbox != null )
    {
	    checkbox.checked = 'true';
    }
};

function ReadingValue3Change() 
{
    var checkbox = document.getElementById("save_reading3");
    if ( checkbox != null )
    {
	    checkbox.checked = 'true';
    }
};

function ReadingValue4Change() 
{
    var checkbox = document.getElementById("save_reading4");
    if ( checkbox != null )
    {
	    checkbox.checked = 'true';
    }
};


function FuelReconDipsOnLoad() {
    if (document.getElementById) 
    {
        document.getElementById("reading_value1").onchange = ReadingValue1Change;
	document.getElementById("dip_type1").onchange = ReadingValue1Change;
        document.getElementById("reading_value2").onchange = ReadingValue2Change;
	document.getElementById("dip_type2").onchange = ReadingValue2Change;
        document.getElementById("reading_value3").onchange = ReadingValue3Change;
	document.getElementById("dip_type3").onchange = ReadingValue3Change;
        document.getElementById("reading_value4").onchange = ReadingValue4Change;
	document.getElementById("dip_type4").onchange = ReadingValue4Change;
	
    }
};
