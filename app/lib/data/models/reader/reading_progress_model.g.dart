// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_progress_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReadingProgressModelAdapter extends TypeAdapter<ReadingProgressModel> {
  @override
  final int typeId = 3;

  @override
  ReadingProgressModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReadingProgressModel(
      bookId: fields[0] as String,
      currentPage: fields[1] as int,
      bookmarkedPages: (fields[2] as List).cast<int>(),
      lastReadTimeMillis: fields[3] as int,
      epubCfi: fields[4] as String?,
      totalPages: fields[5] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, ReadingProgressModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.bookId)
      ..writeByte(1)
      ..write(obj.currentPage)
      ..writeByte(2)
      ..write(obj.bookmarkedPages)
      ..writeByte(3)
      ..write(obj.lastReadTimeMillis)
      ..writeByte(4)
      ..write(obj.epubCfi)
      ..writeByte(5)
      ..write(obj.totalPages);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingProgressModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
