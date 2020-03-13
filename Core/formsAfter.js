
(function() {

 function findForms() {
    var forms = document.getElementsByTagName("form")
    var formCount = forms ? forms.length : 0
    duckduckgoDebugMessaging.log("*** " + formCount + " forms found after document")
 }
 
    findForms()
    setTimeout(findForms, 3000);
 
}) ()
