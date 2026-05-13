class LandlordLoginResponse {
  bool? status;
  String? message;
  String? role;
  Tokens? tokens;
  String? accessToken;
  String? expiresIn;
  String? tokenType;

  LandlordLoginResponse({
    this.status,
    this.message,
    this.role,
    this.tokens,
    this.accessToken,
    this.expiresIn,
    this.tokenType,
  });

  factory LandlordLoginResponse.fromJson(Map<String, dynamic> json) {
    return LandlordLoginResponse(
      status: json['status'],
      message: json['message'],
      role: json['role'],
      // Support both old format (tokens object) and new format (access_token)
      tokens: json['tokens'] != null ? Tokens.fromJson(json['tokens']) : null,
      accessToken: json['access_token'],
      expiresIn: json['expires_in'],
      tokenType: json['token_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'role': role,
      'tokens': tokens?.toJson(),
      'access_token': accessToken,
      'expires_in': expiresIn,
      'token_type': tokenType,
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
