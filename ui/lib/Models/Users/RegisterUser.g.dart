// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'RegisterUser.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterUser _$RegisterUserFromJson(Map<String, dynamic> json) => RegisterUser(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      telephoneNr: json['telephoneNr'] as String,
      function: (json['function'] as num).toInt(),
    );

Map<String, dynamic> _$RegisterUserToJson(RegisterUser instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'password': instance.password,
      'telephoneNr': instance.telephoneNr,
      'function': instance.function,
    };
