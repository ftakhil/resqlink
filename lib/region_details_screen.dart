import 'package:flutter/material.dart';

class RegionDetailsScreen extends StatefulWidget {
  final String regionName;
  final int selectedIndex;
  final void Function(int)? onNavItemTapped;
  const RegionDetailsScreen({Key? key, required this.regionName, this.selectedIndex = 1, this.onNavItemTapped}) : super(key: key);

  @override
  State<RegionDetailsScreen> createState() => _RegionDetailsScreenState();
}

class _RegionDetailsScreenState extends State<RegionDetailsScreen> {
  bool isNeedHelp = true; // Default to Need Help mode
  final TextEditingController controller = TextEditingController();
  final List<Map<String, dynamic>> messages = [];

  void _sendMessage() {
    if (controller.text.trim().isNotEmpty) {
      setState(() {
        messages.add({
          'text': controller.text,
          'isNeedHelp': isNeedHelp,
          'timestamp': DateTime.now(),
        });
        controller.clear();
      });
    }
  }

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
        title: Text(widget.regionName),
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Align(
                  alignment: message['isNeedHelp'] ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: message['isNeedHelp'] 
                          ? Colors.red[100]
                          : Colors.green[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: message['isNeedHelp']
                            ? Colors.red[300]!
                            : Colors.green[300]!,
                      ),
                    ),
                    child: Text(
                      message['text'],
                      style: TextStyle(
                        color: message['isNeedHelp']
                            ? Colors.red[900]
                            : Colors.green[900],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.emergency_outlined, size: 16),
                      label: const Text('Need Help'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isNeedHelp ? Colors.red : Colors.grey[200],
                        foregroundColor: isNeedHelp ? Colors.white : Colors.grey[600],
                        elevation: isNeedHelp ? 2 : 0,
                      ),
                      onPressed: () => setState(() => isNeedHelp = true),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.volunteer_activism, size: 16),
                      label: const Text('Offer Help'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !isNeedHelp ? Colors.green : Colors.grey[200],
                        foregroundColor: !isNeedHelp ? Colors.white : Colors.grey[600],
                        elevation: !isNeedHelp ? 2 : 0,
                      ),
                      onPressed: () => setState(() => isNeedHelp = false),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: isNeedHelp ? 'Type your request...' : 'Type your offer...',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isNeedHelp ? Colors.red : Colors.green,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.onNavItemTapped != null ? BottomNavigationBar(
        currentIndex: widget.selectedIndex,
        onTap: widget.onNavItemTapped,
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