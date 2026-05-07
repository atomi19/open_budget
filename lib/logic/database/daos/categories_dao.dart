import 'package:drift/drift.dart';
import 'package:open_budget/logic/database/category_summary.dart';
import '../database.dart';

import '../tables/categories.dart';
import '../tables/transactions.dart';

part 'categories_dao.g.dart';

@DriftAccessor(tables: [Categories, Transactions])
class CategoriesDao extends DatabaseAccessor<AppDatabase> with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  // sort categories from highest to lowest expenses or incomes
  Stream<List<CategorySummary>> sortCategoriesByTotalAmount({
    required int accountOwnerId,
    required bool isIncome,
    required DateTime startDate,
    required DateTime endDate,
    }) {
    final totalAmount = transactions.amount.sum();
    final absTotalAmount = totalAmount.abs();

    final query = select(categories).join([
      leftOuterJoin(
        transactions, 
        // filter all transactions with category id and account id 
        transactions.accountOwnerId.equals(accountOwnerId) &
        transactions.categoryId.equalsExp(categories.id) &
        // date range (from start to end date)
        transactions.dateAndTime.isBiggerOrEqualValue(startDate) &
        transactions.dateAndTime.isSmallerOrEqualValue(endDate),
      )
    ])
      ..where(categories.isIncome.equals(isIncome)) // true = income, false = expense
      ..addColumns([totalAmount])
      ..groupBy([categories.id])
      ..orderBy([OrderingTerm(expression: absTotalAmount, mode: OrderingMode.desc)]);

    return query.watch().map((rows) {
      final percentageTotal = rows.fold<double>(
        0, 
        (sum, row) => sum + (row.read(totalAmount) ?? 0),
      );

      return rows.map((row) {
        final category = row.readTable(categories);
        // total money spent for this category
        final total = row.read(totalAmount) ?? 0;
        // total percent of spent money for this category across all categories
        final double percentage = percentageTotal == 0
          ? 0
          : (total / percentageTotal) * 100;

        return CategorySummary(
          category: category, 
          totalAmount: total, 
          percentage: percentage,
        );
      }).toList();
    });
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

  // update category name
  Future<int> updateCategoryName(int id, String newName) async {
    return (update(categories)
      ..where(((c) => c.id.equals(id))))
        .write(CategoriesCompanion(name: Value(newName)
      )
    );
  }

  // update category icon
  Future<int> updateCategoryIcon(int id, String newIcon) async {
    return (update(categories)
      ..where(((c) => c.id.equals(id))))
        .write(CategoriesCompanion(iconName: Value(newIcon)
      )
    );
  }
}