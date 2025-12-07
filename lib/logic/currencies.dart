class Currency {
  final String code;
  final String symbol;
  final String name;

  Currency({
    required this.code,
    required this.symbol,
    required this.name,
  });

  static final List<Currency> currencies = [
    // north america
    Currency(
      code: 'USD', 
      symbol: '\$', 
      name: 'United States dollar',
    ),
    Currency(
      code: 'CAD', 
      symbol: 'CA\$', 
      name: 'Canadian dollar'
    ),
    Currency(
      code: 'MXN', 
      symbol: 'MX\$', 
      name: 'Mexican peso'
    ),
    // south america 
    Currency(
      code: 'BRL', 
      symbol: 'R\$',
      name: 'Brazilian real'
    ),  
    Currency(
      code: 'ARS', 
      symbol: '\$',
      name: 'Argentine peso'
    ),
    // europe
    Currency(
      code: 'EUR', 
      symbol: '€', 
      name: 'Euro'
    ),
    Currency(
      code: 'GBP', 
      symbol: '£', 
      name: 'Pound sterling'
    ),
    Currency(
      code: 'CHF', 
      symbol: 'CHF', 
      name: 'Swiss franc'
    ),
    Currency(
      code: 'SEK', 
      symbol: 'kr', 
      name: 'Swedish krona'
    ),
    Currency(
      code: 'NOK', 
      symbol: 'kr', 
      name: 'Norwegian krone'
    ),
    Currency(
      code: 'DKK', 
      symbol: 'kr', 
      name: 'Danish krone'
    ),
    Currency(
      code: 'PLN', 
      symbol: 'zł', 
      name: 'Polish złoty'
    ),
    Currency(
      code: 'CZK', 
      symbol: 'Kč', 
      name: 'Czech koruna'
    ),
    Currency(
      code: 'HUF', 
      symbol: 'Ft', 
      name: 'Hungarian forint'
    ),
    Currency(
      code: 'RON', 
      symbol: 'lei', 
      name: 'Romanian leu'
    ),
    Currency(
      code: 'UAH', 
      symbol: '₴', 
      name: 'Ukrainian hryvnia'
    ),
    Currency(
      code: 'GEL', 
      symbol: '₾', 
      name: 'Georgian lari'
    ),
    // middle east
    Currency(
      code: 'AED', 
      symbol: 'AED', 
      name: 'United Arab Emirates dirham'
    ),
    Currency(
      code: 'TRY', 
      symbol: '₺', 
      name: 'Turkish lira'
    ),
    Currency(
      code: 'ILS', 
      symbol: '₪', 
      name: 'Israeli new shekel'
    ),
    // asia pacific
    Currency(
      code: 'JPY', 
      symbol: '¥', 
      name: 'Japanese yen'
    ),
    Currency(
      code: 'KRW', 
      symbol: '₩', 
      name: 'South Korean won'
    ),
    Currency(
      code: 'AUD', 
      symbol: 'AU\$', 
      name: 'Australian dollar'
    ),
    Currency(
      code: 'NZD', 
      symbol: 'NZ\$', 
      name: 'New Zealand dollar'
    ),
  ];
}