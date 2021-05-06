import 'package:hive/hive.dart';
import 'package:sea_mates/data/sync_status.dart';

part 'shift.g.dart';

@HiveType(typeId: 0)
class Shift {
  int id;
  @HiveField(0)
  DateTime unavailabilityStartDate;
  @HiveField(1)
  DateTime boardingDate;
  @HiveField(2)
  DateTime leavingDate;
  @HiveField(3)
  DateTime unavailabilityEndDate;
  @HiveField(4)
  SyncStatus syncStatus = SyncStatus.UNSYNC;

  int cycleDays = 0;
  int repeat = 0;

  Shift(
      [this.id,
      this.unavailabilityStartDate,
      this.boardingDate,
      this.leavingDate,
      this.unavailabilityEndDate,
      this.syncStatus]);
}
