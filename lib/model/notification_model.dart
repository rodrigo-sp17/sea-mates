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
      response.stream.toStringStream().listen((value) {
        print(_parseEvent(value)); // TODO - handle events
      });
    } on Exception {
      // TODO
    }
  }

  Map<String, String> _parseEvent(String data) {
    var parts = data.split("\n");
    var eventPair = parts[0].split(":");
    var dataPair = parts[1].split(":");
    if (parts[1].isEmpty) {
      dataPair = ["data", ""];
    }
    return {eventPair[0]: eventPair[1], dataPair[0]: dataPair[1]};
  }
}
