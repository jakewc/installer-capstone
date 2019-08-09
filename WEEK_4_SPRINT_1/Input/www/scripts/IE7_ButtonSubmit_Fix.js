/* this script was supposed to handle the IE7 submit value button bug!
 * however, this did not work on IE7 Windows Vista 64 bit test */

function ChangeButtonToInputForIE7() {  
   /* trigger our debugger */
   debugger;
   $("form").on("click", "button", function() {  
   var f = $(this).get(0).form;  
  
   if (typeof(f) != 'undefined') 
   {  
      if (this.type && (this.type.toUpperCase() != 'SUBMIT'))  
	  return;  
      $("input[type='hidden'][name='"+this.name+"']", f).remove(); 
      if (typeof(this.attributes.value) != 'undefined')  
         $(f).append('<input type="hidden" name="'+this.name+'_hidden' +'" value="'+this.attributes.value.value+'">');  
      $(f).trigger('submit');  
    }  
  });  
};  

/* source:
 * http://rommelsantor.com/clog/2012/03/12/fixing-the-ie7-submit-value */
