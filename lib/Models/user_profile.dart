// To parse this JSON data, do
//
//     final userProfile = userProfileFromJson(jsonString);

import 'dart:convert';

UserProfile userProfileFromJson(String str) => UserProfile.fromJson(json.decode(str));

String userProfileToJson(UserProfile data) => json.encode(data.toJson());

class UserProfile {
    bool? status;
    Profile? profile;

    UserProfile({
        this.status,
        this.profile,
    });

    factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        status: json["status"],
        profile: json["profile"] == null ? null : Profile.fromJson(json["profile"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "profile": profile?.toJson(),
    };
}

class Profile {
    int? id;
    User? user;
    PropertyBlock? propertyBlock;
    String? email;
    String? name;
    String? idNumber;
    int? isActive;

    Profile({
        this.id,
        this.user,
        this.propertyBlock,
        this.email,
        this.name,
        this.idNumber,
        this.isActive,
    });

    factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json["id"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        propertyBlock: json["PropertyBlock"] == null ? null : PropertyBlock.fromJson(json["PropertyBlock"]),
        email: json["email"],
        name: json["name"],
        idNumber: json["id_number"],
        isActive: json["is_active"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "user": user?.toJson(),
        "PropertyBlock": propertyBlock?.toJson(),
        "email": email,
        "name": name,
        "id_number": idNumber,
        "is_active": isActive,
    };
}

class PropertyBlock {
    int? id;
    String? houseNumber;
    String? serviceCharge;
    String? rentCharged;
    DateTime? rentDueDate;
    int? block;

    PropertyBlock({
        this.id,
        this.houseNumber,
        this.serviceCharge,
        this.rentCharged,
        this.rentDueDate,
        this.block,
    });

    factory PropertyBlock.fromJson(Map<String, dynamic> json) => PropertyBlock(
        id: json["id"],
        houseNumber: json["house_number"],
        serviceCharge: json["service_charge"],
        rentCharged: json["rent_charged"],
        rentDueDate: json["rent_due_date"] == null ? null : DateTime.parse(json["rent_due_date"]),
        block: json["block"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "house_number": houseNumber,
        "service_charge": serviceCharge,
        "rent_charged": rentCharged,
        "rent_due_date": "${rentDueDate!.year.toString().padLeft(4, '0')}-${rentDueDate!.month.toString().padLeft(2, '0')}-${rentDueDate!.day.toString().padLeft(2, '0')}",
        "block": block,
    };
}

class User {
    int? id;
    dynamic createdOn;
    dynamic lastLogin;
    bool? isSuperuser;
    String? firstName;
    String? lastName;
    bool? isStaff;
    bool? isActive;
    DateTime? dateJoined;
    String? email;
    String? username;
    String? mobileNumber;
    String? password;
    int? status;
    int? role;
    List<dynamic>? groups;
    List<dynamic>? userPermissions;

    User({
        this.id,
        this.createdOn,
        this.lastLogin,
        this.isSuperuser,
        this.firstName,
        this.lastName,
        this.isStaff,
        this.isActive,
        this.dateJoined,
        this.email,
        this.username,
        this.mobileNumber,
        this.password,
        this.status,
        this.role,
        this.groups,
        this.userPermissions,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        createdOn: json["created_on"],
        lastLogin: json["last_login"],
        isSuperuser: json["is_superuser"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        isStaff: json["is_staff"],
        isActive: json["is_active"],
        dateJoined: json["date_joined"] == null ? null : DateTime.parse(json["date_joined"]),
        email: json["email"],
        username: json["username"],
        mobileNumber: json["mobile_number"],
        password: json["password"],
        status: json["status"],
        role: json["role"],
        groups: json["groups"] == null ? [] : List<dynamic>.from(json["groups"]!.map((x) => x)),
        userPermissions: json["user_permissions"] == null ? [] : List<dynamic>.from(json["user_permissions"]!.map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "created_on": createdOn,
        "last_login": lastLogin,
        "is_superuser": isSuperuser,
        "first_name": firstName,
        "last_name": lastName,
        "is_staff": isStaff,
        "is_active": isActive,
        "date_joined": dateJoined?.toIso8601String(),
        "email": email,
        "username": username,
        "mobile_number": mobileNumber,
        "password": password,
        "status": status,
        "role": role,
        "groups": groups == null ? [] : List<dynamic>.from(groups!.map((x) => x)),
        "user_permissions": userPermissions == null ? [] : List<dynamic>.from(userPermissions!.map((x) => x)),
    };
}
