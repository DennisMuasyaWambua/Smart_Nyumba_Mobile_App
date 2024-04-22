// To parse this JSON data, do
//
//     final adminProfile = adminProfileFromJson(jsonString);

import 'dart:convert';

AdminProfile adminProfileFromJson(String str) => AdminProfile.fromJson(json.decode(str));

String adminProfileToJson(AdminProfile data) => json.encode(data.toJson());

class AdminProfile {
    bool status;
    AdProfile profile;

    AdminProfile({
        required this.status,
        required this.profile,
    });

    factory AdminProfile.fromJson(Map<String, dynamic> json) => AdminProfile(
        status: json["status"],
        profile: AdProfile.fromJson(json["profile"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "profile": profile.toJson(),
    };
}

class AdProfile {
    int id;
    String email;
    String name;
    String phoneNumber;
    String idNumber;
    int isActive;
    int user;

    AdProfile({
        required this.id,
        required this.email,
        required this.name,
        required this.phoneNumber,
        required this.idNumber,
        required this.isActive,
        required this.user,
    });

    factory AdProfile.fromJson(Map<String, dynamic> json) => AdProfile(
        id: json["id"],
        email: json["email"],
        name: json["name"],
        phoneNumber: json["phone_number"],
        idNumber: json["id_number"],
        isActive: json["is_active"],
        user: json["user"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "name": name,
        "phone_number": phoneNumber,
        "id_number": idNumber,
        "is_active": isActive,
        "user": user,
    };
}
