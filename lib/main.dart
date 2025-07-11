import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'widgets/action_icon_button.dart';
import 'widgets/alert_card.dart';
import 'community_screen.dart';
import 'region_details_screen.dart';
import 'map_page.dart';
import 'guide_page.dart';

void main() {
  runApp(const ResQLinkApp());
}

class ResQLinkApp extends StatelessWidget {
  const ResQLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResQ Link',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: const Color(0xFF003366),
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 2,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const ResQLinkHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ResQLinkHomePage extends StatefulWidget {
  const ResQLinkHomePage({super.key});

  @override
  State<ResQLinkHomePage> createState() => _ResQLinkHomePageState();
}

class _ResQLinkHomePageState extends State<ResQLinkHomePage> {
  int _selectedIndex = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavKey = GlobalKey();

  void _onNavItemTapped(int index) {
    print('Tapped index: $index');
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    Widget bodyWidget;
    print('Building with _selectedIndex: $_selectedIndex');
    if (_selectedIndex == 1) {
      print('Building CommunityScreen');
      bodyWidget = CommunityScreen(key: const ValueKey('community'));
    } else if (_selectedIndex == 2) {
      print('Building MapPage');
      bodyWidget = MapPage(key: const ValueKey('map'));
    } else if (_selectedIndex == 3) {
      print('Building GuidePage');
      bodyWidget = GuidePage(key: const ValueKey('guide'));
    } else {
      print('Building HomePage');
      bodyWidget = SafeArea(key: const ValueKey('home'),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                const AlertCard(
                  backgroundColor: Color(0xFF003366), // Changed back to blue
                  icon: Icons.notifications_active_outlined,
                  text: "Heavy rain expected in 2 hours with no call",
                  iconColor: Colors.white,
                  textColor: Colors.white,
                ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2),
                const SizedBox(height: 12),
                const AlertCard(
                  backgroundColor: Color(0xFFFFE5B4),
                  icon: Icons.wb_sunny_outlined,
                  text: "Mostly sunny 72°",
                  iconColor: Color(0xFFCC8400),
                  textColor: Color(0xFFCC8400),
                ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: -0.2),
                const SizedBox(height: 28),
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: isSmallScreen ? 240 : 300, // Enlarged
                        maxHeight: isSmallScreen ? 240 : 300), // Enlarged
                    child: Material(
                      color: Colors.red,
                      shape: const CircleBorder(),
                      elevation: 8,
                      shadowColor: Colors.redAccent.withOpacity(0.6),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.all(36), // Enlarged padding
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.white,
                                size: 96, // Enlarged icon
                                semanticLabel: 'Warning triangle icon',
                              ),
                              const SizedBox(height: 18), // More space
                              Text(
                                'SOS',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium! // Larger text
                                    .copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                const SizedBox(height: 48), // Increased space above SOS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ActionIconButton(
                      backgroundColor: Colors.green,
                      icon: Icons.phone,
                      label: 'Phone',
                      onTap: () {},
                      iconSize: 40, // Increased icon size
                      avatarRadius: 36, // Increased avatar size
                    ),
                    ActionIconButton(
                      backgroundColor: Colors.blue,
                      icon: Icons.mic,
                      label: 'Voice',
                      onTap: () {},
                      iconSize: 40, // Increased icon size
                      avatarRadius: 36, // Increased avatar size
                    ),
                    ActionIconButton(
                      backgroundColor: Colors.grey,
                      icon: Icons.medical_services,
                      label: 'Medical',
                      onTap: () {},
                      iconSize: 40, // Increased icon size
                      avatarRadius: 36, // Increased avatar size
                    ),
                  ],
                ).animate().fadeIn(duration: 500.ms, delay: 400.ms).slideY(begin: 0.5),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('ResQ Link'),
        leading: null, // Removed the menu icon
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: bodyWidget,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.shifting,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: const Color(0xFF003366),
        showUnselectedLabels: true,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Color(0xFF003366),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Community',
            backgroundColor: Color(0xFF003366),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
            backgroundColor: Color(0xFF003366),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Guide',
            backgroundColor: Color(0xFF003366),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            backgroundColor: Color(0xFF003366),
          ),
        ],
      ),
    );
  }
}
