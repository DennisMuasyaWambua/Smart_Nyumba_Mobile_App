class LandlordProfile {
  bool? status;
  String? message;
  Profile? profile;

  LandlordProfile({this.status, this.message, this.profile});

  factory LandlordProfile.fromJson(Map<String, dynamic> json) {
    return LandlordProfile(
      status: json['status'],
      message: json['message'],
      profile: json['profile'] != null ? Profile.fromJson(json['profile']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'profile': profile?.toJson(),
    };
  }
}

class Profile {
  User? user;
  LandlordDetails? landlord;
  List<Property>? properties;

  Profile({this.user, this.landlord, this.properties});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      landlord: json['landlord'] != null ? LandlordDetails.fromJson(json['landlord']) : null,
      properties: json['properties'] != null
          ? (json['properties'] as List).map((p) => Property.fromJson(p)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user?.toJson(),
      'landlord': landlord?.toJson(),
      'properties': properties?.map((p) => p.toJson()).toList(),
    };
  }
}

class User {
  String? email;
  String? firstName;
  String? lastName;
  String? mobileNumber;
  String? role;

  User({this.email, this.firstName, this.lastName, this.mobileNumber, this.role});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      mobileNumber: json['mobile_number'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'mobile_number': mobileNumber,
      'role': role,
    };
  }
}

class LandlordDetails {
  String? email;
  String? phoneNumber;
  String? idNumber;
  bool? isActive;

  LandlordDetails({this.email, this.phoneNumber, this.idNumber, this.isActive});

  factory LandlordDetails.fromJson(Map<String, dynamic> json) {
    return LandlordDetails(
      email: json['email'],
      phoneNumber: json['phone_number'],
      idNumber: json['id_number'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phone_number': phoneNumber,
      'id_number': idNumber,
      'is_active': isActive,
    };
  }
}

class Property {
  int? id;
  String? blockNumber;
  String? location;
  int? totalHouses;

  Property({this.id, this.blockNumber, this.location, this.totalHouses});

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'],
      blockNumber: json['block_number'],
      location: json['location'],
      totalHouses: json['total_houses'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'block_number': blockNumber,
      'location': location,
      'total_houses': totalHouses,
    };
  }
}
