// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DownloadStatusAdapter extends TypeAdapter<DownloadStatus> {
  @override
  final int typeId = 2;

  @override
  DownloadStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DownloadStatus.notDownloaded;
      case 1:
        return DownloadStatus.downloading;
      case 2:
        return DownloadStatus.paused;
      case 3:
        return DownloadStatus.downloaded;
      case 4:
        return DownloadStatus.failed;
      default:
        return DownloadStatus.notDownloaded;
    }
  }

  @override
  void write(BinaryWriter writer, DownloadStatus obj) {
    switch (obj) {
      case DownloadStatus.notDownloaded:
        writer.writeByte(0);
        break;
      case DownloadStatus.downloading:
        writer.writeByte(1);
        break;
      case DownloadStatus.paused:
        writer.writeByte(2);
        break;
      case DownloadStatus.downloaded:
        writer.writeByte(3);
        break;
      case DownloadStatus.failed:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
