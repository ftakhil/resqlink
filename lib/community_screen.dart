import 'package:flutter/material.dart';
import 'region_details_screen.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({Key? key}) : super(key: key);
  final List<String> regions = const [
    'Thiruvananthapuram',
    'Ernakulam',
    'Kollam',
    'Kottayam',
    'Alappuzha',
    'Thrissur',
    'Kozhikode',
    'Kannur',
    'Pathanamthitta',
    'Idukki',
    'Malappuram',
    'Palakkad',
    'Kasaragod',
    'Wayanad',
  ];

  @override
  Widget build(BuildContext context) {
    void onNavItemTapped(int index) {
      Navigator.pop(context); // Go back to region list
      // Optionally, you can use a callback to update the main navigation
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Connect'),
        leading: Navigator.canPop(context)
            ? BackButton()
            : null,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: regions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            child: ListTile(
              title: Text(
                regions[index],
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegionDetailsScreen(
                      regionName: regions[index],
                      selectedIndex: 1,
                      onNavItemTapped: onNavItemTapped,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
} 