// Add this to your HomePage class in main.dart

class _HomePageState extends State<HomePage> {
  bool _showNotification = false;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // Your existing content
          ListView(
            padding: const EdgeInsets.only(top: 100), // Add padding for weather widget
            children: [
              // Your existing ListView content
            ],
          ),
          
          // Weather widget at the top
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: WeatherWidget(
              initialPosition: _currentPosition,
              showInCard: false,
            ),
          ),

          // Notification below weather widget
          if (_showNotification)
            Positioned(
              top: 100, // Position below weather widget
              left: 16,
              right: 16,
              child: AlertCard(
                onDismiss: () {
                  setState(() {
                    _showNotification = false;
                  });
                },
              ),
            ),
        ],
      ),
      // Rest of your scaffold
    );
  }
}
