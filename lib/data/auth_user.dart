import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sea_mates/data/user.dart';

part 'auth_user.g.dart';

@JsonSerializable()
@HiveType(typeId: 2)
class AuthenticatedUser implements User {
  @HiveField(0)
  int id;

  @HiveField(1)
  String username;

  @HiveField(2)
  String name;

  @HiveField(3)
  String email;

  @HiveField(4)
  @JsonKey(ignore: true)
  String token;

  AuthenticatedUser(this.id, this.username, this.name, this.email, this.token);

  factory AuthenticatedUser.fromJson(Map<String, dynamic> json) =>
      _$AuthenticatedUserFromJson(json);
  Map<String, dynamic> toJson() => _$AuthenticatedUserToJson(this);

  @override
  bool isLocalUser() => false;
}
