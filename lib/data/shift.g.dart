// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShiftAdapter extends TypeAdapter<Shift> {
  @override
  final int typeId = 0;

  @override
  Shift read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Shift(
      null,
      fields[0] as DateTime,
      fields[1] as DateTime,
      fields[2] as DateTime,
      fields[3] as DateTime,
      fields[4] as SyncStatus,
    );
  }

  @override
  void write(BinaryWriter writer, Shift obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.unavailabilityStartDate)
      ..writeByte(1)
      ..write(obj.boardingDate)
      ..writeByte(2)
      ..write(obj.leavingDate)
      ..writeByte(3)
      ..write(obj.unavailabilityEndDate)
      ..writeByte(4)
      ..write(obj.syncStatus);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShiftAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
