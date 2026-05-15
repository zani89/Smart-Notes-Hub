// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignment_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AssignmentModelAdapter extends TypeAdapter<AssignmentModel> {
  @override
  final int typeId = 1;

  @override
  AssignmentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AssignmentModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      teacherId: fields[3] as String,
      dueDate: fields[4] as DateTime,
      createdAt: fields[5] as DateTime,
      course: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AssignmentModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.teacherId)
      ..writeByte(4)
      ..write(obj.dueDate)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.course);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssignmentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SubmissionModelAdapter extends TypeAdapter<SubmissionModel> {
  @override
  final int typeId = 2;

  @override
  SubmissionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubmissionModel(
      id: fields[0] as String,
      assignmentId: fields[1] as String,
      studentId: fields[2] as String,
      fileUrl: fields[3] as String,
      grade: fields[4] as String?,
      feedback: fields[5] as String?,
      createdAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SubmissionModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.assignmentId)
      ..writeByte(2)
      ..write(obj.studentId)
      ..writeByte(3)
      ..write(obj.fileUrl)
      ..writeByte(4)
      ..write(obj.grade)
      ..writeByte(5)
      ..write(obj.feedback)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubmissionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
