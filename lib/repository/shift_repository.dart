import 'package:sea_mates/data/shift.dart';

abstract class ShiftRepository {
  Future<List<Shift>> loadShifts();
  Future<List<Shift>> addAll(Iterable<Shift> shifts);
  Future<int> removeAll(Iterable<int> shiftIds);
  Future<List<Shift>> saveAll(Iterable<Shift> shifts);
}
