// emergency_model.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class EmergencyModel {
  late Position currentPosition;
  String type = '';
  String name = '';
  String email = '';
//get sender current position
  Future<void> getCurrentLocation() async {
    try {
      currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting current location: $e');
    }
  }
}

class EmergencyData {
  final String type;
  final String email;
  final double latitude;
  final String name;
  final double longitude;
  final String status;
  final DateTime createAt;

  const EmergencyData(
      {required this.type,
      required this.email,
      required this.latitude,
      required this.name,
      required this.longitude,
      required this.status,
      required this.createAt});
}
