import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Library manga row (persisted), distinct from a source's transient `SManga`.
@DataClassName('MangaData')
class Mangas extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get source => integer()();
  TextColumn get url => text()();
  TextColumn get title => text()();
  TextColumn get artist => text().nullable()();
  TextColumn get author => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get genre => text().nullable()();
  IntColumn get status => integer().withDefault(const Constant(0))();
  TextColumn get thumbnailUrl => text().nullable()();
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get dateAdded => dateTime().nullable()();
  DateTimeColumn get lastUpdate => dateTime().nullable()();
  IntColumn get viewerFlags => integer().withDefault(const Constant(0))();
  IntColumn get chapterFlags => integer().withDefault(const Constant(0))();
}

/// Chapter row belonging to a [Mangas] entry; cascade-deleted with its manga.
@DataClassName('ChapterData')
class Chapters extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get mangaId =>
      integer().references(Mangas, #id, onDelete: KeyAction.cascade)();
  TextColumn get url => text()();
  TextColumn get name => text()();
  TextColumn get scanlator => text().nullable()();
  BoolColumn get read => boolean().withDefault(const Constant(false))();
  BoolColumn get bookmark => boolean().withDefault(const Constant(false))();
  IntColumn get lastPageRead => integer().withDefault(const Constant(0))();
  RealColumn get chapterNumber => real().withDefault(const Constant(-1))();
  DateTimeColumn get dateUpload => dateTime().nullable()();
  DateTimeColumn get dateFetch => dateTime().nullable()();
  IntColumn get sourceOrder => integer().withDefault(const Constant(0))();
}

/// User-defined library category (Mihon's library tabs/filters).
@DataClassName('CategoryData')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get position => integer().withDefault(const Constant(0))();
  IntColumn get flags => integer().withDefault(const Constant(0))();
}

/// Many-to-many join between [Mangas] and [Categories].
@DataClassName('MangaCategoryData')
class MangasCategories extends Table {
  IntColumn get mangaId =>
      integer().references(Mangas, #id, onDelete: KeyAction.cascade)();
  IntColumn get categoryId =>
      integer().references(Categories, #id, onDelete: KeyAction.cascade)();

  /// Composite key prevents duplicate manga/category assignments.
  @override
  Set<Column<Object>> get primaryKey => {mangaId, categoryId};
}

/// Per-chapter reading history (last read time, accumulated read duration).
@DataClassName('HistoryData')
class HistoryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get chapterId =>
      integer().references(Chapters, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get lastRead => dateTime().nullable()();
  IntColumn get timeRead => integer().withDefault(const Constant(0))();
}

@DriftDatabase(
  tables: [Mangas, Chapters, Categories, MangasCategories, HistoryEntries],
)
/// The app's Drift database; owns all tables and connection lifecycle.
class AppDatabase extends _$AppDatabase {
  /// Opens the on-disk `hondana` database via drift_flutter.
  AppDatabase() : super(driftDatabase(name: 'hondana'));

  /// Backs the database with a caller-supplied executor (e.g. in-memory tests).
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}
