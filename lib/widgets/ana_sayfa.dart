import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/chat/chat_room.dart';
import 'package:flutter_firebase_auth/widgets/tum_kullanicilar.dart';

import 'ayarlar/ayarlar.dart';

class AnaSayfa extends StatefulWidget {
  // User user; required this.user,
  AnaSayfa({Key? key}) : super(key: key);

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  // auth initialize
  late FirebaseAuth auth;
  late PageController _pageController;
  int _currentIndex = 0;

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
            Container(
              color: Colors.red,
            ),
            ChatRoom(),
            TumKullanicilar(),
            Ayarlar(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() => _currentIndex = index);
          _pageController.jumpToPage(index);
        },
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
            title: const Text('Personal chat'),
            icon: const Icon(Icons.chat_bubble),
          ),
          BottomNavyBarItem(
            title: const Text('Chat Room'),
            icon: const Icon(Icons.chat),
          ),
          BottomNavyBarItem(
            title: const Text('Friends'),
            icon: const Icon(Icons.person),
          ),
          BottomNavyBarItem(
            title: const Text('Settings'),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
    );
  }
}
