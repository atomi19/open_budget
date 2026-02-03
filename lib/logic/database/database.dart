import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/material.dart' hide Table;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

// tables
// transactions table
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get description => text()();
  IntColumn get categoryId => integer()(); // category id 
  DateTimeColumn get dateAndTime => dateTime()();
}

// categories table
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  BoolColumn get isIncome => boolean()(); // true - income, false - expense
  TextColumn get iconName => text()(); // store icon as String key 
}

// db
@DriftDatabase(tables: [Transactions, Categories])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  // transactions daos

  // add (insert) transaction
  Future<int> addTransaction({
    required double amount,
    required String description,
    required int categoryId,
    required DateTime date, 
    required TimeOfDay time,
  }) {
    final dateAndTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute
    );

    return into(transactions).insert(
      TransactionsCompanion.insert(
        amount: amount, 
        description: description, 
        categoryId: categoryId,
        dateAndTime: dateAndTime,
      )
    );
  }

  // delete transaction
  Future<int> deleteTransaction(int id) {
    return (delete(transactions)..where((transaction) => transaction.id.equals(id))).go();
  }

  // update amaount
  Future<int> updateAmount(int id, double newAmount) async {
    return (update(transactions)
      ..where(((transaction) => transaction.id.equals(id))))
        .write(TransactionsCompanion(amount: Value(newAmount)
      )
    );
  }

  // update transaction date 
  Future<int> updateDateAndTime(int id, DateTime newDate) async {
    return (update(transactions)
      ..where(((transaction) => transaction.id.equals(id))))
        .write(TransactionsCompanion(dateAndTime: Value(newDate)
      )
    );
  }

  // update transaction category id 
  Future<int> updateTransactionCategoryId(int id, int newCategoryId) {
    return (update(transactions)
      ..where(((transaction) => transaction.id.equals(id))))
        .write(TransactionsCompanion(categoryId: Value(newCategoryId)
      )
    );
  }

  // update (edit) transaction description
  Future<int> updateDescription(int id, String newDescription) async {
    return (update(transactions)
      ..where(((transaction) => transaction.id.equals(id))))
        .write(TransactionsCompanion(description: Value(newDescription)
      )
    );
  }

  // get all transactions
  Stream<List<Transaction>> watchAllTransactionItems() {
    return (select(transactions)..orderBy([
      (transaction) => OrderingTerm(
        expression: transaction.dateAndTime,
        mode: OrderingMode.desc // highest items first (so user gets recent transactions first)
      )
    ])
    ).watch();
  }

  // calculate total balance 
  Stream<String> watchTotalBalance() {
    final query = select(transactions).addColumns([transactions.amount.sum()]);
    return query.watchSingle().map((row) {
      final totalBalance = row.read(transactions.amount.sum()) ?? 0;
      return totalBalance % 1 == 0 ? totalBalance.toInt().toString() : totalBalance.toString();
    });
  }

  // search transactions
  Stream<List<Transaction>> searchTransactions(String query) {
    // if query is empty return all transactions
    if(query.isEmpty) {
      return watchAllTransactionItems();
    }
    final String formattedQuery = '%${query.toLowerCase()}%';
    // search through descriptions and amounts 
    return (
      select(transactions)..orderBy([
        (t) => OrderingTerm(
          expression: t.dateAndTime,
          mode: OrderingMode.desc,
        )
      ])..where((t) => 
        t.description.lower().like(formattedQuery) |
        t.amount.cast<String>().like(formattedQuery)
      )
    ).watch();
  }


  // categories daos

  // watch all categories
  Stream<List<Category>> watchCategories() {
    return (select(categories)).watch();
  }

  // watch income/expense categories
  Stream<List<Category>> watchIncomeOrExpenseCategories(bool isIncome) {
    return (select(categories)..where((c) => c.isIncome.equals(isIncome))).watch();
  }

  // add category
  Future<int> addCategory({
    required String name,
    required bool isIncome,
    required String iconName,
  }) {
    return into(categories).insert(
      CategoriesCompanion.insert(
        name: name, 
        isIncome: isIncome, 
        iconName: iconName,
      )
    );
  } 

  // delete category
  Future<int> deleteCategory(int categoryId) {
    return (delete(categories)..where((c) => c.id.equals(categoryId))).go();
  }

  // find category
  Future<Category?> getCategoryById(int id) {
    return (select(categories)..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'open_budget_db',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      )
    );
  }
}