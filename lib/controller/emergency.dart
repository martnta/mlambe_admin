import 'package:admin/models/emergency.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../emergency.dart';

class EmergencyController {
  final EmergencyModel _model = EmergencyModel();
  late final TextEditingController email;
  late final TextEditingController name;

  EmergencyController() {
    email = TextEditingController();
    name = TextEditingController();
  }

  // Submitting function
  Future<void> submitEmergency() async {
    try {
      await _model.getCurrentLocation();

      final emergencyData = {
        'email': email.text,
        'name': name.text,
        'status': 'unattended',
        'latitude': _model.currentPosition.latitude.toDouble(),
        'longitude': _model.currentPosition.longitude.toDouble(),
      };

      final dio = Dio();
      dio.options.headers["Content-Type"] =
          "application/json"; // Set content type
      final response = await dio.post(
          'http://localhost:5000/api/emergency/addemg/',
          data: emergencyData);
      print('emergencyData: $emergencyData');

      if (response.statusCode == 200) {
        // Success
        print('Emergency data sent successfully: ${response.data}');
      } else {
        // Handle error
        print('Error sending emergency data: ${response.data}');
      }
    } catch (e) {
      print('Error: $e');
      // Handle other errors
    }
  }

  Future<List<Emergency>> getAllEmergencies() async {
    try {
      final dio = Dio(); // Create a Dio client for HTTP requests
      final response = await dio.get(
          'http://localhost:5000/api/emergency/getemg'); // Send a GET request to the server

      if (response.statusCode == 200) {
        // Check if the request was successful
        final responseData =
            response.data as List<dynamic>; // Parse the JSON response
        final emergencies = responseData.map((data) {
          Emergency emergency = Emergency.fromJson(
              data); // Create an Emergency object from each JSON data item

          // Handle null values for properties if necessary
          if (emergency.type == null) {
            print('Null value found for type property');
          }

          // ... process other properties as needed

          return emergency;
        }).toList(); // Convert the mapped list to a normal list

        return emergencies; // Return the list of Emergency objects
      } else {
        print('Error fetching emergencies: ${response.data}'); // Handle errors
        return []; // Return an empty list if there's an error
      }
    } catch (e) {
      print('Error fetching emergencies: $e'); // Handle other errors
      return []; // Return an empty list if there's an error
    }
  }
}

class EmergencyData {
  final String email;
  final String type;
  final String name;
  final String status;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  const EmergencyData(
      {required this.type,
      required this.email,
      required this.latitude,
      required this.name,
      required this.longitude,
      required this.status,
      required this.createdAt});

  factory EmergencyData.fromEmergency(Emergency emergency) {
    return EmergencyData(
        type: emergency.type,
        email: emergency.email,
        latitude: emergency.latitude,
        name: emergency.name,
        longitude: emergency.longitude,
        status: emergency.status,
        createdAt: emergency.createdAt);
  }
}
