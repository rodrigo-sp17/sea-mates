import 'package:sea_mates/data/shift.dart';

abstract class ShiftRepository {
  Future<List<Shift>> loadShifts();
  Future<List<Shift>> addAll(List<Shift> shifts);
  Future<int> removeAll(List<int> shiftIds);
  Future<List<Shift>> saveAll(List<Shift> shifts);
}
