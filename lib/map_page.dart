import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? _userLocation;
  bool _locationPermissionDenied = false;
  List<LatLng> _routePoints = [];
  String _routeProfile = 'driving-car'; // 'driving-car' or 'foot-walking'

  // Example rescue camps (schools) in Thiruvananthapuram
  final List<Map<String, dynamic>> _rescueCamps = [
    {
      'name': 'Govt. Model Boys HSS',
      'position': LatLng(8.5074, 76.9722),
    },
    {
      'name': 'Cotton Hill Girls HSS',
      'position': LatLng(8.5171, 76.9566),
    },
    {
      'name': 'St. Mary’s HSS Pattom',
      'position': LatLng(8.5282, 76.9577),
    },
    {
      'name': 'SMV Govt. Model HSS',
      'position': LatLng(8.4922, 76.9568),
    },
  ];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _locationPermissionDenied = true);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _locationPermissionDenied = true);
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() => _locationPermissionDenied = true);
      return;
    }

    try {
      // Try to get the most accurate position
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _locationPermissionDenied = false;
      });
    } catch (e) {
      // Fallback to last known position if available
      final lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null) {
        setState(() {
          _userLocation = LatLng(lastPosition.latitude, lastPosition.longitude);
          _locationPermissionDenied = false;
        });
      }
    }
    _fetchRouteToNearestCamp();
  }

  LatLng _getInitialCenter() {
    // Center on Thiruvananthapuram if user location is not available
    return _userLocation ?? LatLng(8.5241, 76.9366);
  }

  Map<String, dynamic>? _getNearestRescueCamp() {
    if (_userLocation == null) return null;
    final Distance distance = const Distance();
    Map<String, dynamic>? nearest;
    double minDist = double.infinity;
    for (var camp in _rescueCamps) {
      final d = distance(_userLocation!, camp['position'] as LatLng);
      if (d < minDist) {
        minDist = d;
        nearest = camp;
      }
    }
    return nearest;
  }

  Future<void> _fetchRouteToNearestCamp() async {
    final nearest = _getNearestRescueCamp();
    if (_userLocation == null || nearest == null) return;
    final start = _userLocation!;
    final end = nearest['position'] as LatLng;
    final apiKey = 'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6IjBhMjc5MDY2ZmI5OTQ1ODJiN2NmMmJhYTQ4YzRlMjBjIiwiaCI6Im11cm11cjY0In0=';
    final url = Uri.parse(
      'https://api.openrouteservice.org/v2/directions/$_routeProfile?api_key=$apiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final geometry = data['features'][0]['geometry'];
        if (geometry['type'] == 'LineString') {
          final coords = geometry['coordinates'] as List;
          setState(() {
            _routePoints = coords
                .map<LatLng>((c) => LatLng(c[1].toDouble(), c[0].toDouble()))
                .toList();
          });
        }
      }
    } catch (e) {
      // ignore errors for demo
    }
  }

  @override
  Widget build(BuildContext context) {
    final nearestCamp = _getNearestRescueCamp();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thiruvananthapuram Rescue Map'),
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
      ),
      body: _locationPermissionDenied
          ? Center(
              child: Text(
                'Location permission denied. Please enable location to use the map.',
                style: TextStyle(color: Colors.red[800]),
                textAlign: TextAlign.center,
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Text('Route:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      DropdownButton<String>(
                        value: _routeProfile,
                        items: const [
                          DropdownMenuItem(value: 'driving-car', child: Text('Car')),
                          DropdownMenuItem(value: 'foot-walking', child: Text('Foot-walking')),
                        ],
                        onChanged: (value) async {
                          if (value != null) {
                            setState(() {
                              _routeProfile = value;
                            });
                            await _fetchRouteToNearestCamp();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FlutterMap(
                    options: MapOptions(
                      center: _getInitialCenter(),
                      zoom: 13.0,
                      maxZoom: 18,
                      minZoom: 10,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                        userAgentPackageName: 'com.example.resq_link',
                      ),
                      MarkerLayer(
                        markers: [
                          if (_userLocation != null)
                            Marker(
                              point: _userLocation!,
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.my_location, color: Colors.blue, size: 36),
                            ),
                          ..._rescueCamps.map((camp) => Marker(
                                point: camp['position'] as LatLng,
                                width: 40,
                                height: 40,
                                child: Column(
                                  children: [
                                    const Icon(Icons.school, color: Colors.red, size: 32),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        camp['name'],
                                        style: const TextStyle(fontSize: 10, color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                      if (_routePoints.isNotEmpty)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: _routePoints,
                              color: Colors.blue,
                              strokeWidth: 4,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
} 