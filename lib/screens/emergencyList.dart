import 'package:admin/controller/emergency.dart';
import 'package:admin/emergency.dart';
import 'package:admin/screens/track.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EmergencyListPage extends StatefulWidget {
  const EmergencyListPage({Key? key}) : super(key: key);

  @override
  State<EmergencyListPage> createState() => _EmergencyListPageState();
}

class _EmergencyListPageState extends State<EmergencyListPage> {
  final EmergencyController _controller = EmergencyController();
  List<EmergencyData> _emergencies = [];
  late final String destination;

  @override
  void initState() {
    super.initState();
    _fetchEmergencies();
  }

  Future _fetchEmergencies() async {
    final emergencies = await _controller.getAllEmergencies();
    final emergencyDataList = emergencies
        .map((emergency) => EmergencyData.fromEmergency(emergency))
        .toList();
    setState(() {
      _emergencies = emergencyDataList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mlambe Emergency - Emergencies'),
      ),
      body: ListView.builder(
        itemCount: _emergencies.length,
        itemBuilder: (context, index) {
          final emergency = _emergencies[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TrackPage(
                      latitude: emergency.latitude,
                      longitude: emergency.longitude),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.all(10.0),
              color: Color.fromARGB(255, 253, 239, 241),
              shadowColor: Colors.black,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          emergency.name,
                          style: const TextStyle(
                            fontSize: 18.0,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 227, 35,
                                28), // Set your desired background color
                            borderRadius: BorderRadius.circular(
                                8.0), // Optional: Add border radius
                          ),
                          padding: const EdgeInsets.all(
                              8.0), // Optional: Add padding
                          child: Text(
                            emergency.type,
                            style: const TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w200,
                              color: Color.fromARGB(255, 251, 251,
                                  251), // Set your desired text color
                            ),
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          (emergency.latitude != null &&
                                  emergency.longitude != null)
                              ? '${emergency.latitude}, ${emergency.longitude}'
                              : 'No coordinates available',
                          style: const TextStyle(
                              fontSize: 14.0,
                              color: Color.fromARGB(255, 32, 32, 32)),
                        ),
                        const SizedBox(height: 5.0),
                      ],
                    ),
                  ),
                  Positioned(
                    // Positioned widget for timestamp
                    bottom: 5.0,
                    right: 5.0,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        // Display formatted timestamp
                        DateFormat('yyyy-MM-dd HH:mm:ss')
                            .format(emergency.createdAt),
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Color.fromARGB(255, 107, 174, 41),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
