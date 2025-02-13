import 'package:json_annotation/json_annotation.dart';

part 'UpdateUser.g.dart';

@JsonSerializable()
class UpdateUser {
  final String id;
  final String Uid;
  final String firstName;
  final String lastName;
  final String email;
  final String telephoneNr;

  UpdateUser({
    required this.id,
    required this.Uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.telephoneNr,
  });

  factory UpdateUser.fromJson(Map<String, dynamic> json) => _$UpdateUserFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateUserToJson(this);
}