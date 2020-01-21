using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Math;
using Toybox.System;

const UnixEpochJulianDate = 2440587.5;

function JDN(dateTime) {
    return dateTime.value().toFloat()/86400 + UnixEpochJulianDate;
}

function normalizeAngle(a) {
    while (a < 0) {
        a += 360.0;
    }
    while (a >= 360) {
        a -= 360.0;
    }
    return a;
}

// https://en.wikipedia.org/wiki/Position_of_the_Sun#Ecliptic_coordinates
function EclipticLongitude(jdn) {
    var n = jdn - 2451545.0;
    var L = normalizeAngle(280.460+0.9856474*n);
    var g = normalizeAngle(357.528+0.9856003*n);
    var lon = L + 1.915*Math.sin(Math.toRadians(g)) + 0.02*Math.sin(Math.toRadians(2*g));
    return normalizeAngle(lon);
}

function GetClosestSolarTerm(lon) {
    var min = 360.0;
    var past = lon.toNumber() / 15 * 15;
    var future = past + 15;
    if ((future - lon) < (lon - past)) {
        var diff = ((future-lon)*365.0/360).toNumber();
        // close to future
        System.println("Next Solar Term:" + future + " [In " + diff + "days]");
        return [normalizeAngle(future), diff];
    } else {
        var diff = ((lon-past)*365.0/360).toNumber();
        System.println("Previous Solar Term:" + past + " [" + diff + "days ago]");
        return [past, -diff];
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
