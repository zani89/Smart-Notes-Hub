// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collaboration_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContributionRequestModelAdapter
    extends TypeAdapter<ContributionRequestModel> {
  @override
  final int typeId = 3;

  @override
  ContributionRequestModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ContributionRequestModel(
      id: fields[0] as String,
      noteId: fields[1] as String,
      studentId: fields[2] as String,
      reason: fields[3] as String?,
      status: fields[4] as String,
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ContributionRequestModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.noteId)
      ..writeByte(2)
      ..write(obj.studentId)
      ..writeByte(3)
      ..write(obj.reason)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContributionRequestModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
