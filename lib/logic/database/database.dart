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
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to)async {
      if(from < 2) {
        await m.addColumn(accounts, accounts.isArchived);
      }

      if(from < 3) {
        await m.addColumn(accounts, accounts.sortIndex);
        
        // sort accounts by id (from lowest to highest)
        final allAccounts = await (select(accounts)
          ..orderBy([(a) => OrderingTerm(expression: a.id)])
        ).get();
        
        for(var i = 0; i < allAccounts.length; i++) {
          await (update(accounts)
            ..where((a) => a.id.equals(allAccounts[i].id))
          ).write(AccountsCompanion(sortIndex: Value(i)));
        }
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