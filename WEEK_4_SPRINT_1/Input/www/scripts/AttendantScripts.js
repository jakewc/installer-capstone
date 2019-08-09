var avtive_Tag;

function AttendantOnload() {
    avtive_Tag = document.getElementById('Attendant_Tag_Active');
    avtive_Tag.onchange = TagActiveChanged;
    TagActiveChanged();
}

function TagActiveChanged() {
    if(avtive_Tag.checked)
        $("#Attendant_Tag_Info").slideDown("fast");
    else
        $("#Attendant_Tag_Info").slideUp("fast");
}

