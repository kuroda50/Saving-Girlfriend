// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $BudgetHistoriesTable extends BudgetHistories
    with TableInfo<$BudgetHistoriesTable, BudgetHistory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetHistoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
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
  List<GeneratedColumn> get $columns => [id, date, amount, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budget_histories';
  @override
  VerificationContext validateIntegrity(Insertable<BudgetHistory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
  BudgetHistory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetHistory(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $BudgetHistoriesTable createAlias(String alias) {
    return $BudgetHistoriesTable(attachedDatabase, alias);
  }
}

class BudgetHistory extends DataClass implements Insertable<BudgetHistory> {
  final int id;
  final DateTime date;
  final int amount;
  final DateTime createdAt;
  const BudgetHistory(
      {required this.id,
      required this.date,
      required this.amount,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['amount'] = Variable<int>(amount);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BudgetHistoriesCompanion toCompanion(bool nullToAbsent) {
    return BudgetHistoriesCompanion(
      id: Value(id),
      date: Value(date),
      amount: Value(amount),
      createdAt: Value(createdAt),
    );
  }

  factory BudgetHistory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetHistory(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      amount: serializer.fromJson<int>(json['amount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'amount': serializer.toJson<int>(amount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BudgetHistory copyWith(
          {int? id, DateTime? date, int? amount, DateTime? createdAt}) =>
      BudgetHistory(
        id: id ?? this.id,
        date: date ?? this.date,
        amount: amount ?? this.amount,
        createdAt: createdAt ?? this.createdAt,
      );
  BudgetHistory copyWithCompanion(BudgetHistoriesCompanion data) {
    return BudgetHistory(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      amount: data.amount.present ? data.amount.value : this.amount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetHistory(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('amount: $amount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, amount, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetHistory &&
          other.id == this.id &&
          other.date == this.date &&
          other.amount == this.amount &&
          other.createdAt == this.createdAt);
}

class BudgetHistoriesCompanion extends UpdateCompanion<BudgetHistory> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<int> amount;
  final Value<DateTime> createdAt;
  const BudgetHistoriesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.amount = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BudgetHistoriesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required int amount,
    this.createdAt = const Value.absent(),
  })  : date = Value(date),
        amount = Value(amount);
  static Insertable<BudgetHistory> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<int>? amount,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (amount != null) 'amount': amount,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BudgetHistoriesCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? date,
      Value<int>? amount,
      Value<DateTime>? createdAt}) {
    return BudgetHistoriesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetHistoriesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('amount: $amount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BudgetHistoriesTable budgetHistories =
      $BudgetHistoriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [budgetHistories];
}

typedef $$BudgetHistoriesTableCreateCompanionBuilder = BudgetHistoriesCompanion
    Function({
  Value<int> id,
  required DateTime date,
  required int amount,
  Value<DateTime> createdAt,
});
typedef $$BudgetHistoriesTableUpdateCompanionBuilder = BudgetHistoriesCompanion
    Function({
  Value<int> id,
  Value<DateTime> date,
  Value<int> amount,
  Value<DateTime> createdAt,
});

class $$BudgetHistoriesTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetHistoriesTable> {
  $$BudgetHistoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$BudgetHistoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetHistoriesTable> {
  $$BudgetHistoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$BudgetHistoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetHistoriesTable> {
  $$BudgetHistoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BudgetHistoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BudgetHistoriesTable,
    BudgetHistory,
    $$BudgetHistoriesTableFilterComposer,
    $$BudgetHistoriesTableOrderingComposer,
    $$BudgetHistoriesTableAnnotationComposer,
    $$BudgetHistoriesTableCreateCompanionBuilder,
    $$BudgetHistoriesTableUpdateCompanionBuilder,
    (
      BudgetHistory,
      BaseReferences<_$AppDatabase, $BudgetHistoriesTable, BudgetHistory>
    ),
    BudgetHistory,
    PrefetchHooks Function()> {
  $$BudgetHistoriesTableTableManager(
      _$AppDatabase db, $BudgetHistoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetHistoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetHistoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetHistoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<int> amount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              BudgetHistoriesCompanion(
            id: id,
            date: date,
            amount: amount,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime date,
            required int amount,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              BudgetHistoriesCompanion.insert(
            id: id,
            date: date,
            amount: amount,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BudgetHistoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BudgetHistoriesTable,
    BudgetHistory,
    $$BudgetHistoriesTableFilterComposer,
    $$BudgetHistoriesTableOrderingComposer,
    $$BudgetHistoriesTableAnnotationComposer,
    $$BudgetHistoriesTableCreateCompanionBuilder,
    $$BudgetHistoriesTableUpdateCompanionBuilder,
    (
      BudgetHistory,
      BaseReferences<_$AppDatabase, $BudgetHistoriesTable, BudgetHistory>
    ),
    BudgetHistory,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BudgetHistoriesTableTableManager get budgetHistories =>
      $$BudgetHistoriesTableTableManager(_db, _db.budgetHistories);
}
