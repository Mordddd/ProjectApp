import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';

abstract class ZodiacRepository {
  String get storageLabel;

  Stream<List<ZodiacRecord>> watchZodiacRecords();

  Future<int> createZodiacRecord(ZodiacRecordsCompanion record);

  Future<int> updateZodiacRecord({
    required int id,
    required ZodiacRecordsCompanion record,
  });

  Future<int> deleteZodiacRecord(int id);
}

class LocalZodiacRepository implements ZodiacRepository {
  final AppDatabase database;

  LocalZodiacRepository(this.database);

  @override
  String get storageLabel => 'SQLite';

  @override
  Stream<List<ZodiacRecord>> watchZodiacRecords() =>
      database.watchZodiacRecords();

  @override
  Future<int> createZodiacRecord(ZodiacRecordsCompanion record) =>
      database.createZodiacRecord(record);

  @override
  Future<int> updateZodiacRecord({
    required int id,
    required ZodiacRecordsCompanion record,
  }) => database.updateZodiacRecord(id: id, record: record);

  @override
  Future<int> deleteZodiacRecord(int id) => database.deleteZodiacRecord(id);
}

class SupabaseZodiacRepository implements ZodiacRepository {
  final SupabaseClient client;

  SupabaseZodiacRepository(this.client);

  @override
  String get storageLabel => 'Supabase';

  String get _userId {
    final id = client.auth.currentUser?.id;
    if (id == null) throw StateError('A user must be signed in.');
    return id;
  }

  @override
  Stream<List<ZodiacRecord>> watchZodiacRecords() {
    return client
        .from('zodiac_records')
        .stream(primaryKey: ['id'])
        .eq('owner_id', _userId)
        .order('created_at', ascending: false)
        .map((rows) => rows.map(_fromRow).toList(growable: false));
  }

  @override
  Future<int> createZodiacRecord(ZodiacRecordsCompanion record) async {
    final row = await client
        .from('zodiac_records')
        .insert({'owner_id': _userId, ..._toRow(record)})
        .select('id')
        .single();
    return (row['id'] as num).toInt();
  }

  @override
  Future<int> updateZodiacRecord({
    required int id,
    required ZodiacRecordsCompanion record,
  }) async {
    final rows = await client
        .from('zodiac_records')
        .update(_toRow(record))
        .eq('id', id)
        .eq('owner_id', _userId)
        .select('id');
    return rows.length;
  }

  @override
  Future<int> deleteZodiacRecord(int id) async {
    final rows = await client
        .from('zodiac_records')
        .delete()
        .eq('id', id)
        .eq('owner_id', _userId)
        .select('id');
    return rows.length;
  }

  Map<String, Object> _toRow(ZodiacRecordsCompanion record) {
    return {
      'day': _required(record.day, 'day'),
      'month': _required(record.month, 'month'),
      'zodiac_name': _required(record.zodiacName, 'zodiac_name'),
      'date_range': _required(record.dateRange, 'date_range'),
      'character': _required(record.character, 'character'),
      'strengths': _required(record.strengths, 'strengths'),
      'weaknesses': _required(record.weaknesses, 'weaknesses'),
      'compatible': _required(record.compatible, 'compatible'),
      'less_compatible': _required(record.lessCompatible, 'less_compatible'),
      'element': _required(record.element, 'element'),
      'symbol': _required(record.symbol, 'symbol'),
      'accent_value': _required(record.accentValue, 'accent_value'),
    };
  }

  T _required<T>(Value<T> value, String field) {
    if (!value.present) throw ArgumentError('$field is required.');
    return value.value;
  }

  ZodiacRecord _fromRow(Map<String, dynamic> row) {
    return ZodiacRecord(
      id: (row['id'] as num).toInt(),
      day: (row['day'] as num).toInt(),
      month: (row['month'] as num).toInt(),
      zodiacName: row['zodiac_name'] as String,
      dateRange: row['date_range'] as String,
      character: row['character'] as String,
      strengths: row['strengths'] as String,
      weaknesses: row['weaknesses'] as String,
      compatible: row['compatible'] as String,
      lessCompatible: row['less_compatible'] as String,
      element: row['element'] as String,
      symbol: row['symbol'] as String,
      accentValue: (row['accent_value'] as num).toInt(),
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}
