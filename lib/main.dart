import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'widgets/action_icon_button.dart';
import 'widgets/alert_card.dart';
import 'community_screen.dart';
import 'region_details_screen.dart';
import 'map_page.dart';
import 'guide_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'auth_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://axhllqkehjppzhjyjumg.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF4aGxscWtlaGpwcHpoanlqdW1nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIyMTgwMTQsImV4cCI6MjA2Nzc5NDAxNH0.F7debMomICZ6Nub20jdK8vtOwBBA3dOT7u707xaXMbw',
  );
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
      home: const AuthPage(),
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

    Future<void> _openMedicalCamAI() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        final url = Uri.parse('YOUR_API_ENDPOINT');
        final request = http.MultipartRequest('POST', url);
        request.files.add(await http.MultipartFile.fromPath('file', pickedFile.path));
        final response = await request.send();
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image sent successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send image. Status: ${response.statusCode}')),
          );
        }
      }
    }

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
                      icon: Icons.camera_alt,
                      label: 'MedicalCam AI',
                      onTap: _openMedicalCamAI,
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
        title: Image.asset(
          'assets/logo.png',
          height: 50,
        ),
        leading: null, // Removed the menu icon
      ),
      body: bodyWidget,
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavKey,
        index: _selectedIndex,
        height: 60.0,
        items: const <Widget>[
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.people, size: 30, color: Colors.white),
          Icon(Icons.map, size: 30, color: Colors.white),
          Icon(Icons.menu_book, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
        ],
        color: const Color(0xFF003366),
        buttonBackgroundColor: const Color(0xFF003366),
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        letIndexChange: (index) => true,
      ),
    );
  }
}
