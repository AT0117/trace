import 'package:flutter/material.dart';

import 'screens/command_center.dart';
import 'screens/investigation_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/temporal_explorer.dart';
import 'screens/decision_intelligence.dart';

import 'widgets/design_system.dart';

void main() {
  runApp(const TraceApp());
}

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

class TraceApp extends StatelessWidget {
  const TraceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Trace Engine',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          home: const MainNavigation(),
        );
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const CommandCenter(),
    const InvestigationScreen(),
    const TemporalExplorerScreen(),
    const AnalyticsScreen(),
    const DecisionIntelligenceScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            _buildSidebar(),
            const VerticalDivider(
              thickness: 1,
              width: 1,
              color: Colors.white10,
            ),
            Expanded(child: _screens[_currentIndex]),
          ],
        ),
      );
    }

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: const Border(
            top: BorderSide(color: Colors.white10, width: 0.5),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: const Color(0xFF0D1117),
          selectedItemColor: const Color(0xFF00E5FF),
          unselectedItemColor: Colors.white30,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Command',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Investigate',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_toggle_off),
              label: 'Time',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.psychology),
              label: 'Intel',
            ),
          ],
        ),
      ),
      floatingActionButton: _currentIndex != 1
          ? Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00E5FF), Color(0xFF7C4DFF)],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withOpacity(0.4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () => setState(() => _currentIndex = 1),
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: const Icon(Icons.auto_awesome, color: Colors.black),
              ),
            )
          : null,
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: const Color(0xFF0D1117),
      child: Column(
        children: [
          const SizedBox(height: 32),
          AppBar(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppTheme.primaryBlue, AppTheme.successGreen]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.blur_on, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Text(
                  'TRACE',
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(themeNotifier.value == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
                onPressed: () {
                  themeNotifier.value = themeNotifier.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 48),
          _sidebarItem(0, Icons.dashboard, 'Command Center'),
          _sidebarItem(1, Icons.search, 'Investigation'),
          _sidebarItem(2, Icons.history_toggle_off, 'Temporal Explorer'),
          _sidebarItem(3, Icons.bar_chart, 'Analytics'),
          _sidebarItem(4, Icons.psychology, 'Decision Intel'),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'Trace v2.0-beta',
              style: TextStyle(color: Colors.white24, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00E5FF).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF00E5FF) : Colors.white38,
              size: 22,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
