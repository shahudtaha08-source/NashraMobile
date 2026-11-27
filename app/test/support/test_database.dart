import 'dart:io';

import 'package:meri_nashra/persistence/app_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void initializeSqliteFfi() {
  sqfliteFfiInit();
}

AppDatabase makeTestDatabase(String path) {
  return AppDatabase(path, factory: databaseFactoryFfi);
}

Future<Directory> createTestDirectory() {
  return Directory.systemTemp.createTemp('nashra_phase1_');
}

String databasePath(Directory directory, [String name = 'nashra_test.db']) {
  return '${directory.path}${Platform.pathSeparator}$name';
}
