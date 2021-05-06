import 'dart:core';

import 'package:sea_mates/data/shift.dart';

abstract class ShiftRemoteRepository {
  Future<List<Shift>> loadRemote(String token);
  Future<List<Shift>> addRemote(Iterable<Shift> shifts, String token);
  Future<int> removeRemote(Iterable<int> shiftIds, String token);
  Future<List<Shift>> saveRemote(Iterable<Shift> shifts, String token);
}
