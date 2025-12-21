import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/material.dart' hide Table;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

// tables
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get description => text()();
  TextColumn get category => text()();
  DateTimeColumn get dateAndTime => dateTime()();
}

// db
@DriftDatabase(tables: [Transactions])
class TransactionsDatabase extends _$TransactionsDatabase {
  TransactionsDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  // add (insert) transaction
  Future<int> addTransaction({
    required double amount,
    required String description,
    required String category,
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
        category: category,
        dateAndTime: dateAndTime,
      )
    );
  }

  // delete transaction
  Future<int> deleteTransaction(int id) {
    return (delete(transactions)..where((transaction) => transaction.id.equals(id))).go();
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

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'open_budget_db',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      )
    );
  }
}