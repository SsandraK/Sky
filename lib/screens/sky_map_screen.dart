import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_map/helpers/calc_celestial.dart';
import 'package:sky_map/models/stars.dart';
import 'package:sky_map/service/constellations_data.dart';
import 'package:sky_map/service/planet_data.dart';
import 'package:sky_map/service/sensor_location.dart';
import 'package:sky_map/widgets/background_widget.dart';
import 'package:sky_map/widgets/planets_widget.dart';
import 'package:sky_map/widgets/sensor_info_widget.dart';
import 'package:sky_map/widgets/constellation_widget.dart';


class SkyMapScreen extends StatefulWidget {
  const SkyMapScreen({super.key});

  @override
  SkyMapScreenState createState() => SkyMapScreenState();
}

class SkyMapScreenState extends State<SkyMapScreen> {

  @override
  void initState() {
    super.initState();

    // Fetch location data and initialize celestial calculations
    final locationProvider = Provider.of<SensorLocation>(context, listen: false);
    CelestialCalculations.initialize(locationProvider);

    // Fetch planetary data
    final celestialDataProvider = Provider.of<FetchPlanetData>(context, listen: false);
    celestialDataProvider.fetchPlanets();

    // Fetch constellation data
    final constellationDataProvider = Provider.of<ConstellationDataProvider>(context, listen: false);
    constellationDataProvider.fetchAllConstellationsData(constellations);
  }

  @override
  Widget build(BuildContext context) {
    final celestialDataProvider = Provider.of<FetchPlanetData>(context);
    final constellationDataProvider = Provider.of<ConstellationDataProvider>(context);

  return Scaffold(
    body: Stack(
      children: [
        const BackgroundWidget(),

          // Display planets as widgets
          if (celestialDataProvider.planetData.isNotEmpty)
            ...celestialDataProvider.planetData.entries.map((entry) {
              final String planetName = entry.key;
              final data = entry.value;

              if (data.containsKey('azimuth') && data.containsKey('altitude')) {
                return PlanetsWidget(
                  name: planetName,
                  azimuth: data['azimuth'] ?? 0,
                  altitude: data['altitude'] ?? 0,
                  deviceWidth: MediaQuery.of(context).size.width,
                  deviceHeight: MediaQuery.of(context).size.height,
                );
              }
              return const SizedBox.shrink();
            }),

          // Display constellations as widgets
        if (constellationDataProvider.constellationData.isNotEmpty)
      
              ConstellationWidget(
       
                constellationsData: constellationDataProvider.constellationData,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),

          // Sensor info widget at the bottom
          const Positioned(
            bottom: 15,
            left: 10,
            right: 10,
            child: SensorInfoWidget(),
          ),
        ],
      ),
  );}
}
