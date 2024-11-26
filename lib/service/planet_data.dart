import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sky_map/helpers/calc_celestial.dart';
import 'package:sky_map/models/planets.dart';
import 'sensor_location.dart'; 


class FetchPlanetData with ChangeNotifier {
  Map<String, Map<String, dynamic>> planetData = {};
  late Timer _updateTimer;
  SensorLocation locationProvider;

  FetchPlanetData(this.locationProvider) {
    // Initialize celestial calculations with the location provider
    CelestialCalculations.initialize(locationProvider);
    _startPeriodicUpdate();
  }

  void updateLocationProvider(SensorLocation newLocationProvider) {
    locationProvider = newLocationProvider;
    CelestialCalculations.initialize(locationProvider);
    notifyListeners();
  }

  void _startPeriodicUpdate() {
    fetchPlanets();
    _updateTimer = Timer.periodic(
      const Duration(hours: 1),
      (timer) => fetchPlanets(),
    );
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    super.dispose();
  }

  Future<void> fetchPlanetData(String planetName, String commandId) async {
    const String apiBaseUrl = 'https://ssd.jpl.nasa.gov/api/horizons.api';
    final DateTime now = DateTime.now().toUtc();
    final DateTime oneMinuteLater = now.add(const Duration(minutes: 1));
    final DateFormat formatter = DateFormat('yyyy-MMM-dd HH:mm:ss.SSS');
    final String startTime = formatter.format(now);
    final String stopTime = formatter.format(oneMinuteLater);

    final Uri url = Uri.parse(
      "$apiBaseUrl?format=json&COMMAND='$commandId'&OBJ_DATA='NO'&MAKE_EPHEM='YES'&EPHEM_TYPE='OBSERVER'&CENTER='500@399'&START_TIME='$startTime'&STOP_TIME='$stopTime'&STEP_SIZE='1min'",
    );

    try {
      final http.Response response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception(
            "Failed to fetch data: ${response.statusCode} - ${response.reasonPhrase}");
      }

      final Map<String, dynamic> data = json.decode(response.body);

      if (data['result'] is! String) {
        throw Exception('Unexpected data format: Missing "result" as a string');
      }

      final String resultString = data['result'] as String;
      final Map<String, dynamic> parsedData =
          _parseResultString(resultString, startTime);

      if (!parsedData.containsKey('ra') || !parsedData.containsKey('dec')) {
        throw Exception('Missing RA or Dec in the parsed data');
      }

      final double ra = parsedData['ra'];
      final double dec = parsedData['dec'];

      final Map<String, double> azimuthAltitude =
          CelestialCalculations().calculateAzimuthAltitude(
        ra,
        dec,
        DateTime.now().toUtc(),
      );

      parsedData['azimuth'] = azimuthAltitude['azimuth'];
      parsedData['altitude'] = azimuthAltitude['altitude'];

      planetData[planetName] = parsedData;
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching planet data for $planetName: $e");
    }
  }

  double convertToDecimal(String input) {
    input = input.replaceAll(RegExp(r'[^\d+\-.\s]'), '');

    final parts = input
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.length < 3) return 0.0;

    final double primary = double.tryParse(parts[0]) ?? 0.0;
    final double minutes = double.tryParse(parts[1]) ?? 0.0;
    final double seconds = double.tryParse(parts[2]) ?? 0.0;

    double decimalValue = primary.abs() + (minutes / 60) + (seconds / 3600);
    return primary.isNegative ? -decimalValue : decimalValue;
  }

  Map<String, dynamic> _parseResultString(
      String resultString, String startTime) {
    final Map<String, dynamic> parsedData = {};
    final List<String> lines = resultString.split('\n');

    for (final String line in lines) {
      if (line.startsWith(' $startTime')) {
        final List<String> parts = line.split(RegExp(r'\s+'));
        if (parts.length >= 7) {
          final String raHMS = '${parts[3]} ${parts[4]} ${parts[5]}';
          final String decDMS = '${parts[6]} ${parts[7]} ${parts[8]}';

          final double ra = convertToDecimal(raHMS) * 15;
          final double dec = convertToDecimal(decDMS);

          parsedData['ra'] = ra;
          parsedData['dec'] = dec;
        }
        break;
      }
    }

    return parsedData;
  }

  Future<void> fetchPlanets() async {
    for (final planet in Planet.planets) {
      await fetchPlanetData(planet.name, planet.command);
    }
  }
}
