// To parse this JSON data, do
//
//     final allTenants = allTenantsFromJson(jsonString);

import 'dart:convert';

AllTenants allTenantsFromJson(String str) => AllTenants.fromJson(json.decode(str));

String allTenantsToJson(AllTenants data) => json.encode(data.toJson());

class AllTenants {
    bool status;
    List<Tenant> tenant;

    AllTenants({
        required this.status,
        required this.tenant,
    });

    factory AllTenants.fromJson(Map<String, dynamic> json) => AllTenants(
        status: json["status"],
        tenant: List<Tenant>.from(json["tenant"].map((x) => Tenant.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "tenant": List<dynamic>.from(tenant.map((x) => x.toJson())),
    };
}

class Tenant {
    int id;
    PropertyBlock propertyBlock;
    String email;
    String name;
    String idNumber;
    int isActive;
    int user;

    Tenant({
        required this.id,
        required this.propertyBlock,
        required this.email,
        required this.name,
        required this.idNumber,
        required this.isActive,
        required this.user,
    });

    factory Tenant.fromJson(Map<String, dynamic> json) => Tenant(
        id: json["id"],
        propertyBlock: PropertyBlock.fromJson(json["PropertyBlock"]),
        email: json["email"],
        name: json["name"],
        idNumber: json["id_number"],
        isActive: json["is_active"],
        user: json["user"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "PropertyBlock": propertyBlock.toJson(),
        "email": email,
        "name": name,
        "id_number": idNumber,
        "is_active": isActive,
        "user": user,
    };
}

class PropertyBlock {
    int id;
    Block block;
    String houseNumber;
    String serviceCharge;
    String rentCharged;
    DateTime rentDueDate;

    PropertyBlock({
        required this.id,
        required this.block,
        required this.houseNumber,
        required this.serviceCharge,
        required this.rentCharged,
        required this.rentDueDate,
    });

    factory PropertyBlock.fromJson(Map<String, dynamic> json) => PropertyBlock(
        id: json["id"],
        block: Block.fromJson(json["block"]),
        houseNumber: json["house_number"],
        serviceCharge: json["service_charge"],
        rentCharged: json["rent_charged"],
        rentDueDate: DateTime.parse(json["rent_due_date"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "block": block.toJson(),
        "house_number": houseNumber,
        "service_charge": serviceCharge,
        "rent_charged": rentCharged,
        "rent_due_date": "${rentDueDate.year.toString().padLeft(4, '0')}-${rentDueDate.month.toString().padLeft(2, '0')}-${rentDueDate.day.toString().padLeft(2, '0')}",
    };
}

class Block {
    int id;
    String location;
    String blockNumber;
    DateTime registrationDate;

    Block({
        required this.id,
        required this.location,
        required this.blockNumber,
        required this.registrationDate,
    });

    factory Block.fromJson(Map<String, dynamic> json) => Block(
        id: json["id"],
        location: json["location"],
        blockNumber: json["block_number"],
        registrationDate: DateTime.parse(json["registration_date"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "location": location,
        "block_number": blockNumber,
        "registration_date": "${registrationDate.year.toString().padLeft(4, '0')}-${registrationDate.month.toString().padLeft(2, '0')}-${registrationDate.day.toString().padLeft(2, '0')}",
    };
}
