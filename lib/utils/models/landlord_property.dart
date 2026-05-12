class LandlordProperty {
  int? id;
  String? blockNumber;
  String? location;
  int? totalHouses;
  String? createdAt;

  LandlordProperty({
    this.id,
    this.blockNumber,
    this.location,
    this.totalHouses,
    this.createdAt,
  });

  factory LandlordProperty.fromJson(Map<String, dynamic> json) {
    return LandlordProperty(
      id: json['id'],
      blockNumber: json['block_number'],
      location: json['location'],
      totalHouses: json['total_houses'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'block_number': blockNumber,
      'location': location,
      'total_houses': totalHouses,
      'created_at': createdAt,
    };
  }
}

class PropertyHouse {
  int? id;
  String? houseNumber;
  String? blockNumber;
  String? serviceCharge;
  String? rentCharged;
  String? rentDueDate;
  bool? isOccupied;
  String? createdAt;

  PropertyHouse({
    this.id,
    this.houseNumber,
    this.blockNumber,
    this.serviceCharge,
    this.rentCharged,
    this.rentDueDate,
    this.isOccupied,
    this.createdAt,
  });

  factory PropertyHouse.fromJson(Map<String, dynamic> json) {
    return PropertyHouse(
      id: json['id'],
      houseNumber: json['house_number'],
      blockNumber: json['block_number'],
      serviceCharge: json['service_charge'],
      rentCharged: json['rent_charged'],
      rentDueDate: json['rent_due_date'],
      isOccupied: json['is_occupied'] ?? false,
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'house_number': houseNumber,
      'block_number': blockNumber,
      'service_charge': serviceCharge,
      'rent_charged': rentCharged,
      'rent_due_date': rentDueDate,
      'is_occupied': isOccupied,
      'created_at': createdAt,
    };
  }
}

class AddHouseResponse {
  bool? status;
  String? message;

  AddHouseResponse({this.status, this.message});

  factory AddHouseResponse.fromJson(Map<String, dynamic> json) {
    return AddHouseResponse(
      status: json['status'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
    };
  }
}
