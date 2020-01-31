using Toybox.Application;
using Toybox.WatchUi;

class elevenfortyfiveApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        if (WatchUi has :WatchFaceDelegate) {
            return [ new elevenfortyfiveView(), new elevenfortyfiveDelegate()];
        } else {
            return [ new elevenfortyfiveView()];
        }
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() {
        WatchUi.requestUpdate();
    }

}