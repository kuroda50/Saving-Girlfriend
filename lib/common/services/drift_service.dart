import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'drift_service.g.dart';

@DataClassName('AppMessage')
class Messages extends Table {
  IntColumn get dbId => integer().autoIncrement();
  TextColumn get id => text();
  TextColumn get type => text(); // Changed from IntColumn to TextColumn
  @override
  TextColumn get text => text();
  TextColumn get time => text();
}

@DataClassName('AppTransactionState')
class TransactionStates extends Table {
  IntColumn get dbId => integer().autoIncrement();
  TextColumn get id => text();
  TextColumn get type => text();
  DateTimeColumn get date => dateTime();
  IntColumn get amount => integer();
  TextColumn get category => text();
}

@DriftDatabase(tables: [Messages, TransactionStates])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});
