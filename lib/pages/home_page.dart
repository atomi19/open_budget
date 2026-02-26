// main page of the app with Scaffold
// with bottomNavigationBar to switch between pages with content
 
import 'package:flutter/material.dart';
import 'package:open_budget/pages/add_transaction_page.dart';
import 'package:open_budget/pages/home_page_content.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/pages/statistics_page.dart';

class HomePage extends StatefulWidget {
  final Function(ThemeMode) setTheme;

  const HomePage({
    super.key,
    required this.setTheme
  });
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final db = AppDatabase();
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> tabs =[
      HomePageContent(
        db: db,
        setTheme: widget.setTheme,
      ),
      AddTransactionPage(db: db),
      StatisticsPage(db: db),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      // body
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: IndexedStack(
            index: _currentTabIndex,
            children: tabs,
          ),
        )
      ),
      // bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        selectedItemColor: Theme.of(context).colorScheme.onPrimary,
        unselectedItemColor: Theme.of(context).colorScheme.onPrimary,
        currentIndex: _currentTabIndex,
        onTap: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, color: Theme.of(context).colorScheme.tertiary,),
            activeIcon: const Icon(Icons.home,),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add, color: Theme.of(context).colorScheme.tertiary,),
            activeIcon: const Icon(Icons.add_circle),
            label: 'Add Transaction',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.data_usage, color: Theme.of(context).colorScheme.tertiary,),
            activeIcon: const Icon(Icons.data_usage_outlined),
            label: 'Statistics',
          ),
        ]
      ),
    );
  }
}