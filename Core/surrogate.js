
document.addEventListener("DOMContentLoaded", function(event) {
	if (!duckduckgoBlockerData.blockingEnabled) { return }

	console.log("Overriding GoogleAnalyticsObject")
	var temp = window["GoogleAnalyticsObject"]
	window[temp] = ga
}, true)
