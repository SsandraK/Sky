import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sky_map/helpers/calc_location.dart';
import 'package:sky_map/screens/celestial_info_screen.dart';
import 'package:sky_map/service/sensor_location.dart';

class ConstellationWidget extends StatelessWidget {
  final Map<String, List<Map<String, dynamic>>> constellationsData;
  final double width;
  final double height;

  const ConstellationWidget({
    super.key,
    required this.constellationsData,
    required this.width,
    required this.height,
  });

  Future<Map<String, dynamic>?> _fetchConstellationInfo(String name) async {
    try {
      final String response =
          await rootBundle.loadString('assets/info/celestial_info.json');
      final Map<String, dynamic> data = json.decode(response);
      return data[name];
    } catch (e) {
      debugPrint('Error fetching constellation info: $e');
      return null;
    }
  }

@override
Widget build(BuildContext context) {
  List<Widget> constellationWidgets = [];
  final locationProvider = Provider.of<SensorLocation>(context);
  final userHeading = locationProvider.heading ?? 0.0;
  final userTilt = locationProvider.tilt ?? 0.0;

  constellationsData.forEach((name, stars) {
    List<Offset> starPositions = [];

    for (var star in stars) {
      final double azimuth = star['azimuth'] ?? 0.0;
      final double altitude = star['altitude'] ?? 0.0;
      final position = calculatePosition(
        userHeading,
        userTilt,
        azimuth,
        altitude,
        width,
        height,
      );

      if (position != null &&
          position.dx >= 0 &&
          position.dx <= width &&
          position.dy >= 0 &&
          position.dy <= height) {
        starPositions.add(position);
        final dotSize = calculateStarSize(star['apparent_magnitude']);
        _addStarDot(constellationWidgets, position, dotSize);
      }
    }

    if (starPositions.isNotEmpty) {
      final averageX = starPositions.map((pos) => pos.dx).reduce((a, b) => a + b) / starPositions.length;
      final averageY = starPositions.map((pos) => pos.dy).reduce((a, b) => a + b) / starPositions.length;

      constellationWidgets.add(
        Positioned(
          left: averageX,
          top: averageY,
          child: GestureDetector(
            onTap: () async {
              final constellationInfo = await _fetchConstellationInfo(name);

              if (constellationInfo != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CelestialInfoScreen(
                      name: name,
                      description: constellationInfo['description'] ?? 'No description available',
                      details: Map<String, String>.from(constellationInfo['details'] ?? {}),
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Information not available for $name.')),
                );
              }
            },
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }
  });

  return Stack(children: constellationWidgets);
}


  void _addStarDot(List<Widget> widgets, Offset position, double dotSize) {
    widgets.add(
      Positioned(
        left: position.dx,
        top: position.dy,
        child: Icon(
          Icons.circle,
          color: const Color.fromARGB(255, 191, 228, 245),
          size: dotSize,
        ),
      ),
    );
  }

  double calculateStarSize(dynamic magnitude) {
    double parsedMagnitude = (magnitude is String ? double.tryParse(magnitude) : magnitude) ?? 5.0;
    double clampedMagnitude = parsedMagnitude.clamp(-1.0, 6.0);
    return (10 - (clampedMagnitude + 1) * 1.5).clamp(2.0, double.infinity);
  }
}
