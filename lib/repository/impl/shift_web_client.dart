import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sea_mates/api_utils.dart';
import 'package:sea_mates/data/shift.dart';
import 'package:sea_mates/exception/rest_exceptions.dart';

import '../shift_remote_repository.dart';

class ShiftWebClient implements ShiftRemoteRepository {
  final String url = ApiUtils.API_BASE + '/api/shift';

  @override
  Future<List<Shift>> addRemote(Iterable<Shift> shifts, String token) async {
    List<Shift> result = [];
    var client = http.Client();
    try {
      for (Shift s in shifts) {
        var response = await client.post(Uri.https(url, 'add'),
            body: json.encode(s.toJson()),
            headers: {
              'content-type': 'application/json',
              'Authorization': token
            });

        if (response.statusCode == 200) {
          List<dynamic> resultList = jsonDecode(response.body);
          resultList.forEach((element) {
            result.add(Shift.fromJson(element));
          });
        } else if (response.statusCode == 400) {
          Map<String, String> errors = jsonDecode(response.body);
          throw BadRequestException(errors.toString());
        } else if (response.statusCode == 403 || response.statusCode == 401) {
          throw ForbiddenException(response.body);
        } else {
          throw ServerException(response.toString());
        }
      }
    } finally {
      client.close();
    }
    return result;
  }

  @override
  Future<List<Shift>> loadRemote(String token) async {
    List<Shift> result = [];
    var response =
        await http.get(Uri.https(url, '/'), headers: {'Authorization': token});

    if (response.statusCode == 200) {
      List<dynamic> resultList = jsonDecode(response.body);
      resultList.forEach((element) {
        result.add(Shift.fromJson(element));
      });
    } else if (response.statusCode == 400) {
      Map<String, String> errors = jsonDecode(response.body);
      throw BadRequestException(errors.toString());
    } else if (response.statusCode == 403 || response.statusCode == 401) {
      throw ForbiddenException(response.body);
    } else {
      throw ServerException(response.toString());
    }
    return result;
  }

  @override
  Future<int> removeRemote(Iterable<int> shiftIds, String token) async {
    int counter = 0;
    var client = http.Client();
    try {
      for (int id in shiftIds) {
        var response = await client.delete(Uri.https(url, 'remove', {'id': id}),
            headers: {'Authorization': token});

        if (response.statusCode == 204) {
          counter++;
        } else if (response.statusCode == 400) {
          Map<String, String> errors = jsonDecode(response.body);
          throw BadRequestException(errors.toString());
        } else if (response.statusCode == 403 || response.statusCode == 401) {
          throw ForbiddenException(response.body);
        } else {
          throw ServerException(response.toString());
        }
      }
    } finally {
      client.close();
    }
    return counter;
  }

  @override
  Future<List<Shift>> saveRemote(Iterable<Shift> shifts, String token) async {
    List<Shift> result = [];
    var client = http.Client();
    try {
      for (Shift s in shifts) {
        var response = await client.put(Uri.https(url, 'edit'),
            body: json.encode(s.toJson()),
            headers: {
              'content-type': 'application/json',
              'Authorization': token
            });
        if (response.statusCode == 200) {
          List<dynamic> resultList = jsonDecode(response.body);
          resultList.forEach((element) {
            result.add(Shift.fromJson(element));
          });
        } else if (response.statusCode == 400) {
          Map<String, String> errors = jsonDecode(response.body);
          throw BadRequestException(errors.toString());
        } else if (response.statusCode == 403 || response.statusCode == 401) {
          throw ForbiddenException(response.body);
        } else {
          throw ServerException(response.toString());
        }
      }
    } finally {
      client.close();
    }
    return result;
  }
}
