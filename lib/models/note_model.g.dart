// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteModelAdapter extends TypeAdapter<NoteModel> {
  @override
  final int typeId = 0;

  @override
  NoteModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoteModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      contentUrl: fields[3] as String,
      category: fields[4] as String?,
      tags: (fields[5] as List).cast<String>(),
      isShared: fields[6] as bool,
      viewCount: fields[7] as int,
      authorId: fields[8] as String,
      authorName: fields[9] as String,
      status: fields[10] as String,
      semester: fields[11] as String?,
      createdAt: fields[12] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, NoteModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.contentUrl)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.tags)
      ..writeByte(6)
      ..write(obj.isShared)
      ..writeByte(7)
      ..write(obj.viewCount)
      ..writeByte(8)
      ..write(obj.authorId)
      ..writeByte(9)
      ..write(obj.authorName)
      ..writeByte(10)
      ..write(obj.status)
      ..writeByte(11)
      ..write(obj.semester)
      ..writeByte(12)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
