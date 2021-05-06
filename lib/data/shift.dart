import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sea_mates/data/sync_status.dart';

part 'shift.g.dart';

@JsonSerializable()
@HiveType(typeId: 0)
class Shift {
  int? id;

  @HiveField(0)
  DateTime unavailabilityStartDate;

  @HiveField(1)
  DateTime boardingDate;

  @HiveField(2)
  DateTime leavingDate;

  @HiveField(3)
  DateTime unavailabilityEndDate;

  @JsonKey(ignore: true)
  @HiveField(4)
  SyncStatus syncStatus;

  int cycleDays = 0;
  int repeat = 0;

  Shift(
      {this.id,
      DateTime? unStartDate,
      DateTime? boardingDate,
      DateTime? leavingDate,
      DateTime? unEndDate,
      SyncStatus? syncStatus})
      : unavailabilityStartDate = unStartDate ?? DateTime.now(),
        this.boardingDate = boardingDate ?? DateTime.now(),
        this.leavingDate = leavingDate ?? DateTime.now(),
        unavailabilityEndDate = unEndDate ?? DateTime.now(),
        this.syncStatus = syncStatus ?? SyncStatus.UNSYNC;

  factory Shift.fromJson(Map<String, dynamic> json) => _$ShiftFromJson(json);
  Map<String, dynamic> toJson() => _$ShiftToJson(this);
}
