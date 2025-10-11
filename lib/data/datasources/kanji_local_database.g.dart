// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kanji_local_database.dart';

// ignore_for_file: type=lint
class $KanjiTableTable extends KanjiTable
    with TableInfo<$KanjiTableTable, KanjiTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KanjiTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _meaningsMeta = const VerificationMeta(
    'meanings',
  );
  @override
  late final GeneratedColumn<String> meanings = GeneratedColumn<String>(
    'meanings',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _onyomiMeta = const VerificationMeta('onyomi');
  @override
  late final GeneratedColumn<String> onyomi = GeneratedColumn<String>(
    'onyomi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kunyomiMeta = const VerificationMeta(
    'kunyomi',
  );
  @override
  late final GeneratedColumn<String> kunyomi = GeneratedColumn<String>(
    'kunyomi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _strokeCountMeta = const VerificationMeta(
    'strokeCount',
  );
  @override
  late final GeneratedColumn<int> strokeCount = GeneratedColumn<int>(
    'stroke_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _jlptMeta = const VerificationMeta('jlpt');
  @override
  late final GeneratedColumn<int> jlpt = GeneratedColumn<int>(
    'jlpt',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<int> grade = GeneratedColumn<int>(
    'grade',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<int> frequency = GeneratedColumn<int>(
    'frequency',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _radicalsMeta = const VerificationMeta(
    'radicals',
  );
  @override
  late final GeneratedColumn<String> radicals = GeneratedColumn<String>(
    'radicals',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    character,
    meanings,
    onyomi,
    kunyomi,
    strokeCount,
    jlpt,
    grade,
    frequency,
    radicals,
    isSynced,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kanji_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<KanjiTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('character')) {
      context.handle(
        _characterMeta,
        character.isAcceptableOrUnknown(data['character']!, _characterMeta),
      );
    } else if (isInserting) {
      context.missing(_characterMeta);
    }
    if (data.containsKey('meanings')) {
      context.handle(
        _meaningsMeta,
        meanings.isAcceptableOrUnknown(data['meanings']!, _meaningsMeta),
      );
    } else if (isInserting) {
      context.missing(_meaningsMeta);
    }
    if (data.containsKey('onyomi')) {
      context.handle(
        _onyomiMeta,
        onyomi.isAcceptableOrUnknown(data['onyomi']!, _onyomiMeta),
      );
    }
    if (data.containsKey('kunyomi')) {
      context.handle(
        _kunyomiMeta,
        kunyomi.isAcceptableOrUnknown(data['kunyomi']!, _kunyomiMeta),
      );
    }
    if (data.containsKey('stroke_count')) {
      context.handle(
        _strokeCountMeta,
        strokeCount.isAcceptableOrUnknown(
          data['stroke_count']!,
          _strokeCountMeta,
        ),
      );
    }
    if (data.containsKey('jlpt')) {
      context.handle(
        _jlptMeta,
        jlpt.isAcceptableOrUnknown(data['jlpt']!, _jlptMeta),
      );
    }
    if (data.containsKey('grade')) {
      context.handle(
        _gradeMeta,
        grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta),
      );
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    }
    if (data.containsKey('radicals')) {
      context.handle(
        _radicalsMeta,
        radicals.isAcceptableOrUnknown(data['radicals']!, _radicalsMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KanjiTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KanjiTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      character: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}character'],
      )!,
      meanings: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meanings'],
      )!,
      onyomi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}onyomi'],
      ),
      kunyomi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kunyomi'],
      ),
      strokeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stroke_count'],
      ),
      jlpt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jlpt'],
      ),
      grade: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grade'],
      ),
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}frequency'],
      ),
      radicals: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}radicals'],
      ),
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $KanjiTableTable createAlias(String alias) {
    return $KanjiTableTable(attachedDatabase, alias);
  }
}

