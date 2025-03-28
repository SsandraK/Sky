import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sky_map/helpers/calc_celestial.dart';

class ConstellationDataProvider with ChangeNotifier {
  final String baseUrl = 'https://api.api-ninjas.com/v1/';
  final String apiKey;
  final Map<String, List<Map<String, dynamic>>> constellationData = {};

  ConstellationDataProvider({required this.apiKey});

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

      constellationData[constellation] = [];

      for (var star in data) {
        if (!star.containsKey('right_ascension') ||
            !star.containsKey('declination')) {
          continue;
        }

        // Convert RA and Dec to decimal 
        final double ra = convertToDecimal(star['right_ascension']);
        final double dec = convertToDecimal(star['declination']);

        // azimuth and altitude
        final Map<String, double> azAlt =
            CelestialCalculations().calculateAzimuthAltitude(
          ra,
          dec,
          DateTime.now().toUtc(),
        );

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


  Future<void> fetchAllConstellationsData(List<String> constellations) async {
    for (var constellation in constellations) {
      await fetchConstellationData(constellation);
    }
    debugPrint("All constellation data fetched: $constellationData");
    debugPrint("Data for Orion: ${constellationData['Lyra']}");
  }


  double convertToDecimal(String input) {
    input = input.replaceAll(RegExp(r'[^\d+\-.\s]'), '');

    final parts =
        input.split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();

    if (parts.length < 3) return 0.0;

    final double primary = double.tryParse(parts[0]) ?? 0.0;
    final double minutes = double.tryParse(parts[1]) ?? 0.0;
    final double seconds = double.tryParse(parts[2]) ?? 0.0;

    double decimalValue = primary.abs() + (minutes / 60) + (seconds / 3600);
    return primary.isNegative ? -decimalValue : decimalValue;
  }
}
