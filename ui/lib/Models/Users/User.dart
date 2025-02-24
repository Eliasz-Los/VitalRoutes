import 'package:json_annotation/json_annotation.dart';
import 'package:ui/Models/Enums/FunctionType.dart';
part 'User.g.dart';

@JsonSerializable()
class User {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? password;
  final String? telephoneNr;
  @JsonKey(fromJson: _functionTypeFromJson, toJson: _functionTypeToJson)
  final FunctionType? function;
  @JsonKey(fromJson: _idsFromJson, toJson: _idsToJson)
  final List<String>? underSupervisions;


  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.telephoneNr,
    required this.function,
    required this.underSupervisions
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

FunctionType? _functionTypeFromJson(int? value) {
  if (value == null) return null;
  return FunctionType.values[value];
}

int? _functionTypeToJson(FunctionType? function) {
  return function?.index;
}

List<String>? _idsFromJson(List<dynamic>? json) {
if (json == null) return [];
return json.map((e) => e as String).toList();
}

List<dynamic>? _idsToJson(List<String>? ids) {
return ids;
}

