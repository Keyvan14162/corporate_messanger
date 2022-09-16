import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/widgets/friends/friends.dart';
import 'package:flutter_firebase_auth/widgets/groups/groups.dart';
import 'package:flutter_firebase_auth/widgets/settings/settings.dart';
import 'package:flutter_firebase_auth/constants.dart' as Constants;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  // User user; required this.user,
  // const AnaSayfa({Key? key}) : super(key: key);

  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // auth initialize
  late FirebaseAuth auth;
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: <Widget>[
            /*
            Container(
              color: Colors.red,
            ),
            */
            Groups(),
            Friends(),
            Settings(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavyBar(
        backgroundColor: Colors.white,
        itemCornerRadius: 50,
        curve: Curves.decelerate,
        selectedIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() => _currentIndex = index);
          _pageController.jumpToPage(index);
        },
        items: <BottomNavyBarItem>[
          /*
          BottomNavyBarItem(
            title: const Text('Personal chat'),
            icon: const Icon(Icons.chat_bubble),
          ),
          */
          BottomNavyBarItem(
            activeColor: Theme.of(context).primaryColor,
            inactiveColor: Theme.of(context).primaryColor,
            title: const Text(
              'Groups',
              style: TextStyle(color: Colors.black),
            ),
            icon: const Icon(Icons.chat),
          ),
          BottomNavyBarItem(
            activeColor: Theme.of(context).primaryColor,
            inactiveColor: Theme.of(context).primaryColor,
            title: const Text(
              'Friends',
              style: TextStyle(color: Colors.black),
            ),
            icon: const Icon(Icons.person),
          ),
          BottomNavyBarItem(
            activeColor: Theme.of(context).primaryColor,
            inactiveColor: Theme.of(context).primaryColor,
            title: const Text(
              'Settings',
              style: TextStyle(color: Colors.black),
            ),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
    );
  }
}
