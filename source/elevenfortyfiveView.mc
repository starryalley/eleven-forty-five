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
    hidden var lastNorthHemisphere = true;
    hidden var currentTermName = "";
    hidden var lastCalculatedTermTime = 0;
    hidden var text_term = "";
    hidden var isAwake = true;
    hidden var lastUpdatedTs = 0;
    hidden var screenShape;
    hidden var marginPixels = 15;
    hidden var partialUpdateAllowed = false;
    hidden var lastHR = 0;
    hidden var lastHRTime = 0;

    // for Chinese font
    hidden var font;
    hidden var fontData;
    hidden var fontWidth;

    const chToIndexMap = {
        "初" => 0, "正" => 1, "子" => 2, "丑" => 3, "寅" => 4,
        "卯" => 5, "辰" => 6, "巳" => 7, "午" => 8, "未" => 9,
        "申" => 10, "酉" => 11, "戌" => 12, "亥" => 13, "雞" => 14,
        "鳴" => 15, "平" => 16, "旦" => 17, "日" => 18, "出" => 19,
        "食" => 20, "時" => 21, "隅" => 22, "中" => 23, "昳" => 24,
        "哺" => 25, "入" => 26, "黃" => 27, "昏" => 28, "人" => 29,
        "定" => 30, "夜" => 31, "半" => 32, "更" => 33, "一" => 34,
        "二" => 35, "三" => 36, "四" => 37, "五" => 38, "刻" => 39,
        "立" => 40, "春" => 41, "雨" => 42, "水" => 43, "驚" => 44,
        "蟄" => 45, "分" => 46, "清" => 47, "明" => 48, "穀" => 49,
        "夏" => 50, "小" => 51, "滿" => 52, "芒" => 53, "種" => 54,
        "至" => 55, "暑" => 56, "大" => 57, "秋" => 58, "處" => 59,
        "白" => 60, "露" => 61, "寒" => 62, "霜" => 63, "降" => 64,
        "冬" => 65, "雪" => 66,
    };

    const hourNameMap = {
        23 => "子初", 0 => "子正",
        1 => "丑初", 2 => "丑正",
        3 => "寅初", 4 => "寅正",
        5 => "卯初", 6 => "卯正",
        7 => "辰初", 8 => "辰正",
        9 => "巳初", 10 => "巳正",
        11 => "午初", 12 => "午正",
        13 => "未初", 14 => "未正",
        15 => "申初", 16 => "申正",
        17 => "酉初", 18 => "酉正",
        19 => "戌初", 20 => "戌正",
        21 => "亥初", 22 => "亥正",
    };

    const nightHourNameMap = {
        19 => "一更", 20 => "一更",
        21 => "二更", 22 => "二更",
        23 => "三更", 0 => "三更",
        1 => "四更", 2 => "四更",
        3 => "五更", 4 => "五更",
    };

    const altHourNameMap = {
        23 => "夜半", 0 => "夜半",
        1 => "雞鳴", 2 => "雞鳴",
        3 => "平旦", 4 => "平旦",
        5 => "日出", 6 => "日出",
        7 => "食時", 8 => "食時",
        9 => "隅中", 10 => "隅中",
        11 => "日中", 12 => "日中",
        13 => "日昳", 14 => "日昳",
        15 => "哺時", 16 => "哺時",
        17 => "日入", 18 => "日入",
        19 => "黃昏", 20 => "黃昏",
        21 => "人定", 22 => "人定",
    };

    const termNameMap = {
        0 => "春分", 15 => "清明",
        30 => "穀雨", 45 => "立夏",
        60 => "小滿", 75 => "芒種",
        90 => "夏至", 105 => "小暑",
        120 => "大暑", 135 => "立秋",
        150 => "處暑", 165 => "白露",
        180 => "秋分", 195 => "寒露",
        210 => "霜降", 225 => "立冬",
        240 => "小雪", 255 => "大雪",
        270 => "冬至", 285 => "小寒",
        300 => "大寒", 315 => "立春",
        330 => "雨水", 345 => "驚蟄",
    };

    function drawChineseTextHorizontal(dc, text, color, x, y, justification) {
        if (text.length() == 0) {
            return;
        }
        // modify x according to justification
        var pixels = text.length() * fontWidth;
        switch(justification) {
        case Graphics.TEXT_JUSTIFY_CENTER:
            x = dc.getWidth() / 2 - pixels/2;
            break;
        case Graphics.TEXT_JUSTIFY_RIGHT:
            x = dc.getWidth() - pixels - x;
            break;
        }
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < text.length(); i++) {
            var ch = text.substring(i, i+1);
            if (chToIndexMap.hasKey(ch)) {
                drawTiles(dc, fontData[chToIndexMap.get(ch)], font, x + i*fontWidth, y);
            }
        }
    }

    // copied from https://github.com/sunpazed/garmin-tilemapper
    function drawTiles(dc, data, font, xoff, yoff) {
        for(var i = 0; i < data.size(); i++) {
            var packed_value = data[i];
            var char = (packed_value&0x00000FFF);
            var xpos = (packed_value&0x003FF000)>>12;
            var ypos = (packed_value&0xFFC00000)>>22;
            dc.drawText(xoff + xpos, yoff + ypos, font, (char.toNumber()).toChar(), Graphics.TEXT_JUSTIFY_LEFT);
        }
    }

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
        font = WatchUi.loadResource(Rez.Fonts.font_ch);
        fontData = WatchUi.loadResource(Rez.JsonData.fontData);
        fontWidth = dc.getFontHeight(font);
        marginPixels = fontWidth/3;

        System.println("screen width:" + width + ",height:" + height + ",shape:" + screenShape +
            ",tiny text height:" + textHeight + ",marginPixels:" + marginPixels + ",font size:" + fontWidth);
    }

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

        var marginOffset = marginPixels + Application.getApp().getProperty("MarginOffset");
        northHemisphere = !Application.getApp().getProperty("SouthHemisphere");
        var hemisphereChanged = false;
        if (lastNorthHemisphere != northHemisphere) {
            lastNorthHemisphere = northHemisphere;
            hemisphereChanged = true;
        }

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        var clockTime = System.getClockTime();
        var hours = clockTime.hour;

        // calculate solar term every 1 hour
        if (Time.now().value() - lastCalculatedTermTime > 3600 || hemisphereChanged) {
            updateSolarTermAndDate();
            lastCalculatedTermTime = Time.now().value();
        }

        // alternative name on top
        if (isAwake) {
            drawChineseTextHorizontal(dc, altHourNameMap[hours], Application.getApp().getProperty("AltHourColor"),
                width/2, marginOffset, Graphics.TEXT_JUSTIFY_CENTER);
            // night name on top, below alternative name
            if (nightHourNameMap.hasKey(hours)) {
                drawChineseTextHorizontal(dc, nightHourNameMap[hours], Application.getApp().getProperty("NightHourColor"),
                    width/2, marginOffset + fontWidth, Graphics.TEXT_JUSTIFY_CENTER);
            }
        }

        // modern hour/minute clock on the left
        var semiXOffset = 0;
        if (screenShape == System.SCREEN_SHAPE_SEMI_ROUND) {
            semiXOffset = 5;
        }
        var offset = dc.getFontHeight(Graphics.FONT_NUMBER_MEDIUM);

        if (!System.getDeviceSettings().is24Hour && hours > 12) {
            hours = hours - 12;
        }
        dc.setColor(Application.getApp().getProperty("HourColor"), Graphics.COLOR_TRANSPARENT);
        dc.drawText(marginOffset + semiXOffset, height/2-offset - Application.getApp().getProperty("TimeDigitYOffset"),
            Graphics.FONT_NUMBER_MEDIUM, Lang.format("$1$", [hours]), Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(Application.getApp().getProperty("MinuteColor"), Graphics.COLOR_TRANSPARENT);
        dc.drawText(marginOffset + semiXOffset, height/2 + Application.getApp().getProperty("TimeDigitYOffset"),
            Graphics.FONT_NUMBER_MEDIUM, Lang.format("$1$", [clockTime.min.format("%02d")]), Graphics.TEXT_JUSTIFY_LEFT);

        // old Chinese clock hour on the right
        drawChineseTextHorizontal(dc, hourNameMap[clockTime.hour], Application.getApp().getProperty("HourColor"),
            width-marginOffset - fontWidth * 2 - semiXOffset, height/2-fontWidth, Graphics.TEXT_JUSTIFY_LEFT);
        drawChineseTextHorizontal(dc, getMinuteInChinese(clockTime.min), Application.getApp().getProperty("MinuteColor"),
            width-marginOffset - fontWidth * 2 - semiXOffset, height/2, Graphics.TEXT_JUSTIFY_LEFT);

        // show modern date on bottom, above solar term
        var spaceHeight = textHeight/5;
        if (height <= 210) {
            spaceHeight = 0;
        }
        spaceHeight += Application.getApp().getProperty("BottomInfoSpaceOffset");
        var startY = height - textHeight * 2 - spaceHeight - marginOffset/2 - fontWidth + Application.getApp().getProperty("BottomInfoOffset");
        if (screenShape == System.SCREEN_SHAPE_SEMI_ROUND) {
            startY -= (width-height);
        }

        if (isAwake && Application.getApp().getProperty("ShowDate")) {
            var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
            var dateString = Lang.format(
                "$1$ $2$ $3$", [today.day_of_week, today.day, today.month]
            );
            dc.setColor(Application.getApp().getProperty("DateColor"), Graphics.COLOR_TRANSPARENT);
            dc.drawText(width/2, startY, Graphics.FONT_XTINY, dateString, Graphics.TEXT_JUSTIFY_CENTER);
        }
        // solar term on bottom
        if (isAwake) {
            drawChineseTextHorizontal(dc, currentTermName, Application.getApp().getProperty("SolarTermColor"),
                width/2, startY + textHeight + spaceHeight, Graphics.TEXT_JUSTIFY_CENTER);
        }
        // show xx days ago or in xx days
        if (isAwake && text_term.length() > 0 && Application.getApp().getProperty("ShowDaysToTerm")) {
            dc.setColor(Application.getApp().getProperty("SolarTermNoteColor"), Graphics.COLOR_TRANSPARENT);
            dc.drawText(width/2, startY + textHeight + spaceHeight * 2 + fontWidth, Graphics.FONT_XTINY, text_term, Graphics.TEXT_JUSTIFY_CENTER);
        }
        // show battery
        if (isAwake && Application.getApp().getProperty("ShowBattery")) {
            dc.setColor(Application.getApp().getProperty("BatteryColor"), Graphics.COLOR_TRANSPARENT);
            dc.drawText(width - width/5, height - height/5, Graphics.FONT_XTINY, System.getSystemStats().battery.toNumber() + "%",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
        // show heart rate
        if (isAwake && Application.getApp().getProperty("ShowHeartRate")) {
            drawHeartRate(dc);
        }
    }

    function onPartialUpdate(dc) {
        //System.println("onPartialUpdate");
    }

    function drawHeartRate(dc) {
        if (Graphics.Dc has :setClip) {
            dc.setClip(width/5 - textHeight/2, height - height/5 - textHeight/2, textHeight*2, textHeight);
            dc.setColor(Graphics.COLOR_TRANSPARENT, Application.getApp().getProperty("BackgroundColor"));
            dc.clear();
        }
        dc.setColor(Application.getApp().getProperty("HRColor"), Graphics.COLOR_TRANSPARENT);
        var hr = Activity.getActivityInfo().currentHeartRate;
        if (hr == null && ActivityMonitor has :getHeartRateHistory) {
            var hrHistory = ActivityMonitor.getHeartRateHistory(1, true);
            var hrSample = hrHistory.next();
            if (hrSample != null && hrSample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
                hr = hrSample.heartRate;
                lastHR = hr;
                lastHRTime = Time.now().value();
            } else {
                if (Time.now().value() - lastHRTime < 10) {
                    hr = lastHR;
                } else {
                    hr = "--";
                }
            }
        } else {
            lastHR = hr;
            lastHRTime = Time.now().value();
        }
        if (lastHR != null) {
            dc.drawText(width/5, height - height/5, Graphics.FONT_XTINY, hr,
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    function getMinuteInChinese(minutes) {
        if (minutes < 15) {
            return "一刻";
        } else if (minutes < 30) {
            return "二刻";
        } else if (minutes < 45) {
            return "三刻";
        } else {
            return "四刻";
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
        currentTermName = termNameMap[term[0]];
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
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
