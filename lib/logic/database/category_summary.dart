import 'package:open_budget/logic/database/database.dart';

class CategorySummary {
  final Category category;
  final double totalAmount;
  final double percentage;

  CategorySummary({
    required this.category,
    required this.totalAmount,
    required this.percentage,
  });
}
