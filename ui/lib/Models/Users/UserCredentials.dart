import 'package:json_annotation/json_annotation.dart';

part 'UserCredentials.g.dart';

@JsonSerializable()
class UserCredentials {
  final String email;
  final String password;

  UserCredentials({
    required this.email,
    required this.password,
  });

  factory UserCredentials.fromJson(Map<String, dynamic> json) => _$UserCredentialsFromJson(json);
  Map<String, dynamic> toJson() => _$UserCredentialsToJson(this);
}