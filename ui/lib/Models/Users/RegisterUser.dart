import 'package:json_annotation/json_annotation.dart';

part 'RegisterUser.g.dart';

@JsonSerializable()
class RegisterUser {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String telephoneNr;
  final int function;

  RegisterUser({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.telephoneNr,
    required this.function,
  });

  factory RegisterUser.fromJson(Map<String, dynamic> json) => _$RegisterUserFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterUserToJson(this);
}

/*TODO: run altijd dit erna : 'flutter pub run build_runner build'*/