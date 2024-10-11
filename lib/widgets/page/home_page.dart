import 'package:app_team1/widgets/screen/favorite_screen.dart';
import 'package:app_team1/widgets/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    FavoriteScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? '방 목록' : '마이'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              context.push('/filter');
            },
            icon: const Icon(Icons.filter_alt),
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: '마이',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: _selectedIndex == 0 ? Colors.purple : Colors.red,
        onTap: _onItemTapped,
      ),
    );
  }
}
