class CaretakerProfile {
  bool? status;
  String? message;
  Profile? profile;

  CaretakerProfile({this.status, this.message, this.profile});

  factory CaretakerProfile.fromJson(Map<String, dynamic> json) {
    return CaretakerProfile(
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
  CaretakerDetails? caretaker;

  Profile({this.user, this.caretaker});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      caretaker: json['caretaker'] != null
          ? CaretakerDetails.fromJson(json['caretaker'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user?.toJson(),
      'caretaker': caretaker?.toJson(),
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

class CaretakerDetails {
  String? email;
  String? phoneNumber;
  String? idNumber;
  bool? isActive;

  CaretakerDetails({this.email, this.phoneNumber, this.idNumber, this.isActive});

  factory CaretakerDetails.fromJson(Map<String, dynamic> json) {
    return CaretakerDetails(
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
