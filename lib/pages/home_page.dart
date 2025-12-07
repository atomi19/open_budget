// main page of the app with Scaffold
// with bottomNavigationBar to switch between pages with content
 
import 'package:flutter/material.dart';
import 'package:open_budget/pages/add_transaction_page.dart';
import 'package:open_budget/pages/home_page_content.dart';
import 'package:open_budget/logic/database/database.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final db = TransactionsDatabase();
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> tabs =[
      HomePageContent(db: db),
      AddTransactionPage(db: db),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
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
        currentIndex: _currentTabIndex,
        onTap: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            activeIcon: Icon(Icons.add_circle),
            label: 'Add Transaction'
          ),
        ]
      ),
    );
  }
}