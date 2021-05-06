import 'package:sea_mates/data/shift.dart';
import 'package:sea_mates/repository/shift_repository.dart';

class ShiftsRemoteRepositoryImpl implements ShiftRepository {
  @override
  Future<List<Shift>> addAll(List<Shift> shifts) {
    throw UnimplementedError();
  }

  @override
  Future<List<Shift>> loadShifts() {
    throw UnimplementedError();
  }

  @override
  Future<int> removeAll(List<int> shiftIds) {
    throw UnimplementedError();
  }

  @override
  Future<List<Shift>> saveAll(List<Shift> shifts) {
    throw UnimplementedError();
  }
}
