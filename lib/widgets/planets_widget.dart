import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<SensorLocation>(context);
    final userHeading = locationProvider.heading ?? 0.0;
    final userTilt = locationProvider.tilt ?? 0.0;

    // Calculate the position of the celestial body on the screen
    final position = calculatePosition(userHeading, userTilt, azimuth,
      altitude, deviceWidth, deviceHeight);

    // Check if position is within screen bounds
    if (position == null) {
      return SizedBox.shrink(); // If out of bounds, don't render
    }

    // Render the celestial body icon at the calculated position
    return AnimatedPositioned(
      left: position.dx,
      top: position.dy,
      duration: Duration(milliseconds: 100),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => InformationScreen(
          //       name: name,
          //       azimuth: celestialAzimuth,
          //       altitude: celestialAltitude,
          //     ),
          //   ),
          // );
        },
        child: Column(
          children: [
            Image.asset(
              'assets/${name.toLowerCase()}.png',
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.circle, color: Colors.grey, size: 24);
              },
            ),
            Text(
              name,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
