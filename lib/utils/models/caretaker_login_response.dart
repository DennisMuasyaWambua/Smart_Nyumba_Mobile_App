class CaretakerLoginResponse {
  bool? status;
  String? message;
  String? role;
  Tokens? tokens;

  CaretakerLoginResponse({this.status, this.message, this.role, this.tokens});

  factory CaretakerLoginResponse.fromJson(Map<String, dynamic> json) {
    return CaretakerLoginResponse(
      status: json['status'],
      message: json['message'],
      role: json['role'],
      tokens: json['tokens'] != null ? Tokens.fromJson(json['tokens']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'role': role,
      'tokens': tokens?.toJson(),
    };
  }
}

class Tokens {
  String? refresh;
  String? access;

  Tokens({this.refresh, this.access});

  factory Tokens.fromJson(Map<String, dynamic> json) {
    return Tokens(
      refresh: json['refresh'],
      access: json['access'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'refresh': refresh,
      'access': access,
    };
  }
}
