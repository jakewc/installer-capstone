function siteConfigurationOnLoad() {
    if (document.getElementById) {
        document.getElementById("Auto_PostMix_Price").onchange = AutoPostMixPricesChanged;
        AutoPostMixPricesChanged();
    }
}

function AutoPostMixPricesChanged() {

	try {
		var table = document.getElementById("Pricing");
		var checkBox = document.getElementById("Auto_PostMix_Price");
        var rowCount = table.rows.length;
		
		// We have one extra row to content with if price level control is displayed.
		var blendDecIndex = rowCount == 4 ? 2 : 1  
		var blendRoundIndex = rowCount == 4 ? 3 : 2
		if (checkBox.checked) {
			document.getElementById("Pricing").rows[blendDecIndex].style.display = '';
			document.getElementById("Pricing").rows[blendRoundIndex].style.display = '';
		}
		else {
			document.getElementById("Pricing").rows[blendDecIndex].style.display = 'none';
			document.getElementById("Pricing").rows[blendRoundIndex].style.display = 'none';
		}	
        
    } catch (err) {
        alert(err);
    }
	
}