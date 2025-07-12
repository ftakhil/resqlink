import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../user_session.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = '';
  String phone = '';
  String email = '';
  String location = 'Unknown';
  String? avatarUrl;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final supabase = Supabase.instance.client;
    final userEmail = UserSession.email;
    if (userEmail == null) {
      setState(() {
        name = UserSession.name ?? '';
        phone = UserSession.phone ?? '';
        email = '';
        loading = false;
      });
      return;
    }
    final response = await supabase
        .from('users')
        .select()
        .eq('email', userEmail)
        .maybeSingle();
    if (response != null) {
      setState(() {
        name = response['name'] ?? UserSession.name ?? '';
        phone = response['phone'] ?? UserSession.phone ?? '';
        email = response['email'] ?? userEmail;
        loading = false;
      });
    } else {
      setState(() {
        name = UserSession.name ?? '';
        phone = UserSession.phone ?? '';
        email = userEmail;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('You'),
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 56,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                        child: avatarUrl == null
                            ? const Icon(Icons.person, size: 64, color: Colors.white70)
                            : null,
                      ).animate().fadeIn(duration: 600.ms).scale(),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(Icons.add_circle, color: Colors.blue[700], size: 32),
                        ).animate().fadeIn(duration: 600.ms, delay: 200.ms).scale(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name.isNotEmpty ? name : 'Your Name',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ).animate().fadeIn(duration: 600.ms, delay: 100.ms).slideY(begin: 0.2),
                  const SizedBox(height: 24),
                  _profileField('Phone:', phone),
                  const SizedBox(height: 12),
                  _profileField('Gmail:', email),
                  const SizedBox(height: 12),
                  _profileField('Location:', location),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Home', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF003366),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Edit', style: TextStyle(color: Colors.white)),
                      ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideX(begin: 0.2),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _profileField(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : '---',
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ).animate().fadeIn(duration: 600.ms, delay: 100.ms).slideX(begin: -0.1),
        ),
      ],
    );
  }
} 