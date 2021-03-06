using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Math;
using Toybox.System;

const UnixEpochJulianDate = 2440587.5;

function JDN(t) {
    return t.value().toDouble()/86400.0 + UnixEpochJulianDate;
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
        var diff = Math.round((future-lon)*365.0/360).toNumber();
        System.println("Ecliptic Longitude: " + lon + ", Next Solar Term:" + normalizeAngle(future).toNumber() + " [In " + ((future-lon)*365.0/360) + " days]");
        return [normalizeAngle(future).toNumber(), diff];
    } else {
        var diff = Math.round((lon-past)*365.0/360).toNumber();
        System.println("Ecliptic Longitude: " + lon + ", Previous Solar Term:" + past + " [" + ((lon-past)*365.0/360) + " days ago]");
        return [past, -diff];
    }
}
