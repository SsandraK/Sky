import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensorLocation with ChangeNotifier {
  Position? currentPosition;
  double? heading;  
  double? tilt; 
  double? altitude; 

  final List<List<double>> accelerometerBuffer = [];
  final List<List<double>> magnetometerBuffer = [];

  static const int bufferSize = 10; 
  static const int updateIntervalMs =
      100; 

  late Timer _updateTimer;
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;
  late StreamSubscription<MagnetometerEvent> _magnetometerSubscription;

  SensorLocation() {
    _initLocation();
    _initSensors();
    _startUpdateTimer();
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    _accelerometerSubscription.cancel();
    _magnetometerSubscription.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    final permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      print("Location permission denied");
      return;
    } else if (permission == LocationPermission.deniedForever) {
      print("Location permission denied permanently");
      return;
    }

    currentPosition = await Geolocator.getCurrentPosition();
    altitude = currentPosition?.altitude;
    notifyListeners();
  }

  void _initSensors() {
    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      _updateBuffer(accelerometerBuffer, [event.x, event.y, event.z]);
    });

    _magnetometerSubscription =
        magnetometerEvents.listen((MagnetometerEvent event) {
      _updateBuffer(magnetometerBuffer, [event.x, event.y, event.z]);
    });
  }

  void _startUpdateTimer() {
    _updateTimer =
        Timer.periodic(const Duration(milliseconds: updateIntervalMs), (timer) {
      _processSensorData();
    });
  }

  void _updateBuffer(List<List<double>> buffer, List<double> newReading) {
    buffer.add(newReading);

    if (buffer.length > bufferSize) {
      buffer.removeAt(0);
    }
  }

  void _processSensorData() {
    if (accelerometerBuffer.isEmpty || magnetometerBuffer.isEmpty) return;

    // accelerometer values
    final ax = _calculateAverage(accelerometerBuffer, 0);
    final ay = _calculateAverage(accelerometerBuffer, 1);
    final az = _calculateAverage(accelerometerBuffer, 2);

    // magnetometer values
    final mx = _calculateAverage(magnetometerBuffer, 0);
    final my = _calculateAverage(magnetometerBuffer, 1);
    final mz = _calculateAverage(magnetometerBuffer, 2);

  
    final roll = atan2(ay, az);
    final pitch = atan2(-ax, sqrt(ay * ay + az * az));

    final compensatedMx = mx * cos(pitch) + mz * sin(pitch);
    final compensatedMy = mx * sin(roll) * sin(pitch) +
        my * cos(roll) -
        mz * sin(roll) * cos(pitch);


    heading = (atan2(-compensatedMx, compensatedMy) * (180 / pi) + 360) % 360;
    tilt = atan2(az, sqrt(ax * ax + ay * ay)) * (180 / pi);

    notifyListeners();
  }


  double _calculateAverage(List<List<double>> readings, int axis) {
    if (readings.isEmpty) return 0.0;
    return readings.map((reading) => reading[axis]).reduce((a, b) => a + b) /
        readings.length;
  }
}