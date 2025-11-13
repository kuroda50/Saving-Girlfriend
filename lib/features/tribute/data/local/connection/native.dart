// Package imports:
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

QueryExecutor openConnection() {
  return DatabaseConnection.delayed(Future(() async {
    // Also apply the recommended native sqlite3 configuration.
    applyWorkaroundToOpenSqlite3OnOldAndroidVersions();

    final appDir = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(appDir.path, 'tribute_db.sqlite'));
    return DatabaseConnection(NativeDatabase.createInBackground(dbFile));
  }));
}
