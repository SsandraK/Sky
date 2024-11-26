import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_map/screens/sky_map_screen.dart';
import 'package:sky_map/service/constellations_data.dart';
import 'package:sky_map/service/planet_data.dart';
import 'package:sky_map/service/sensor_location.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SensorLocation()),
        ChangeNotifierProxyProvider<SensorLocation, FetchPlanetData>(
          create: (context) => FetchPlanetData(
            Provider.of<SensorLocation>(context, listen: false),
          ),
          update: (context, locationProvider, previous) =>
              previous!..updateLocationProvider(locationProvider),
        ),
        ChangeNotifierProvider(create: (_) => ConstellationDataProvider(apiKey:'V6vQWnnd6V++ZGEztnGTiw==RpMGlbSXCmtuvp5T'),
    ),
    ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sky Map',
        theme: ThemeData.dark(),
        home: const SkyMapScreen(),
      ),
    );
  }
}
