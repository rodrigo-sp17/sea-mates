import 'package:flutter/material.dart';
import 'package:sea_mates/data/auth_user.dart';
import 'package:sea_mates/data/user.dart';
import 'package:sea_mates/repository/user_repository.dart';

class UserModel extends ChangeNotifier {
  final UserRepository userRepository;

  UserModel(this.userRepository);

  User? _user;

  User? get user => _user;

  void load() async {
    _user = await userRepository.loadUser();
    notifyListeners();
  }

  bool hasUser() {
    return _user != null;
  }

  bool hasAuthentication() {
    if (_user == null) {
      return false;
    } else if (_user!.isLocalUser()) {
      return false;
    } else {
      return true;
    }
  }

  Future<void> login(String username, String password) async {
    // login, updates all
  }

  String getToken() {
    if (_user == null) {
      throw Exception("Not an auth user!");
    } else if (_user!.isLocalUser()) {
      throw Exception("User is local");
    } else {
      return (_user as AuthenticatedUser).token;
    }
  }
}
