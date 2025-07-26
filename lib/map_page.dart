import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class Weather {
  final double temp;
  final String condition;
  final String iconUrl;
  final double feelsLike;
  final double humidity;
  final double windSpeed;
  final String windDir;
  final double pressure;
  final double precipitation;
  final double visibility;
  final double uv;

  Weather({
    required this.temp,
    required this.condition,
    required this.iconUrl,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.windDir,
    required this.pressure,
    required this.precipitation,
    required this.visibility,
    required this.uv,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    return Weather(
      temp: current['temp_c'].toDouble(),
      condition: current['condition']['text'],
      iconUrl: 'https:${current['condition']['icon']}',
      feelsLike: current['feelslike_c'].toDouble(),
      humidity: current['humidity'].toDouble(),
      windSpeed: current['wind_kph'].toDouble(),
      windDir: current['wind_dir'],
      pressure: current['pressure_mb'].toDouble(),
      precipitation: current['precip_mm'].toDouble(),
      visibility: current['vis_km'].toDouble(),
      uv: current['uv'].toDouble(),
    );
  }
}

class SearchResult {
  final String name;
  final LatLng location;

  SearchResult({
    required this.name,
    required this.location,
  });
}

class Survivor {
  final String id;
  final LatLng location;
  final DateTime timestamp;
  final bool needsHelp;

  Survivor({
    required this.id,
    required this.location,
    required this.timestamp,
    required this.needsHelp,
  });

  factory Survivor.fromJson(Map<String, dynamic> json) {
    return Survivor(
      id: json['id'],
      location: LatLng(json['latitude'], json['longitude']),
      timestamp: DateTime.parse(json['created_at']),
      needsHelp: json['alert'] == 'yes',
    );
  }
}

class Camp {
  final String name;
  final String type;
  final LatLng location;
  final String status;
  final int capacity;

  Camp({
    required this.name,
    required this.type,
    required this.location,
    required this.status,
    required this.capacity,
  });
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  Position? _currentPosition;
  bool _loading = false;
  List<LatLng> _routePoints = [];
  Camp? _selectedCamp;
  String? _routeDistance;
  String? _routeDuration;
  bool _isCalculatingRoute = false;

  // State variables
  final TextEditingController _searchController = TextEditingController();
  List<SearchResult> _searchResults = [];
  bool _isSearching = false;
  Weather? _weather;
  bool _isWeatherExpanded = true;
  bool _isWeatherCompact = false;
  List<Survivor> _survivors = [];
  Timer? _survivorUpdateTimer;
  LatLng? _selectedSearchLocation;
  LatLng? _lastTappedLocation;
  String? _locationName;
  String? _stateName;
  String? _disasterRisk;
  String? _fullLocationName;

  Future<void> _getLocationDetails(LatLng point) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?format=json&lat=${point.latitude}&lon=${point.longitude}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'] ?? {};
        String? road = address['road'];
        String? village = address['village'] ??
            address['suburb'] ??
            address['town'] ??
            address['city'] ??
            address['locality'];
        String? state = address['state'];
        String? fullLoc;
        if (road != null && village != null && state != null) {
          fullLoc = '$road, $village, $state';
        } else if (village != null && state != null) {
          fullLoc = '$village, $state';
        } else if (state != null) {
          fullLoc = state;
        } else {
          fullLoc = data['display_name'] ?? 'Unknown Location';
        }
        setState(() {
          _locationName = data['name'] ??
              road ??
              village ??
              data['display_name']?.split(',')[0] ??
              'Unknown Location';
          _stateName = state ?? 'Unknown State';
          _fullLocationName = fullLoc;
          // Dummy logic for disaster risk based on location
          final random = point.latitude.abs() % 4;
          _disasterRisk = random < 1
              ? 'Low'
              : random < 2
                  ? 'Medium'
                  : random < 3
                      ? 'High'
                      : 'Very High';
        });
      }
    } catch (e) {
      print('Error getting location details: $e');
    }
  }

  void _onMapTapped(TapPosition tapPosition, LatLng point) {
    setState(() {
      _lastTappedLocation = point;
    });
    _getWeather(point);
    _getLocationDetails(point);
  }

  Future<void> _refreshMap() async {
    setState(() => _loading = true);
    await Future.wait([
      _getCurrentLocation(),
      _updateSurvivors(),
      if (_lastTappedLocation != null) _getWeather(_lastTappedLocation!),
    ]);
    setState(() => _loading = false);
  }

  // Kerala relief camps and emergency centers
  final List<Camp> camps = [
    Camp(
      name: 'Thiruvananthapuram Medical Camp',
      type: 'Medical',
      location: const LatLng(8.5241, 76.9366),
      status: 'Active',
      capacity: 500,
    ),
    Camp(
      name: 'Kochi Emergency Center',
      type: 'Emergency',
      location: const LatLng(9.9312, 76.2673),
      status: 'Active',
      capacity: 400,
    ),
    Camp(
      name: 'Kozhikode Relief Camp',
      type: 'Shelter',
      location: const LatLng(11.2588, 75.7804),
      status: 'Active',
      capacity: 300,
    ),
    Camp(
      name: 'Alappuzha Flood Relief',
      type: 'Shelter',
      location: const LatLng(9.4981, 76.3388),
      status: 'Active',
      capacity: 250,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _startSurvivorUpdates();
  }

  @override
  void dispose() {
    _survivorUpdateTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getWeather(LatLng location) async {
    try {
      final apiKey = dotenv.env['WEATHER_API_KEY'];
      if (apiKey == null) {
        _showSnackBar('Weather API key not found');
        return;
      }

      final response = await http.get(
        Uri.parse(
            'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=${location.latitude},${location.longitude}&aqi=no'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _weather = Weather.fromJson(data);
        });
      } else {
        print('Weather API error: ${response.statusCode} - ${response.body}');
        _showSnackBar('Unable to fetch weather information');
      }
    } catch (e) {
      print('Weather API error: $e');
      _showSnackBar('Error loading weather data');
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final response = await http.get(
        Uri.parse(
            'https://api.openrouteservice.org/geocode/search?api_key=${dotenv.env['OPENROUTE_API_KEY']}&text=$query'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List;

        setState(() {
          _searchResults = features.map((feature) {
            final coordinates = feature['geometry']['coordinates'] as List;
            return SearchResult(
              name: feature['properties']['label'],
              location: LatLng(coordinates[1], coordinates[0]),
            );
          }).toList();
        });
      }
    } catch (e) {
      print('Search API error: $e');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _selectSearchResult(SearchResult result) {
    setState(() {
      _selectedSearchLocation = result.location;
      _searchResults = [];
      _searchController.text = result.name;
    });

    _mapController.move(result.location, 15.0);
    _getWeather(result.location);
    _getLocationDetails(result.location);
    _getRoute(result.location);
  }

  Future<void> _startSurvivorUpdates() async {
    // Initial load
    await _updateSurvivors();

    // Set up periodic updates
    _survivorUpdateTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _updateSurvivors(),
    );
  }

  Future<void> _updateSurvivors() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('alerts')
          .select()
          .eq('alert', 'yes')
          .order('created_at', ascending: false)
          .limit(50);

      setState(() {
        _survivors =
            (response as List).map((data) => Survivor.fromJson(data)).toList();
      });
    } catch (e) {
      print('Supabase error: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _loading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('Location services are disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Location permissions are denied');
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _mapController.move(
          LatLng(position.latitude, position.longitude),
          15.0,
        );
      });
    } catch (e) {
      _showSnackBar('Error getting location: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _getRoute(LatLng destination) async {
    if (_currentPosition == null) {
      _showSnackBar('Current location not available');
      return;
    }

    setState(() => _isCalculatingRoute = true);
    final apiKey = dotenv.env['OPENROUTE_API_KEY'];

    if (apiKey == null) {
      _showSnackBar('API key not found');
      return;
    }

    final start = [_currentPosition!.longitude, _currentPosition!.latitude];
    final end = [destination.longitude, destination.latitude];

    final body = {
      "coordinates": [start, end],
      "instructions": true,
      "preference": 'driving-car', // Default to driving-car
      "units": "km",
      "language": "en"
    };

    try {
      final url = Uri.parse(
          'https://api.openrouteservice.org/v2/directions/driving-car');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(body),
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coordinates =
            data['routes'][0]['geometry']['coordinates'] as List;
        final summary = data['routes'][0]['summary'];

        final distance = summary['distance']; // in meters
        final duration = summary['duration']; // in seconds

        setState(() {
          _routePoints = coordinates
              .map((coord) => LatLng(coord[1] as double, coord[0] as double))
              .toList();

          // Format distance
          _routeDistance = distance > 1000
              ? '${(distance / 1000).toStringAsFixed(1)} km'
              : '${distance.toStringAsFixed(0)} m';

          // Format duration
          if (duration > 3600) {
            _routeDuration = '${(duration / 3600).toStringAsFixed(1)} hours';
          } else if (duration > 60) {
            _routeDuration = '${(duration / 60).toStringAsFixed(0)} minutes';
          } else {
            _routeDuration = '${duration.toStringAsFixed(0)} seconds';
          }

          // Center map to show entire route
          _fitRoute();
        });
      } else {
        print('Error Response: ${response.body}');
        _showSnackBar('Error calculating route: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception while calculating route: $e');
      _showSnackBar('Error: Unable to calculate route');
    } finally {
      setState(() => _isCalculatingRoute = false);
    }
  }

  void _fitRoute() {
    if (_routePoints.isEmpty) return;

    final bounds = LatLngBounds.fromPoints(_routePoints);
    _mapController.fitBounds(
      bounds,
      options: const FitBoundsOptions(padding: EdgeInsets.all(50.0)),
    );
  }

  void _selectCamp(Camp camp) {
    setState(() {
      _selectedCamp = camp;
      _getRoute(camp.location);
    });

    _mapController.move(camp.location, 15.0);
  }

  Widget _buildRouteInfo() {
    if (_routeDistance == null || _routeDuration == null)
      return const SizedBox.shrink();

    return Positioned(
      top: 16,
      left: 16,
      right: 80,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Distance: $_routeDistance',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Duration: $_routeDuration',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCampInfo() {
    if (_selectedCamp == null) return const SizedBox.shrink();

    return Positioned(
      top: _routeDistance != null ? 120 : 16,
      left: 16,
      right: 80,
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedCamp!.name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Type: ${_selectedCamp!.type}'),
              Text('Status: ${_selectedCamp!.status}'),
              Text('Capacity: ${_selectedCamp!.capacity}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search location...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchResults = []);
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) => _searchLocation(value),
            ),
          ),
          if (_searchResults.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final result = _searchResults[index];
                  return ListTile(
                    title: Text(result.name),
                    onTap: () => _selectSearchResult(result),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeatherInfo() {
    if (_weather == null) return const SizedBox.shrink();

    return Positioned(
      top: 80,
      right: 16,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isWeatherExpanded = !_isWeatherExpanded;
          });
        },
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white.withOpacity(0.85),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: 400,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row - always visible
                Row(
                  children: [
                    // Temperature and weather icon
                    Text(
                      '${_weather!.temp.round()}°C',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Image.network(
                      _weather!.iconUrl,
                      width: 28,
                      height: 28,
                    ),
                    const Text(
                      ' | ',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _weather!.condition,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Text(
                      ' | ',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _fullLocationName ??
                            _locationName ??
                            'Unknown Location',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      _isWeatherExpanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ],
                ),
                // Animated details section
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: _isWeatherExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      children: [
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildDetailItem(
                              'Feels like',
                              '${_weather!.feelsLike.round()}°C',
                            ),
                            _buildDetailItem(
                              'Humidity',
                              '${_weather!.humidity.round()}%',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildDetailItem(
                              'Wind',
                              '${_weather!.windSpeed.round()} km/h ${_weather!.windDir}',
                            ),
                            _buildDetailItem(
                              'UV Index',
                              _weather!.uv.round().toString(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildDetailItem(
                              'Visibility',
                              '${_weather!.visibility} km',
                            ),
                            _buildDetailItem(
                              'Pressure',
                              '${_weather!.pressure} mb',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: const LatLng(10.8505, 76.2711), // Kerala center
              zoom: 8.0,
              onTap: _onMapTapped,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  if (_currentPosition != null)
                    Marker(
                      width: 60,
                      height: 60,
                      point: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                  if (_lastTappedLocation != null)
                    Marker(
                      width: 30,
                      height: 30,
                      point: _lastTappedLocation!,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.orange,
                        size: 30,
                      ),
                    ),
                  ...camps.map(
                    (camp) => Marker(
                      width: 60,
                      height: 60,
                      point: camp.location,
                      child: GestureDetector(
                        onTap: () => _selectCamp(camp),
                        child: Icon(
                          Icons.local_hospital,
                          color:
                              _selectedCamp == camp ? Colors.blue : Colors.red,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  if (_selectedSearchLocation != null)
                    Marker(
                      width: 60,
                      height: 60,
                      point: _selectedSearchLocation!,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.green,
                        size: 40,
                      ),
                    ),
                ],
              ),
              // Survivor markers
              MarkerLayer(
                markers: _survivors
                    .map((survivor) => Marker(
                          width: 60,
                          height: 60,
                          point: survivor.location,
                          child: GestureDetector(
                            onTap: () {
                              _showSnackBar(
                                  'SOS Alert from ${survivor.timestamp.toString()}');
                              _getRoute(survivor.location);
                            },
                            child: const Icon(
                              Icons.emergency,
                              color: Colors.red,
                              size: 30,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 4,
                      color: Colors.blue,
                    ),
                  ],
                ),
            ],
          ),
          _buildSearchBar(),
          if (_weather != null) _buildWeatherInfo(),
          _buildRouteInfo(),
          _buildCampInfo(),
          if (_loading || _isCalculatingRoute || _isSearching)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _refreshMap,
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _getCurrentLocation,
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }
}
