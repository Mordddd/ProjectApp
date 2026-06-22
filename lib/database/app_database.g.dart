// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ZodiacRecordsTable extends ZodiacRecords
    with TableInfo<$ZodiacRecordsTable, ZodiacRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ZodiacRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<int> day = GeneratedColumn<int>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<int> month = GeneratedColumn<int>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _zodiacNameMeta = const VerificationMeta(
    'zodiacName',
  );
  @override
  late final GeneratedColumn<String> zodiacName = GeneratedColumn<String>(
    'zodiac_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateRangeMeta = const VerificationMeta(
    'dateRange',
  );
  @override
  late final GeneratedColumn<String> dateRange = GeneratedColumn<String>(
    'date_range',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _characterMeta = const VerificationMeta(
    'character',
  );
  @override
  late final GeneratedColumn<String> character = GeneratedColumn<String>(
    'character',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _strengthsMeta = const VerificationMeta(
    'strengths',
  );
  @override
  late final GeneratedColumn<String> strengths = GeneratedColumn<String>(
    'strengths',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weaknessesMeta = const VerificationMeta(
    'weaknesses',
  );
  @override
  late final GeneratedColumn<String> weaknesses = GeneratedColumn<String>(
    'weaknesses',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _compatibleMeta = const VerificationMeta(
    'compatible',
  );
  @override
  late final GeneratedColumn<String> compatible = GeneratedColumn<String>(
    'compatible',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lessCompatibleMeta = const VerificationMeta(
    'lessCompatible',
  );
  @override
  late final GeneratedColumn<String> lessCompatible = GeneratedColumn<String>(
    'less_compatible',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _elementMeta = const VerificationMeta(
    'element',
  );
  @override
  late final GeneratedColumn<String> element = GeneratedColumn<String>(
    'element',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accentValueMeta = const VerificationMeta(
    'accentValue',
  );
  @override
  late final GeneratedColumn<int> accentValue = GeneratedColumn<int>(
    'accent_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    day,
    month,
    zodiacName,
    dateRange,
    character,
    strengths,
    weaknesses,
    compatible,
    lessCompatible,
    element,
    symbol,
    accentValue,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'zodiac_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ZodiacRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('zodiac_name')) {
      context.handle(
        _zodiacNameMeta,
        zodiacName.isAcceptableOrUnknown(data['zodiac_name']!, _zodiacNameMeta),
      );
    } else if (isInserting) {
      context.missing(_zodiacNameMeta);
    }
    if (data.containsKey('date_range')) {
      context.handle(
        _dateRangeMeta,
        dateRange.isAcceptableOrUnknown(data['date_range']!, _dateRangeMeta),
      );
    } else if (isInserting) {
      context.missing(_dateRangeMeta);
    }
    if (data.containsKey('character')) {
      context.handle(
        _characterMeta,
        character.isAcceptableOrUnknown(data['character']!, _characterMeta),
      );
    } else if (isInserting) {
      context.missing(_characterMeta);
    }
    if (data.containsKey('strengths')) {
      context.handle(
        _strengthsMeta,
        strengths.isAcceptableOrUnknown(data['strengths']!, _strengthsMeta),
      );
    } else if (isInserting) {
      context.missing(_strengthsMeta);
    }
    if (data.containsKey('weaknesses')) {
      context.handle(
        _weaknessesMeta,
        weaknesses.isAcceptableOrUnknown(data['weaknesses']!, _weaknessesMeta),
      );
    } else if (isInserting) {
      context.missing(_weaknessesMeta);
    }
    if (data.containsKey('compatible')) {
      context.handle(
        _compatibleMeta,
        compatible.isAcceptableOrUnknown(data['compatible']!, _compatibleMeta),
      );
    } else if (isInserting) {
      context.missing(_compatibleMeta);
    }
    if (data.containsKey('less_compatible')) {
      context.handle(
        _lessCompatibleMeta,
        lessCompatible.isAcceptableOrUnknown(
          data['less_compatible']!,
          _lessCompatibleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lessCompatibleMeta);
    }
    if (data.containsKey('element')) {
      context.handle(
        _elementMeta,
        element.isAcceptableOrUnknown(data['element']!, _elementMeta),
      );
    } else if (isInserting) {
      context.missing(_elementMeta);
    }
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('accent_value')) {
      context.handle(
        _accentValueMeta,
        accentValue.isAcceptableOrUnknown(
          data['accent_value']!,
          _accentValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accentValueMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ZodiacRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ZodiacRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day'],
      )!,
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}month'],
      )!,
      zodiacName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zodiac_name'],
      )!,
      dateRange: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_range'],
      )!,
      character: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}character'],
      )!,
      strengths: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}strengths'],
      )!,
      weaknesses: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weaknesses'],
      )!,
      compatible: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}compatible'],
      )!,
      lessCompatible: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}less_compatible'],
      )!,
      element: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}element'],
      )!,
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      )!,
      accentValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accent_value'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ZodiacRecordsTable createAlias(String alias) {
    return $ZodiacRecordsTable(attachedDatabase, alias);
  }
}

