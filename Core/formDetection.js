(function() {

    duckduckgoDebugMessaging.log("DDG - login.js");

    function onSubmit() {
        duckduckgoMessaging.possibleLogin();
    }

    function addFormListener(form) {
        var inputs = form.getElementsByTagName("input");
        if (!inputs || inputs.length == 0) { return }
        for (var i = 0; i < inputs.length; i++) {
            var input = inputs[i];
            if (input.type == "password") {
                duckduckgoDebugMessaging.log("DDG - adding login listener");
                form.removeEventListener("submit", onSubmit);
                form.addEventListener("submit", onSubmit, false);
                return;
            }
        }
    }

    function addFormListenerToForms(forms) {
        if (!forms || forms.length == 0) { return }
        for (var i = 0; i < forms.length; i++) {
            var form = forms.item(i);
            addFormListener(form);
        }
    }

    function mutationCallback(mutationList, observer) {
      mutationList.forEach((mutation) => {
        mutation.addedNodes.forEach((node) => {
            if (node.nodeName == "FORM") {
                addFormListener(node);
            } else if (node.getElementsByTagName) {
                addFormListenerToForms(node.getElementsByTagName("form"));
            }
        });
      });
    }

    var observerOptions = {
        childList: true,
        subtree: true
    };

    var observer = new MutationObserver(mutationCallback);
    observer.observe(document, observerOptions);

}) ()
