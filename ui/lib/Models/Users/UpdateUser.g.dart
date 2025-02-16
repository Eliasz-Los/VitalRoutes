// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UpdateUser.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateUser _$UpdateUserFromJson(Map<String, dynamic> json) => UpdateUser(
      id: json['id'] as String,
      Uid: json['Uid'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      telephoneNr: json['telephoneNr'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$UpdateUserToJson(UpdateUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'Uid': instance.Uid,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'telephoneNr': instance.telephoneNr,
      'password': instance.password,
    };
