import 'dart:math';
import 'package:sky_map/service/sensor_location.dart';

class CelestialCalculations {
  static SensorLocation? _locationProvider;

  // Constants for degree-radian conversions
  static const double radToDeg = 180 / pi;
  static const double degToRad = pi / 180;

  /// Initialize the class with a `SensorLocation` instance
  static void initialize(SensorLocation locationProvider) {
    _locationProvider = locationProvider;
  }

  /// Calculate azimuth and altitude for a given RA/Dec, time, and location
  Map<String, double> calculateAzimuthAltitude(
      double ra, double dec, DateTime time) {
    if (_locationProvider == null) {
      throw Exception(
          "LocationProvider not initialized in CelestialCalculations.");
    }

    // Get latitude and longitude from the LocationProvider
    final latitude = _locationProvider!.currentPosition?.latitude ?? 0.0;
    final longitude = _locationProvider!.currentPosition?.longitude ?? 0.0;

    // Validate latitude and longitude ranges
    if (latitude < -90.0 || latitude > 90.0) {
      throw Exception("Invalid latitude: $latitude");
    }
    if (longitude < -180.0 || longitude > 180.0) {
      throw Exception("Invalid longitude: $longitude");
    }

    // Calculate Julian Date and GMST
    final julianDate = calculateJulianDate(time);
    final gmst = calculateGMST(julianDate);

    // Calculate Local Sidereal Time (LST)
    final lst = (gmst + longitude * degToRad) % (2 * pi);

    // Convert RA to radians and calculate Hour Angle (HA)
    final raInRadians = ra * degToRad * 15; // Convert hours to degrees, then to radians
    final ha = lst - raInRadians;

    // Calculate altitude
    final sinAlt = sin(latitude * degToRad) * sin(dec * degToRad) +
        cos(latitude * degToRad) * cos(dec * degToRad) * cos(ha);
    final altitude = asin(sinAlt);

    // Calculate azimuth
    final sinAz = -cos(dec * degToRad) * sin(ha);
    final cosAz = sin(dec * degToRad) -
        sin(latitude * degToRad) * sinAlt;

    var azimuth = atan2(sinAz, cosAz);
    if (azimuth < 0) {
      azimuth += 2 * pi; // Normalize azimuth to the range [0, 2π]
    }

    // Return azimuth and altitude in degrees
    return {
      'azimuth': azimuth * radToDeg,
      'altitude': altitude * radToDeg,
    };
  }

  /// Calculate Julian Date for a given UTC time
  double calculateJulianDate(DateTime time) {
    return time.millisecondsSinceEpoch / 86400000 + 2440587.5;
  }

  /// Calculate Greenwich Mean Sidereal Time (GMST) in radians
  double calculateGMST(double julianDate) {
    final t = (julianDate - 2451545.0) / 36525.0;
    final gmstDegrees = 280.46061837 +
        360.98564736629 * (julianDate - 2451545.0) +
        0.000387933 * t * t -
        t * t * t / 38710000.0;
    final gmstRadians = (gmstDegrees % 360) * degToRad;

    // Normalize GMST to the range [0, 2π]
    return (gmstRadians + 2 * pi) % (2 * pi);
  }
}
