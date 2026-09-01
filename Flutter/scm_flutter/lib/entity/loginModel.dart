class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class LoginResponse {
  final String token;
  final String tokenType;
  final int userId;
  final String name;
  final String email;
  final String phone;
  final String role;
  final int? hubId;
  final String? hubName;
  final String? image;

  LoginResponse({
    required this.token,
    required this.tokenType,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.hubId,
    this.hubName,
    this.image,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      tokenType: json['tokenType'] ?? '',
      userId: json['userId'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      hubId: json['hubId'],
      hubName: json['hubName'],
      image: json['image'] ?? json['photo'] ?? json['profileImage'] ?? json['avatar'] ?? json['userImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'tokenType': tokenType,
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'hubId': hubId,
      'hubName': hubName,
      'image': image,
    };
  }
}