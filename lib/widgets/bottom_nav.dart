import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EmoBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const EmoBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: Colors.white,
      indicatorColor: AppTheme.primary.withOpacity(0.15),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded, color: AppTheme.primary),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.auto_stories_outlined),
          selectedIcon: Icon(Icons.auto_stories, color: AppTheme.primary),
          label: 'Learn',
        ),
        NavigationDestination(
          icon: Icon(Icons.videogame_asset_outlined),
          selectedIcon: Icon(Icons.videogame_asset, color: AppTheme.primary),
          label: 'Games',
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart_rounded, color: AppTheme.primary),
          label: 'Progress',
        ),
      ],
    );
  }
}
