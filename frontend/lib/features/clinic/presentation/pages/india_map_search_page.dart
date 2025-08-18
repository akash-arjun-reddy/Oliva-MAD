import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IndiaMapSearchPage extends StatefulWidget {
  final String? initialQuery;
  const IndiaMapSearchPage({Key? key, this.initialQuery}) : super(key: key);

  @override
  State<IndiaMapSearchPage> createState() => _IndiaMapSearchPageState();
}

class _IndiaMapSearchPageState extends State<IndiaMapSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  LatLng _mapCenter = LatLng(22.5937, 78.9629); // Center of India
  LatLng? _searchedLocation;

  // Static list of Oliva Skin and Hair Clinic locations
  final List<Map<String, dynamic>> _olivaClinics = [
    { 'name': 'Oliva Clinic Banjara Hills, Hyderabad', 'lat': 17.4239, 'lon': 78.4398 },
    { 'name': 'Oliva Clinic Secunderabad, Hyderabad', 'lat': 17.4399, 'lon': 78.4983 },
    { 'name': 'Oliva Clinic Kukatpally, Hyderabad', 'lat': 17.4948, 'lon': 78.3996 },
    { 'name': 'Oliva Clinic Gachibowli, Hyderabad', 'lat': 17.4445, 'lon': 78.3524 },
    { 'name': 'Oliva Clinic Himayat Nagar, Hyderabad', 'lat': 17.3986, 'lon': 78.4857 },
    { 'name': 'Oliva Clinic Kothapet, Hyderabad', 'lat': 17.3660, 'lon': 78.5426 },
    { 'name': 'Oliva Clinic Dilsukhnagar, Hyderabad', 'lat': 17.3686, 'lon': 78.5247 },
    { 'name': 'Oliva Clinic HSR Layout, Bangalore', 'lat': 12.9116, 'lon': 77.6412 },
    { 'name': 'Oliva Clinic Indiranagar, Bangalore', 'lat': 12.9716, 'lon': 77.6408 },
    { 'name': 'Oliva Clinic Jayanagar, Bangalore', 'lat': 12.9250, 'lon': 77.5938 },
    { 'name': 'Oliva Clinic Koramangala, Bangalore', 'lat': 12.9352, 'lon': 77.6245 },
    { 'name': 'Oliva Clinic Sadashivanagar, Bangalore', 'lat': 13.0096, 'lon': 77.5696 },
    { 'name': 'Oliva Clinic Whitefield, Bangalore', 'lat': 12.9698, 'lon': 77.7499 },
    { 'name': 'Oliva Clinic Anna Nagar, Chennai', 'lat': 13.0878, 'lon': 80.2170 },
    { 'name': 'Oliva Clinic Adyar, Chennai', 'lat': 13.0067, 'lon': 80.2570 },
    { 'name': 'Oliva Clinic Velachery, Chennai', 'lat': 12.9792, 'lon': 80.2214 },
    { 'name': 'Oliva Clinic T Nagar, Chennai', 'lat': 13.0418, 'lon': 80.2337 },
    { 'name': 'Oliva Clinic Gachibowli, Hyderabad', 'lat': 17.4445, 'lon': 78.3524 },
    { 'name': 'Oliva Clinic Jubilee Hills, Hyderabad', 'lat': 17.4301, 'lon': 78.4070 },
    { 'name': 'Oliva Clinic Begumpet, Hyderabad', 'lat': 17.4440, 'lon': 78.4600 },
    { 'name': 'Oliva Clinic Kondapur, Hyderabad', 'lat': 17.4697, 'lon': 78.3570 },
    { 'name': 'Oliva Clinic Somajiguda, Hyderabad', 'lat': 17.4260, 'lon': 78.4597 },
    { 'name': 'Oliva Clinic Manikonda, Hyderabad', 'lat': 17.4065, 'lon': 78.3827 },
    { 'name': 'Oliva Clinic Miyapur, Hyderabad', 'lat': 17.5000, 'lon': 78.3915 },
    { 'name': 'Oliva Clinic KPHB, Hyderabad', 'lat': 17.4932, 'lon': 78.3996 },
    { 'name': 'Oliva Clinic Kondapur, Hyderabad', 'lat': 17.4697, 'lon': 78.3570 },
    { 'name': 'Oliva Clinic Madhapur, Hyderabad', 'lat': 17.4486, 'lon': 78.3907 },
    { 'name': 'Oliva Clinic Ameerpet, Hyderabad', 'lat': 17.4375, 'lon': 78.4483 },
    { 'name': 'Oliva Clinic Panjagutta, Hyderabad', 'lat': 17.4270, 'lon': 78.4486 },
    { 'name': 'Oliva Clinic Somajiguda, Hyderabad', 'lat': 17.4260, 'lon': 78.4597 },
    { 'name': 'Oliva Clinic Kondapur, Hyderabad', 'lat': 17.4697, 'lon': 78.3570 },
    { 'name': 'Oliva Clinic Gachibowli, Hyderabad', 'lat': 17.4445, 'lon': 78.3524 },
    { 'name': 'Oliva Clinic Kukatpally, Hyderabad', 'lat': 17.4948, 'lon': 78.3996 },
    { 'name': 'Oliva Clinic Himayat Nagar, Hyderabad', 'lat': 17.3986, 'lon': 78.4857 },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      WidgetsBinding.instance.addPostFrameCallback((_) => _searchLocation());
    }
  }

  Future<void> _searchLocation() async {
    final query = _searchController.text;
    if (query.isEmpty) return;

    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query,India&format=json&limit=1');
    final response = await http.get(url, headers: {
      'User-Agent': 'FlutterApp'
    });

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        setState(() {
          _searchedLocation = LatLng(lat, lon);
          _mapCenter = LatLng(lat, lon);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location not found')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('India Map Search')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Search box
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search location',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchLocation,
                ),
              ),
              onSubmitted: (_) => _searchLocation(),
            ),
            SizedBox(height: 8),
            // Map
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  center: _mapCenter,
                  zoom: 5.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                  ),
                  if (_searchedLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 40.0,
                          height: 40.0,
                          point: _searchedLocation!,
                          child: Icon(
                            Icons.location_on,
                            color: Colors.blue,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 