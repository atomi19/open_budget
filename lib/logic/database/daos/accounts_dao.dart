import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/accounts.dart';

part 'accounts_dao.g.dart';

@DriftAccessor(tables: [Accounts])
class AccountsDao extends DatabaseAccessor<AppDatabase> with _$AccountsDaoMixin{
  AccountsDao(super.db);

  // add account to db
  Future<int> createAccount({
    required double initialBalance,
    required String name,
    required String currency,
    required String icon,
  }) {
    return into(accounts).insert(
      AccountsCompanion.insert(
        initialBalance: initialBalance,
        name: name, 
        currency: currency, 
        icon: icon,
      ),
    );
  }

  // delete account 
  Future<int> deleteAccount(int id) {
    return (delete(accounts)..where((account) => account.id.equals(id))).go();
  }

  // stream accounts
  Stream<List<Account>> watchAccounts(bool isArchived) {
    return (
      select(accounts)..where((a) => a.isArchived.equals(isArchived))
    ).watch();
  }

  // update account name
  Future<int> updateAccountName(int id, String newName) {
    return (update(accounts)
      ..where(((c) => c.id.equals(id))))
        .write(AccountsCompanion(name: Value(newName)
      )
    );
  }

  // update account initial balance
  Future<int> updateAccountInitialBalance(int id, double newInitialBalance) {
    return (update(accounts)
      ..where(((c) => c.id.equals(id))))
        .write(AccountsCompanion(initialBalance: Value(newInitialBalance)
      )
    );
  }

  // update account currency
  Future<int> updateAccountCurrency(int id, String newCurrency) {
    return (update(accounts)
      ..where(((c) => c.id.equals(id))))
        .write(AccountsCompanion(currency: Value(newCurrency)
      )
    );
  }

  // update account icon
  Future<int> updateAccountIcon(int id, String newIcon) {
    return (update(accounts)
      ..where(((c) => c.id.equals(id))))
        .write(AccountsCompanion(icon: Value(newIcon)
      )
    );
  }

  // set isArchived to true or false
  Future<int> updateAccountArchiveStatus(int id, bool isArchived) {
    return (update(accounts)
      ..where(((account) => account.id.equals(id))))
        .write(AccountsCompanion(isArchived: Value(isArchived)
      )
    );
  }
}