class KanjiTableData extends DataClass implements Insertable<KanjiTableData> {
  final int id;
  final String character;
  final String meanings;
  final String? onyomi;
  final String? kunyomi;
  final int? strokeCount;
  final int? jlpt;
  final int? grade;
  final int? frequency;
  final String? radicals;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;
  const KanjiTableData({
    required this.id,
    required this.character,
    required this.meanings,
    this.onyomi,
    this.kunyomi,
    this.strokeCount,
    this.jlpt,
    this.grade,
    this.frequency,
    this.radicals,
    required this.isSynced,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['character'] = Variable<String>(character);
    map['meanings'] = Variable<String>(meanings);
    if (!nullToAbsent || onyomi != null) {
      map['onyomi'] = Variable<String>(onyomi);
    }
    if (!nullToAbsent || kunyomi != null) {
      map['kunyomi'] = Variable<String>(kunyomi);
    }
    if (!nullToAbsent || strokeCount != null) {
      map['stroke_count'] = Variable<int>(strokeCount);
    }
    if (!nullToAbsent || jlpt != null) {
      map['jlpt'] = Variable<int>(jlpt);
    }
    if (!nullToAbsent || grade != null) {
      map['grade'] = Variable<int>(grade);
    }
    if (!nullToAbsent || frequency != null) {
      map['frequency'] = Variable<int>(frequency);
    }
    if (!nullToAbsent || radicals != null) {
      map['radicals'] = Variable<String>(radicals);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  KanjiTableCompanion toCompanion(bool nullToAbsent) {
    return KanjiTableCompanion(
      id: Value(id),
      character: Value(character),
      meanings: Value(meanings),
      onyomi: onyomi == null && nullToAbsent
          ? const Value.absent()
          : Value(onyomi),
      kunyomi: kunyomi == null && nullToAbsent
          ? const Value.absent()
          : Value(kunyomi),
      strokeCount: strokeCount == null && nullToAbsent
          ? const Value.absent()
          : Value(strokeCount),
      jlpt: jlpt == null && nullToAbsent ? const Value.absent() : Value(jlpt),
      grade: grade == null && nullToAbsent
          ? const Value.absent()
          : Value(grade),
      frequency: frequency == null && nullToAbsent
          ? const Value.absent()
          : Value(frequency),
      radicals: radicals == null && nullToAbsent
          ? const Value.absent()
          : Value(radicals),
      isSynced: Value(isSynced),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory KanjiTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KanjiTableData(
      id: serializer.fromJson<int>(json['id']),
      character: serializer.fromJson<String>(json['character']),
      meanings: serializer.fromJson<String>(json['meanings']),
      onyomi: serializer.fromJson<String?>(json['onyomi']),
      kunyomi: serializer.fromJson<String?>(json['kunyomi']),
      strokeCount: serializer.fromJson<int?>(json['strokeCount']),
      jlpt: serializer.fromJson<int?>(json['jlpt']),
      grade: serializer.fromJson<int?>(json['grade']),
      frequency: serializer.fromJson<int?>(json['frequency']),
      radicals: serializer.fromJson<String?>(json['radicals']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'character': serializer.toJson<String>(character),
      'meanings': serializer.toJson<String>(meanings),
      'onyomi': serializer.toJson<String?>(onyomi),
      'kunyomi': serializer.toJson<String?>(kunyomi),
      'strokeCount': serializer.toJson<int?>(strokeCount),
      'jlpt': serializer.toJson<int?>(jlpt),
      'grade': serializer.toJson<int?>(grade),
      'frequency': serializer.toJson<int?>(frequency),
      'radicals': serializer.toJson<String?>(radicals),
      'isSynced': serializer.toJson<bool>(isSynced),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  KanjiTableData copyWith({
    int? id,
    String? character,
    String? meanings,
    Value<String?> onyomi = const Value.absent(),
    Value<String?> kunyomi = const Value.absent(),
    Value<int?> strokeCount = const Value.absent(),
    Value<int?> jlpt = const Value.absent(),
    Value<int?> grade = const Value.absent(),
    Value<int?> frequency = const Value.absent(),
    Value<String?> radicals = const Value.absent(),
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => KanjiTableData(
    id: id ?? this.id,
    character: character ?? this.character,
    meanings: meanings ?? this.meanings,
    onyomi: onyomi.present ? onyomi.value : this.onyomi,
    kunyomi: kunyomi.present ? kunyomi.value : this.kunyomi,
    strokeCount: strokeCount.present ? strokeCount.value : this.strokeCount,
    jlpt: jlpt.present ? jlpt.value : this.jlpt,
    grade: grade.present ? grade.value : this.grade,
    frequency: frequency.present ? frequency.value : this.frequency,
    radicals: radicals.present ? radicals.value : this.radicals,
    isSynced: isSynced ?? this.isSynced,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  KanjiTableData copyWithCompanion(KanjiTableCompanion data) {
    return KanjiTableData(
      id: data.id.present ? data.id.value : this.id,
      character: data.character.present ? data.character.value : this.character,
      meanings: data.meanings.present ? data.meanings.value : this.meanings,
      onyomi: data.onyomi.present ? data.onyomi.value : this.onyomi,
      kunyomi: data.kunyomi.present ? data.kunyomi.value : this.kunyomi,
      strokeCount: data.strokeCount.present
          ? data.strokeCount.value
          : this.strokeCount,
      jlpt: data.jlpt.present ? data.jlpt.value : this.jlpt,
      grade: data.grade.present ? data.grade.value : this.grade,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      radicals: data.radicals.present ? data.radicals.value : this.radicals,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KanjiTableData(')
          ..write('id: $id, ')
          ..write('character: $character, ')
          ..write('meanings: $meanings, ')
          ..write('onyomi: $onyomi, ')
          ..write('kunyomi: $kunyomi, ')
          ..write('strokeCount: $strokeCount, ')
          ..write('jlpt: $jlpt, ')
          ..write('grade: $grade, ')
          ..write('frequency: $frequency, ')
          ..write('radicals: $radicals, ')
          ..write('isSynced: $isSynced, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    character,
    meanings,
    onyomi,
    kunyomi,
    strokeCount,
    jlpt,
    grade,
    frequency,
    radicals,
    isSynced,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KanjiTableData &&
          other.id == this.id &&
          other.character == this.character &&
          other.meanings == this.meanings &&
          other.onyomi == this.onyomi &&
          other.kunyomi == this.kunyomi &&
          other.strokeCount == this.strokeCount &&
          other.jlpt == this.jlpt &&
          other.grade == this.grade &&
          other.frequency == this.frequency &&
          other.radicals == this.radicals &&
          other.isSynced == this.isSynced &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class KanjiTableCompanion extends UpdateCompanion<KanjiTableData> {
  final Value<int> id;
  final Value<String> character;
  final Value<String> meanings;
  final Value<String?> onyomi;
  final Value<String?> kunyomi;
  final Value<int?> strokeCount;
  final Value<int?> jlpt;
  final Value<int?> grade;
  final Value<int?> frequency;
  final Value<String?> radicals;
  final Value<bool> isSynced;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const KanjiTableCompanion({
    this.id = const Value.absent(),
    this.character = const Value.absent(),
    this.meanings = const Value.absent(),
    this.onyomi = const Value.absent(),
    this.kunyomi = const Value.absent(),
    this.strokeCount = const Value.absent(),
    this.jlpt = const Value.absent(),
    this.grade = const Value.absent(),
    this.frequency = const Value.absent(),
    this.radicals = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  KanjiTableCompanion.insert({
    this.id = const Value.absent(),
    required String character,
    required String meanings,
    this.onyomi = const Value.absent(),
    this.kunyomi = const Value.absent(),
    this.strokeCount = const Value.absent(),
    this.jlpt = const Value.absent(),
    this.grade = const Value.absent(),
    this.frequency = const Value.absent(),
    this.radicals = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : character = Value(character),
       meanings = Value(meanings);
  static Insertable<KanjiTableData> custom({
    Expression<int>? id,
    Expression<String>? character,
    Expression<String>? meanings,
    Expression<String>? onyomi,
    Expression<String>? kunyomi,
    Expression<int>? strokeCount,
    Expression<int>? jlpt,
    Expression<int>? grade,
    Expression<int>? frequency,
    Expression<String>? radicals,
    Expression<bool>? isSynced,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (character != null) 'character': character,
      if (meanings != null) 'meanings': meanings,
      if (onyomi != null) 'onyomi': onyomi,
      if (kunyomi != null) 'kunyomi': kunyomi,
      if (strokeCount != null) 'stroke_count': strokeCount,
      if (jlpt != null) 'jlpt': jlpt,
      if (grade != null) 'grade': grade,
      if (frequency != null) 'frequency': frequency,
      if (radicals != null) 'radicals': radicals,
      if (isSynced != null) 'is_synced': isSynced,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  KanjiTableCompanion copyWith({
    Value<int>? id,
    Value<String>? character,
    Value<String>? meanings,
    Value<String?>? onyomi,
    Value<String?>? kunyomi,
    Value<int?>? strokeCount,
    Value<int?>? jlpt,
    Value<int?>? grade,
    Value<int?>? frequency,
    Value<String?>? radicals,
    Value<bool>? isSynced,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return KanjiTableCompanion(
      id: id ?? this.id,
      character: character ?? this.character,
      meanings: meanings ?? this.meanings,
      onyomi: onyomi ?? this.onyomi,
      kunyomi: kunyomi ?? this.kunyomi,
      strokeCount: strokeCount ?? this.strokeCount,
      jlpt: jlpt ?? this.jlpt,
      grade: grade ?? this.grade,
      frequency: frequency ?? this.frequency,
      radicals: radicals ?? this.radicals,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (character.present) {
      map['character'] = Variable<String>(character.value);
    }
    if (meanings.present) {
      map['meanings'] = Variable<String>(meanings.value);
    }
    if (onyomi.present) {
      map['onyomi'] = Variable<String>(onyomi.value);
    }
    if (kunyomi.present) {
      map['kunyomi'] = Variable<String>(kunyomi.value);
    }
    if (strokeCount.present) {
      map['stroke_count'] = Variable<int>(strokeCount.value);
    }
    if (jlpt.present) {
      map['jlpt'] = Variable<int>(jlpt.value);
    }
    if (grade.present) {
      map['grade'] = Variable<int>(grade.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<int>(frequency.value);
    }
    if (radicals.present) {
      map['radicals'] = Variable<String>(radicals.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KanjiTableCompanion(')
          ..write('id: $id, ')
          ..write('character: $character, ')
          ..write('meanings: $meanings, ')
          ..write('onyomi: $onyomi, ')
          ..write('kunyomi: $kunyomi, ')
          ..write('strokeCount: $strokeCount, ')
          ..write('jlpt: $jlpt, ')
          ..write('grade: $grade, ')
          ..write('frequency: $frequency, ')
          ..write('radicals: $radicals, ')
          ..write('isSynced: $isSynced, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$KanjiLocalDatabase extends GeneratedDatabase {
  _$KanjiLocalDatabase(QueryExecutor e) : super(e);
  $KanjiLocalDatabaseManager get managers => $KanjiLocalDatabaseManager(this);
  late final $KanjiTableTable kanjiTable = $KanjiTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [kanjiTable];
}

typedef $$KanjiTableTableCreateCompanionBuilder =
    KanjiTableCompanion Function({
      Value<int> id,
      required String character,
      required String meanings,
      Value<String?> onyomi,
      Value<String?> kunyomi,
      Value<int?> strokeCount,
      Value<int?> jlpt,
      Value<int?> grade,
      Value<int?> frequency,
      Value<String?> radicals,
      Value<bool> isSynced,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$KanjiTableTableUpdateCompanionBuilder =
    KanjiTableCompanion Function({
      Value<int> id,
      Value<String> character,
      Value<String> meanings,
      Value<String?> onyomi,
      Value<String?> kunyomi,
      Value<int?> strokeCount,
      Value<int?> jlpt,
      Value<int?> grade,
      Value<int?> frequency,
      Value<String?> radicals,
      Value<bool> isSynced,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$KanjiTableTableFilterComposer
    extends Composer<_$KanjiLocalDatabase, $KanjiTableTable> {
  $$KanjiTableTableFilterComposer({
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

  ColumnFilters<String> get character => $composableBuilder(
    column: $table.character,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meanings => $composableBuilder(
    column: $table.meanings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get onyomi => $composableBuilder(
    column: $table.onyomi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kunyomi => $composableBuilder(
    column: $table.kunyomi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get strokeCount => $composableBuilder(
    column: $table.strokeCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get jlpt => $composableBuilder(
    column: $table.jlpt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get radicals => $composableBuilder(
    column: $table.radicals,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KanjiTableTableOrderingComposer
    extends Composer<_$KanjiLocalDatabase, $KanjiTableTable> {
  $$KanjiTableTableOrderingComposer({
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

  ColumnOrderings<String> get character => $composableBuilder(
    column: $table.character,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meanings => $composableBuilder(
    column: $table.meanings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get onyomi => $composableBuilder(
    column: $table.onyomi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kunyomi => $composableBuilder(
    column: $table.kunyomi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get strokeCount => $composableBuilder(
    column: $table.strokeCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get jlpt => $composableBuilder(
    column: $table.jlpt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get radicals => $composableBuilder(
    column: $table.radicals,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KanjiTableTableAnnotationComposer
    extends Composer<_$KanjiLocalDatabase, $KanjiTableTable> {
  $$KanjiTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get character =>
      $composableBuilder(column: $table.character, builder: (column) => column);

  GeneratedColumn<String> get meanings =>
      $composableBuilder(column: $table.meanings, builder: (column) => column);

  GeneratedColumn<String> get onyomi =>
      $composableBuilder(column: $table.onyomi, builder: (column) => column);

  GeneratedColumn<String> get kunyomi =>
      $composableBuilder(column: $table.kunyomi, builder: (column) => column);

  GeneratedColumn<int> get strokeCount => $composableBuilder(
    column: $table.strokeCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get jlpt =>
      $composableBuilder(column: $table.jlpt, builder: (column) => column);

  GeneratedColumn<int> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<int> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<String> get radicals =>
      $composableBuilder(column: $table.radicals, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$KanjiTableTableTableManager
    extends
        RootTableManager<
          _$KanjiLocalDatabase,
          $KanjiTableTable,
          KanjiTableData,
          $$KanjiTableTableFilterComposer,
          $$KanjiTableTableOrderingComposer,
          $$KanjiTableTableAnnotationComposer,
          $$KanjiTableTableCreateCompanionBuilder,
          $$KanjiTableTableUpdateCompanionBuilder,
          (
            KanjiTableData,
            BaseReferences<
              _$KanjiLocalDatabase,
              $KanjiTableTable,
              KanjiTableData
            >,
          ),
          KanjiTableData,
          PrefetchHooks Function()
        > {
  $$KanjiTableTableTableManager(_$KanjiLocalDatabase db, $KanjiTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KanjiTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KanjiTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KanjiTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> character = const Value.absent(),
                Value<String> meanings = const Value.absent(),
                Value<String?> onyomi = const Value.absent(),
                Value<String?> kunyomi = const Value.absent(),
                Value<int?> strokeCount = const Value.absent(),
                Value<int?> jlpt = const Value.absent(),
                Value<int?> grade = const Value.absent(),
                Value<int?> frequency = const Value.absent(),
                Value<String?> radicals = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => KanjiTableCompanion(
                id: id,
                character: character,
                meanings: meanings,
                onyomi: onyomi,
                kunyomi: kunyomi,
                strokeCount: strokeCount,
                jlpt: jlpt,
                grade: grade,
                frequency: frequency,
                radicals: radicals,
                isSynced: isSynced,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String character,
                required String meanings,
                Value<String?> onyomi = const Value.absent(),
                Value<String?> kunyomi = const Value.absent(),
                Value<int?> strokeCount = const Value.absent(),
                Value<int?> jlpt = const Value.absent(),
                Value<int?> grade = const Value.absent(),
                Value<int?> frequency = const Value.absent(),
                Value<String?> radicals = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => KanjiTableCompanion.insert(
                id: id,
                character: character,
                meanings: meanings,
                onyomi: onyomi,
                kunyomi: kunyomi,
                strokeCount: strokeCount,
                jlpt: jlpt,
                grade: grade,
                frequency: frequency,
                radicals: radicals,
                isSynced: isSynced,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KanjiTableTableProcessedTableManager =
    ProcessedTableManager<
      _$KanjiLocalDatabase,
      $KanjiTableTable,
      KanjiTableData,
      $$KanjiTableTableFilterComposer,
      $$KanjiTableTableOrderingComposer,
      $$KanjiTableTableAnnotationComposer,
      $$KanjiTableTableCreateCompanionBuilder,
      $$KanjiTableTableUpdateCompanionBuilder,
      (
        KanjiTableData,
        BaseReferences<_$KanjiLocalDatabase, $KanjiTableTable, KanjiTableData>,
      ),
      KanjiTableData,
      PrefetchHooks Function()
    >;

class $KanjiLocalDatabaseManager {
  final _$KanjiLocalDatabase _db;
  $KanjiLocalDatabaseManager(this._db);
  $$KanjiTableTableTableManager get kanjiTable =>
      $$KanjiTableTableTableManager(_db, _db.kanjiTable);
}
