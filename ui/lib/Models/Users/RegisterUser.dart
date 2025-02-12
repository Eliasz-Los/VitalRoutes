import 'package:json_annotation/json_annotation.dart';

import '../Enums/FunctionType.dart';

part 'RegisterUser.g.dart';

@JsonSerializable()
class RegisterUser {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? password;
  final String? telephoneNr;
  @JsonKey(fromJson: _functionTypeFromJson, toJson: _functionTypeToJson)
  final FunctionType? function;

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

FunctionType? _functionTypeFromJson(int? value) {
  if (value == null) return null;
  return FunctionType.values[value];
}

int? _functionTypeToJson(FunctionType? function) {
  return function?.index;
}
/*TODO: run altijd dit na veranderingen: 'flutter pub run build_runner build'*/