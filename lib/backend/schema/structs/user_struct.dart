// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UserStruct extends BaseStruct {
  UserStruct({
    /// usuario
    String? user,

    /// success
    String? success,
  })  : _user = user,
        _success = success;

  // "user" field.
  String? _user;
  String get user => _user ?? '';
  set user(String? val) => _user = val;

  bool hasUser() => _user != null;

  // "success" field.
  String? _success;
  String get success => _success ?? '';
  set success(String? val) => _success = val;

  bool hasSuccess() => _success != null;

  static UserStruct fromMap(Map<String, dynamic> data) => UserStruct(
        user: data['user'] as String?,
        success: data['success'] as String?,
      );

  static UserStruct? maybeFromMap(dynamic data) =>
      data is Map ? UserStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'user': _user,
        'success': _success,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'user': serializeParam(
          _user,
          ParamType.String,
        ),
        'success': serializeParam(
          _success,
          ParamType.String,
        ),
      }.withoutNulls;

  static UserStruct fromSerializableMap(Map<String, dynamic> data) =>
      UserStruct(
        user: deserializeParam(
          data['user'],
          ParamType.String,
          false,
        ),
        success: deserializeParam(
          data['success'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'UserStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is UserStruct &&
        user == other.user &&
        success == other.success;
  }

  @override
  int get hashCode => const ListEquality().hash([user, success]);
}

UserStruct createUserStruct({
  String? user,
  String? success,
}) =>
    UserStruct(
      user: user,
      success: success,
    );
