import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sky_map/helpers/calc_celestial.dart';

class ConstellationDataProvider with ChangeNotifier {
  final String baseUrl = 'https://api.api-ninjas.com/v1/';
  final String apiKey;
  final Map<String, List<Map<String, dynamic>>> constellationData = {};

  ConstellationDataProvider({required this.apiKey});

  /// Fetch data for a single constellation
  Future<void> fetchConstellationData(String constellation) async {
    final Uri url = Uri.parse('$baseUrl/stars?constellation=$constellation');

    try {
      final response = await http.get(url, headers: {'X-Api-Key': apiKey});

      if (response.statusCode != 200) {
        throw Exception(
            "Failed to fetch data: ${response.statusCode} - ${response.reasonPhrase}");
      }

      final List<dynamic> data = json.decode(response.body);

      if (data.isEmpty) {
        throw Exception('No data found for constellation: $constellation');
      }

      // Initialize constellation data list
      constellationData[constellation] = [];

      for (var star in data) {
        // Ensure required fields exist
        if (!star.containsKey('right_ascension') ||
            !star.containsKey('declination')) {
          continue; // Skip invalid data
        }

        // Convert RA and Dec to decimal format
        final double ra = convertToDecimal(star['right_ascension']);
        final double dec = convertToDecimal(star['declination']);

        // Calculate azimuth and altitude
        final Map<String, double> azAlt =
            CelestialCalculations().calculateAzimuthAltitude(
          ra,
          dec,
          DateTime.now().toUtc(),
        );

        // Add the star data along with azimuth and altitude
        constellationData[constellation]!.add({
          'name': star['name'] ?? 'Unknown',
          'right_ascension': star['right_ascension'],
          'declination': star['declination'],
          'apparent_magnitude': star['apparent_magnitude'],
          'azimuth': azAlt['azimuth'],
          'altitude': azAlt['altitude'],
        });
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching constellation data for $constellation: $e");
    }
  }

  /// Fetch data for all constellations
  Future<void> fetchAllConstellationsData(List<String> constellations) async {
    for (var constellation in constellations) {
      await fetchConstellationData(constellation);
    }
    debugPrint("All constellation data fetched: $constellationData");
// debugPrint("Data for Ursa Minor: ${constellationData['Ursa Minor']}");
// debugPrint("Data for Ursa Major: ${constellationData['Ursa Major']}");
// debugPrint("Data for Orion: ${constellationData['Orion']}");
    debugPrint("Data for Orion: ${constellationData['Lyra']}");
  }

  /// Helper method to convert RA/Dec from string to decimal
  double convertToDecimal(String input) {
    input = input.replaceAll(RegExp(r'[^\d+\-.\s]'), '');

    // Split by whitespace to get parts (hours/degrees, minutes, seconds)
    final parts =
        input.split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();

    if (parts.length < 3) return 0.0;

    // Parse components
    final double primary = double.tryParse(parts[0]) ?? 0.0;
    final double minutes = double.tryParse(parts[1]) ?? 0.0;
    final double seconds = double.tryParse(parts[2]) ?? 0.0;

    double decimalValue = primary.abs() + (minutes / 60) + (seconds / 3600);
    return primary.isNegative ? -decimalValue : decimalValue;
  }
}
