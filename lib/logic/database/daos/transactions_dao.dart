import 'package:drift/drift.dart';
import 'package:flutter/material.dart' hide Table;
import 'package:open_budget/logic/format_number.dart';
import '../database.dart';
import '../tables/transactions.dart';

part 'transactions_dao.g.dart';

@DriftAccessor(tables: [Transactions])
class TransactionsDao extends DatabaseAccessor<AppDatabase> with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  // add (insert) transaction
  Future<int> addTransaction({
    required double amount,
    required String description,
    required int accountOwnerId,
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
        accountOwnerId: accountOwnerId,
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
  Stream<List<Transaction>> watchAllTransactionItems(int accountOwnerId) {
    return (select(transactions)
      ..where((t) => t.accountOwnerId.equals(accountOwnerId))
      ..orderBy([
        (transaction) => OrderingTerm(
          expression: transaction.dateAndTime,
          mode: OrderingMode.desc // highest items first (so user gets recent transactions first)
        )
      ])
    ).watch();
  }

  // calculate total balance 
  Stream<String> watchTotalBalance(
    Account accountOwner,
  ) {
    final totalExpression = transactions.amount.sum();
    final initialBalance = accountOwner.initialBalance;

    final query = selectOnly(transactions)
      ..addColumns([totalExpression])
      ..where(transactions.accountOwnerId.equals(accountOwner.id));

    return query.watchSingleOrNull().map((row) {
      final totalBalance = row?.read(transactions.amount.sum()) ?? 0;
      // sum total balance with initial balance
      return formatNumber(totalBalance + initialBalance);
    });
  }

  // watch total income
  Stream<double> watchTotalIncome(int accountOwnerId) {
    return (select(transactions)
      ..where((t) => t.amount.isBiggerThanValue(0))
      ..where((t) => t.accountOwnerId.equals(accountOwnerId))
    ).watch()
      .map((rows) => rows.fold(0, (sum, t) => sum + t.amount)
    );
  }

  // watch total expense
  Stream<double> watchTotalExpense(int accountOwnerId) {
    return (select(transactions)
      ..where((t) => t.amount.isSmallerThanValue(0))
      ..where((t) => t.accountOwnerId.equals(accountOwnerId))
    ).watch()
      .map((rows) => rows.fold(0, (sum, t) => sum + t.amount)
    );
  }

  // delete all transactions that associated with account 
  Future<int> deleteAllTransactionsByAccountOwnerId(int accountOwnerId) {
    return (delete(transactions)..where((transaction) => transaction.accountOwnerId.equals(accountOwnerId))).go();
  }

  // search transactions
  Stream<List<Transaction>> searchTransactions({
    required String query, 
    required int accountOwnerId}) {
    // if query is empty return all transactions
    if(query.isEmpty) {
      return watchAllTransactionItems(accountOwnerId);
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
}