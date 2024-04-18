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
    String annualServiceCharge;
    int status;
    DateTime datePaid;
    String merchantRequestId;
    String checkoutRequestId;
    String houseNumber;
    String blockNumber;

    Transaction({
        required this.id,
        required this.user,
        required this.serviceName,
        required this.amount,
        required this.paymentMode,
        required this.annualServiceCharge,
        required this.status,
        required this.datePaid,
        required this.merchantRequestId,
        required this.checkoutRequestId,
        required this.houseNumber,
        required this.blockNumber,
    });

    factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json["id"],
        user: User.fromJson(json["user"]),
        serviceName: json["service_name"],
        amount: json["amount"],
        paymentMode: json["payment_mode"],
        annualServiceCharge: json["annual_service_charge"],
        status: json["status"],
        datePaid: DateTime.parse(json["date_paid"]),
        merchantRequestId: json["MerchantRequestID"],
        checkoutRequestId: json["CheckoutRequestID"],
        houseNumber: json["house_number"],
        blockNumber: json["block_number"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "user": user.toJson(),
        "service_name": serviceName,
        "amount": amount,
        "payment_mode": paymentMode,
        "annual_service_charge": annualServiceCharge,
        "status": status,
        "date_paid": "${datePaid.year.toString().padLeft(4, '0')}-${datePaid.month.toString().padLeft(2, '0')}-${datePaid.day.toString().padLeft(2, '0')}",
        "MerchantRequestID": merchantRequestId,
        "CheckoutRequestID": checkoutRequestId,
        "house_number": houseNumber,
        "block_number": blockNumber,
    };
}

class User {
    int id;
    dynamic createdOn;
    dynamic lastLogin;
    bool isSuperuser;
    String firstName;
    String lastName;
    bool isStaff;
    bool isActive;
    DateTime dateJoined;
    String email;
    String username;
    String mobileNumber;
    String password;
    int status;
    int role;
    List<dynamic> groups;
    List<dynamic> userPermissions;

    User({
        required this.id,
        required this.createdOn,
        required this.lastLogin,
        required this.isSuperuser,
        required this.firstName,
        required this.lastName,
        required this.isStaff,
        required this.isActive,
        required this.dateJoined,
        required this.email,
        required this.username,
        required this.mobileNumber,
        required this.password,
        required this.status,
        required this.role,
        required this.groups,
        required this.userPermissions,
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
        dateJoined: DateTime.parse(json["date_joined"]),
        email: json["email"],
        username: json["username"],
        mobileNumber: json["mobile_number"],
        password: json["password"],
        status: json["status"],
        role: json["role"],
        groups: List<dynamic>.from(json["groups"].map((x) => x)),
        userPermissions: List<dynamic>.from(json["user_permissions"].map((x) => x)),
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
        "date_joined": dateJoined.toIso8601String(),
        "email": email,
        "username": username,
        "mobile_number": mobileNumber,
        "password": password,
        "status": status,
        "role": role,
        "groups": List<dynamic>.from(groups.map((x) => x)),
        "user_permissions": List<dynamic>.from(userPermissions.map((x) => x)),
    };
}