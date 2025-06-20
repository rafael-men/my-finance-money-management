// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TripItemAdapter extends TypeAdapter<TripItem> {
  @override
  final int typeId = 34;

  @override
  TripItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TripItem(
      destination: fields[0] as String,
      currency: fields[1] as String,
      startDate: fields[2] as DateTime,
      endDate: fields[3] as DateTime,
      notes: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TripItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.destination)
      ..writeByte(1)
      ..write(obj.currency)
      ..writeByte(2)
      ..write(obj.startDate)
      ..writeByte(3)
      ..write(obj.endDate)
      ..writeByte(4)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
