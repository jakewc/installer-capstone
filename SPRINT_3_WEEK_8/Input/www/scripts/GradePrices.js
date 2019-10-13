function GradePricesOnload() {
    document.getElementsByName('Grade_Type')[0].onchange = GradeTypeChange;
    GradeTypeChange();
}

function GradeTypeChange() {
    var type = document.getElementsByName('Grade_Type')[0];
    var selectedType = type.options[type.selectedIndex].value;

    switch(selectedType)
    {
    case "0":
        document.getElementById('GradePriceTable').style.display = '';
	ChangePostMixGridDisplay('');
	ChangeActionButtons('');
      break;
    case "1":
        document.getElementById('GradePriceTable').style.display = 'none'; 
	ChangePostMixGridDisplay('');
	ChangeActionButtons('none');	
      break;
    case "2":
        document.getElementById('GradePriceTable').style.display = '';
	ChangePostMixGridDisplay('none');
	ChangeActionButtons('');
      break;
    default:
        document.getElementById('GradePriceTable').style.display = '';
	ChangePostMixGridDisplay('');
	ChangeActionButtons('');
      break;
      
    }
}

function ChangePostMixGridDisplay(displayStyle) {
    var elements = document.getElementById('GradePriceForm');
    var name = 'Label_postmix_grade';
    for (var i = 0; i < elements.length; i++) {
        try {
            if (elements[i].id.substring(0, name.length) == name) {
                elements[i].style.display = displayStyle;
            }
        }
        catch (err) { }
    }
}

function ChangeActionButtons(displayStyle) {
    document.getElementById('id').style.display = displayStyle; 
}


