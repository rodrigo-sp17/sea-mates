import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:sea_mates/data/auth_user.dart';
import 'package:sea_mates/data/friend.dart';
import 'package:sea_mates/exception/rest_exceptions.dart';
import 'package:sea_mates/model/user_model.dart';
import 'package:sea_mates/repository/impl/friends_web_client.dart';

class FriendListModel extends ChangeNotifier {
  final log = Logger('FriendListModel');

  // Dependencies
  final FriendsWebClient _friendsWebClient;
  late UserModel _userModel;

  FriendListModel(this._friendsWebClient);

  void update(UserModel userModel) {
    _userModel = userModel;
  }

  // State
  bool _isLoading = false;
  List<Friend> _friends = [];
  List<FriendRequest> _myRequests = [];
  List<FriendRequest> _otherRequests = [];

  bool get isLoading => _isLoading;

  List<Friend> get friends => _friends;

  List<FriendRequest> get myRequests => _myRequests;

  List<FriendRequest> get otherRequests => _otherRequests;

  Future<String?> refresh() async {
    _isLoading = true;
    notifyListeners();

    var token = _userModel.getToken();
    try {
      _friends = await _friendsWebClient.getFriends(token);
      var requests = await _friendsWebClient.getRequests(token);
      _myRequests = [];
      _otherRequests = [];

      var authUsername = (_userModel.user as AuthenticatedUser).username;
      requests.forEach((req) {
        if (req.sourceUsername == authUsername) {
          _myRequests.add(req);
        } else {
          _otherRequests.add(req);
        }
      });
      return null;
    } on TimeoutException {
      return 'Could not reach server. Are you online?';
    } on ForbiddenException {
      // TODO - handle
      return 'You are not unauthorized';
    } on ServerException {
      return "Sync failed!";
    } on Exception {
      return "Something went wrong...";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Requests friendship for the given username
  /// Returns null if ok, or an error message if failed
  Future<String?> requestFriendship(String username) async {
    _isLoading = true;
    notifyListeners();

    // assume the token exists, otherwise the view should not be shown
    try {
      var request = await _friendsWebClient.requestFriendship(
          _userModel.getToken(), username);
      _myRequests.add(request);
      return null;
    } on TimeoutException {
      return 'Could not reach server. Are you online?';
    } on ForbiddenException {
      // TODO - handle
      return 'Request unauthorized';
    } on NotFoundException {
      return 'The user does not exist!';
    } on BadRequestException {
      return 'Trying to be friends with yourself? Nice!';
    } on ServerException {
      return "Request failed!";
    } on Exception {
      return "Something went wrong...";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Accepts friendship for the given username
  /// Returns null if ok, or an error message if failed
  Future<String?> acceptFriendship(String username) async {
    _isLoading = true;
    notifyListeners();

    // assume the token exists, otherwise the view should not be shown
    try {
      var friend = await _friendsWebClient.acceptRequest(
          _userModel.getToken(), username);
      _friends.add(friend);
      _otherRequests.removeWhere((req) => req.sourceUsername == username);
      return null;
    } on TimeoutException {
      return 'Could not reach server. Are you online?';
    } on ForbiddenException {
      // TODO - handle
      return 'Request unauthorized';
    } on NotFoundException {
      return 'The request does not exist!';
    } on ServerException {
      return "Could not accept!";
    } on Exception {
      return "Something went wrong...";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Removes friendship for the given username
  /// Returns null if ok, or an error message if failed
  Future<String?> removeFriend(String username) async {
    _isLoading = true;
    notifyListeners();

    // assume the token exists, otherwise the view should not be shown
    try {
      var success =
          await _friendsWebClient.removeFriend(_userModel.getToken(), username);
      if (success) {
        _friends.removeWhere((friend) => friend.user.username == username);
      } else {
        return "Unfriending failed!";
      }
      return null;
    } on TimeoutException {
      return 'Could not reach server. Are you online?';
    } on ForbiddenException {
      // TODO - handle
      return 'Request unauthorized';
    } on NotFoundException {
      return 'The friend does not exist!';
    } on ServerException {
      return "Could not remove friend!";
    } on Exception {
      return "Something went wrong...";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
