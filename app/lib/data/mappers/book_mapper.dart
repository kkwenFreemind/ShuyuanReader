import '../../domain/entities/book.dart';
import '../models/book_model.dart';

/// Extension to convert BookModel to Book entity
extension BookModelMapper on BookModel {
  /// Converts a BookModel (data layer) to a Book entity (domain layer)
  Book toEntity() {
    return Book(
      id: id,
      title: title,
      author: author,
      coverUrl: coverUrl,
      epubUrl: epubUrl,
      description: description,
      language: language,
      fileSize: fileSize,
      downloadedAt: downloadedAt,
      localPath: localPath,
    );
  }
}

/// Extension to convert Book entity to BookModel
extension BookEntityMapper on Book {
  /// Converts a Book entity (domain layer) to a BookModel (data layer)
  BookModel toModel() {
    return BookModel(
      id: id,
      title: title,
      author: author,
      coverUrl: coverUrl,
      epubUrl: epubUrl,
      description: description,
      language: language,
      fileSize: fileSize,
      downloadedAt: downloadedAt,
      localPath: localPath,
    );
  }
}

/// Helper functions for list conversions
extension BookModelListMapper on List<BookModel> {
  /// Converts a list of BookModel to a list of Book entities
  List<Book> toEntities() {
    return map((model) => model.toEntity()).toList();
  }
}

extension BookEntityListMapper on List<Book> {
  /// Converts a list of Book entities to a list of BookModel
  List<BookModel> toModels() {
    return map((entity) => entity.toModel()).toList();
  }
}
