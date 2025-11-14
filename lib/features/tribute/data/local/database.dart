// Package imports:
import 'package:drift/drift.dart';

// Project imports:
import 'connection/native.dart' if (dart.library.html) 'connection/web.dart';

part 'database.g.dart';

class TributeHistories extends Table {
  TextColumn get id => text()();
  TextColumn get character => text()();
  DateTimeColumn get date => dateTime()();
  IntColumn get amount => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [TributeHistories])
class TributeAppDatabase extends _$TributeAppDatabase {
  TributeAppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 1;
}
