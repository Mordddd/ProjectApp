import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class ZodiacRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get day => integer()();
  IntColumn get month => integer()();
  TextColumn get zodiacName => text()();
  TextColumn get dateRange => text()();
  TextColumn get character => text()();
  TextColumn get strengths => text()();
  TextColumn get weaknesses => text()();
  TextColumn get compatible => text()();
  TextColumn get lessCompatible => text()();
  TextColumn get element => text()();
  TextColumn get symbol => text()();
  IntColumn get accentValue => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [ZodiacRecords])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(
        executor ??
            driftDatabase(
              name: 'learning_hub',
              web: DriftWebOptions(
                sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                driftWorker: Uri.parse('drift_worker.js'),
              ),
            ),
      );

  @override
  int get schemaVersion => 1;

  Stream<List<ZodiacRecord>> watchZodiacRecords() {
    return (select(zodiacRecords)..orderBy([
          (table) => OrderingTerm.desc(table.createdAt),
          (table) => OrderingTerm.desc(table.id),
        ]))
        .watch();
  }

  Future<int> createZodiacRecord(ZodiacRecordsCompanion record) {
    return into(zodiacRecords).insert(record);
  }

  Future<int> updateZodiacRecord({
    required int id,
    required ZodiacRecordsCompanion record,
  }) {
    return (update(zodiacRecords)..where((table) => table.id.equals(id))).write(
      record.copyWith(createdAt: Value(DateTime.now())),
    );
  }

  Future<int> deleteZodiacRecord(int id) {
    return (delete(zodiacRecords)..where((table) => table.id.equals(id))).go();
  }

  Future<int> clearZodiacRecords() {
    return delete(zodiacRecords).go();
  }
}
