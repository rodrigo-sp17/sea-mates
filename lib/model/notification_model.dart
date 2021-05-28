import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:sea_mates/data/auth_user.dart';
import 'package:sea_mates/model/user_model.dart';
import 'package:sea_mates/util/api_utils.dart';

class NotificationModel extends ChangeNotifier {
  final log = Logger('NotificationModel');

  // Dependencies
  late UserModel _userModel;

  void update(UserModel userModel) {
    _userModel = userModel;
  }

  // State
  bool _isSubscribed = false;

  // Actions
  Future<void> subscribe() async {
    if (!_userModel.hasAuthentication()) {
      return;
    }

    var user = _userModel.user as AuthenticatedUser;
    var username = user.username;
    var token = _userModel.getToken();

    var uri = Uri.https(ApiUtils.API_BASE, '/api/push/subscribe/$username');
    try {
      var _client = http.Client();

      var request = new http.Request("GET", uri);
      request.headers["Accept"] = "text/event-stream";
      request.headers["Authorization"] = token;

      var response = await _client.send(request);
      if (response.statusCode == 200) {
        _isSubscribed = true;
        response.stream.toStringStream().listen((value) {
          //var json = _parseEvent(value);
          print('called');
          print(value); // TODO - handle events
          //print(json["data"]);
        });
      } else {
        _isSubscribed = false;
      }

      notifyListeners();
      return;
    } on Exception {
      // TODO
    }
  }
}
