import 'package:sea_mates/data/sync_status.dart';

class Shift {
  int id;
  DateTime unavailabilityStartDate;
  DateTime boardingDate;
  DateTime leavingDate;
  DateTime unavailabilityEndDate;
  SyncStatus syncStatus;

  Shift(this.id, this.unavailabilityStartDate, this.boardingDate,
      this.leavingDate, this.unavailabilityEndDate, this.syncStatus);
}
