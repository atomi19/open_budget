import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

// tables
import 'tables/transactions.dart';
import 'tables/categories.dart';
import 'tables/accounts.dart';

// daos
import 'daos/transactions_dao.dart';
import 'daos/categories_dao.dart';
import 'daos/accounts_dao.dart';

part 'database.g.dart';

// db
@DriftDatabase(
  tables: [Transactions, Categories, Accounts],
  daos: [TransactionsDao, CategoriesDao, AccountsDao]
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to)async {
      if(from < 4) {
        // drop everything before
        await m.drop(transactions);
        await m.drop(accounts);
        await m.drop(categories);

        await m.createAll();
      }
    }
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'open_budget_db',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      )
    );
  }
}