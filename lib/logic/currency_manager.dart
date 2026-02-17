import 'package:open_budget/logic/app_settings.dart';
import 'package:open_budget/logic/currencies.dart';

class CurrencyManager {
  static Currency? currentCurrency;

  static Future<void> loadCurrency() async {
    currentCurrency = await AppSettings.getSelectedCurrency() ?? Currency.currencies.first;
  }

  static Future<void> setCurrency(Currency currency) async {
    currentCurrency = currency;
    await AppSettings.setCurrency(currency.code);
  }
}