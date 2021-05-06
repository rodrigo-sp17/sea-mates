import 'dart:core';

import 'package:sea_mates/data/shift.dart';

abstract class ShiftsRepository {
  Future<List<Shift>> loadRemote();
  Future<List<Shift>> loadLocal();
  Future<List<Shift>> addRemote(Iterable<Shift> shifts);
  Future<List<Shift>> addLocal(Iterable<Shift> shifts);
  Future<int> removeRemote(Iterable<int> shiftIds);
  Future<int> removeLocal(Iterable<int> shiftIds);
  Future<List<Shift>> saveLocal(Iterable<Shift> shifts);
  Future<List<Shift>> saveRemote(Iterable<Shift> shifts);
}
