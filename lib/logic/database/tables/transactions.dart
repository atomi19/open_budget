import 'package:drift/drift.dart';

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get description => text()();
  IntColumn get accountOwnerId => integer()(); // account owner id
  IntColumn get categoryId => integer()(); // category id 
  DateTimeColumn get dateAndTime => dateTime()();
}