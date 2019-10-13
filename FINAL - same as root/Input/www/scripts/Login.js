function POSTBrowserInfo() {  
	// get the first form!
	var f = document.forms[0];

	if (typeof(f) != 'undefined')
	{
		// POST the browser details to our form!
		$(f).append('<input type="hidden" name="Browser.Name" value="'+$.browser.name+'">');
		$(f).append('<input type="hidden" name="Browser.ClassName" value="'+$.browser.className+'">');
		$(f).append('<input type="hidden" name="Browser.VersionNumber" value="'+$.browser.versionNumber+'">');
		$(f).append('<input type="hidden" name="Browser.VersionString" value="'+$.browser.version+'">');
	}
};  

