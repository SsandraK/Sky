import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_map/helpers/calc_location.dart';
import 'package:sky_map/service/sensor_location.dart';


class ConstellationWidget extends StatelessWidget {
  final Map<String, List<Map<String, dynamic>>> constellationsData;
  final double width;
  final double height;

  const ConstellationWidget(
      {super.key,
      required this.constellationsData,
      required this.width,
      required this.height});

  @override
  Widget build(BuildContext context) {
    List<Widget> constellationWidgets = [];
    final locationProvider = Provider.of<SensorLocation>(context);
    final userHeading = locationProvider.heading ?? 0.0;
    final userTilt = locationProvider.tilt ?? 0.0;

    constellationsData.forEach((constellation, stars) {
      List<Offset> starPositions = [];

      // Loop through each star in the constellation
      for (var star in stars) {
        final double azimuth = star['azimuth'] ?? 0.0;
        final double altitude = star['altitude'] ?? 0.0;
        final position = calculatePosition(userHeading, userTilt, azimuth,
            altitude, width, height);

        // Check if the position is within screen bounds
        if (position != null &&
            position.dx >= 0 &&
            position.dx <= width &&
            position.dy >= 0 &&
            position.dy <= height) {
          starPositions.add(position);
          // Calculate star size based on apparent magnitude
          final dotSize = calculateStarSize(star['apparent_magnitude']);
          constellationWidgets.add(
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
      }

      // Display the constellation name at the average position of its stars
      if (starPositions.isNotEmpty) {
        final averageX =
            starPositions.map((pos) => pos.dx).reduce((a, b) => a + b) /
                starPositions.length;
        final averageY =
            starPositions.map((pos) => pos.dy).reduce((a, b) => a + b) /
                starPositions.length;

        constellationWidgets.add(
          Positioned(
            left: averageX,
            top: averageY,
            child: GestureDetector(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => InformationScreen(
                //       name: constellation,
                //     ),
                //   ),
                // );
              },
              child: Text(
                constellation,
                style:const  TextStyle(
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

  // Helper function that maps apparent magnitudes to dot sizes for stars
  double calculateStarSize(dynamic magnitude) {
    // Attempt to parse magnitude as a double, and set a default if parsing fails
    double parsedMagnitude;
    parsedMagnitude = magnitude is String
        ? double.tryParse(magnitude) ?? 5.0
        : magnitude is double
            ? magnitude
            : 5.0; // default if null or unexpected type

    double clampedMagnitude = parsedMagnitude.clamp(-1.0, 6.0);
    // Map magnitude to a size range, e.g., 10 (bright) to 2 (dim)
    double starSize = 10 - (clampedMagnitude + 1) * 1.5;

    return starSize.clamp(2.0, double.infinity);
  }
}
