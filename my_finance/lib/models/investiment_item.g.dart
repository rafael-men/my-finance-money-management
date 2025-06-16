// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investiment_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InvestmentItemAdapter extends TypeAdapter<InvestmentItem> {
  @override
  final int typeId = 33;

  @override
  InvestmentItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InvestmentItem(
      name: fields[0] as String,
      amount: fields[1] as String,
      date: fields[2] as DateTime,
      type: fields[3] as String,
      currency: fields[4] == null ? 'BRL' : fields[4] as String,
      broker: fields[5] == null ? '' : fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, InvestmentItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.currency)
      ..writeByte(5)
      ..write(obj.broker);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvestmentItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
