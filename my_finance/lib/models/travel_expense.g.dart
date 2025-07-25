// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'travel_expense.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TravelExpenseAdapter extends TypeAdapter<TravelExpense> {
  @override
  final int typeId = 35;

  @override
  TravelExpense read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TravelExpense(
      tripId: fields[0] as String,
      description: fields[1] as String,
      amount: fields[2] as double,
      date: fields[3] as DateTime,
      category: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TravelExpense obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.tripId)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TravelExpenseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
