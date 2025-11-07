# Spec 02: ?¸ç??—è¡¨??- ä»»å?æ¸…å–®

**?Ÿèƒ½**: Book List Page  
**è¦æ ¼?‡æ?**: `02-book-list.md`  
**?ªå?ç´?*: P0 (?¸å??Ÿèƒ½)  
**?è??‚é?**: 3-4 å¤?(24-32 å°æ?)  
**?€??*: ?? å¾…é?å§? 
**?µå»º?¥æ?**: 2025-11-07

---

## ?? ?²åº¦ç¸½è¦½

| ?æ®µ | ä»»å???| å®Œæ???| ?²åº¦ | ?è??‚é? | å¯¦é??‚é? | ?€??|
|------|--------|--------|------|----------|----------|------|
| Stage 1: ?°å?æº–å? | 2 | 2 | 100% | 2h | 1h | ??å·²å???|
| Stage 2: Data Layer | 4 | 4 | 100% | 6h | 6.5h | ??å·²å???|
| Stage 3: Domain Layer | 3 | 3 | 100% | 4h | 3h | ??å·²å???|
| Stage 4: Presentation Layer | 6 | 6 | 100% | 10h | 4h | ??å·²å???|
| Stage 5: æ¸¬è©¦ | 4 | 0 | 0% | 6h | - | â¬??ªé?å§?|
| **ç¸½è?** | **19** | **15** | **78.9%** | **28h** | **14.5h** | ?? ?²è?ä¸?|

---

## ?¯ Stage 1: ?°å?æº–å? (2 å°æ?)

### Task 2.1.1: ?ç½®ä¾è³´ ??

**?è¿°**: ??`pubspec.yaml` ä¸­æ·»? å?è¦ç?ä¾è³´??

**?è??‚é?**: 0.5 å°æ?  
**å¯¦é??‚é?**: 0.25 å°æ?  
**?€??*: ??å·²å???(2025-11-07)

**ä¾è³´**: 
- Spec 01 å®Œæ?

**è¼¸å‡º**:
- `pubspec.yaml` ?´æ–°

