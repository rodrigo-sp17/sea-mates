import 'package:sea_mates/data/shift.dart';
import 'package:sea_mates/repository/impl/shifts_local_repository_impl.dart';
import 'package:sea_mates/repository/impl/shifts_remote_repository_impl.dart';
import 'package:sea_mates/repository/shift_repository.dart';
import 'package:sea_mates/repository/shifts_repository.dart';

class ShiftsRepositoryImpl implements ShiftsRepository {
  final ShiftRepository localRepo = ShiftsLocalRepositoryImpl();
  final ShiftRepository remoteRepo = ShiftsRemoteRepositoryImpl();

  @override
  Future<List<Shift>> addLocal(List<Shift> shifts) {
    return localRepo.addAll(shifts);
  }

  @override
  Future<List<Shift>> addRemote(List<Shift> shifts) {
    return remoteRepo.addAll(shifts);
  }

  @override
  Future<List<Shift>> loadLocal() {
    return localRepo.loadShifts();
  }

  @override
  Future<List<Shift>> loadRemote() {
    return remoteRepo.loadShifts();
  }

  @override
  Future<int> removeLocal(List<int> ids) {
    return localRepo.removeAll(ids);
  }

  @override
  Future<int> removeRemote(List<int> ids) {
    return removeRemote(ids);
  }

  @override
  Future<List<Shift>> saveLocal(List<Shift> shifts) {
    return localRepo.saveAll(shifts);
  }

  @override
  Future<List<Shift>> saveRemote(List<Shift> shifts) {
    return remoteRepo.saveAll(shifts);
  }
}
