class AccountsProfile {
  bool? status;
  String? message;
  Profile? profile;

  AccountsProfile({this.status, this.message, this.profile});

  factory AccountsProfile.fromJson(Map<String, dynamic> json) {
    return AccountsProfile(
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
  AccountsDetails? accounts;

  Profile({this.user, this.accounts});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      accounts: json['accounts'] != null
          ? AccountsDetails.fromJson(json['accounts'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user?.toJson(),
      'accounts': accounts?.toJson(),
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

class AccountsDetails {
  String? email;
  String? phoneNumber;
  String? idNumber;
  bool? isActive;

  AccountsDetails({this.email, this.phoneNumber, this.idNumber, this.isActive});

  factory AccountsDetails.fromJson(Map<String, dynamic> json) {
    return AccountsDetails(
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
