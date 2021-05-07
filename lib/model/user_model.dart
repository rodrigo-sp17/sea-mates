import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sea_mates/api_utils.dart';
import 'package:sea_mates/data/auth_user.dart';
import 'package:sea_mates/data/local_user.dart';
import 'package:sea_mates/data/user.dart';
import 'package:sea_mates/data/user_request.dart';
import 'package:sea_mates/model/shift_list_model.dart';
import 'package:sea_mates/repository/user_repository.dart';

class UserModel extends ChangeNotifier {
  final UserRepository userRepository;
  late ShiftListModel shiftListModel;

  UserModel(this.userRepository) {
    load();
  }

  void update(ShiftListModel shiftListModel) {
    this.shiftListModel = shiftListModel;
  }

  bool _loaded = false;
  User? _user;
  UserStatus _userStatus = UserStatus.ANONYMOUS;

  User? get user => _user;
  UserStatus get userStatus => _userStatus;
  bool get loaded => _loaded;

  Future<void> load() async {
    _loaded = false;
    try {
      _user = await userRepository.loadUser();
      _userStatus = _user!.isLocalUser() ? UserStatus.LOCAL : UserStatus.AUTH;
    } on UserNotFoundException {
      _user = null;
      _userStatus = UserStatus.ANONYMOUS;
    }
    _loaded = true;
    notifyListeners();
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

  String getToken() {
    if (_user == null) {
      throw Exception("Not an auth user!");
    } else if (_user!.isLocalUser()) {
      throw Exception("User is local");
    } else {
      return (_user as AuthenticatedUser).token;
    }
  }

  Future<void> signup(UserRequest request) async {
    // TODO
  }

  Future<bool> login(String username, String password) async {
    _loaded = false;
    notifyListeners();

    var uri = Uri.https(ApiUtils.API_BASE, '/login');
    Map<String, String> body = {"username": username, "password": password};
    var response = await http.post(uri,
        body: jsonEncode(body), headers: {"content-type": "application/json"});

    String? error;
    bool answer = false;

    if (response.statusCode == 200) {
      var token = response.headers['authorization'];
      var hasUserInfo = await _getUserInfo(token!);
      if (hasUserInfo) {
        answer = true;
      } else {
        error = "Failed to fetch user info";
      }
    } else if (response.statusCode == 403 || response.statusCode == 401) {
      answer = false;
    } else {
      error = "Something seem wrong with the server...";
    }

    _loaded = true;
    notifyListeners();

    if (error != null) {
      return Future.error(error);
    } else {
      return answer;
    }
  }

  Future<bool> loginAsLocal() async {
    User user = new LocalUser();
    await userRepository.saveUser(user);
    _user = user;
    _userStatus = UserStatus.LOCAL;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    await shiftListModel.clearLocalDatabase();
    await userRepository.dropUser();
    _userStatus = UserStatus.ANONYMOUS;
    _user = null;
    notifyListeners();
  }

  Future<bool> _getUserInfo(String token) async {
    var result = await http.get(Uri.https(ApiUtils.API_BASE, 'api/user/me'),
        headers: {'authorization': token});

    if (result.statusCode == 200) {
      var json = jsonDecode(result.body);
      AuthenticatedUser user;
      try {
        user = AuthenticatedUser.fromAppUserJson(json);
      } catch (e) {
        _loaded = true;
        notifyListeners();
        return false;
      }
      user.token = token;
      await userRepository.saveUser(user);
      await load();
      return true;
    } else {
      return false;
    }
  }
}

enum UserStatus { ANONYMOUS, LOCAL, AUTH }
