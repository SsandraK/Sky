import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_map/service/sensor_location.dart';

class SensorInfoWidget extends StatelessWidget {
  const SensorInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SensorLocation>(
      builder: (context, locationProvider, child) {
        // Extract and format sensor data
        final latitude = locationProvider.currentPosition?.latitude.toStringAsFixed(3) ?? 'N/A';
        final longitude = locationProvider.currentPosition?.longitude.toStringAsFixed(3) ?? 'N/A';
        final heading = locationProvider.heading?.toStringAsFixed(3) ?? 'N/A';
        final tilt = locationProvider.tilt?.toStringAsFixed(3) ?? 'N/A';

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // First line: Latitude and Longitude
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Lat: $latitude',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Long: $longitude',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Second line: Heading and Tilt
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Heading: $heading°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Tilt: $tilt°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
