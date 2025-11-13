// Package imports:
import 'package:drift/drift.dart';

// Project imports:
import 'connection/native.dart' if (dart.library.html) 'connection/web.dart';

part 'database.g.dart';

@UseRowClass(BudgetHistory)
class BudgetHistories extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime().unique()();
  IntColumn get amount => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [BudgetHistories])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 1;
}