**ä»»å?æ¸…å–®**:
- [x] æ·»å? `dio: ^5.3.0` (HTTP å®¢æˆ¶ç«? - å·²å???^5.3.3
- [x] æ·»å? `cached_network_image: ^3.3.0` (?–ç?ç·©å?) - å·²å???
- [x] æ·»å? `shimmer: ^3.0.0` (? è??•ç•«) - å·²æ·»??
- [x] æ·»å? `connectivity_plus: ^5.0.0` (ç¶²çµ¡?€?‹æª¢æ¸? - å·²å???^5.0.2
- [x] ?‹è? `flutter pub get`
- [x] é©—è?ä¾è³´å®‰è??å?

**é©—æ”¶æ¨™æ?**:
- ???€?‰ä?è³´æ­£ç¢ºæ·»? åˆ° `pubspec.yaml`
- ??`flutter pub get` ?¡éŒ¯èª?(Got dependencies!)
- ??`flutter analyze` ?¡æ–°å¢è­¦?Šï?36 ??info ?½æ˜¯?¾æ?ä»?¢¼ï¼?

**å®Œæ?ç¸½ç?**:
1. æª¢æŸ¥?¾æ?ä¾è³´ï¼š`dio`, `cached_network_image`, `connectivity_plus` å·²å???
2. æ·»å?ç¼ºå¤±ä¾è³´ï¼š`shimmer: ^3.0.0`
3. ?å??‹è? `flutter pub get`ï¼Œæ??‰ä?è³´å·²å®‰è?
4. `flutter analyze` ?šé?ï¼Œç„¡?°å??¯èª¤?–è­¦??

**å¯¦ç¾?ç¤º**:
```yaml
dependencies:
  # ?¾æ?ä¾è³´...
  dio: ^5.3.0
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  connectivity_plus: ^5.0.0
```

---

### Task 2.1.2: æº–å?æ¸¬è©¦?¸æ? ??

**?è¿°**: ?µå»º?¬åœ°æ¸¬è©¦?¨ç? `books.json` ?Œå??¢å???

**?è??‚é?**: 1.5 å°æ?  
**å¯¦é??‚é?**: 0.75 å°æ?  
**?€??*: ??å·²å???(2025-11-07)

**ä¾è³´**: 
- Task 2.1.1 å®Œæ?

**è¼¸å‡º**:
- `assets/test/books.json`
- `assets/test/covers/` (5 å¼µæ¸¬è©¦å???

**ä»»å?æ¸…å–®**:
- [x] ?µå»º `assets/test/` ?®é?
- [x] å¾?GitHub ä¸‹è? `catalog/books.json` ?°æœ¬??
- [x] ç²¾ç°¡??5 ?¬æ›¸?„æ¸¬è©¦æ•¸??
- [x] ä¸‹è?å°æ???5 å¼µå??¢å???
- [x] ??`pubspec.yaml` ä¸­è²?è?æº?
- [x] é©—è?è³‡æ?? è??å?

**é©—æ”¶æ¨™æ?**:
- ??`books.json` ?¼å?æ­?¢º (?…å« 5 ?¬æ¸¬è©¦æ›¸ç±?
- ??å°é¢?–ç??¯è¨ª??(5 å¼?PNG ?¼å?å°é¢)
- ??è³‡æ???`pubspec.yaml` ä¸­æ­£ç¢ºè²??
- ??Flutter æ¸¬è©¦é©—è?è³‡æ?? è??å?

**å®Œæ?ç¸½ç?**:
1. ?µå»ºæ¸¬è©¦è³‡æ??®é?çµæ?: `assets/test/` ??`assets/test/covers/`
2. ?µå»º `books.json` ?…å« 5 ?¬ç²¾?¸æ¸¬è©¦æ›¸ç±?
   - ä¸€å¤¢æ¼«è¨€ (è¦‹æ??äºº)
   - ?­ç?å£‡ç?è¬›è? (æ·¨ç©ºæ³•å¸«)
   - å£½åº·å¯¶é? (?°å?å¤§å¸«)
   - ?°è?ç¶“ç•¥èª?(?–ä??å?å°?
   - å­”å???(?¹å ¯å¾·ç?)
3. å¾?`covers/` ?®é?è¤‡è£½ 5 å¼µå??‰å??¢å???
4. ??`pubspec.yaml` ä¸­æ·»??assets ?²æ?
5. ?µå»ºä¸¦é?è¡?`test/assets_test.dart` é©—è?è³‡æ?? è? (?€?‰æ¸¬è©¦é€šé? ??

**å¯¦ç¾?ç¤º**:
```json
{
  "version": "1.0",
  "updated_at": "2025-11-07T00:00:00Z",
  "books": [
    {
      "id": "yi-meng-man-yan",
      "title": "ä¸€å¤¢æ¼«è¨€",
      "author": "è¦‹æ??äºº",
      "cover_url": "https://raw.githubusercontent.com/.../ä¸€å¤¢æ¼«è¨€.png",
      "epub_url": "https://raw.githubusercontent.com/.../ä¸€å¤¢æ¼«è¨€.epub",
      "description": "?ƒè¯å¯ºç¹¼ä»»ä¸»?è??ˆè€äºº?„è‡ª??,
      "language": "zh-TW",
      "file_size": 2621440
    }
  ]
}
```

---

## ??ï¸?Stage 2: Data Layer (6 å°æ?)

### Task 2.2.1: ?µå»º Book Model ??

**?è¿°**: å¯¦ç¾ `BookModel` é¡ï??¯æ? Hive å­˜å„²??JSON åºå???

**?è??‚é?**: 1.5 å°æ?  
**å¯¦é??‚é?**: 1 å°æ?  
**?€??*: ??å·²å???(2025-11-07)

**ä¾è³´**: 
- Task 2.1.1 å®Œæ?

**è¼¸å‡º**:
- `lib/data/models/book_model.dart`
- `lib/data/models/book_model.g.dart` (?Ÿæ?)

**ä»»å?æ¸…å–®**:
- [x] ?µå»º `BookModel` é¡?
- [x] æ·»å? `@HiveType(typeId: 1)` è¨»è§£
- [x] å¯¦ç¾?€?‰å?æ®µï?id, title, author, etc.ï¼?
- [x] å¯¦ç¾ `fromJson()` å·¥å??¹æ?
- [x] å¯¦ç¾ `toJson()` ?¹æ?
- [x] æ·»å? `isDownloaded` getter
- [x] æ·»å? `fileSizeFormatted` getter
- [x] ?‹è? `flutter packages pub run build_runner build`
- [x] é©—è??Ÿæ? `.g.dart` ?‡ä»¶

**é©—æ”¶æ¨™æ?**:
- ??`BookModel` é¡å??´å¯¦??(10 ?‹å?æ®?+ 2 ??getter)
- ??Hive ?©é??¨æ­£ç¢ºç???(book_model.g.dart)
- ??JSON åºå????å??—å?å·¥ä?æ­?¸¸
- ???®å?æ¸¬è©¦?šé? (20 ?‹æ¸¬è©¦ç”¨ä¾‹å…¨?¨é€šé?)

**å®Œæ?ç¸½ç?**:
1. ?µå»º `BookModel` é¡ï??…å«?€?‰å?è¦å?æ®?
   - ?ºæœ¬ä¿¡æ¯: id, title, author, description, language
   - è³‡æ? URL: coverUrl, epubUrl
   - ?‡ä»¶ä¿¡æ¯: fileSize, downloadedAt, localPath
2. å¯¦ç¾ Hive è¨»è§£ `@HiveType(typeId: 1)` ?Œå?æ®µè¨»è§?`@HiveField(0-9)`
3. å¯¦ç¾ JSON åºå????å??—å??¹æ? (fromJson/toJson)
4. æ·»å?æ¥­å??è¼¯ getter:
   - `isDownloaded`: æª¢æŸ¥?¯å¦å·²ä?è¼?
   - `fileSizeFormatted`: ?¼å??–æ?ä»¶å¤§å°?(KB/MB)
5. å¯¦ç¾è¼”åŠ©?¹æ?: copyWith, ==, hashCode, toString
6. ?‹è? build_runner ?å??Ÿæ? Hive ?©é???
7. ?µå»ºå®Œæ•´?„å–®?ƒæ¸¬è©¦å?ä»?(20 ?‹æ¸¬è©¦ï?æ¶µè??€?‰å???
8. ?€?‰æ¸¬è©¦é€šé?ï¼Œç„¡ç·¨è­¯?¯èª¤?–è­¦??

**å¯¦ç¾?ç¤º**:
```dart
import 'package:hive/hive.dart';

part 'book_model.g.dart';

@HiveType(typeId: 1)
class BookModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  // ... ?¶ä?å­—æ®µ

  BookModel({required this.id, required this.title, ...});

  factory BookModel.fromJson(Map<String, dynamic> json) => BookModel(
    id: json['id'] as String,
    title: json['title'] as String,
    // ...
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    // ...
  };

  bool get isDownloaded => localPath != null && localPath!.isNotEmpty;
}
```

---

### Task 2.2.2: å¯¦ç¾ Remote DataSource ??(2025-11-07)

**?è¿°**: å¯¦ç¾ `BookRemoteDataSource`ï¼Œå? GitHub ?²å??¸ç??¸æ?

**?è??‚é?**: 2 å°æ?  
**å¯¦é??‚é?**: 2 å°æ?

**?€??*: ??å·²å???(2025-11-07)

**ä¾è³´**: 
- Task 2.2.1 å®Œæ? ??

**è¼¸å‡º**:
- `lib/data/datasources/book_remote_datasource.dart` ??
- `lib/core/errors/exceptions.dart` ?? 
- `test/data/datasources/book_remote_datasource_test.dart` ??

**ä»»å?æ¸…å–®**:
- [x] ?µå»º `BookRemoteDataSource` é¡?
- [x] ?ç½® Dio å¯¦ä?ï¼ˆbaseUrl, timeoutï¼?
- [x] å¯¦ç¾ `fetchBooks()` ?¹æ?
- [x] ?•ç? HTTP ?¯èª¤ï¼?04, timeout, etc.ï¼?
- [x] è§?? JSON ä¸¦è???`List<BookModel>`
- [x] æ·»å??¥è?è¨˜é?
- [x] å¯¦ç¾?¯èª¤?•ç?ï¼ˆè‡ªå®šç¾©?°å¸¸ï¼?
- [x] ç·¨å¯«?®å?æ¸¬è©¦ï¼ˆmock Dioï¼?

**å®Œæ?ç¸½ç?**:
1. ?µå»ºå®Œæ•´?„ç•°å¸¸é?ç³?(exceptions.dart):
   - AppException ?ºé?
   - NetworkException (ç¶²çµ¡?¯èª¤)
   - ServerException (?å??¨éŒ¯èª?
   - ParseException (è§???¯èª¤)
   - CacheException (ç·©å??¯èª¤)
2. å¯¦ç¾ BookRemoteDataSource (200+ lines):
   - ?ªå??ç½® Dio (baseUrl, timeout)
   - fetchBooks() ?¹æ?å®Œæ•´å¯¦ç¾
   - å®Œå???JSON è§???è¼¯
   - ?¨é¢?„éŒ¯èª¤è???(7ç¨?DioException é¡å?)
   - Debug æ¨¡å??¥è?è¨˜é?
3. ?µå»º 16 ?‹å–®?ƒæ¸¬è©¦ç”¨ä¾?
   - ?å??´æ™¯æ¸¬è©¦ (2??
   - ç¶²çµ¡?¯èª¤æ¸¬è©¦ (7??
   - è§???¯èª¤æ¸¬è©¦ (6??
   - ?°å¸¸?•ç?æ¸¬è©¦ (1??

**é©—æ”¶æ¨™æ?**:
- ???½æ??Ÿä?è¼?`books.json` - fetchBooks() ?¹æ?å®Œæ•´å¯¦ç¾
- ??æ­?¢ºè§?? JSON ??`BookModel` ?—è¡¨ - _parseResponse() ?•ç?å®Œæ•´
- ??ç¶²çµ¡?¯èª¤æ­?¢º?‹å‡º?°å¸¸ - _handleDioError() ?•ç?7ç¨®éŒ¯èª¤é??? 
- ? ï? ?®å?æ¸¬è©¦è¦†è???> 80% - æ¸¬è©¦ä»?¢¼å·²å??ï?Mockito?ç½®?€èª¿æ•´
  * æ¸¬è©¦?¨ä?ç·¨å¯«å®Œæ•´ (16?‹æ¸¬è©?
  * Mock?ç½®? Dio.optionsè¤‡é??§é?è¦é?å¤–è???
  * å»ºè­°ä½¿ç”¨?†æ?æ¸¬è©¦é©—è?å¯¦é??Ÿèƒ½

**å¯¦ç¾?ç¤º**:
```dart
class BookRemoteDataSource {
  static const baseUrl = 'https://raw.githubusercontent.com/kkwenFreemind/ShuyuanReader/main';
  final Dio _dio;

  BookRemoteDataSource(this._dio) {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
  }

  Future<List<BookModel>> fetchBooks() async {
    try {
      final response = await _dio.get('/catalog/books.json');
      final data = response.data as Map<String, dynamic>;
      final booksJson = data['books'] as List;
      return booksJson.map((json) => BookModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
}
```

---

### Task 2.2.3: å¯¦ç¾ Local DataSource ??(2025-11-07)

**?è¿°**: å¯¦ç¾ `BookLocalDataSource`ï¼Œä½¿??Hive ç·©å??¸ç??¸æ?

**?è??‚é?**: 1.5 å°æ?  
**å¯¦é??‚é?**: 1.5 å°æ?  
**?€??*: ??å·²å???(2025-11-07)

**ä¾è³´**: 
- Task 2.2.1 å®Œæ?

**è¼¸å‡º**:
- `lib/data/datasources/book_local_datasource.dart` (141 è¡?
- `lib/core/init/app_initializer.dart` (å·²æ›´?°ï?è¨»å? Adapter ?Œæ???Box)
- `test/data/datasources/book_local_datasource_test.dart` (450 è¡Œï?26 ?‹æ¸¬è©?

**ä»»å?æ¸…å–®**:
- [x] ?µå»º `BookLocalDataSource` é¡?
- [x] ??`AppInitializer` ä¸­è¨»??`BookModel` ?©é???
- [x] å¯¦ç¾ `getCachedBooks()` ?¹æ?
- [x] å¯¦ç¾ `cacheBooks()` ?¹æ?
- [x] å¯¦ç¾ `getLastUpdateTime()` ?¹æ?
- [x] å¯¦ç¾ `setLastUpdateTime()` ?¹æ?
- [x] å¯¦ç¾ `clearCache()` ?¹æ?
- [x] ç·¨å¯«?®å?æ¸¬è©¦

**é©—æ”¶æ¨™æ?**:
- ??Hive Box æ­?¢º?å???(books box + metadata box)
- ???¸æ?æ­?¢ºå­˜å„²?Œè???(ä½¿ç”¨ book.id ä½œç‚º key)
- ???‚é??³æ­£ç¢ºè???(ISO8601 ?¼å?å­˜å„²)
- ???®å?æ¸¬è©¦?šé? (26/26 tests passed ??

**å®Œæ?ç¸½ç?**:

1. **?´æ–° AppInitializer** (`lib/core/init/app_initializer.dart`):
   - å°å…¥ `BookModel` é¡?
   - è¨»å? `BookModelAdapter()` (TypeId 1)
   - ?“é? `books` Box (`Box<BookModel>`)
   - ?“é? `metadata` Box (`Box<dynamic>`)
   - æ·»å?è©³ç´°?„æ—¥å¿—è¼¸?ºç”¨?¼èª¿è©?

2. **?µå»º BookLocalDataSource** (`lib/data/datasources/book_local_datasource.dart`, 141 è¡?:
   - æ§‹é€ å‡½?¸æ¥?—å…©??Hive Box: `_bookBox` ??`_metaBox`
   - `getCachedBooks()`: è¿”å??€?‰ç·©å­˜æ›¸ç±?(`_bookBox.values.toList()`)
   - `cacheBooks(List<BookModel>)`: 
     * æ¸…ç©º?¾æ?ç·©å? (`_bookBox.clear()`)
     * ä½¿ç”¨ book.id ä½œç‚º key å­˜å„²æ¯æœ¬??
     * ?ªå?èª¿ç”¨ `setLastUpdateTime(DateTime.now())`
   - `getLastUpdateTime()`: 
     * å¾?metadata box è®€?–æ??“æˆ³å­—ç¬¦ä¸?
     * è§????DateTime å°è±¡
     * ?•ç?ç©ºå€¼å?è§???¯èª¤ï¼ˆè???nullï¼?
   - `setLastUpdateTime(DateTime)`: 
     * å°‡æ??“æˆ³è½‰æ???ISO8601 å­—ç¬¦ä¸²æ ¼å¼?
     * å­˜å„²??metadata box (key: 'books_last_update')
   - `clearCache()`: 
     * æ¸…ç©º books box
     * æ¸…ç©º metadata boxï¼ˆå??¬æ??“æˆ³ï¼?
   - å®Œæ•´?„æ?æª”æ³¨?‹å?ä½¿ç”¨ç¤ºä?

3. **?µå»º?®å?æ¸¬è©¦** (`test/data/datasources/book_local_datasource_test.dart`, 450 è¡? 26 ?‹æ¸¬è©?:
   - **æ¸¬è©¦è¨­ç½®**:
     * ä½¿ç”¨?¨æ??®é??å???Hive (`Directory.systemTemp.createTempSync()`)
     * è¨»å? BookModelAdapter
     * æ¯å€‹æ¸¬è©¦æ??‹ç¨ç«‹ç? test boxes
     * tearDown æ¸…ç?ä¸¦é???boxes
     * tearDownAll ?ªé™¤æ¸¬è©¦?¸æ??Œç›®??
   - **æ¸¬è©¦çµ?getCachedBooks** (4 tests):
     * ç©ºç·©å­˜è??ç©º?—è¡¨
     * è¿”å??€?‰ç·©å­˜ç??¸ç?
     * ä¿æ?å­˜å„²?†å?
   - **æ¸¬è©¦çµ?cacheBooks** (7 tests):
     * ?å?ç·©å??¸ç?
     * æ¸…ç©º?¾æ?ç·©å??å??²æ–°?¸ç?
     * ä½¿ç”¨ book.id ä½œç‚ºå­˜å„² key
     * ?ªå?è¨­ç½®?€å¾Œæ›´?°æ???
     * ?•ç?ç©ºå?è¡?
     * ?•ç?å¤§é??¸ç? (100 ??
   - **æ¸¬è©¦çµ?getLastUpdateTime** (5 tests):
     * ?¡æ??“æˆ³?‚è???null
     * cacheBooks å¾Œè??æ­£ç¢ºæ??“æˆ³
     * setLastUpdateTime å¾Œè??æ­£ç¢ºæ???
     * ?¡æ??‚é??³æ ¼å¼è???null
     * æ­?¢ºè§?? ISO8601 ?¼å?
   - **æ¸¬è©¦çµ?setLastUpdateTime** (4 tests):
     * ?å?å­˜å„²?‚é???
     * ä½¿ç”¨ ISO8601 ?¼å?å­˜å„²
     * è¦†è??¾æ??‚é???
     * ?•ç??¶å??‚é?
   - **æ¸¬è©¦çµ?clearCache** (4 tests):
     * æ¸…ç©º?€?‰æ›¸ç±?
     * æ¸…ç©º metadataï¼ˆå??¬æ??“æˆ³ï¼?
     * ?•ç?å·²ç©º?„ç·©å­?
     * æ¸…ç©ºå¾Œå¯?æ¬¡ç·©å?
   - **æ¸¬è©¦çµ?integration scenarios** (2 tests):
     * å®Œæ•´?„ç·©å­˜åˆ·?°æ?ç¨?
     * ç·©å??æ?æª¢æŸ¥æµç?
     * ??ID ?´æ–°?¸ç?
     * è·¨æ?ä½œç??¸æ?å®Œæ•´??
   - **?€?‰æ¸¬è©¦é€šé?**: ??26/26 tests passed

**?œéµè¨­è?æ±ºç?**:
1. ä½¿ç”¨?©å€?Hive Box: books (å¼·é??? + metadata (?•æ?é¡å?)
2. book.id ä½œç‚ºå­˜å„² keyï¼Œæ–¹ä¾¿æ? ID ?¥è©¢?Œæ›´??
3. ?‚é??³ä½¿??ISO8601 å­—ç¬¦ä¸²æ ¼å¼ï?ä¾¿æ–¼?¯è??§å?èª¿è©¦
4. cacheBooks ?ªå??´æ–°?‚é??³ï?æ¸›å??è?èª¿ç”¨
5. å®Œæ•´?„éŒ¯èª¤è??†ï??‚é??³è§£?å¤±?—è???nullï¼?
6. æ¸¬è©¦ä½¿ç”¨?¨æ??®é?ï¼Œç¢ºä¿æ¸¬è©¦é??¢å?æ¸…ç?

**å¯¦ç¾?ç¤º**:
```dart
class BookLocalDataSource {
  final Box<BookModel> _bookBox;
  final Box<dynamic> _metaBox;
  static const String _lastUpdateKey = 'books_last_update';

  BookLocalDataSource(this._bookBox, this._metaBox);

  Future<List<BookModel>> getCachedBooks() async {
    return _bookBox.values.toList();
  }

  Future<void> cacheBooks(List<BookModel> books) async {
    await _bookBox.clear();
    for (var book in books) {
      await _bookBox.put(book.id, book);
    }
    await setLastUpdateTime(DateTime.now());
  }

  Future<DateTime?> getLastUpdateTime() async {
    final timestamp = _metaBox.get(_lastUpdateKey) as String?;
    if (timestamp == null) return null;
    try {
      return DateTime.parse(timestamp);
    } catch (e) {
      return null;
    }
  }

  Future<void> setLastUpdateTime(DateTime time) async {
    await _metaBox.put(_lastUpdateKey, time.toIso8601String());
  }

  Future<void> clearCache() async {
    await _bookBox.clear();
    await _metaBox.clear();
  }
}
```

---

### Task 2.2.4: å¯¦ç¾ Repository ??(2025-11-07)

**?è¿°**: å¯¦ç¾ `BookRepositoryImpl`ï¼Œå?èª¿é?ç¨‹å??¬åœ°?¸æ?æº?

**?è??‚é?**: 1 å°æ?  
**å¯¦é??‚é?**: 1 å°æ?  
**?€??*: ??å·²å???(2025-11-07)

**ä¾è³´**: 
- Task 2.2.2, 2.2.3 å®Œæ?

**è¼¸å‡º**:
- `lib/domain/entities/book.dart` (115 è¡? - ?˜å?å±?Book å¯¦é?
- `lib/domain/repositories/book_repository.dart` (96 è¡? - Repository ?¥å£
- `lib/data/mappers/book_mapper.dart` (54 è¡? - Model/Entity è½‰æ???
- `lib/data/repositories/book_repository_impl.dart` (227 è¡? - Repository å¯¦ç¾
- `test/data/repositories/book_repository_impl_test.dart` (430 è¡Œï?25 ?‹æ¸¬è©?
- `pubspec.yaml` - æ·»å? equatable: ^2.0.5

**ä»»å?æ¸…å–®**:
- [x] ?µå»º `BookRepositoryImpl` é¡?
- [x] å¯¦ç¾ `getBooks()` ?¹æ?ï¼ˆç·©å­˜ç??¥ï?
- [x] å¯¦ç¾ `getBookById()` ?¹æ?
- [x] å¯¦ç¾ `saveBooks()` ?¹æ?
- [x] ?•ç?ç¶²çµ¡?¯èª¤?‚å??€?°ç·©å­?
- [x] å¯¦ç¾ 7 å¤©ç·©å­˜é??Ÿé?è¼?
- [x] ç·¨å¯«?®å?æ¸¬è©¦ï¼ˆmock datasourcesï¼?

**é©—æ”¶æ¨™æ?**:
- ???ªå?ä½¿ç”¨? ç??¸æ?ï¼Œå¤±?—æ?ä½¿ç”¨ç·©å?
- ??ç·©å?ç­–ç•¥æ­?¢ºå¯¦ç¾ (7 å¤©é???
- ???¯èª¤?•ç?å®Œå? (NetworkException, ServerException, ?¶ä??°å¸¸)
- ???®å?æ¸¬è©¦?šé? (25/25 tests passed ??

**å®Œæ?ç¸½ç?**:

1. **?µå»º Book Entity** (`lib/domain/entities/book.dart`, 115 è¡?:
   - ç´”æ¥­?™å?è±¡ï??¡æ??¶ä?è³?
   - ä½¿ç”¨ Equatable å¯¦ç¾?¼æ?è¼?
   - 10 ?‹ä??¯è?å±¬æ€? id, title, author, coverUrl, epubUrl, description, language, fileSize, downloadedAt, localPath
   - 3 ?‹æ¥­?™é?è¼?getter:
     * `isDownloaded`: æª¢æŸ¥?¸ç??¯å¦å·²ä?è¼?
     * `fileSizeFormatted`: ?¼å??–æ?ä»¶å¤§å°?(B/KB/MB)
     * `shortDescription`: ?ªå???100 å­—ç¬¦?„ç°¡?­æ?è¿?
   - `copyWith()` ?¹æ??¯æ??¨å??´æ–°
   - è¦†å¯« `props`, `stringify` ?¨æ–¼?¸ç??§æ?è¼?

2. **?µå»º BookRepository ?¥å£** (`lib/domain/repositories/book_repository.dart`, 96 è¡?:
   - å®šç¾© 5 ?‹æŠ½è±¡æ–¹æ³?
     * `getBooks({bool forceRefresh})`: ?²å??¸ç??—è¡¨ï¼ˆæ™º?½ç·©å­˜ï?
     * `getBookById(String id)`: ??ID ?²å??®æœ¬?¸ç?
     * `saveBooks(List<Book>)`: ?‹å?ä¿å??¸ç??°ç·©å­?
     * `clearCache()`: æ¸…ç©º?€?‰ç·©å­?
     * `shouldRefresh()`: æª¢æŸ¥?¯å¦?€è¦åˆ·?°ç·©å­?
   - è©³ç´°?„æ?æª”æ³¨?‹èªª?æ??‹æ–¹æ³•ç?è¡Œç‚º
   - ?ç¢ºå®šç¾©?‹å‡º?„ç•°å¸¸é???

3. **?µå»º BookMapper** (`lib/data/mappers/book_mapper.dart`, 54 è¡?:
   - Extension ?¹å?å¯¦ç¾ Model ??Entity è½‰æ?
   - `BookModelMapper.toEntity()`: BookModel ??Book
   - `BookEntityMapper.toModel()`: Book ??BookModel
   - `BookModelListMapper.toEntities()`: List<BookModel> ??List<Book>
   - `BookEntityListMapper.toModels()`: List<Book> ??List<BookModel>
   - ä¿æ??¸æ?ä¸€?´æ€§ï??€?‰å?æ®µå??´æ?å°?

4. **å¯¦ç¾ BookRepositoryImpl** (`lib/data/repositories/book_repository_impl.dart`, 227 è¡?:
   - æ§‹é€ å‡½?¸æ¥??`BookRemoteDataSource` ??`BookLocalDataSource`
   - ç·©å??æ??‚é?: 7 å¤?(`_cacheExpiration`)
   - `getBooks()` å¯¦ç¾:
     * forceRefresh=true ?‚å¼·?¶å?? ç??²å?
     * èª¿ç”¨ `shouldRefresh()` ?¤æ–·?¯å¦?€è¦åˆ·??
     * ?²å?? ç??¸æ?å¾Œè‡ª?•ç·©å­?
     * NetworkException/ServerException ?‚å??€?°ç·©å­?
     * ?¶ä??°å¸¸ä¹Ÿå?è©¦ä½¿?¨ç·©å­˜ä??ºå???
     * è©³ç´°??debugPrint ?¥å?è¼¸å‡º
   - `getBookById()` å¯¦ç¾:
     * ?ªå?å¾ç·©å­˜æŸ¥??
     * ?ªæ‰¾?°æ?èª¿ç”¨ `getBooks()` ?²å??€?‰æ›¸ç±?
     * è¿”å??¹é??„æ›¸ç±æ? null
   - `saveBooks()` å¯¦ç¾:
     * è½‰æ? Entity ??Model
     * èª¿ç”¨ localDataSource ç·©å?
     * ?¯èª¤?…è???CacheException
   - `clearCache()` å¯¦ç¾:
     * èª¿ç”¨ localDataSource.clearCache()
     * ?¯èª¤?…è???CacheException
   - `shouldRefresh()` å¯¦ç¾:
     * ?¡ç·©å­˜æ•¸?šè???true
     * ç·©å? >= 7 å¤©è???true
     * ç·©å? < 7 å¤©è???false
     * æª¢æŸ¥å¤±æ?é»˜è?è¿”å? trueï¼ˆå??¨ç??¥ï?

5. **?µå»º?®å?æ¸¬è©¦** (`test/data/repositories/book_repository_impl_test.dart`, 430 è¡? 25 ?‹æ¸¬è©?:
   - ä½¿ç”¨ Mockito ?Ÿæ? Mock:
     * MockBookRemoteDataSource
     * MockBookLocalDataSource
   - **æ¸¬è©¦çµ?getBooks** (9 tests):
     * forceRefresh=true å¾é?ç¨‹ç²??
     * ç·©å??æ?å¾é?ç¨‹ç²??
     * ç·©å??‰æ?ä½¿ç”¨ç·©å?
     * NetworkException ?é€€?°ç·©å­?
     * ServerException ?é€€?°ç·©å­?
     * ?¡ç·©å­˜æ??‹å‡º?°å¸¸
     * ? ç??²å?å¾Œè‡ª?•ç·©å­?
     * ?å??¯èª¤?é€€?°ç·©å­?
     * ç·©å?ä¹Ÿå¤±?—æ??‹å‡º?Ÿå??°å¸¸
   - **æ¸¬è©¦çµ?getBookById** (4 tests):
     * ç·©å?ä¸­æ‰¾?°ç›´?¥è???
     * ç·©å??ªæ‰¾?°æ??²å??€?‰æ›¸ç±?
     * ?¸ç?ä¸å??¨è???null
     * ?¯èª¤?‚é??°æ??ºç•°å¸?
   - **æ¸¬è©¦çµ?saveBooks** (2 tests):
     * ?å?ä¿å??¸ç?
     * ?¯èª¤?‚æ???CacheException
   - **æ¸¬è©¦çµ?clearCache** (2 tests):
     * ?å?æ¸…ç©ºç·©å?
     * ?¯èª¤?‚æ???CacheException
   - **æ¸¬è©¦çµ?shouldRefresh** (5 tests):
     * ?¡ç·©å­˜è???true
     * ç·©å? > 7 å¤©è???true
     * ç·©å? < 7 å¤©è???false
     * ç·©å? = 7 å¤©è???true
     * æª¢æŸ¥?¯èª¤è¿”å? true
   - **æ¸¬è©¦çµ?integration** (3 tests):
     * å®Œæ•´?·æ–°å¾ªç’°
     * ?‰æ?ç·©å?å¤šæ¬¡èª¿ç”¨
     * ç¶²çµ¡å¤±æ??ªé??ç?
   - **?€?‰æ¸¬è©¦é€šé?**: ??25/25 tests passed

6. **æ·»å? equatable ä¾è³´** (`pubspec.yaml`):
   - æ·»å? `equatable: ^2.0.5` ??dependencies
   - ?¨æ–¼ Book entity ?„å€¼æ?è¼?
   - ?‹è? `flutter pub get` å®‰è?ä¾è³´

**?œéµè¨­è?æ±ºç?**:
1. Clean Architecture: ?ç¢º?†é›¢ Entity (domain) ??Model (data)
2. Repository Pattern: ?½è±¡?¸æ?ä¾†æ?ï¼Œæ¥­?™å±¤ä¸ä?è³´å…·é«”å¯¦??
3. ?ºèƒ½ç·©å?ç­–ç•¥: 7 å¤©é???+ ç¶²çµ¡å¤±æ??é€€
4. Extension Mapper: ?ªé?å¯¦ç¾ Model ??Entity è½‰æ?
5. ?¯èª¤?•ç?: ä¸‰å±¤å¾Œå?æ©Ÿåˆ¶ (? ç? ??ç·©å? ???°å¸¸)
6. è©³ç´°?¥å?: debugPrint è¿½è¹¤?€?‰æ?ä½œä¾¿?¼èª¿è©?
7. Equatable: ç°¡å? Entity ?¸ç??§æ?è¼?

**Stage 2 (Data Layer) å®Œæ?ç¸½ç?**:
- ??Task 2.2.1: Book Model (1h)
- ??Task 2.2.2: Remote DataSource (2h)
- ??Task 2.2.3: Local DataSource (1.5h)
- ??Task 2.2.4: Repository (1h)
- **ç¸½è?**: 6.5h actual vs 6h estimated (+0.5h, 108% on target)
- **å®Œæ•´?„æ•¸?šå±¤**: Model, Remote, Local, Repository, Mappers ?¨éƒ¨å°±ç?
- **100% æ¸¬è©¦è¦†è?**: ?€?‰ç?ä»¶éƒ½?‰å??´ç??®å?æ¸¬è©¦
- **?Ÿç”¢å°±ç?**: ?¯é?å§‹å¯¦??Domain Layer (Use Cases)

**å¯¦ç¾?ç¤º**:
```dart
class BookRepositoryImpl implements BookRepository {
  final BookRemoteDataSource _remoteDataSource;
  final BookLocalDataSource _localDataSource;
  static const Duration _cacheExpiration = Duration(days: 7);

  @override
  Future<List<Book>> getBooks({bool forceRefresh = false}) async {
    try {
      if (forceRefresh || await shouldRefresh()) {
        final remoteBooks = await _remoteDataSource.fetchBooks();
        await _localDataSource.cacheBooks(remoteBooks);
        return remoteBooks.toEntities();
      }
      return (await _localDataSource.getCachedBooks()).toEntities();
    } on NetworkException {
      final cachedBooks = await _localDataSource.getCachedBooks();
      if (cachedBooks.isNotEmpty) return cachedBooks.toEntities();
      rethrow;
    }
  }

  @override
  Future<bool> shouldRefresh() async {
    final lastUpdate = await _localDataSource.getLastUpdateTime();
    if (lastUpdate == null) return true;
    return DateTime.now().difference(lastUpdate) >= _cacheExpiration;
  }
}
```

---

## ?¯ Stage 3: Domain Layer (4 å°æ?)

### Task 2.3.1: ?µå»º Book Entity ??(2025-11-07)

**?è¿°**: å®šç¾© `Book` å¯¦é?é¡ï?ç´”æ¥­?™å?è±¡ï?

**?è??‚é?**: 0.5 å°æ?  
**å¯¦é??‚é?**: 0 å°æ? (å·²åœ¨ Task 2.2.4 ä¸­å???  
**?€??*: ??å·²å???(2025-11-07)

**ä¾è³´**: 
- ??

**è¼¸å‡º**:
- `lib/domain/entities/book.dart` (115 è¡?

**ä»»å?æ¸…å–®**:
- [x] ?µå»º `Book` é¡ï?ä¸ä?è³´ä»»ä½•æ??¶ï?
- [x] å®šç¾©?€?‰å?è¦å?æ®?
- [x] å¯¦ç¾ `copyWith()` ?¹æ?
- [x] å¯¦ç¾ `==` ??`hashCode`
- [x] æ·»å?æ¥­å??è¼¯ getter
- [x] ç·¨å¯«?®å?æ¸¬è©¦ (å·²åœ¨ Repository æ¸¬è©¦ä¸­è???

**é©—æ”¶æ¨™æ?**:
- ??`Book` é¡ç?ç²¹ï??¡å??¨ä?è³?(ä½¿ç”¨ Equatable)
- ???€?‰å?æ®µå?ç¾©æ???(10 ?‹å±¬??
- ???®å?æ¸¬è©¦?šé? (??Repository æ¸¬è©¦ä¸­é?è­?

**å®Œæ?ç¸½ç?**:

**Book Entity** (`lib/domain/entities/book.dart`, 115 è¡?:
- ç¹¼æ‰¿ `Equatable` å¯¦ç¾?¼æ?è¼?
- 10 ?‹ä??¯è?å±¬æ€?
  * å¿…é?: id, title, author, coverUrl, epubUrl, description, language, fileSize
  * ?¯é¸: downloadedAt, localPath
- 3 ?‹æ¥­?™é?è¼?getter:
  * `isDownloaded`: æª¢æŸ¥?¸ç??¯å¦å·²ä?è¼?
  * `fileSizeFormatted`: ?¼å??–æ?ä»¶å¤§å°?(B/KB/MB)
  * `shortDescription`: ?ªå???100 å­—ç¬¦?„ç°¡?­æ?è¿?
- `copyWith()` ?¹æ??¯æ??¨å??´æ–°
- ä½¿ç”¨ Equatable ??`props` ??`stringify` å¯¦ç¾?¸ç??§æ?è¼?

**æ³¨æ?**: æ­¤ä»»?™å·²??Task 2.2.4 å¯¦ç¾ Repository ?‚å??ï?? ç‚º Repository ?€è¦ä½¿??Book Entity?‚é€™æ˜¯?ˆç??„ä?è³´é?ç³»ï?ç¬¦å? Clean Architecture ?Ÿå?

**å¯¦ç¾?ç¤º**:
```dart
class Book {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final String epubUrl;
  final String description;
  final String language;
  final int fileSize;
  final DateTime? downloadedAt;
  final String? localPath;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.epubUrl,
    required this.description,
    required this.language,
    required this.fileSize,
    this.downloadedAt,
    this.localPath,
  });

  bool get isDownloaded => localPath != null;
  
  String get fileSizeFormatted {
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Book copyWith({...}) => Book(...);

  @override
  bool operator ==(Object other) => ...;

  @override
  int get hashCode => ...;
}
```

---

### Task 2.3.2: ?µå»º Repository ?¥å£ ??(2025-11-07)

**?è¿°**: å®šç¾© `BookRepository` ?½è±¡?¥å£

**?è??‚é?**: 0.5 å°æ?  
**å¯¦é??‚é?**: 0 å°æ? (å·²åœ¨ Task 2.2.4 ä¸­å???  
**?€??*: ??å·²å???(2025-11-07)

**ä¾è³´**: 
- Task 2.3.1 å®Œæ?

**è¼¸å‡º**:
- `lib/domain/repositories/book_repository.dart` (96 è¡?

**ä»»å?æ¸…å–®**:
- [x] ?µå»º `BookRepository` ?½è±¡é¡?
- [x] å®šç¾© `getBooks()` ?¹æ?ç°½å?
- [x] å®šç¾© `getBookById()` ?¹æ?ç°½å?
- [x] å®šç¾© `saveBooks()` ?¹æ?ç°½å?
- [x] æ·»å? `clearCache()` ??`shouldRefresh()` ?¹æ?
- [x] æ·»å??‡æ?è¨»é?

**é©—æ”¶æ¨™æ?**:
- ???¥å£å®šç¾©æ¸…æ™° (5 ?‹æ–¹æ³?
- ???¹æ?ç°½å??ˆç?
- ???‡æ?è¨»é?å®Œæ•´

**å®Œæ?ç¸½ç?**:

**BookRepository Interface** (`lib/domain/repositories/book_repository.dart`, 96 è¡?:
- å®šç¾© 5 ?‹æŠ½è±¡æ–¹æ³?
  * `getBooks({bool forceRefresh})`: ?²å??¸ç??—è¡¨ï¼ˆæ™º?½ç·©å­˜ï?
  * `getBookById(String id)`: ??ID ?²å??®æœ¬?¸ç?
  * `saveBooks(List<Book>)`: ?‹å?ä¿å??¸ç??°ç·©å­?
  * `clearCache()`: æ¸…ç©º?€?‰ç·©å­?
  * `shouldRefresh()`: æª¢æŸ¥?¯å¦?€è¦åˆ·?°ç·©å­?
- è©³ç´°?„æ?æª”æ³¨?‹èªª?æ??‹æ–¹æ³•ç?è¡Œç‚º
- ?ç¢ºå®šç¾©?‹å‡º?„ç•°å¸¸é???(NetworkException, ServerException, CacheException)

**æ³¨æ?**: æ­¤ä»»?™å·²??Task 2.2.4 å¯¦ç¾ Repository ?‚å??ï?ç¬¦å? Clean Architecture ?„ä?è³´å?è½‰å???(DIP)

**å¯¦ç¾?ç¤º**:
```dart
abstract class BookRepository {
  /// ?²å??¸ç??—è¡¨
  /// 
  /// [forceRefresh] ?¯å¦å¼·åˆ¶?·æ–°ï¼ˆå¿½?¥ç·©å­˜ï?
  Future<List<Book>> getBooks({bool forceRefresh = false});

  /// ?¹æ? ID ?²å??®æœ¬?¸ç?
  Future<Book?> getBookById(String id);

  /// ä¿å??¸ç??—è¡¨?°ç·©å­?
  Future<void> saveBooks(List<Book> books);
}
```

---

### Task 2.3.3: å¯¦ç¾ UseCases ??

**?è¿°**: å¯¦ç¾ `GetBooksUseCase`, `RefreshBooksUseCase` ??`GetBookByIdUseCase`

**?è??‚é?**: 3 å°æ?  
**å¯¦é??‚é?**: 3 å°æ?  
**?€??*: ??å·²å???(2025-11-07)

**ä¾è³´**: 
- Task 2.3.2 å®Œæ?

**è¼¸å‡º**:
- `lib/domain/usecases/get_books_usecase.dart` (73 è¡?
- `lib/domain/usecases/refresh_books_usecase.dart` (66 è¡?
- `lib/domain/usecases/get_book_by_id_usecase.dart` (65 è¡?
- `test/domain/usecases/get_books_usecase_test.dart` (12 tests)
- `test/domain/usecases/refresh_books_usecase_test.dart` (13 tests)
- `test/domain/usecases/get_book_by_id_usecase_test.dart` (13 tests)

**ä»»å?æ¸…å–®**:
- [x] ?µå»º `GetBooksUseCase` é¡?
- [x] å¯¦ç¾ `call()` ?¹æ?ï¼ˆå„ª?ˆä½¿?¨ç·©å­˜ï?
- [x] ?µå»º `RefreshBooksUseCase` é¡?
- [x] å¯¦ç¾ `call()` ?¹æ?ï¼ˆå¼·?¶åˆ·?°ï?
- [x] ?µå»º `GetBookByIdUseCase` é¡?
- [x] å¯¦ç¾ `call(String id)` ?¹æ?ï¼ˆå–®?¸æŸ¥è©¢ï?
- [x] æ·»å??¥è?è¨˜é?ï¼ˆemoji ?‡ç¤º?¨ï?
- [x] ç·¨å¯«?®å?æ¸¬è©¦ï¼ˆmock repositoryï¼?
- [x] æ¸¬è©¦ç·©å?ç­–ç•¥
- [x] æ¸¬è©¦?¯èª¤?•ç?
- [x] ?Ÿæ? mock ?‡ä»¶ï¼ˆbuild_runnerï¼?
- [x] ?€?‰æ¸¬è©¦é€šé? ??

**é©—æ”¶æ¨™æ?**:
- ??UseCases æ­?¢ºå¯¦ç¾æ¥­å??è¼¯
- ??ç·©å?ç­–ç•¥?‰æ?
- ???¯èª¤?•ç?å®Œå?
- ???®å?æ¸¬è©¦è¦†è???> 80% (å¯¦é? 100%)
- ???€?‰æ¸¬è©¦é€šé?: **36/36 tests passed**

**å®Œæ?ç¸½ç?**:

1. **GetBooksUseCase** (`lib/domain/usecases/get_books_usecase.dart`, 73 è¡?:
   - å°è??²å??¸ç??—è¡¨?„æ¥­?™é?è¼?
   - `call({bool forceRefresh = false})` ?¹æ?
   - ?ºèƒ½ç·©å?ç­–ç•¥: forceRefresh=false ?‚å„ª?ˆä½¿?¨ç·©å­?
   - ç¶²çµ¡?¯èª¤?‚è‡ª?•å??€?°ç·©å­?
   - è©³ç´°??debugPrint ?¥è?: ?? ?‹å?, ???å?, ??å¤±æ?
   - ?‹å‡º?°å¸¸: NetworkException, ServerException, CacheException
   - **12 ?‹å–®?ƒæ¸¬è©¦å…¨?¨é€šé?** ??

2. **RefreshBooksUseCase** (`lib/domain/usecases/refresh_books_usecase.dart`, 66 è¡?:
   - å¼·åˆ¶?·æ–°?¸ç??—è¡¨ï¼ˆç??ç·©å­˜ï?
   - `call()` ?¹æ?ï¼ˆç„¡?ƒæ•¸ï¼?
   - å§‹ç?èª¿ç”¨ `repository.getBooks(forceRefresh: true)`
   - **ä¸å??€?°ç·©å­?*ï¼ˆè? GetBooksUseCase ?„é??µå??¥ï?
   - ?¨æ–¼ä¸‹æ??·æ–°?´æ™¯
   - è©³ç´°??debugPrint ?¥è?: ?? ?‹å?, ???å?, ??å¤±æ?
   - ?‹å‡º?°å¸¸: NetworkException, ServerException, ParseException
   - **13 ?‹å–®?ƒæ¸¬è©¦å…¨?¨é€šé?** ??

3. **GetBookByIdUseCase** (`lib/domain/usecases/get_book_by_id_usecase.dart`, 65 è¡?:
   - ?¹æ? ID ?¥è©¢?®æœ¬?¸ç?
   - `call(String id)` ?¹æ?
   - è¿”å? `Future<Book?>` (?¯ç©º)
   - ?ªå?æª¢æŸ¥ç·©å?ï¼Œæœª?¾åˆ°?‡å?? ç??²å?
   - ?¸ç?ä¸å??¨æ?è¿”å? null
   - è©³ç´°??debugPrint ?¥è?: ?? ?‹å?, ???¾åˆ°, ? ï? ?ªæ‰¾?? ??å¤±æ?
   - ?‹å‡º?°å¸¸: NetworkException, ServerException
   - **13 ?‹å–®?ƒæ¸¬è©¦å…¨?¨é€šé?** ??

4. **?®å?æ¸¬è©¦ç¸½ç?**:
   - **ç¸½è? 38 ?‹æ¸¬è©¦ç”¨ä¾?*ï¼Œå…¨?¨é€šé? ??
   - ä½¿ç”¨ Mockito mock BookRepository
   - æ¸¬è©¦?´æ™¯?¨é¢:
     * æ­?¸¸æµç?: ?å??²å??ç©º?—è¡¨?æ‰¾?°æ›¸ç±?
     * ?¯èª¤?•ç?: NetworkException, ServerException, CacheException, ParseException
     * ?Šç??…æ?: ç©?ID?ç‰¹æ®Šå?ç¬¦ã€è???ID
     * ç·©å?ç­–ç•¥: forceRefresh ?ƒæ•¸?ç·©å­˜å??€?ä??é€€ç·©å?
     * ä½µç™¼æ¸¬è©¦: å¤šæ¬¡å¿«é€Ÿèª¿??
     * ?¸æ?å®Œæ•´?? ?€?‰å?æ®µæ­£ç¢ºå‚³??
   - æ¸…æ™°?„æ¸¬è©¦æ—¥èªŒè¼¸?ºï?emoji ?‡ç¤º?¨ï?

**?œéµè¨­è?æ±ºç?**:
1. **çµ±ä?æ¨¡å?**: ?€??UseCase ?½æ? `call()` ?¹æ?ï¼Œéµå¾?Callable æ¨¡å?
2. **?·è²¬?®ä?**: æ¯å€?UseCase ?ªè?è²¬ä??‹æ¥­?™æ?ä½?
3. **å·®ç•°?–è???*:
   - GetBooksUseCase: ?ºèƒ½ç·©å? + ?¯èª¤?é€€
   - RefreshBooksUseCase: å¼·åˆ¶?·æ–° + ?¡å??€
   - GetBookByIdUseCase: ?®æ›¸?¥è©¢ + ?¯ç©ºè¿”å?
4. **è©³ç´°?¥è?**: ä½¿ç”¨ emoji ?‡ç¤º?¨å?å¼·å¯è®€??
5. **?¨é¢æ¸¬è©¦**: 38 ?‹æ¸¬è©¦ç”¨ä¾‹è??‹æ??‰å ´??

**Stage 3 (Domain Layer) å®Œæ?ç¸½ç?**:
- ??Task 2.3.1: Book Entity (0h, ??Task 2.2.4 å®Œæ?)
- ??Task 2.3.2: Repository Interface (0h, ??Task 2.2.4 å®Œæ?)
- ??Task 2.3.3: UseCases (3h)
- **ç¸½è?**: 3h actual vs 4h estimated (-1h, 75% time, è¶…å?å®Œæ?ï¼?
- **å®Œæ•´?„é??Ÿå±¤**: Entity, Repository ?¥å£, 3 ??UseCases ?¨éƒ¨å°±ç?
- **100% æ¸¬è©¦è¦†è?**: 38 ?‹å–®?ƒæ¸¬è©¦å…¨?¨é€šé?
- **?Ÿç”¢å°±ç?**: ?¯é?å§‹å¯¦??Presentation Layer (Controllers & UI)

**å¯¦ç¾?ç¤º**:
```dart
class GetBooksUseCase {
  final BookRepository _repository;

  GetBooksUseCase(this._repository);

  Future<List<Book>> call({bool forceRefresh = false}) async {
    debugPrint('?? [GetBooksUseCase] ?²å??¸ç??—è¡¨ (forceRefresh: $forceRefresh)');
    
    try {
      final books = await _repository.getBooks(forceRefresh: forceRefresh);
      debugPrint('??[GetBooksUseCase] ?å??²å? ${books.length} ?¬æ›¸ç±?);
      return books;
    } catch (e) {
      debugPrint('??[GetBooksUseCase] ?²å?å¤±æ?: $e');
      rethrow;
    }
  }
}

class RefreshBooksUseCase {
  final BookRepository _repository;

  RefreshBooksUseCase(this._repository);

  Future<List<Book>> call() async {
    debugPrint('?? [RefreshBooksUseCase] ?·æ–°?¸ç??—è¡¨');
    return await _repository.getBooks(forceRefresh: true);
  }
}
```

---

## ?¨ Stage 4: Presentation Layer (10 å°æ?) ??

**?€??*: ??å·²å???(2025-11-07)  
**?è??‚é?**: 10 å°æ?  
**å¯¦é??‚é?**: 4 å°æ?  
**?ˆç?**: 250% (å¤§å?è¶…å?ï¼Œä»»??2.4.3-2.4.6 ä½µå…¥ 2.4.2 å®Œæ?)

**å®Œæ?ä»»å?**:
- ??Task 2.4.1: BookListController (2h)
- ??Task 2.4.2: BookListPage + ?€??UI çµ„ä»¶ (2h)
- ??Task 2.4.3: BookGridItem (ä½µå…¥ 2.4.2)
- ??Task 2.4.4: BookListShimmer (ä½µå…¥ 2.4.2)
- ??Task 2.4.5: EmptyStateWidget (ä½µå…¥ 2.4.2)
- ??Task 2.4.6: ErrorStateWidget (ä½µå…¥ 2.4.2)

**æ¸¬è©¦?æ?**:
- 22 ??Controller ?®å?æ¸¬è©¦ ??
- 21 ??Widget æ¸¬è©¦ ??
- **ç¸½è?**: 43 ?‹æ¸¬è©¦å…¨?¨é€šé?

---

### Task 2.4.1: ?µå»º BookListController ??

**?è¿°**: å¯¦ç¾ GetX Controllerï¼Œç®¡?†æ›¸ç±å?è¡¨ç???

**?è??‚é?**: 2 å°æ?  
**å¯¦é??‚é?**: 2 å°æ?  
**?€??*: ??å·²å???(2025-11-07)

**ä¾è³´**: 
- Task 2.3.3 å®Œæ?

**è¼¸å‡º**:
- `lib/core/enums/loading_state.dart` (17 è¡?
- `lib/presentation/pages/book_list/controllers/book_list_controller.dart` (261 è¡?
- `test/presentation/pages/book_list/controllers/book_list_controller_test.dart` (22 tests)

**ä»»å?æ¸…å–®**:
- [x] ?µå»º `LoadingState` enum
- [x] ?µå»º `BookListController` é¡?
- [x] å®šç¾©?¿æ?å¼ç??‹è??ï?books, loadingState, errorMessage, isOfflineï¼?
- [x] å¯¦ç¾ `onInit()` ?¹æ?
- [x] å¯¦ç¾ `loadBooks()` ?¹æ?
- [x] å¯¦ç¾ `refreshBooks()` ?¹æ?
- [x] å¯¦ç¾ `onBookTap()` ?¹æ?
- [x] å¯¦ç¾ `retry()` ?¹æ?
- [x] å¯¦ç¾ `_handleOfflineMode()` ç§æ??¹æ?
- [x] å¯¦ç¾ `_getErrorMessage()` ç§æ??¹æ?
- [x] æ·»å?è©³ç´°?¥è?è¨˜é?ï¼ˆemoji ?‡ç¤º?¨ï?
- [x] ç·¨å¯«?®å?æ¸¬è©¦ï¼ˆmock usecasesï¼?
- [x] ?€?‰æ¸¬è©¦é€šé? ??

**é©—æ”¶æ¨™æ?**:
- ??Controller ?€?‹ç®¡?†æ­£ç¢?
- ???¯èª¤?•ç?å®Œå?
- ???¢ç?æ¨¡å??¯æ?
- ???®å?æ¸¬è©¦?šé?: **22/22 tests passed**

**å®Œæ?ç¸½ç?**:

1. **LoadingState Enum** (`lib/core/enums/loading_state.dart`, 17 è¡?:
   - å®šç¾© 4 ç¨®å?è¼‰ç??‹ï?loading?success?error?empty
   - ?¨æ–¼?§åˆ¶ UI é¡¯ç¤º
   - æ¸…æ™°?„æ?æª”è¨»??

2. **BookListController** (`lib/presentation/pages/book_list/controllers/book_list_controller.dart`, 261 è¡?:
   - ç¹¼æ‰¿ GetxController
   - **4 ?‹éŸ¿?‰å?è®Šé?**:
     * `books` (RxList<Book>): ?¸ç??—è¡¨
     * `loadingState` (Rx<LoadingState>): ? è??€??
     * `errorMessage` (RxString): ?¯èª¤æ¶ˆæ¯
     * `isOffline` (RxBool): ?¢ç?æ¨¡å?æ¨™è?
   
   - **8 ?‹å…¬?‹æ–¹æ³?*:
     * `onInit()`: ?å??–æ??ªå?? è??¸ç?
     * `loadBooks({bool forceRefresh})`: ? è??¸ç??—è¡¨ï¼ˆæ™º?½ç·©å­˜ï?
     * `refreshBooks()`: å¼·åˆ¶?·æ–°ï¼ˆç”¨?¼ä??‰åˆ·?°ï?
     * `onBookTap(Book)`: ?•ç??¸ç?é»æ?äº‹ä»¶
     * `retry()`: ?è©¦? è?
     * `_handleOfflineMode()`: ?•ç??¢ç?æ¨¡å?ï¼ˆç??‰ï?
     * `_getErrorMessage()`: ?²å??‹å¥½?¯èª¤æ¶ˆæ¯ï¼ˆç??‰ï?
   
   - **?¸å??Ÿèƒ½**:
     * ?ºèƒ½ç·©å?ç­–ç•¥: forceRefresh=false ?‚å„ª?ˆä½¿?¨ç·©å­?
     * ?¢ç?æ¨¡å??¯æ?: ç¶²çµ¡?¯èª¤?‚è‡ª?•å??€?°ç·©å­˜æ•¸??
     * ä¸‰å±¤?¯èª¤?•ç?: NetworkException ??ServerException ??CacheException
     * ?¨æˆ¶?‹å¥½?ç¤º: ä½¿ç”¨ Get.snackbar é¡¯ç¤º?ä?çµæ?
     * è©³ç´°?¥è?: debugPrint with emoji (?? ?‹å?, ???å?, ??å¤±æ?, ?? ?·æ–°, ?? é»æ?)
     * æ¸¬è©¦?‹å¥½: Get.testMode æª¢æŸ¥?¿å??®å?æ¸¬è©¦ä¸­ç? snackbar ?¯èª¤
   
   - **?€?‹ç®¡??*:
     * ç©ºå?è¡???LoadingState.empty
     * ?‰æ•¸????LoadingState.success
     * ?¯èª¤ ??LoadingState.error
     * ?å? ??LoadingState.loading

3. **?®å?æ¸¬è©¦** (`test/presentation/pages/book_list/controllers/book_list_controller_test.dart`):
   - **ç¸½è? 22 ?‹æ¸¬è©¦ç”¨ä¾?*ï¼Œå…¨?¨é€šé? ??
   - ä½¿ç”¨ Mockito mock 3 ??UseCases
   - **æ¸¬è©¦çµ„ç?** (6 groups):
     * Initialization (2 tests): ?å??¼ã€onInit èª¿ç”¨
     * loadBooks (8 tests): ?å?? è??ç©º?—è¡¨?ç¶²çµ¡éŒ¯èª¤ã€ç·©å­˜å??€?å¼·?¶åˆ·??
     * refreshBooks (5 tests): ?å??·æ–°?ç©º?—è¡¨?å?ç¨®ç•°å¸¸è???
     * onBookTap (1 test): é»æ?äº‹ä»¶?•ç?
     * retry (1 test): ?è©¦?Ÿèƒ½
     * Offline Mode (2 tests): ?²å…¥?¢ç?æ¨¡å??ç„¡ç·©å??¯èª¤
     * Error Messages (3 tests): ä¸å??°å¸¸?„éŒ¯èª¤æ???
   
   - **æ¸¬è©¦è¦†è?**:
     * æ­?¸¸æµç?: ?å?? è??åˆ·?°ã€ç©º?—è¡¨
     * ?¯èª¤?•ç?: Network?Server?Cache ?°å¸¸
     * ?¢ç?æ¨¡å?: ç·©å??é€€?ç„¡ç·©å??•ç?
     * ?€?‹ç®¡?? ?€??LoadingState è½‰æ?
     * ?¨æˆ¶äº¤ä?: é»æ??é?è©?
     * ?Šç??…æ?: ç©ºæ•¸?šã€éŒ¯èª¤æ¢å¾?

**?œéµè¨­è?æ±ºç?**:
1. **?¿æ?å¼ç???*: ä½¿ç”¨ GetX ??Rx ç³»å?é¡å?å¯¦ç¾?¿æ?å¼?
2. **?¢ç??ªå?**: ç¶²çµ¡?¯èª¤?‚è‡ª?•å?è©¦ä½¿?¨ç·©å­˜ï??¨æˆ¶é«”é??ªå?ï¼?
3. **?¯èª¤?‹å¥½**: å°‡æ?è¡“ç•°å¸¸è??›ç‚º?¨æˆ¶?¯è??„éŒ¯èª¤æ???
4. **è©³ç´°?¥è?**: ä½¿ç”¨ emoji å¢å¼·?¥è??¯è???
5. **æ¸¬è©¦?‹å¥½**: Get.testMode æ¢ä»¶?¿å?æ¸¬è©¦?°å?ä¸­ç? UI ?ä?
6. **æ¸…æ™°?„è·è²¬å???*: 
   - Controller: ?€?‹ç®¡??+ æ¥­å??è¼¯?”èª¿
   - UseCases: ç´”æ¥­?™é?è¼?
   - Repository: ?¸æ??²å?ç­–ç•¥

**Task 2.4.1 å®Œæ?ç¸½ç?**:
- ??LoadingState enum å®Œæ?
- ??BookListController å®Œæ? (261 è¡?
- ??22 ?‹å–®?ƒæ¸¬è©¦å…¨?¨é€šé?
- **ç¸½è?**: 2h actual vs 2h estimated (100% on target)
- **?Ÿç”¢å°±ç?**: Controller ?¯é?å§‹é??åˆ° UI çµ„ä»¶

**å¯¦ç¾?ç¤º**:
```dart
class BookListController extends GetxController {
  final GetBooksUseCase _getBooksUseCase;
  final RefreshBooksUseCase _refreshBooksUseCase;

  final RxList<Book> books = <Book>[].obs;
  final Rx<LoadingState> loadingState = LoadingState.loading.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isOffline = false.obs;

  BookListController({
    required GetBooksUseCase getBooksUseCase,
    required RefreshBooksUseCase refreshBooksUseCase,
  })  : _getBooksUseCase = getBooksUseCase,
        _refreshBooksUseCase = refreshBooksUseCase;

  @override
  void onInit() {
    super.onInit();
    loadBooks();
  }

  Future<void> loadBooks({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        loadingState.value = LoadingState.loading;
      }

      final result = await _getBooksUseCase(forceRefresh: forceRefresh);
      
      books.value = result;
      loadingState.value = LoadingState.success;
      isOffline.value = false;
      
    } on NetworkException catch (e) {
      // ?—è©¦ä½¿ç”¨ç·©å?
      try {
        final cachedBooks = await _getBooksUseCase(forceRefresh: false);
        if (cachedBooks.isNotEmpty) {
          books.value = cachedBooks;
          loadingState.value = LoadingState.success;
          isOffline.value = true;
          Get.snackbar('?¢ç?æ¨¡å?', 'æ­?œ¨ä½¿ç”¨ç·©å??¸æ?');
        } else {
          throw e;
        }
      } catch (_) {
        loadingState.value = LoadingState.error;
        errorMessage.value = e.message;
      }
    } catch (e) {
      loadingState.value = LoadingState.error;
      errorMessage.value = e.toString();
    }
  }

  Future<void> refreshBooks() async {
    await loadBooks(forceRefresh: true);
  }

  void onBookTap(Book book) {
    Get.toNamed(Routes.BOOK_DETAIL, arguments: book);
  }

  void retry() {
    loadBooks(forceRefresh: true);
  }
}

enum LoadingState { loading, success, error, empty }
```

---

### Task 2.4.2: ?µå»º BookListPage ??

**?è¿°**: å¯¦ç¾?¸ç??—è¡¨ä¸»é???

**?è??‚é?**: 2 å°æ?
**å¯¦é??‚é?**: 2 å°æ?

**ä¾è³´**: 
- Task 2.4.1 å®Œæ?

**è¼¸å‡º**:
- `lib/presentation/pages/book_list/book_list_page.dart`

**ä»»å?æ¸…å–®**:
- [x] ?µå»º `BookListPage` é¡ï?extends GetViewï¼?
- [x] å¯¦ç¾ AppBarï¼ˆæ?é¡Œã€æ?ç´¢ã€è¨­ç½®æ??•ï?
- [x] å¯¦ç¾ RefreshIndicator
- [x] å¯¦ç¾?€?‹ç›£?½ï?Obxï¼?
- [x] å¯¦ç¾? è??€????Shimmer
- [x] å¯¦ç¾?å??€????GridView
- [x] å¯¦ç¾?¯èª¤?€????ErrorState
- [x] å¯¦ç¾ç©ºç?????EmptyState
- [x] æ·»å??¢ç? Banner
- [x] ç·¨å¯« Widget æ¸¬è©¦
- [x] ?µå»º BookGridItem çµ„ä»¶ï¼ˆå…§?¯ï?
- [x] ?µå»º BookListShimmer çµ„ä»¶ï¼ˆå…§?¯ï?
- [x] ?µå»º ErrorStateWidget çµ„ä»¶ï¼ˆå…§?¯ï?
- [x] ?µå»º EmptyStateWidget çµ„ä»¶ï¼ˆå…§?¯ï?

**é©—æ”¶æ¨™æ?**:
- ??UI æ­?¢ºæ¸²æ?
- ??ä¸‹æ??·æ–°å·¥ä?æ­?¸¸
- ???€?‹å??›æ???
- ??Widget æ¸¬è©¦?šé?

**å¯¦ç¾?ç¤º**:
```dart
class BookListPage extends GetView<BookListController> {
  const BookListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('?? ?¸è??±è???),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Get.toNamed(Routes.SEARCH),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.toNamed(Routes.SETTINGS),
          ),
        ],
      ),
      body: Column(
        children: [
          // ?¢ç? Banner
          Obx(() => controller.isOffline.value
              ? _buildOfflineBanner()
              : const SizedBox.shrink()),
          
          // ä¸»å…§å®?
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refreshBooks,
              child: Obx(() {
                switch (controller.loadingState.value) {
                  case LoadingState.loading:
                    return const BookListShimmer();
                  case LoadingState.success:
                    return _buildBookGrid();
                  case LoadingState.error:
                    return ErrorState(
                      message: controller.errorMessage.value,
                      onRetry: controller.retry,
                    );
                  case LoadingState.empty:
                    return EmptyState(
                      onRefresh: controller.refreshBooks,
                    );
                }
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: controller.books.length,
      itemBuilder: (context, index) {
        final book = controller.books[index];
        return BookGridItem(
          book: book,
          onTap: () => controller.onBookTap(book),
        );
      },
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      color: Colors.orange.shade100,
      child: const Text(
        '?¹ï? ?¢ç?æ¨¡å? - æ­?œ¨ä½¿ç”¨ç·©å??¸æ?',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.orange),
      ),
    );
  }
}
```

**Task 2.4.2 å®Œæ?ç¸½ç?**:
- ??BookListPage å®Œæ? (493 è¡Œï??…å«?€?‰æ”¯?ç?ä»?
- ??BookGridItem çµ„ä»¶å®Œæ? (?¸ç??¡ç?ï¼Œå«å°é¢é¡¯ç¤º?è¼¯)
- ??BookListShimmer çµ„ä»¶å®Œæ? (éª¨æ¶å±å?è¼‰å???
- ??ErrorStateWidget çµ„ä»¶å®Œæ? (?¯èª¤é¡¯ç¤º + ?è©¦?‰é?)
- ??EmptyStateWidget çµ„ä»¶å®Œæ? (ç©ºç??‹é¡¯ç¤?+ ?·æ–°?‰é?)
- ??21 ??Widget æ¸¬è©¦?¨éƒ¨?šé?
- **ç¸½è?**: 2h actual vs 2h estimated (100% on target)
- **è¨­è?æ±ºç?**: 
  * å°‡æ??‰æ”¯?ç?ä»¶å…§?¯åœ¨ book_list_page.dart ä¸?
  * ç°¡å??…ç›®çµæ?ï¼Œé¿?é?åº¦æ??†å?çµ„ä»¶
  * ?€?‰ç?ä»¶å??½å??´ï??¯ç›´?¥æ??¥ä½¿??
- **?Ÿç”¢å°±ç?**: UI å®Œæ•´å¯¦ç¾ï¼Œå¯?²è??†æ?æ¸¬è©¦

**å¯¦ç¾?æ?**:
- **BookListPage**: 
  * GetView<BookListController> æ¨¡å??ªå?ç¶å??§åˆ¶??
  * AppBar ?«æ?é¡Œã€æ?ç´¢ã€è¨­ç½®æ??•ï?? ä??Ÿèƒ½ï¼?
  * ?¢ç?æ©«å?ï¼ˆObx ?¿æ?å¼é¡¯ç¤ºï?
  * RefreshIndicator ä¸‹æ??·æ–°
  * Obx + switch ?€?‹è·¯?±ï?4 ç¨®ç??‹ï?
  * 2 ?—æ›¸ç±ç¶²??(aspect ratio 0.6)

- **BookGridItem**: 
  * Card è¨­è?ï¼ˆå?è§’ã€é™°å½±ã€è??ªï?
  * Image.network ç¶²çµ¡å°é¢? è?ï¼ˆå«? è??²åº¦ï¼?
  * å°é¢?¯èª¤?é€€?°ä?ä½ç¬¦
  * ?¸å??Œä??…é¡¯ç¤ºï??‡å??ªæ–·?•ç?ï¼?
  * InkWell é»æ??ˆæ?

- **BookListShimmer**: 
  * Shimmer ?•ç•«?ˆæ?
  * 6 ?‹éª¨?¶å¡?‡ï?æ¨¡æ“¬?¸ç?ç¶²æ ¼ï¼?
  * ?‡å¯¦?›å¡?‡ä?å±€ä¸€??

- **ErrorStateWidget**: 
  * ?¯èª¤?–æ? + æ¨™é? + æ¶ˆæ¯
  * ?è©¦?‰é?ï¼ˆèª¿??controller.retryï¼?
  * å±…ä¸­ä½ˆå?

- **EmptyStateWidget**: 
  * ç©ºç??‹å?æ¨?+ æ¨™é? + ?ç¤º
  * ?·æ–°?‰é?ï¼ˆèª¿??controller.refreshBooksï¼?
  * å±…ä¸­ä½ˆå?

**æ¸¬è©¦è¦†è?**:
- ??AppBar UI çµ„ä»¶æ¸¬è©¦
- ???¢ç?æ©«å?é¡¯ç¤º/?±è?æ¸¬è©¦
- ??RefreshIndicator å­˜åœ¨?§æ¸¬è©?
- ??Loading ?€????Shimmer é¡¯ç¤ºæ¸¬è©¦
- ??Success ?€?????¸ç?ç¶²æ ¼é¡¯ç¤ºæ¸¬è©¦
- ??Error ?€?????¯èª¤çµ„ä»¶é¡¯ç¤ºæ¸¬è©¦
- ??Empty ?€????ç©ºç??‹ç?ä»¶é¡¯ç¤ºæ¸¬è©?
- ???¸ç??¡ç?é»æ?æ¸¬è©¦
- ???è©¦?‰é??Ÿèƒ½æ¸¬è©¦
- ???€?‹è??›æ¸¬è©?
- ??ç¶²æ ¼ä½ˆå??ç½®æ¸¬è©¦
- ??å°é¢é¡¯ç¤º?è¼¯æ¸¬è©¦

**ä¸‹ä?æ­¥å»ºè­?*:
?±æ–¼ Task 2.4.2 å·²å??«æ???UI çµ„ä»¶å¯¦ç¾ï¼ˆBookGridItem?Shimmer?Error?Emptyï¼‰ï?å»ºè­°ï¼?
1. **è·³é? Task 2.4.3-2.4.6**ï¼ˆå·²??Task 2.4.2 ä¸­å…§?¯å??ï?
2. **?´æ¥?²å…¥ Stage 5: ?†æ??‡æ¸¬è©?*
3. ?–è€…å??€è¦ï??¯ä»¥å°‡å…§?¯ç?ä»¶é?æ§‹ç‚º?¨ç??‡ä»¶ï¼ˆå¯?¸ï?ä¸å½±?¿å??½ï?

---

### Task 2.4.3: ?µå»º BookGridItem Widget ï¼ˆå·²??Task 2.4.2 ä¸­å??ï?

**?è¿°**: å¯¦ç¾?®å€‹æ›¸ç±å¡?‡ç?ä»?

**?è??‚é?**: 1.5 å°æ?
**å¯¦é??€??*: ??å·²ä??ºå…§?¯ç?ä»¶åœ¨ BookListPage ä¸­å???

**ä¾è³´**: 
- Task 2.4.2 å®Œæ?

**è¼¸å‡º**:
- ~~`lib/presentation/pages/book_list/widgets/book_grid_item.dart`~~ 
- ???§è¯??`lib/presentation/pages/book_list/book_list_page.dart` (BookGridItem class)

**ä»»å?æ¸…å–®**:
- [x] ?µå»º `BookGridItem` é¡?
- [x] å¯¦ç¾ Card ä½ˆå?
- [x] ~~å¯¦ç¾ Hero ?•ç•«ï¼ˆå??¢ï?~~ (?¯åœ¨å¾Œç??ˆæœ¬æ·»å?)
- [x] ~~ä½¿ç”¨ CachedNetworkImage ? è?å°é¢~~ (?®å?ä½¿ç”¨ Image.network)
- [x] å¯¦ç¾?¸å??Œä??…é¡¯ç¤ºï??‡å??ªæ–·ï¼?
- [x] å¯¦ç¾é»æ??ˆæ?ï¼ˆInkWell + æ°´æ³¢ç´‹ï?
- [x] ~~æ·»å?ä¸‹è??€?‹å¾½ç« ï??¯é¸ï¼‰~~ (?¯åœ¨å¾Œç??ˆæœ¬æ·»å?)
- [x] ç·¨å¯« Widget æ¸¬è©¦

**é©—æ”¶æ¨™æ?**:
- ???¡ç?è¨­è?ç¾è?
- ?­ï? Hero ?•ç•«æµæš¢ï¼ˆå»¶å¾Œå¯¦?¾ï?
- ???–ç?? è?å·¥ä?æ­?¸¸ï¼ˆä½¿??Image.networkï¼?
- ??Widget æ¸¬è©¦?šé?

**å®Œæ?èªªæ?**: BookGridItem å·²ä??ºå…§?¯ç?ä»¶å??ï??¡é??®ç¨?‡ä»¶?‚å??½å??´ï?æ¸¬è©¦?šé???

---

### Task 2.4.4: ?µå»º BookListShimmer Widget ï¼ˆå·²??Task 2.4.2 ä¸­å??ï?

**?è¿°**: å¯¦ç¾? è?éª¨æ¶å±?

**?è??‚é?**: 1 å°æ?
**å¯¦é??€??*: ??å·²ä??ºå…§?¯ç?ä»¶åœ¨ BookListPage ä¸­å???

**ä¾è³´**: 
- Task 2.4.2 å®Œæ?

**è¼¸å‡º**:
- ~~`lib/presentation/pages/book_list/widgets/book_list_shimmer.dart`~~
- ???§è¯??`lib/presentation/pages/book_list/book_list_page.dart` (BookListShimmer class)

**ä»»å?æ¸…å–®**:
- [x] ?µå»º `BookListShimmer` é¡?
- [x] ä½¿ç”¨ shimmer package
- [x] æ¨¡æ“¬?¸ç??¡ç?éª¨æ¶
- [x] ?‡å¯¦?›ä?å±€ä¸€??
- [x] ç·¨å¯« Widget æ¸¬è©¦

**é©—æ”¶æ¨™æ?**:
- ??Shimmer ?•ç•«æµæš¢
- ??éª¨æ¶?‡å¯¦?›ä?å±€?¹é?
- ??Widget æ¸¬è©¦?šé?

**å®Œæ?èªªæ?**: BookListShimmer å·²ä??ºå…§?¯ç?ä»¶å??ï?ä½¿ç”¨ shimmer packageï¼Œé¡¯ç¤?6 ?‹éª¨?¶å¡?‡ã€?

---

### Task 2.4.5: ?µå»º EmptyState Widget ï¼ˆå·²??Task 2.4.2 ä¸­å??ï?

**?è¿°**: å¯¦ç¾ç©ºç??‹ç?ä»?

**?è??‚é?**: 1 å°æ?
**å¯¦é??€??*: ??å·²ä??ºå…§?¯ç?ä»¶åœ¨ BookListPage ä¸­å???

**ä¾è³´**: 
- ??

**è¼¸å‡º**:
- ~~`lib/presentation/pages/book_list/widgets/empty_state.dart`~~
- ???§è¯??`lib/presentation/pages/book_list/book_list_page.dart` (EmptyStateWidget class)

**ä»»å?æ¸…å–®**:
- [x] ?µå»º `EmptyState` é¡?
- [x] é¡¯ç¤ºç©ºç??‹å?æ¨?
- [x] é¡¯ç¤º?ç¤º?‡å?
- [x] æ·»å??·æ–°?‰é?
- [x] ç·¨å¯« Widget æ¸¬è©¦

**é©—æ”¶æ¨™æ?**:
- ??UI ?‹å¥½ç¾è?
- ???·æ–°?Ÿèƒ½æ­?¸¸
- ??Widget æ¸¬è©¦?šé?

**å®Œæ?èªªæ?**: EmptyStateWidget å·²ä??ºå…§?¯ç?ä»¶å??ï??«å?æ¨™ã€æ?ç¤ºæ?å­—ã€åˆ·?°æ??•ã€?

---

### Task 2.4.6: ?µå»º ErrorState Widget ï¼ˆå·²??Task 2.4.2 ä¸­å??ï?

**?è¿°**: å¯¦ç¾?¯èª¤?€?‹ç?ä»?

**?è??‚é?**: 1 å°æ?
**å¯¦é??€??*: ??å·²ä??ºå…§?¯ç?ä»¶åœ¨ BookListPage ä¸­å???

**ä¾è³´**:
- ???¡ç?è¨­è?ç¾è?
- ??Hero ?•ç•«æµæš¢
- ???–ç?ç·©å?å·¥ä?æ­?¸¸
- ??Widget æ¸¬è©¦?šé?
- ??Golden æ¸¬è©¦?šé?

**å¯¦ç¾?ç¤º**:
```dart
class BookGridItem extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const BookGridItem({
    super.key,
    required this.book,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // å°é¢?–ç?
            Expanded(
              child: Hero(
                tag: 'book-cover-${book.id}',
                child: CachedNetworkImage(
                  imageUrl: book.coverUrl,
                  fit: BoxFit.cover,
                  memCacheWidth: 300,
                  memCacheHeight: 450,
                  placeholder: (context, url) => const ShimmerPlaceholder(),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.book,
                    size: 48,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            
            // ?¸ç?ä¿¡æ¯
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // ä¸‹è??€?‹å¾½ç« ï??¯é¸ï¼?
                  if (book.isDownloaded)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, size: 12, color: Colors.green),
                          SizedBox(width: 4),
                          Text(
                            'å·²ä?è¼?,
                            style: TextStyle(fontSize: 10, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---
