// small app settings that are saved into shared_preferences
import 'package:flutter/material.dart';
import 'package:open_budget/logic/currencies.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  static const _themeKey = 'theme';
  static const _currencyKey = 'currency';
  static const _showTransactionDescriptionKey = 'show_transaction_description';
  static const _homeTransactionsCount = 'home_transactions_count';

  static Future<void> setTransactionsCountOnHomePage(int quantity) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_homeTransactionsCount, quantity);
  }

  static Future<int?> getTransactionsCountOnHomePage() async {
    final prefs = await SharedPreferences.getInstance();
    int? quantity = prefs.getInt(_homeTransactionsCount);

    return quantity;
  }


  static Future<void> setTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme);
  }

  static Future<ThemeMode?> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    String? theme = prefs.getString(_themeKey);
 
    if(theme == null) return null;

    if(theme == 'light') {
      return ThemeMode.light;
    }

    if(theme == 'dark') {
      return ThemeMode.dark;
    }

    return ThemeMode.system;
  }

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

  // switch transaction description 
  // false - do not show description as subtitle in transaction listtile
  // true - show it 
  static Future<void> switchTransactionDescription(bool showTransactionDescription) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showTransactionDescriptionKey, showTransactionDescription);
  }

  // get state of transaction description
  static Future<bool?> getTransactionDescriptionState() async {
    final prefs = await SharedPreferences.getInstance();
    bool? showTransactionDescription = prefs.getBool(_showTransactionDescriptionKey); 

    if(showTransactionDescription == null) return false;
    // find Currency by currency code
    return showTransactionDescription;
  }
}