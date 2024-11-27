import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sky_map/screens/celestial_info_screen.dart';
import 'package:sky_map/service/sensor_location.dart';
import 'package:sky_map/helpers/calc_location.dart';


class PlanetsWidget extends StatelessWidget {
  final String name;
  final double azimuth;
  final double altitude;
  final double deviceWidth;
  final double deviceHeight;

  const PlanetsWidget({
    super.key,
    required this.name,
    required this.azimuth,
    required this.altitude,
    required this.deviceWidth,
    required this.deviceHeight,
  });

  Future<Map<String, dynamic>?> _fetchPlanetInfo(String planetName) async {
    try {
      final String response =
          await rootBundle.loadString('assets/info/celestial_info.json');
      final Map<String, dynamic> data = json.decode(response);
      return data[planetName];
    } catch (e) {
      debugPrint('Error fetching planet info: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<SensorLocation>(context);
    final userHeading = locationProvider.heading ?? 0.0;
    final userTilt = locationProvider.tilt ?? 0.0;

    final position = calculatePosition(
      userHeading,
      userTilt,
      azimuth,
      altitude,
      deviceWidth,
      deviceHeight,
    );

    if (position == null) return const SizedBox.shrink();

    return AnimatedPositioned(
      left: position.dx,
      top: position.dy,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: () async {
          final planetInfo = await _fetchPlanetInfo(name);

          if (planetInfo != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CelestialInfoScreen(
                  name: name,
                  description: planetInfo['description'] ?? 'No description available',
                  details: Map<String, String>.from(planetInfo['details'] ?? {}),
                ),
              ),
            );
          } else {
            debugPrint('No data found for $name');
          }
        },
        child: Column(
          children: [
            Image.asset(
              'assets/${name.toLowerCase()}.png',
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.circle, color: Colors.grey, size: 24);
              },
            ),
            Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
