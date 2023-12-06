class Emergency {
  late String id;
  late String type;
  late String name;
  late String email;
  late String status;
  late double latitude;
  late double longitude;
  late DateTime createdAt;

  Emergency.fromJson(Map<String, dynamic> json) {
    id = json["id"] ?? '';
    type = json['type'] ?? ''; // Handle nullable type
    name = json['name'] ?? ''; // Handle nullable name
    email = json['email'] ?? ''; // Handle nullable email
    status = json['status'] ?? ''; // Handle nullable status
    latitude = json['latitude'] ?? 0.0; // Handle nullable latitude
    longitude = json['longitude'] ?? 0.0; // Handle nullable longitude

    // Parse created_at field as DateTime
    createdAt = DateTime.parse(json['createdAt'] ?? '');
  }
}
