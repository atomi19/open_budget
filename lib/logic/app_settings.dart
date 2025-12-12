// small app settings that are saved into shared_preferences
import 'package:open_budget/logic/currencies.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  static const _currencyKey = 'currency';

  // save currency code in shared_preferences
  static Future<void> setCurrency(String currencyCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currencyCode);
  }

  // get currency code from shared_preferences
  static Future<Currency?> getSelectedCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    String? currencyCode = prefs.getString(_currencyKey); 

    if(currencyCode == null) return null;
    // find Currency by currency code
    return Currency.currencies.firstWhere(
      (currency) => currency.code == currencyCode
    );
  }
}