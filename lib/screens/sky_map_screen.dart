import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_map/helpers/calc_celestial.dart';
import 'package:sky_map/service/planet_data.dart';
import 'package:sky_map/service/sensor_location.dart';
import 'package:sky_map/widgets/planets_widget.dart';
import 'package:sky_map/widgets/sensor_info_widget.dart';


class SkyMapScreen extends StatefulWidget {
  const SkyMapScreen({super.key});

  @override
  SkyMapScreenState createState() => SkyMapScreenState();
}

class SkyMapScreenState extends State<SkyMapScreen> {
  @override
  void initState() {
    super.initState();
    // Access the LocationProvider instance from the provider context
   final locationProvider = Provider.of<SensorLocation>(context, listen: false);

    // Initialize CelestialCalculations with the LocationProvider
    CelestialCalculations.initialize(locationProvider);

    // Fetch data for all planets once the widget is initialized
    final celestialDataProvider =
        Provider.of<FetchPlanetData>(context, listen: false);
    celestialDataProvider.fetchPlanets();

    // Fetch data for all constellations
    // final constellationDataProvider =
    //     Provider.of<ConstellationDataProvider>(context, listen: false);
    // constellationDataProvider.fetchAllConstellationsData();
  }

  @override
  Widget build(BuildContext context) {
    final celestialDataProvider = Provider.of<FetchPlanetData>(context);
    // final constellationDataProvider =
    //     Provider.of<ConstellationDataProvider>(context);



  return Scaffold(
      appBar: AppBar(title: const Text('Sky Map')),
      body: Stack(
        children: [
          // Background Image
          SizedBox.expand(
            child: Image.asset(
              'assets/bg_sky.jpeg',
              fit: BoxFit.cover,
            ),
          ),

          // Center Content (optional)
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [],
            ),
          ),

          // Display planets as PlanetWidgets if data is available
          if (celestialDataProvider.planetData.isNotEmpty)
            ...celestialDataProvider.planetData.entries.map((entry) {
              String planetName = entry.key;
              var data = entry.value;

              if (data.containsKey('azimuth') && data.containsKey('altitude')) {
                return PlanetsWidget(
                  name: planetName,
                  azimuth: data['azimuth'] ?? 0,
                  altitude: data['altitude'] ?? 0,
                  deviceWidth: MediaQuery.of(context).size.width,
                  deviceHeight: MediaQuery.of(context).size.height,
                );
              } else {
                return const SizedBox.shrink();
              }
            }).toList(),

          // Current Position Data (Sensor Info) at the bottom
          const Positioned(
            bottom: 15,
            left: 10,
            right: 10,
            child: SensorInfoWidget(),
          ),
        ],
      ),
    );
  }
}