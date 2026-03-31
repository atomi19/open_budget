import 'package:drift/drift.dart';

class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  RealColumn get initialBalance => real()();
  TextColumn get name => text()();
  TextColumn get currency => text()();
  TextColumn get icon => text()();
}