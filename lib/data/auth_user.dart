import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sea_mates/data/user.dart';

part 'user.g.dart';

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
  String token;

  AuthenticatedUser(this.id, this.username, this.name, this.email, this.token);

  @override
  bool isLocalUser() => false;
}
