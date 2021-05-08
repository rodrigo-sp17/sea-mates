import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sea_mates/api_utils.dart';
import 'package:sea_mates/data/shift.dart';
import 'package:sea_mates/data/sync_status.dart';
import 'package:sea_mates/exception/rest_exceptions.dart';

import '../shift_remote_repository.dart';

class ShiftWebClient implements ShiftRemoteRepository {
  final String base = ApiUtils.API_BASE;
  final String path = '/api/shift';

  @override
  Future<List<Shift>> addRemote(Iterable<Shift> shifts, String token) async {
    List<Shift> result = [];
    var client = http.Client();
    try {
      for (Shift s in shifts) {
        var response = await client.post(Uri.https(base, path + '/add'),
            body: json.encode(s.toJson()),
            headers: {
              'content-type': 'application/json',
              'Authorization': token
            });

        if (response.statusCode == 200) {
          dynamic decodedJson = jsonDecode(response.body);
          Iterable<dynamic> resultList = decodedJson['_embedded']['shiftList'];
          resultList.forEach((element) {
            var shift = Shift.fromJson(element);
            shift.syncStatus = SyncStatus.SYNC;
            result.add(shift);
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
    var response = await http
        .get(Uri.https(base, path), headers: {'Authorization': token});

    if (response.statusCode == 200) {
      dynamic decodedJson = jsonDecode(response.body);
      print(decodedJson);
      if (decodedJson.isEmpty) {
        return <Shift>[];
      } else {
        Iterable<dynamic> resultList = decodedJson['_embedded']['shiftList'];
        resultList.forEach((element) {
          print(element);
          var shift = Shift.fromJson(element);
          shift.syncStatus = SyncStatus.SYNC;
          result.add(shift);
        });
      }
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
        var response = await client.delete(
            Uri.https(base, path + '/remove', {'id': id.toString()}),
            headers: {'Authorization': token});

        if (response.statusCode == 204) {
          counter++;
        } else if (response.statusCode == 400) {
          Map<String, String> errors = jsonDecode(response.body);
          throw BadRequestException(errors.toString());
        } else if (response.statusCode == 403 || response.statusCode == 401) {
          throw ForbiddenException(response.body);
        } else {
          print(response.request!.headers.toString());
          print(response.statusCode);
          print(response.reasonPhrase);
          print(response.headers.toString());
          print(response.body);
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
        var response = await client.put(Uri.https(base, path + '/edit'),
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
