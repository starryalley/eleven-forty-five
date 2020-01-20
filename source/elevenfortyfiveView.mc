using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Application;
using Toybox.Time;
using Toybox.Time.Gregorian;

class elevenfortyfiveView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var northHemisphere = true;
        var curLoc = Activity.getActivityInfo().currentLocation;
        if (curLoc != null) {
            var lat= curLoc.toDegrees()[0].toFloat();
            System.println("Current Latitude:" + lat);
            if (lat < 0) {
                northHemisphere = false;
            }
        }

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        var bitmap_hour;
        var bitmap_althour;
        var bitmap_nighthour = null;
        switch (hours) {
            case 0:
                bitmap_hour = WatchUi.loadResource(Rez.Drawables.hour_00);
                bitmap_althour = WatchUi.loadResource(Rez.Drawables.hour_alt_23);
                bitmap_nighthour = WatchUi.loadResource(Rez.Drawables.hour_night_23);
                break;
            case 1:
                bitmap_hour = WatchUi.loadResource(Rez.Drawables.hour_01);
                bitmap_althour = WatchUi.loadResource(Rez.Drawables.hour_alt_01);
                bitmap_nighthour = WatchUi.loadResource(Rez.Drawables.hour_night_01);
                break;
            case 2:
                bitmap_hour = WatchUi.loadResource(Rez.Drawables.hour_02);
                bitmap_althour = WatchUi.loadResource(Rez.Drawables.hour_alt_01);
                bitmap_nighthour = WatchUi.loadResource(Rez.Drawables.hour_night_01);
                break;
            case 3:
                bitmap_hour = WatchUi.loadResource(Rez.Drawables.hour_03);
                bitmap_althour = WatchUi.loadResource(Rez.Drawables.hour_alt_03);
                bitmap_nighthour = WatchUi.loadResource(Rez.Drawables.hour_night_03);
                break;
            case 4:
                bitmap_hour = WatchUi.loadResource(Rez.Drawables.hour_04);
                bitmap_althour = WatchUi.loadResource(Rez.Drawables.hour_alt_03);
                bitmap_nighthour = WatchUi.loadResource(Rez.Drawables.hour_night_03);
                break;
            case 5:
                bitmap_hour = WatchUi.loadResource(Rez.Drawables.hour_05);
                bitmap_althour = WatchUi.loadResource(Rez.Drawables.hour_alt_05);
                break;
            case 6:
                bitmap_hour = WatchUi.loadResource(Rez.Drawables.hour_06);
                bitmap_althour = WatchUi.loadResource(Rez.Drawables.hour_alt_05);
                break;
            case 7:
                bitmap_hour = WatchUi.loadResource(Rez.Drawables.hour_07);
                bitmap_althour = WatchUi.loadResource(Rez.Drawables.hour_alt_07);
                break;
            case 8:
                bitmap_hour = WatchUi.loadResource(Rez.Drawables.hour_08);
                bitmap_althour = WatchUi.loadResource(Rez.Drawables.hour_alt_07);
                break;
            case 9:
                bitmap_hour = WatchUi.loadResource(Rez.Drawables.hour_09);
                bitmap_althour = WatchUi.loadResource(Rez.Drawables.hour_alt_09);
                break;
            case 10:
                bitmap_hour = WatchUi.loadResource(Rez.Drawables.hour_10);
                bitmap_althour = WatchUi.loadResource(Rez.Drawables.hour_alt_09);
                break;
            case 11:
                bitmap_hour = WatchUi.loadResource(Rez.Drawables.hour_11);
                bitmap_althour = WatchUi.loadResource(Rez.Drawables.hour_alt_11);
                break;
            case 12:
                bitmap_hour = WatchUi.loadResource(Rez.Drawables.hour_12);
                bitmap_althour = WatchUi.loadResource(Rez.Drawables.hour_alt_11);
                break;
            case 13:
                bitmap_hour = WatchUi.loadResource(Rez.Drawables.hour_13);
                bitmap_althour = WatchUi.loadResource(Rez.Drawables.hour_alt_13);
                break;
            case 14:
                bitmap_hour = WatchUi.loadResource(Rez.Drawables.hour_14);
                bitmap_althour = WatchUi.loadResource(Rez.Drawables.hour_alt_13);
                break;
            case 15:
                bitmap_hour = WatchUi.loadResource(Rez.Drawables.hour_15);
                bitmap_althour = WatchUi.loadResource(Rez.Drawables.hour_alt_15);
                break;
            case 16:
                bitmap_hour = WatchUi.loadResource(Rez.Drawables.hour_16);
                bitmap_althour = WatchUi.loadResource(Rez.Drawables.hour_alt_15);
                break;
            case 17:
                bitmap_hour = WatchUi.loadResource(Rez.Drawables.hour_17);
                bitmap_althour = WatchUi.loadResource(Rez.Drawables.hour_alt_17);
                break;
            case 18:
                bitmap_hour = WatchUi.loadResource(Rez.Drawables.hour_18);
                bitmap_althour = WatchUi.loadResource(Rez.Drawables.hour_alt_17);
                break;
            case 19:
                bitmap_hour = WatchUi.loadResource(Rez.Drawables.hour_19);
                bitmap_althour = WatchUi.loadResource(Rez.Drawables.hour_alt_19);
                bitmap_nighthour = WatchUi.loadResource(Rez.Drawables.hour_night_19);
                break;
            case 20:
                bitmap_hour = WatchUi.loadResource(Rez.Drawables.hour_20);
                bitmap_althour = WatchUi.loadResource(Rez.Drawables.hour_alt_19);
                bitmap_nighthour = WatchUi.loadResource(Rez.Drawables.hour_night_19);
                break;
            case 21:
                bitmap_hour = WatchUi.loadResource(Rez.Drawables.hour_21);
                bitmap_althour = WatchUi.loadResource(Rez.Drawables.hour_alt_21);
                bitmap_nighthour = WatchUi.loadResource(Rez.Drawables.hour_night_21);
                break;
            case 22:
                bitmap_hour = WatchUi.loadResource(Rez.Drawables.hour_22);
                bitmap_althour = WatchUi.loadResource(Rez.Drawables.hour_alt_21);
                bitmap_nighthour = WatchUi.loadResource(Rez.Drawables.hour_night_21);
                break;
            case 23:
                bitmap_hour = WatchUi.loadResource(Rez.Drawables.hour_23);
                bitmap_althour = WatchUi.loadResource(Rez.Drawables.hour_alt_23);
                bitmap_nighthour = WatchUi.loadResource(Rez.Drawables.hour_night_23);
                break;
        }

        var minutes = clockTime.min;
        var bitmap_minute;
        if (minutes < 15) {
            bitmap_minute = WatchUi.loadResource(Rez.Drawables.minute_15);
        } else if (minutes < 30) {
            bitmap_minute = WatchUi.loadResource(Rez.Drawables.minute_30);
        } else if (minutes < 45) {
            bitmap_minute = WatchUi.loadResource(Rez.Drawables.minute_45);
        } else {
            bitmap_minute = WatchUi.loadResource(Rez.Drawables.minute_60);
        }

        // modern hour/minute clock on the left
        dc.setColor(Application.getApp().getProperty("HourColor"), Graphics.COLOR_TRANSPARENT);
        dc.drawText(30, height/2-30, Graphics.FONT_LARGE, Lang.format("$1$", [hours]), Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(Application.getApp().getProperty("MinuteColor"), Graphics.COLOR_TRANSPARENT);
        dc.drawText(30, height/2, Graphics.FONT_LARGE, Lang.format("$1$", [clockTime.min.format("%02d")]), Graphics.TEXT_JUSTIFY_LEFT);

        // old Chinese clock on the right
        dc.drawBitmap(width-80, height/2-30, bitmap_hour);
        dc.drawBitmap(width-80, height/2, bitmap_minute);

        // alternative name on top
        dc.drawBitmap(width/2-30, 10, bitmap_althour);

        // night name on top, below alternative name
        if (bitmap_nighthour != null) {
            dc.drawBitmap(width/2-30, 40, bitmap_nighthour);
        }

        var jdn = JDN(Time.now());
        var lon = EclipticLongitude(jdn);
        if (!northHemisphere) {
            System.println("Reverse Solar Term for south hemisphere");
            lon = normalizeAngle(lon + 180);
        }
        //System.println(jdn + ", " + lon);
        var term = GetClosestSolarTerm(lon);
        if (term[1] > 0) {
            // in xx days
            dc.drawText(width/2, height-25, Graphics.FONT_XTINY, "in " + term[1] + " days", Graphics.TEXT_JUSTIFY_CENTER);
        } else if (term[1] < 0) {
            // xx days ago
            dc.drawText(width/2, height-25, Graphics.FONT_XTINY, (-term[1]) + " days ago", Graphics.TEXT_JUSTIFY_CENTER);
        }
        var bitmap_term = WatchUi.loadResource(GetSolarTermResource(term[0]));
        if (bitmap_term != null) {
            dc.drawBitmap(width/2-30, height-55, bitmap_term);
        }
        // show modern date above solar term
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var dateString = Lang.format(
            "$1$ $2$ $3$", [today.day_of_week, today.day, today.month]
        );
        if (Application.getApp().getProperty("ShowDate")) {
            dc.drawText(width/2, height - 75, Graphics.FONT_XTINY, dateString, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

}
