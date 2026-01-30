class OfficeAddress {
  final int id;
  final String location;
  final String? state;
  final String? zip;
  final String? address;
  final String? phoneNumber;
  final String? workingHours;

  OfficeAddress({
    required this.id,
    required this.location,
    this.state,
    this.zip,
    this.address,
    this.phoneNumber,
    this.workingHours,
  });

  factory OfficeAddress.fromJson(Map<String, dynamic> json) {
    return OfficeAddress(
      id: json['id'] as int,
      location: json['location'] as String? ?? 'USA', // Default to USA if null, or handle gracefully
      state: json['state'] as String?,
      zip: json['zip'] as String?,
      address: json['address'] as String?,
      phoneNumber: json['phone_number'] as String?,
      workingHours: json['working_hours'] as String?,
    );
  }
}
