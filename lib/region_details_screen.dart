import 'package:flutter/material.dart';

class RegionDetailsScreen extends StatelessWidget {
  final String regionName;
  final int selectedIndex;
  final void Function(int)? onNavItemTapped;
  const RegionDetailsScreen({Key? key, required this.regionName, this.selectedIndex = 1, this.onNavItemTapped}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final contacts = [
      {'role': 'Relief Officer', 'name': 'Anil Kumar', 'number': '9876543210'},
      {'role': 'Medical Help', 'name': 'Dr. Priya', 'number': '9123456780'},
      {'role': 'Local Volunteer', 'name': 'Suresh', 'number': '9988776655'},
    ];
    final camps = [
      {'name': 'Camp Alpha', 'location': 'Govt. School, Main Road'},
      {'name': 'Camp Beta', 'location': 'Community Hall, Market Area'},
    ];
    final TextEditingController controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text(regionName),
        leading: BackButton(onPressed: () {
          Navigator.pop(context);
        }),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => DraggableScrollableSheet(
                  initialChildSize: 0.7,
                  minChildSize: 0.5,
                  maxChildSize: 0.95,
                  expand: false,
                  builder: (_, scrollController) => ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Text(
                        'If you are in this disaster area, please contact these numbers',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Text('Emergency Contacts', 
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.red, 
                          fontWeight: FontWeight.bold
                        )
                      ),
                      const SizedBox(height: 8),
                      ...contacts.map((c) => Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const Icon(Icons.phone, color: Colors.green),
                          title: Text('${c['role']}'),
                          subtitle: Text('${c['name']}'),
                          trailing: Text('${c['number']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      )),
                      const SizedBox(height: 24),
                      Text('Safe Camps', 
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.blue, 
                          fontWeight: FontWeight.bold
                        )
                      ),
                      const SizedBox(height: 8),
                      ...camps.map((camp) => Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const Icon(Icons.home, color: Colors.orange),
                          title: Text('${camp['name']}'),
                          subtitle: Text('${camp['location']}'),
                        ),
                      )),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Send a direct message', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    // TODO: Handle send message
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: onNavItemTapped != null ? BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onNavItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Guide'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ) : null,
    );
  }
} 