import 'package:hive/hive.dart';
import 'package:sea_mates/data/shift.dart';
import 'package:sea_mates/repository/shift_repository.dart';

class ShiftsLocalRepositoryImpl implements ShiftRepository {
  final String _boxName = "shiftsBox";

  @override
  Future<List<Shift>> addAll(List<Shift> shifts) async {
    var box = await Hive.openBox(_boxName);
    List<Shift> result = [];
    for (Shift s in shifts) {
      int index = await box.add(s);
      s.id = index;
      result.add(s);
    }
    return result;
  }

  @override
  Future<List<Shift>> loadShifts() async {
    var box = await Hive.openBox(_boxName);
    // Ensures key to id conversion
    List<Shift> shifts = [];
    box.toMap().forEach((key, value) {
      value.id = key;
      shifts.add(value);
    });
    return shifts;
  }

  @override
  Future<int> removeAll(List<int> shiftIds) async {
    var box = await Hive.openBox(_boxName);
    await box.deleteAll(shiftIds);
    return shiftIds.length;
  }

  @override
  Future<List<Shift>> saveAll(List<Shift> shifts) async {
    var box = await Hive.openBox(_boxName);
    shifts.forEach((element) => box.put(element.id, element));
    var result = shifts.map((e) => box.get(e.id));
    return result;
  }
}
