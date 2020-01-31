using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Application;
using Toybox.Time;
using Toybox.Time.Gregorian;

class elevenfortyfiveView extends WatchUi.WatchFace {
    hidden var width;
    hidden var height;
    hidden var textHeight;
    hidden var northHemisphere = true;
    hidden var bitmap_hour;
    hidden var bitmap_althour;
    hidden var bitmap_nighthour;
    hidden var bitmap_minute;
    hidden var bitmap_term;
    hidden var text_term = "";
    hidden var isAwake;
    hidden var lastUpdatedTs = 0;
    hidden var screenShape;
    hidden var borderWidth = 15;
    hidden var partialUpdateAllowed = false;

    function initialize() {
        WatchFace.initialize();
        partialUpdateAllowed = (Toybox.WatchUi.WatchFace has :onPartialUpdate);
        System.println("Partial update allowed:" + partialUpdateAllowed);
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
        width = dc.getWidth();
        height = dc.getHeight();
        textHeight = dc.getFontHeight(Graphics.Graphics.FONT_XTINY);
        screenShape = System.getDeviceSettings().screenShape;
        var smallSide = height;
        if (width < height) {
            smallSide = width;
        }
        if (smallSide < 200) {
            borderWidth = 3;
        } else if (smallSide < 210) {
            borderWidth = 10;
        } else if (smallSide < 270) {
            borderWidth = 25;
        } else if (smallSide < 300) {
            borderWidth = 35;
        } else {
            borderWidth = 45;
        }

        System.println("screen width:" + width + ",height:" + height + ",shape:" + screenShape +
            ",tiny text height:" + textHeight + ",borderWidth:" + borderWidth);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        // this is necessary as some watch may still be using the clip rectangle set in onPartialUpdate()
        if (Graphics.Dc has :setClip) {
            dc.setClip(0, 0, width, height);
        }
        // not using last GPS position which isn't quite reliable
        /*
        // update hemisphere if we have last activity's location
        var locAccuracy = Activity.getActivityInfo().currentLocationAccuracy;
        if (locAccuracy == Position.QUALITY_LAST_KNOWN ||
                locAccuracy == Position.QUALITY_GOOD) {
            var curLoc = Activity.getActivityInfo().currentLocation;
            if (curLoc != null) {
                var lat= curLoc.toDegrees()[0].toFloat();
                System.println("Current Latitude:" + lat);
                if (lat < 0) {
                    northHemisphere = false;
                } else {
                    northHemisphere = true;
                }
            }
        }
        */
        northHemisphere = !Application.getApp().getProperty("SouthHemisphere");

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        var clockTime = System.getClockTime();
        //if (bitmap_hour == null || clockTime.min == 0) {
        //System.println("Updating hour png");
        updateHourBitmap(clockTime.hour);
        updateSolarTermAndDate();
        //}

        //if (bitmap_minute == null || clockTime.min % 15 == 0) {
        //System.println("Updating minute png");
        updateMinuteBitmap(clockTime.min);
	    //}

        // alternative name on top
        dc.drawBitmap(width/2-30, borderWidth, bitmap_althour);

        // night name on top, below alternative name
        if (bitmap_nighthour != null) {
            dc.drawBitmap(width/2-30, borderWidth + 30, bitmap_nighthour);
        }

        // modern hour/minute clock on the left
        var semiXOffset = 0;
        if (screenShape == System.SCREEN_SHAPE_SEMI_ROUND) {
            semiXOffset = 5;
        }
        var offset = dc.getFontHeight(Graphics.FONT_NUMBER_MEDIUM)/3;
        if (height <= 200) {
            offset += 5;
        }
        var hours = clockTime.hour;
        if (!System.getDeviceSettings().is24Hour && hours > 12) {
            hours = hours - 12;
        }
        dc.setColor(Application.getApp().getProperty("HourColor"), Graphics.COLOR_TRANSPARENT);
        dc.drawText(borderWidth + semiXOffset, height/2-offset + Application.getApp().getProperty("HourDigitYOffset"), Graphics.FONT_NUMBER_MEDIUM, Lang.format("$1$", [hours]), Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(Application.getApp().getProperty("MinuteColor"), Graphics.COLOR_TRANSPARENT);
        dc.drawText(borderWidth + semiXOffset, height/2+offset + Application.getApp().getProperty("MinuteDigitYOffset"), Graphics.FONT_NUMBER_MEDIUM, Lang.format("$1$", [clockTime.min.format("%02d")]), Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_LEFT);

        // old Chinese clock hour on the right
        dc.drawBitmap(width-borderWidth - 60 - semiXOffset, height/2-30, bitmap_hour);
        dc.drawBitmap(width-borderWidth - 60 - semiXOffset, height/2, bitmap_minute);

        // show modern date on bottom, above solar term
        var spaceHeight = textHeight/5;
        if (height <= 210) {
            spaceHeight = 0;
        }
        spaceHeight += Application.getApp().getProperty("BottomInfoSpaceOffset");
        var startY = height - textHeight * 2 - spaceHeight - borderWidth/2 - 30 + Application.getApp().getProperty("BottomInfoOffset");
        if (screenShape == System.SCREEN_SHAPE_SEMI_ROUND) {
            startY -= (width-height);
        }

        if (Application.getApp().getProperty("ShowDate")) {
	        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
	        var dateString = Lang.format(
	            "$1$ $2$ $3$", [today.day_of_week, today.day, today.month]
	        );
            dc.drawText(width/2, startY, Graphics.FONT_XTINY, dateString, Graphics.TEXT_JUSTIFY_CENTER);
        }
        // solar term on bottom
        if (bitmap_term != null) {
            dc.drawBitmap(width/2-30, startY + textHeight + spaceHeight, bitmap_term);
        }
        // show xx days ago or in xx days
        if (text_term.length() > 0 && Application.getApp().getProperty("ShowDaysToTerm")) {
            dc.drawText(width/2, startY + textHeight + spaceHeight * 2 + 30, Graphics.FONT_XTINY, text_term, Graphics.TEXT_JUSTIFY_CENTER);
        }
        // show battery
        if (Application.getApp().getProperty("ShowBattery")) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(width - width/5, height - height/5, Graphics.FONT_XTINY, System.getSystemStats().battery.toNumber() + "%",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
        // show heart rate
        //onPartialUpdate(dc);
    }

    function onPartialUpdate(dc) {
        if (Application.getApp().getProperty("ShowHeartRate")) {
            if (Graphics.Dc has :setClip) {
                dc.setClip(width/5 - textHeight/2, height - height/5 - textHeight/2, textHeight*2, textHeight);
            }
            dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
            dc.clear();
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            var hr = Activity.getActivityInfo().currentHeartRate;
            if (hr == null) {
                var hrHistory = ActivityMonitor.getHeartRateHistory(1, true);
                var hrSample = hrHistory.next();
                if (hrSample != null && hrSample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
                    hr = hrSample.heartRate;
                } else {
                    hr = "--";
                }
            }
	        dc.drawText(width/5, height - height/5, Graphics.FONT_XTINY, hr,
	                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

	function GetSolarTermResource(lon) {
	    switch (lon) {
	    case 0:
	        return Rez.Drawables.solarterm_0;
	    case 15:
	        return Rez.Drawables.solarterm_15;
	    case 30:
	        return Rez.Drawables.solarterm_30;
	    case 45:
	        return Rez.Drawables.solarterm_45;
	    case 60:
	        return Rez.Drawables.solarterm_60;
	    case 75:
	        return Rez.Drawables.solarterm_75;
	    case 90:
	        return Rez.Drawables.solarterm_90;
	    case 105:
	        return Rez.Drawables.solarterm_105;
	    case 120:
	        return Rez.Drawables.solarterm_120;
	    case 135:
	        return Rez.Drawables.solarterm_135;
	    case 150:
	        return Rez.Drawables.solarterm_150;
	    case 165:
	        return Rez.Drawables.solarterm_165;
	    case 180:
	        return Rez.Drawables.solarterm_180;
	    case 195:
	        return Rez.Drawables.solarterm_195;
	    case 210:
	        return Rez.Drawables.solarterm_210;
	    case 225:
	        return Rez.Drawables.solarterm_225;
	    case 240:
	        return Rez.Drawables.solarterm_240;
	    case 255:
	        return Rez.Drawables.solarterm_255;
	    case 270:
	        return Rez.Drawables.solarterm_270;
	    case 285:
	        return Rez.Drawables.solarterm_285;
	    case 300:
	        return Rez.Drawables.solarterm_300;
	    case 315:
	        return Rez.Drawables.solarterm_315;
	    case 330:
	        return Rez.Drawables.solarterm_330;
	    case 345:
	        return Rez.Drawables.solarterm_345;
	    }
	}

    function updateHourBitmap(hour) {
        bitmap_nighthour = null;
        switch (hour) {
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
    }

    function updateMinuteBitmap(minutes) {
        if (minutes < 15) {
            bitmap_minute = WatchUi.loadResource(Rez.Drawables.minute_15);
        } else if (minutes < 30) {
            bitmap_minute = WatchUi.loadResource(Rez.Drawables.minute_30);
        } else if (minutes < 45) {
            bitmap_minute = WatchUi.loadResource(Rez.Drawables.minute_45);
        } else {
            bitmap_minute = WatchUi.loadResource(Rez.Drawables.minute_60);
        }
    }

    function updateSolarTermAndDate() {
        var jdn = JDN(Time.now());
        var lon = EclipticLongitude(jdn);
        if (!northHemisphere) {
            lon = normalizeAngle(lon + 180);
        }

        var term = GetClosestSolarTerm(lon);
        if (term[1] > 0) {
            // in xx days
            text_term = "in " + term[1];
            if (term[1] == 1) {
                text_term += " day";
            } else {
                text_term += " days";
            }
        } else if (term[1] < 0) {
            // xx days ago
            text_term = (-term[1]) + " ";
            if (-term[1] == 1) {
                text_term += "day ago";
            } else {
                text_term += "days ago";
            }
        } else {
            text_term = "";
        }
        bitmap_term = WatchUi.loadResource(GetSolarTermResource(term[0]));
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
        bitmap_hour = null;
        bitmap_althour = null;
        bitmap_nighthour = null;
        bitmap_minute = null;
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
        System.println("[exit sleep]");
        isAwake = true;
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
        System.println("[enter sleep]");
        isAwake = false;
    }

}

class elevenfortyfiveDelegate extends WatchUi.WatchFaceDelegate {
    function onPowerBudgetExceeded(powerInfo) {
        WatchFaceDelegate.onPowerBudgetExceeded(powerInfo);
        System.println( "Average execution time: " + powerInfo.executionTimeAverage );
        System.println( "Allowed execution time: " + powerInfo.executionTimeLimit );
    }
}
