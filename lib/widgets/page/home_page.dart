import 'package:app_team1/manager/toast_manager.dart';
import 'package:app_team1/widgets/screen/favorite_screen.dart';
import 'package:app_team1/widgets/screen/home_screen.dart';
import 'package:app_team1/widgets/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../gen/assets.gen.dart';

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
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: _selectedIndex == 0
              ? Assets.images.homeIconFilled.image(width: 24, height: 24)
              : Assets.images.homeIconOutlined.image(width: 24, height: 24),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: _selectedIndex == 1
              ? Assets.images.myIconFilled.image(width: 24, height: 24)
              : Assets.images.myIconOutlined.image(width: 24, height: 24),
            label: 'MY ROOM',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.thirdaryColor,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
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
        child: const Icon(Icons.add, color: AppColors.buttonTextColor,),
      ),
    );
  }
}