class ZodiacRecord extends DataClass implements Insertable<ZodiacRecord> {
  final int id;
  final int day;
  final int month;
  final String zodiacName;
  final String dateRange;
  final String character;
  final String strengths;
  final String weaknesses;
  final String compatible;
  final String lessCompatible;
  final String element;
  final String symbol;
  final int accentValue;
  final DateTime createdAt;
  const ZodiacRecord({
    required this.id,
    required this.day,
    required this.month,
    required this.zodiacName,
    required this.dateRange,
    required this.character,
    required this.strengths,
    required this.weaknesses,
    required this.compatible,
    required this.lessCompatible,
    required this.element,
    required this.symbol,
    required this.accentValue,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['day'] = Variable<int>(day);
    map['month'] = Variable<int>(month);
    map['zodiac_name'] = Variable<String>(zodiacName);
    map['date_range'] = Variable<String>(dateRange);
    map['character'] = Variable<String>(character);
    map['strengths'] = Variable<String>(strengths);
    map['weaknesses'] = Variable<String>(weaknesses);
    map['compatible'] = Variable<String>(compatible);
    map['less_compatible'] = Variable<String>(lessCompatible);
    map['element'] = Variable<String>(element);
    map['symbol'] = Variable<String>(symbol);
    map['accent_value'] = Variable<int>(accentValue);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ZodiacRecordsCompanion toCompanion(bool nullToAbsent) {
    return ZodiacRecordsCompanion(
      id: Value(id),
      day: Value(day),
      month: Value(month),
      zodiacName: Value(zodiacName),
      dateRange: Value(dateRange),
      character: Value(character),
      strengths: Value(strengths),
      weaknesses: Value(weaknesses),
      compatible: Value(compatible),
      lessCompatible: Value(lessCompatible),
      element: Value(element),
      symbol: Value(symbol),
      accentValue: Value(accentValue),
      createdAt: Value(createdAt),
    );
  }

  factory ZodiacRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ZodiacRecord(
      id: serializer.fromJson<int>(json['id']),
      day: serializer.fromJson<int>(json['day']),
      month: serializer.fromJson<int>(json['month']),
      zodiacName: serializer.fromJson<String>(json['zodiacName']),
      dateRange: serializer.fromJson<String>(json['dateRange']),
      character: serializer.fromJson<String>(json['character']),
      strengths: serializer.fromJson<String>(json['strengths']),
      weaknesses: serializer.fromJson<String>(json['weaknesses']),
      compatible: serializer.fromJson<String>(json['compatible']),
      lessCompatible: serializer.fromJson<String>(json['lessCompatible']),
      element: serializer.fromJson<String>(json['element']),
      symbol: serializer.fromJson<String>(json['symbol']),
      accentValue: serializer.fromJson<int>(json['accentValue']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'day': serializer.toJson<int>(day),
      'month': serializer.toJson<int>(month),
      'zodiacName': serializer.toJson<String>(zodiacName),
      'dateRange': serializer.toJson<String>(dateRange),
      'character': serializer.toJson<String>(character),
      'strengths': serializer.toJson<String>(strengths),
      'weaknesses': serializer.toJson<String>(weaknesses),
      'compatible': serializer.toJson<String>(compatible),
      'lessCompatible': serializer.toJson<String>(lessCompatible),
      'element': serializer.toJson<String>(element),
      'symbol': serializer.toJson<String>(symbol),
      'accentValue': serializer.toJson<int>(accentValue),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ZodiacRecord copyWith({
    int? id,
    int? day,
    int? month,
    String? zodiacName,
    String? dateRange,
    String? character,
    String? strengths,
    String? weaknesses,
    String? compatible,
    String? lessCompatible,
    String? element,
    String? symbol,
    int? accentValue,
    DateTime? createdAt,
  }) => ZodiacRecord(
    id: id ?? this.id,
    day: day ?? this.day,
    month: month ?? this.month,
    zodiacName: zodiacName ?? this.zodiacName,
    dateRange: dateRange ?? this.dateRange,
    character: character ?? this.character,
    strengths: strengths ?? this.strengths,
    weaknesses: weaknesses ?? this.weaknesses,
    compatible: compatible ?? this.compatible,
    lessCompatible: lessCompatible ?? this.lessCompatible,
    element: element ?? this.element,
    symbol: symbol ?? this.symbol,
    accentValue: accentValue ?? this.accentValue,
    createdAt: createdAt ?? this.createdAt,
  );
  ZodiacRecord copyWithCompanion(ZodiacRecordsCompanion data) {
    return ZodiacRecord(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      month: data.month.present ? data.month.value : this.month,
      zodiacName: data.zodiacName.present
          ? data.zodiacName.value
          : this.zodiacName,
      dateRange: data.dateRange.present ? data.dateRange.value : this.dateRange,
      character: data.character.present ? data.character.value : this.character,
      strengths: data.strengths.present ? data.strengths.value : this.strengths,
      weaknesses: data.weaknesses.present
          ? data.weaknesses.value
          : this.weaknesses,
      compatible: data.compatible.present
          ? data.compatible.value
          : this.compatible,
      lessCompatible: data.lessCompatible.present
          ? data.lessCompatible.value
          : this.lessCompatible,
      element: data.element.present ? data.element.value : this.element,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      accentValue: data.accentValue.present
          ? data.accentValue.value
          : this.accentValue,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ZodiacRecord(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('month: $month, ')
          ..write('zodiacName: $zodiacName, ')
          ..write('dateRange: $dateRange, ')
          ..write('character: $character, ')
          ..write('strengths: $strengths, ')
          ..write('weaknesses: $weaknesses, ')
          ..write('compatible: $compatible, ')
          ..write('lessCompatible: $lessCompatible, ')
          ..write('element: $element, ')
          ..write('symbol: $symbol, ')
          ..write('accentValue: $accentValue, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    day,
    month,
    zodiacName,
    dateRange,
    character,
    strengths,
    weaknesses,
    compatible,
    lessCompatible,
    element,
    symbol,
    accentValue,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ZodiacRecord &&
          other.id == this.id &&
          other.day == this.day &&
          other.month == this.month &&
          other.zodiacName == this.zodiacName &&
          other.dateRange == this.dateRange &&
          other.character == this.character &&
          other.strengths == this.strengths &&
          other.weaknesses == this.weaknesses &&
          other.compatible == this.compatible &&
          other.lessCompatible == this.lessCompatible &&
          other.element == this.element &&
          other.symbol == this.symbol &&
          other.accentValue == this.accentValue &&
          other.createdAt == this.createdAt);
}

class ZodiacRecordsCompanion extends UpdateCompanion<ZodiacRecord> {
  final Value<int> id;
  final Value<int> day;
  final Value<int> month;
  final Value<String> zodiacName;
  final Value<String> dateRange;
  final Value<String> character;
  final Value<String> strengths;
  final Value<String> weaknesses;
  final Value<String> compatible;
  final Value<String> lessCompatible;
  final Value<String> element;
  final Value<String> symbol;
  final Value<int> accentValue;
  final Value<DateTime> createdAt;
  const ZodiacRecordsCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.month = const Value.absent(),
    this.zodiacName = const Value.absent(),
    this.dateRange = const Value.absent(),
    this.character = const Value.absent(),
    this.strengths = const Value.absent(),
    this.weaknesses = const Value.absent(),
    this.compatible = const Value.absent(),
    this.lessCompatible = const Value.absent(),
    this.element = const Value.absent(),
    this.symbol = const Value.absent(),
    this.accentValue = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ZodiacRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int day,
    required int month,
    required String zodiacName,
    required String dateRange,
    required String character,
    required String strengths,
    required String weaknesses,
    required String compatible,
    required String lessCompatible,
    required String element,
    required String symbol,
    required int accentValue,
    this.createdAt = const Value.absent(),
  }) : day = Value(day),
       month = Value(month),
       zodiacName = Value(zodiacName),
       dateRange = Value(dateRange),
       character = Value(character),
       strengths = Value(strengths),
       weaknesses = Value(weaknesses),
       compatible = Value(compatible),
       lessCompatible = Value(lessCompatible),
       element = Value(element),
       symbol = Value(symbol),
       accentValue = Value(accentValue);
  static Insertable<ZodiacRecord> custom({
    Expression<int>? id,
    Expression<int>? day,
    Expression<int>? month,
    Expression<String>? zodiacName,
    Expression<String>? dateRange,
    Expression<String>? character,
    Expression<String>? strengths,
    Expression<String>? weaknesses,
    Expression<String>? compatible,
    Expression<String>? lessCompatible,
    Expression<String>? element,
    Expression<String>? symbol,
    Expression<int>? accentValue,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (month != null) 'month': month,
      if (zodiacName != null) 'zodiac_name': zodiacName,
      if (dateRange != null) 'date_range': dateRange,
      if (character != null) 'character': character,
      if (strengths != null) 'strengths': strengths,
      if (weaknesses != null) 'weaknesses': weaknesses,
      if (compatible != null) 'compatible': compatible,
      if (lessCompatible != null) 'less_compatible': lessCompatible,
      if (element != null) 'element': element,
      if (symbol != null) 'symbol': symbol,
      if (accentValue != null) 'accent_value': accentValue,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ZodiacRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? day,
    Value<int>? month,
    Value<String>? zodiacName,
    Value<String>? dateRange,
    Value<String>? character,
    Value<String>? strengths,
    Value<String>? weaknesses,
    Value<String>? compatible,
    Value<String>? lessCompatible,
    Value<String>? element,
    Value<String>? symbol,
    Value<int>? accentValue,
    Value<DateTime>? createdAt,
  }) {
    return ZodiacRecordsCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      month: month ?? this.month,
      zodiacName: zodiacName ?? this.zodiacName,
      dateRange: dateRange ?? this.dateRange,
      character: character ?? this.character,
      strengths: strengths ?? this.strengths,
      weaknesses: weaknesses ?? this.weaknesses,
      compatible: compatible ?? this.compatible,
      lessCompatible: lessCompatible ?? this.lessCompatible,
      element: element ?? this.element,
      symbol: symbol ?? this.symbol,
      accentValue: accentValue ?? this.accentValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<int>(day.value);
    }
    if (month.present) {
      map['month'] = Variable<int>(month.value);
    }
    if (zodiacName.present) {
      map['zodiac_name'] = Variable<String>(zodiacName.value);
    }
    if (dateRange.present) {
      map['date_range'] = Variable<String>(dateRange.value);
    }
    if (character.present) {
      map['character'] = Variable<String>(character.value);
    }
    if (strengths.present) {
      map['strengths'] = Variable<String>(strengths.value);
    }
    if (weaknesses.present) {
      map['weaknesses'] = Variable<String>(weaknesses.value);
    }
    if (compatible.present) {
      map['compatible'] = Variable<String>(compatible.value);
    }
    if (lessCompatible.present) {
      map['less_compatible'] = Variable<String>(lessCompatible.value);
    }
    if (element.present) {
      map['element'] = Variable<String>(element.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (accentValue.present) {
      map['accent_value'] = Variable<int>(accentValue.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ZodiacRecordsCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('month: $month, ')
          ..write('zodiacName: $zodiacName, ')
          ..write('dateRange: $dateRange, ')
          ..write('character: $character, ')
          ..write('strengths: $strengths, ')
          ..write('weaknesses: $weaknesses, ')
          ..write('compatible: $compatible, ')
          ..write('lessCompatible: $lessCompatible, ')
          ..write('element: $element, ')
          ..write('symbol: $symbol, ')
          ..write('accentValue: $accentValue, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ZodiacRecordsTable zodiacRecords = $ZodiacRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [zodiacRecords];
}

typedef $$ZodiacRecordsTableCreateCompanionBuilder =
    ZodiacRecordsCompanion Function({
      Value<int> id,
      required int day,
      required int month,
      required String zodiacName,
      required String dateRange,
      required String character,
      required String strengths,
      required String weaknesses,
      required String compatible,
      required String lessCompatible,
      required String element,
      required String symbol,
      required int accentValue,
      Value<DateTime> createdAt,
    });
typedef $$ZodiacRecordsTableUpdateCompanionBuilder =
    ZodiacRecordsCompanion Function({
      Value<int> id,
      Value<int> day,
      Value<int> month,
      Value<String> zodiacName,
      Value<String> dateRange,
      Value<String> character,
      Value<String> strengths,
      Value<String> weaknesses,
      Value<String> compatible,
      Value<String> lessCompatible,
      Value<String> element,
      Value<String> symbol,
      Value<int> accentValue,
      Value<DateTime> createdAt,
    });

class $$ZodiacRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $ZodiacRecordsTable> {
  $$ZodiacRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get zodiacName => $composableBuilder(
    column: $table.zodiacName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateRange => $composableBuilder(
    column: $table.dateRange,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get character => $composableBuilder(
    column: $table.character,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get strengths => $composableBuilder(
    column: $table.strengths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weaknesses => $composableBuilder(
    column: $table.weaknesses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get compatible => $composableBuilder(
    column: $table.compatible,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lessCompatible => $composableBuilder(
    column: $table.lessCompatible,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get element => $composableBuilder(
    column: $table.element,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accentValue => $composableBuilder(
    column: $table.accentValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ZodiacRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ZodiacRecordsTable> {
  $$ZodiacRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get zodiacName => $composableBuilder(
    column: $table.zodiacName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateRange => $composableBuilder(
    column: $table.dateRange,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get character => $composableBuilder(
    column: $table.character,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get strengths => $composableBuilder(
    column: $table.strengths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weaknesses => $composableBuilder(
    column: $table.weaknesses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get compatible => $composableBuilder(
    column: $table.compatible,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lessCompatible => $composableBuilder(
    column: $table.lessCompatible,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get element => $composableBuilder(
    column: $table.element,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accentValue => $composableBuilder(
    column: $table.accentValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ZodiacRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ZodiacRecordsTable> {
  $$ZodiacRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<String> get zodiacName => $composableBuilder(
    column: $table.zodiacName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dateRange =>
      $composableBuilder(column: $table.dateRange, builder: (column) => column);

  GeneratedColumn<String> get character =>
      $composableBuilder(column: $table.character, builder: (column) => column);

  GeneratedColumn<String> get strengths =>
      $composableBuilder(column: $table.strengths, builder: (column) => column);

  GeneratedColumn<String> get weaknesses => $composableBuilder(
    column: $table.weaknesses,
    builder: (column) => column,
  );

  GeneratedColumn<String> get compatible => $composableBuilder(
    column: $table.compatible,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lessCompatible => $composableBuilder(
    column: $table.lessCompatible,
    builder: (column) => column,
  );

  GeneratedColumn<String> get element =>
      $composableBuilder(column: $table.element, builder: (column) => column);

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<int> get accentValue => $composableBuilder(
    column: $table.accentValue,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ZodiacRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ZodiacRecordsTable,
          ZodiacRecord,
          $$ZodiacRecordsTableFilterComposer,
          $$ZodiacRecordsTableOrderingComposer,
          $$ZodiacRecordsTableAnnotationComposer,
          $$ZodiacRecordsTableCreateCompanionBuilder,
          $$ZodiacRecordsTableUpdateCompanionBuilder,
          (
            ZodiacRecord,
            BaseReferences<_$AppDatabase, $ZodiacRecordsTable, ZodiacRecord>,
          ),
          ZodiacRecord,
          PrefetchHooks Function()
        > {
  $$ZodiacRecordsTableTableManager(_$AppDatabase db, $ZodiacRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ZodiacRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ZodiacRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ZodiacRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> day = const Value.absent(),
                Value<int> month = const Value.absent(),
                Value<String> zodiacName = const Value.absent(),
                Value<String> dateRange = const Value.absent(),
                Value<String> character = const Value.absent(),
                Value<String> strengths = const Value.absent(),
                Value<String> weaknesses = const Value.absent(),
                Value<String> compatible = const Value.absent(),
                Value<String> lessCompatible = const Value.absent(),
                Value<String> element = const Value.absent(),
                Value<String> symbol = const Value.absent(),
                Value<int> accentValue = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ZodiacRecordsCompanion(
                id: id,
                day: day,
                month: month,
                zodiacName: zodiacName,
                dateRange: dateRange,
                character: character,
                strengths: strengths,
                weaknesses: weaknesses,
                compatible: compatible,
                lessCompatible: lessCompatible,
                element: element,
                symbol: symbol,
                accentValue: accentValue,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int day,
                required int month,
                required String zodiacName,
                required String dateRange,
                required String character,
                required String strengths,
                required String weaknesses,
                required String compatible,
                required String lessCompatible,
                required String element,
                required String symbol,
                required int accentValue,
                Value<DateTime> createdAt = const Value.absent(),
              }) => ZodiacRecordsCompanion.insert(
                id: id,
                day: day,
                month: month,
                zodiacName: zodiacName,
                dateRange: dateRange,
                character: character,
                strengths: strengths,
                weaknesses: weaknesses,
                compatible: compatible,
                lessCompatible: lessCompatible,
                element: element,
                symbol: symbol,
                accentValue: accentValue,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ZodiacRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ZodiacRecordsTable,
      ZodiacRecord,
      $$ZodiacRecordsTableFilterComposer,
      $$ZodiacRecordsTableOrderingComposer,
      $$ZodiacRecordsTableAnnotationComposer,
      $$ZodiacRecordsTableCreateCompanionBuilder,
      $$ZodiacRecordsTableUpdateCompanionBuilder,
      (
        ZodiacRecord,
        BaseReferences<_$AppDatabase, $ZodiacRecordsTable, ZodiacRecord>,
      ),
      ZodiacRecord,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ZodiacRecordsTableTableManager get zodiacRecords =>
      $$ZodiacRecordsTableTableManager(_db, _db.zodiacRecords);
}
