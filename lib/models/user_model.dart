import 'package:uuid/uuid.dart';

class UserModel {
  final String userId;
  final String name;
  final String email;
  final bool isAdmin;
  final bool hasMatch;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.hasMatch,
    required this.isAdmin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] ?? Uuid().v4(),
      name: json['name'] ?? 'Name',
      email: json['email'] ?? "example@gmail.com",
      hasMatch: json['hasMatch'] ?? false,
      isAdmin: json['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toJson(UserModel user) {
    return {
      'userId': user.userId,
      'name': user.name,
      'email': user.email,
      'hasMatch': user.hasMatch,
      'isAdmin': user.isAdmin,
    };
  }
}
