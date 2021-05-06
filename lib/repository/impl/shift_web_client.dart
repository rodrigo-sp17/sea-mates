import 'package:sea_mates/data/shift.dart';
import 'package:sea_mates/repository/shift_repository.dart';

class ShiftWebClient implements ShiftRepository {
  @override
  Future<List<Shift>> addAll(Iterable<Shift> shifts) {
    // TODO: implement addAll
    throw UnimplementedError();
  }

  @override
  Future<List<Shift>> loadShifts() {
    // TODO: implement loadShifts
    throw UnimplementedError();
  }

  @override
  Future<int> removeAll(Iterable<int> shiftIds) {
    // TODO: implement removeAll
    throw UnimplementedError();
  }

  @override
  Future<List<Shift>> saveAll(Iterable<Shift> shifts) {
    // TODO: implement saveAll
    throw UnimplementedError();
  }
}
