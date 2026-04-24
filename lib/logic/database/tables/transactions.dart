import 'package:drift/drift.dart';

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get description => text()();
  IntColumn get accountOwnerId => integer()(); // account owner id
  IntColumn get categoryId => integer().nullable()(); // category id (null if it is transfer)
  DateTimeColumn get dateAndTime => dateTime()();
  IntColumn get transactionType => integer()(); // 0 - income, 1 - expense, 2 - transfer
  IntColumn get transferId => integer().nullable()(); // transfer id (null if it is income or expense transaction)
}