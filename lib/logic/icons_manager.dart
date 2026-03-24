import 'package:flutter/material.dart';

class IconsManager {
  // icons for categories
  static const Map<String,IconData> categoryIcons = {
    'restaurant': Icons.restaurant_outlined,
    'local_cafe': Icons.local_cafe_outlined,
    'local_grocery_store': Icons.local_grocery_store_outlined,
    'fastfood': Icons.fastfood_outlined,

    'directions_car': Icons.directions_car_outlined,
    'directions_bus': Icons.directions_bus_outlined,
    'train': Icons.train_outlined,
    'flight': Icons.flight_outlined,

    'home': Icons.home_outlined,
    'lightbulb': Icons.lightbulb_outlined,
    'water_drop': Icons.water_drop_outlined,
    'wifi': Icons.wifi_outlined,

    'shopping_cart': Icons.shopping_cart_outlined,
    'shopping_bag': Icons.shopping_bag_outlined,
    'checkroom': Icons.checkroom_outlined,
    'watch': Icons.watch_outlined,

    'work': Icons.work_outlined,
    'account_balance': Icons.account_balance_outlined,
    'credit_card': Icons.credit_card_outlined,
    'receipt_long': Icons.receipt_long_outlined,

    'treding_up': Icons.trending_up_outlined,
    'favorite': Icons.favorite_outlined,
    'local_hospital': Icons.local_hospital_outlined,
    'fitness_center': Icons.fitness_center_outlined,

    'pets': Icons.pets_outlined,
    'school': Icons.school_outlined,
    'card_giftcard': Icons.card_giftcard_outlined,
    'movie': Icons.movie_outlined,
  };

  // icons for accounts
  static const Map<String, IconData> accountIcons = {
    'account_balance': Icons.account_balance_outlined,
    'account_balance_wallet': Icons.account_balance_wallet_outlined,
    'wallet': Icons.wallet_outlined,
    'credit_card': Icons.credit_card_outlined,

    'payments': Icons.payments_outlined,
    'savings': Icons.savings_outlined,
    'currency_exchange': Icons.currency_exchange_outlined,
    'attach_money': Icons.attach_money_outlined
  };

  // get icon by String key
  static IconData getCategoryIconByName(String? nameKey) {
    return categoryIcons[nameKey] ?? Icons.help_outline;
  }

  // get account icon by String key
  static IconData getAccountIconByName(String? nameKey) {
    return accountIcons[nameKey] ?? Icons.help_outline;
  }

  // list all category icons keys
  static List<String> get categoriesKeys => categoryIcons.keys.toList();
  
  // list all accounts icon keys
  static List<String> get accountsKeys => accountIcons.keys.toList();
}