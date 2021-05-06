import 'dart:core';

import 'package:sea_mates/data/shift.dart';

abstract class ShiftsRepository {
  Future<List<Shift>> loadRemote();
  Future<List<Shift>> loadLocal();
  Future<List<Shift>> addRemote(List<Shift> shifts);
  Future<List<Shift>> addLocal(List<Shift> shifts);
  Future<int> removeRemote(List<int> shiftIds);
  Future<int> removeLocal(List<int> shiftIds);
  Future<List<Shift>> saveLocal(List<Shift> shifts);
  Future<List<Shift>> saveRemote(List<Shift> shifts);
}
