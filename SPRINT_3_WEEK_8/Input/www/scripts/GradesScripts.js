function gradesOnload() {
    BlendTypeChange();
    LimitTypeChange();
    document.getElementById("Grade_Type").onchange = BlendTypeChange;
    document.getElementById("Alloc_Limit_Type").onchange = LimitTypeChange;
}

function LimitTypeChange() {
    var GradeTable = document.getElementById("Grade_Details");
    var selectedLimit = document.getElementById("Alloc_Limit_Type").value;
    if(selectedLimit == 0) {
        GradeTable.rows[5].style.display = 'none';
    }
    else {
        GradeTable.rows[5].style.display = '';
    }
}

function BlendTypeChange() {
    var BlendTable = document.getElementById("Blend_Details");
    var PostMixRatioGroup = document.getElementById("PostMixRatioGroup");
    var selectedType = document.getElementById("Grade_Type").value;
    /* the first blend table row (blend type) is always visible */ 

    if(selectedType === "0") {
		/* base grade - no blending */
		for (var i = BlendTable.rows.length-1; i>0; i-- ) {
		    BlendTable.rows[i].style.display = 'none';
		}
        PostMixRatioGroup.style.display = 'none'
    }
    else {        
		BlendTable.rows[1].style.display = '';
		BlendTable.rows[2].style.display = ''; 
        if (selectedType === "1") {
			/* fixed blending */
            BlendTable.rows[3].style.display = '';
			if ( BlendTable.rows.length == 5 ) {
				BlendTable.rows[4].style.display = 'none';
			}
            PostMixRatioGroup.style.display = 'none'
        }
        else {
			/* variable blending */
			BlendTable.rows[3].style.display = 'none';
			if ( BlendTable.rows.length == 5 ) {
				BlendTable.rows[4].style.display = '';
			}
            PostMixRatioGroup.style.display = ''
        }
    }
}