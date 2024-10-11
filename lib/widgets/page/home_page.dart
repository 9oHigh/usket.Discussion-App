import 'package:app_team1/manager/toast_manager.dart';
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

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const FavoriteScreen(),
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
              // MARK: - context.go('/filter')
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final isCreated = await context.push('/create_room');
          if (isCreated == true && _selectedIndex == 0) {
            _onItemTapped(1);
          } else if (isCreated == true && _selectedIndex == 1) {
            setState(() {
              _onItemTapped(0);
            });
            await Future.delayed(const Duration(milliseconds: 500));
            _onItemTapped(1);
          } else {
            ToastManager().showToast(context, "방을 만들지 못했습니다.\n다시 시도해주세요.");
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
