// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TributeHistoriesTable extends TributeHistories
    with TableInfo<$TributeHistoriesTable, TributeHistory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TributeHistoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _characterMeta =
      const VerificationMeta('character');
  @override
  late final GeneratedColumn<String> character = GeneratedColumn<String>(
      'character', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, character, date, amount, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tribute_histories';
  @override
  VerificationContext validateIntegrity(Insertable<TributeHistory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('character')) {
      context.handle(_characterMeta,
          character.isAcceptableOrUnknown(data['character']!, _characterMeta));
    } else if (isInserting) {
      context.missing(_characterMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TributeHistory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TributeHistory(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      character: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}character'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $TributeHistoriesTable createAlias(String alias) {
    return $TributeHistoriesTable(attachedDatabase, alias);
  }
}

class TributeHistory extends DataClass implements Insertable<TributeHistory> {
  final String id;
  final String character;
  final DateTime date;
  final int amount;
  final DateTime createdAt;
  const TributeHistory(
      {required this.id,
      required this.character,
      required this.date,
      required this.amount,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['character'] = Variable<String>(character);
    map['date'] = Variable<DateTime>(date);
    map['amount'] = Variable<int>(amount);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TributeHistoriesCompanion toCompanion(bool nullToAbsent) {
    return TributeHistoriesCompanion(
      id: Value(id),
      character: Value(character),
      date: Value(date),
      amount: Value(amount),
      createdAt: Value(createdAt),
    );
  }

  factory TributeHistory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TributeHistory(
      id: serializer.fromJson<String>(json['id']),
      character: serializer.fromJson<String>(json['character']),
      date: serializer.fromJson<DateTime>(json['date']),
      amount: serializer.fromJson<int>(json['amount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'character': serializer.toJson<String>(character),
      'date': serializer.toJson<DateTime>(date),
      'amount': serializer.toJson<int>(amount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TributeHistory copyWith(
          {String? id,
          String? character,
          DateTime? date,
          int? amount,
          DateTime? createdAt}) =>
      TributeHistory(
        id: id ?? this.id,
        character: character ?? this.character,
        date: date ?? this.date,
        amount: amount ?? this.amount,
        createdAt: createdAt ?? this.createdAt,
      );
  TributeHistory copyWithCompanion(TributeHistoriesCompanion data) {
    return TributeHistory(
      id: data.id.present ? data.id.value : this.id,
      character: data.character.present ? data.character.value : this.character,
      date: data.date.present ? data.date.value : this.date,
      amount: data.amount.present ? data.amount.value : this.amount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TributeHistory(')
          ..write('id: $id, ')
          ..write('character: $character, ')
          ..write('date: $date, ')
          ..write('amount: $amount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, character, date, amount, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TributeHistory &&
          other.id == this.id &&
          other.character == this.character &&
          other.date == this.date &&
          other.amount == this.amount &&
          other.createdAt == this.createdAt);
}

class TributeHistoriesCompanion extends UpdateCompanion<TributeHistory> {
  final Value<String> id;
  final Value<String> character;
  final Value<DateTime> date;
  final Value<int> amount;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TributeHistoriesCompanion({
    this.id = const Value.absent(),
    this.character = const Value.absent(),
    this.date = const Value.absent(),
    this.amount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TributeHistoriesCompanion.insert({
    required String id,
    required String character,
    required DateTime date,
    required int amount,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        character = Value(character),
        date = Value(date),
        amount = Value(amount);
  static Insertable<TributeHistory> custom({
    Expression<String>? id,
    Expression<String>? character,
    Expression<DateTime>? date,
    Expression<int>? amount,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (character != null) 'character': character,
      if (date != null) 'date': date,
      if (amount != null) 'amount': amount,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TributeHistoriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? character,
      Value<DateTime>? date,
      Value<int>? amount,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return TributeHistoriesCompanion(
      id: id ?? this.id,
      character: character ?? this.character,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (character.present) {
      map['character'] = Variable<String>(character.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TributeHistoriesCompanion(')
          ..write('id: $id, ')
          ..write('character: $character, ')
          ..write('date: $date, ')
          ..write('amount: $amount, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$TributeAppDatabase extends GeneratedDatabase {
  _$TributeAppDatabase(QueryExecutor e) : super(e);
  $TributeAppDatabaseManager get managers => $TributeAppDatabaseManager(this);
  late final $TributeHistoriesTable tributeHistories =
      $TributeHistoriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [tributeHistories];
}

typedef $$TributeHistoriesTableCreateCompanionBuilder
    = TributeHistoriesCompanion Function({
  required String id,
  required String character,
  required DateTime date,
  required int amount,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$TributeHistoriesTableUpdateCompanionBuilder
    = TributeHistoriesCompanion Function({
  Value<String> id,
  Value<String> character,
  Value<DateTime> date,
  Value<int> amount,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$TributeHistoriesTableFilterComposer
    extends Composer<_$TributeAppDatabase, $TributeHistoriesTable> {
  $$TributeHistoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get character => $composableBuilder(
      column: $table.character, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$TributeHistoriesTableOrderingComposer
    extends Composer<_$TributeAppDatabase, $TributeHistoriesTable> {
  $$TributeHistoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get character => $composableBuilder(
      column: $table.character, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$TributeHistoriesTableAnnotationComposer
    extends Composer<_$TributeAppDatabase, $TributeHistoriesTable> {
  $$TributeHistoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get character =>
      $composableBuilder(column: $table.character, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TributeHistoriesTableTableManager extends RootTableManager<
    _$TributeAppDatabase,
    $TributeHistoriesTable,
    TributeHistory,
    $$TributeHistoriesTableFilterComposer,
    $$TributeHistoriesTableOrderingComposer,
    $$TributeHistoriesTableAnnotationComposer,
    $$TributeHistoriesTableCreateCompanionBuilder,
    $$TributeHistoriesTableUpdateCompanionBuilder,
    (
      TributeHistory,
      BaseReferences<_$TributeAppDatabase, $TributeHistoriesTable,
          TributeHistory>
    ),
    TributeHistory,
    PrefetchHooks Function()> {
  $$TributeHistoriesTableTableManager(
      _$TributeAppDatabase db, $TributeHistoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TributeHistoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TributeHistoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TributeHistoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> character = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<int> amount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TributeHistoriesCompanion(
            id: id,
            character: character,
            date: date,
            amount: amount,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String character,
            required DateTime date,
            required int amount,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TributeHistoriesCompanion.insert(
            id: id,
            character: character,
            date: date,
            amount: amount,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TributeHistoriesTableProcessedTableManager = ProcessedTableManager<
    _$TributeAppDatabase,
    $TributeHistoriesTable,
    TributeHistory,
    $$TributeHistoriesTableFilterComposer,
    $$TributeHistoriesTableOrderingComposer,
    $$TributeHistoriesTableAnnotationComposer,
    $$TributeHistoriesTableCreateCompanionBuilder,
    $$TributeHistoriesTableUpdateCompanionBuilder,
    (
      TributeHistory,
      BaseReferences<_$TributeAppDatabase, $TributeHistoriesTable,
          TributeHistory>
    ),
    TributeHistory,
    PrefetchHooks Function()>;

class $TributeAppDatabaseManager {
  final _$TributeAppDatabase _db;
  $TributeAppDatabaseManager(this._db);
  $$TributeHistoriesTableTableManager get tributeHistories =>
      $$TributeHistoriesTableTableManager(_db, _db.tributeHistories);
}
