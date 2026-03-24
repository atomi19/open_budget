import 'package:drift/drift.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  BoolColumn get isIncome => boolean()(); // true - income, false - expense
  TextColumn get iconName => text()(); // store icon as String key 
}