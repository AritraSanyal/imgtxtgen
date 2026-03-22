import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'profile_screen.dart';
import 'create_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

final _navIndexProvider = StateProvider<int>((_) => 0);

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  static const _screens = [
    ProfileScreen(),
    CreateScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  static const _items = [
    BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
    BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: 'Create'),
    BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
    BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx = ref.watch(_navIndexProvider);
    return Scaffold(
      body: IndexedStack(index: idx, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx,
        onTap: (i) => ref.read(_navIndexProvider.notifier).state = i,
        selectedItemColor: const Color(0xFF6C63FF),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: _items,
      ),
    );
  }
}
