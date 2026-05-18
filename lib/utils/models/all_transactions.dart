// To parse this JSON data, do
//
//     final allTransactions = allTransactionsFromJson(jsonString);

import 'dart:convert';

AllTransactions allTransactionsFromJson(String str) => AllTransactions.fromJson(json.decode(str));

String allTransactionsToJson(AllTransactions data) => json.encode(data.toJson());

class AllTransactions {
    bool status;
    List<Transaction> transactions;

    AllTransactions({
        required this.status,
        required this.transactions,
    });

    factory AllTransactions.fromJson(Map<String, dynamic> json) => AllTransactions(
        status: json["status"],
        transactions: List<Transaction>.from(json["transactions"].map((x) => Transaction.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "transactions": List<dynamic>.from(transactions.map((x) => x.toJson())),
    };
}

class Transaction {
    int id;
    User user;
    String serviceName;
    String amount;
    String paymentMode;
    String balanceServiceCharge;
    int status;
    int? block;  // block ID
    String houseNumber;
    String blockNumber;
    DateTime? datePaid;  // Nullable - API doesn't always return this

    Transaction({
        required this.id,
        required this.user,
        required this.serviceName,
        required this.amount,
        required this.paymentMode,
        required this.balanceServiceCharge,
        required this.status,
        this.block,
        required this.houseNumber,
        required this.blockNumber,
        this.datePaid,
    });

    factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json["id"],
        user: User.fromJson(json["user"]),
        serviceName: json["service_name"],
        amount: json["amount"],
        paymentMode: json["payment_mode"],
        balanceServiceCharge: json["balance_service_charge"],
        status: json["status"],
        block: json["block"],
        houseNumber: json["house_number"],
        blockNumber: json["block_number"],
        datePaid: json["date_paid"] != null ? DateTime.parse(json["date_paid"]) : null,
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "user": user.toJson(),
        "service_name": serviceName,
        "amount": amount,
        "payment_mode": paymentMode,
        "balance_service_charge": balanceServiceCharge,
        "status": status,
        "block": block,
        "house_number": houseNumber,
        "block_number": blockNumber,
        "date_paid": datePaid?.toIso8601String(),
    };
}

class User {
    List<Tenant>? tenant;
    String email;
    String username;
    int role;
    String mobileNumber;
    int status;

    User({
        this.tenant,
        required this.email,
        required this.username,
        required this.role,
        required this.mobileNumber,
        required this.status,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        tenant: json["tenant"] != null
            ? List<Tenant>.from(json["tenant"].map((x) => Tenant.fromJson(x)))
            : null,
        email: json["email"],
        username: json["username"],
        role: json["role"],
        mobileNumber: json["mobile_number"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "tenant": tenant != null
            ? List<dynamic>.from(tenant!.map((x) => x.toJson()))
            : null,
        "email": email,
        "username": username,
        "role": role,
        "mobile_number": mobileNumber,
        "status": status,
    };
}

class Tenant {
    PropertyBlock propertyBlock;

    Tenant({
        required this.propertyBlock,
    });

    factory Tenant.fromJson(Map<String, dynamic> json) => Tenant(
        propertyBlock: PropertyBlock.fromJson(json["PropertyBlock"]),
    );

    Map<String, dynamic> toJson() => {
        "PropertyBlock": propertyBlock.toJson(),
    };
}

class PropertyBlock {
    String houseNumber;
    Block block;

    PropertyBlock({
        required this.houseNumber,
        required this.block,
    });

    factory PropertyBlock.fromJson(Map<String, dynamic> json) => PropertyBlock(
        houseNumber: json["house_number"],
        block: Block.fromJson(json["block"]),
    );

    Map<String, dynamic> toJson() => {
        "house_number": houseNumber,
        "block": block.toJson(),
    };
}

class Block {
    String blockNumber;

    Block({
        required this.blockNumber,
    });

    factory Block.fromJson(Map<String, dynamic> json) => Block(
        blockNumber: json["block_number"],
    );

    Map<String, dynamic> toJson() => {
        "block_number": blockNumber,
    };
}
