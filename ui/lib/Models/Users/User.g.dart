// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'User.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
      password: json['password'] as String?,
      telephoneNr: json['telephoneNr'] as String?,
      function: _functionTypeFromJson(json['function'] as int?),
      underSupervisions: _idsFromJson(json['underSupervisions'] as List<dynamic>?),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'password': instance.password,
      'function': _functionTypeToJson(instance.function),
      'underSupervisions': _idsToJson(instance.underSupervisions),
};