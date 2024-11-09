// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'package:uuid/uuid.dart';
// import 'package:works_app/dao/get_user_location.dart';
//
// class AddressScreen extends StatefulWidget {
//   @override
//   _AddressScreenState createState() => _AddressScreenState();
// }
//
// class _AddressScreenState extends State<AddressScreen> {
//   GoogleMapController? _mapController;
//   TextEditingController _searchController = TextEditingController();
//   final uuid = Uuid();
//
//   // Default location
//   LatLng _initialPosition = LatLng(12.9716, 77.5946);
//   String currentAddress = "Searching address...";
//
//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }
//
//   Future<void> _getCurrentLocation() async {
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//     _mapController?.animateCamera(CameraUpdate.newLatLng(
//       LatLng(position.latitude, position.longitude),
//     ));
//     _updateAddress(position.latitude, position.longitude);
//   }
//
//   Future<void> _updateAddress(double lat, double lng) async {
//     final addressData = await getAddress(lat, lng);
//     setState(() {
//       currentAddress = addressData['address']!;
//     });
//   }
//
//   // Future<List<String>> _getSuggestions(String query) async {
//   //   final requestId = uuid.v4();
//   //   final correlationId = uuid.v4();
//   //
//   //   final response = await http.get(
//   //     Uri.parse('https://api.olamaps.io/places/v1/textsearch?input=Cafes%20in%20Koramangala&location=12.93142%2C77.61645&radius=5000&types=cafe&size=5'),
//   //     headers: {
//   //       'X-Request-Id': requestId,
//   //       'X-Correlation-Id': correlationId,
//   //       'Content-Type': 'application/json',
//   //     },
//   //   );
//   //   print(response);
//   //
//   //   if (response.statusCode == 200) {
//   //     final data = json.decode(response.body);
//   //     print(data);
//   //     return (data['predictions'] as List)
//   //         .map((item) => item['formatted_address'] as String)
//   //         .toList();
//   //   } else {
//   //     return [];
//   //   }
//   // }
//   Future<List<String>> _getSuggestions(String query) async {
//     final requestId = uuid.v4();
//     final correlationId = uuid.v4();
//
//     // final response = await http.get(
//     //   Uri.parse('https://api.olamaps.io/places/v1/textsearch?input=Koramangala&location=12.93142%2C77.61645&radius=5000&types=cafe&size=5&api_key=$apiKey'),
//     //   headers: {
//     //     'X-Request-Id': requestId,
//     //     'X-Correlation-Id': correlationId,
//     //     'Content-Type': 'application/json',
//     //   },
//     // );
//     final response = await http.get(
//       Uri.parse(
//           'https://api.olamaps.io/places/v1/textsearch?input=$query&api_key=$apiKey'),
//       headers: {
//         'X-Request-Id': requestId,
//         'X-Correlation-Id': correlationId,
//         'Content-Type': 'application/json',
//       },
//     );
//
//     print('Response status: ${response.statusCode}');
//     print('Response body: ${response.body}');
//
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       return (data['predictions'] as List)
//           .map((item) => item['formatted_address'] as String)
//           .toList();
//     } else {
//       print('Error: ${response.body}');
//       return [];
//     }
//   }
//
//   Future<Map<String, String>> getAddress(double lat, double lng) async {
//     final latlng = "$lat,$lng";
//     final requestId = Uuid().v4();
//     final correlationId = Uuid().v4();
//
//     try {
//       final response = await http.get(
//         Uri.parse(
//             'https://api.olamaps.io/places/v1/reverse-geocode?latlng=$latlng&api_key=$apiKey'),
//         headers: {
//           'X-Request-Id': requestId,
//           'X-Correlation-Id': correlationId,
//           'Content-Type': 'application/json',
//         },
//       );
//
//       print('Address Response status: ${response.statusCode}');
//       print('Address Response body: ${response.body}');
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final formattedAddress =
//             data['results'][0]['formatted_address'] ?? 'Address not found';
//         return {'address': formattedAddress};
//       } else {
//         print('Address Error: ${response.body}');
//         return {'address': 'Address not found'};
//       }
//     } catch (error) {
//       print('Address Exception: $error');
//       return {'address': 'Error fetching address'};
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           CustomScrollView(
//             slivers: [
//               SliverAppBar(
//                 expandedHeight: MediaQuery.of(context).size.height * 0.6,
//                 floating: false,
//                 pinned: true,
//                 flexibleSpace: FlexibleSpaceBar(
//                   background: GoogleMap(
//                     gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
//                       Factory<OneSequenceGestureRecognizer>(
//                               () => EagerGestureRecognizer()),
//                     },
//                     initialCameraPosition: CameraPosition(
//                       target: _initialPosition,
//                       zoom: 14,
//                     ),
//                     onMapCreated: (controller) {
//                       _mapController = controller;
//                     },
//                   ),
//                 ),
//               ),
//               SliverList(
//                 delegate: SliverChildListDelegate(
//                   [
//                     Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           TextField(
//                             controller: _searchController,
//                             decoration: InputDecoration(
//                               labelText: "Search Address",
//                               border: OutlineInputBorder(),
//                             ),
//                             onChanged: (value) async {
//                               final suggestions = await _getSuggestions(value);
//                               if (suggestions.isEmpty) {
//                                 print('No suggestions found for "$value"');
//                                 // Display a message in the UI
//                               } else {
//                                 print(suggestions);
//                               }
//                             },
//                           ),
//                           SizedBox(height: 16),
//                           Text("Current Address: $currentAddress"),
//                           // Add your address fields and other UI components here
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           Positioned(
//             right: 16,
//             bottom: 16,
//             child: FloatingActionButton(
//               onPressed: _getCurrentLocation,
//               child: Icon(Icons.my_location),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// Future<Map<String, String>> getAddress(double lat, double lng) async {
//   final latlng = "$lat,$lng";
//   final requestId = Uuid().v4();
//   final correlationId = Uuid().v4();
//
//   try {
//     final response = await http.get(
//       Uri.parse(
//           'https://api.olamaps.io/places/v1/reverse-geocode?latlng=$latlng&api_key=$apiKey'),
//       headers: {
//         'X-Request-Id': requestId,
//         'X-Correlation-Id': correlationId,
//         'Content-Type': 'application/json',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       final formattedAddress =
//           data['results'][0]['formatted_address'] ?? 'Address not found';
//       return {'address': formattedAddress};
//     } else {
//       return {'address': 'Address not found'};
//     }
//   } catch (error) {
//     return {'address': 'Error fetching address'};
//   }
// }

// import 'package:flutter/foundation.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// class AddressScreen extends StatefulWidget {
//   @override
//   _AddressScreenState createState() => _AddressScreenState();
// }
//
// class _AddressScreenState extends State<AddressScreen> {
//   GoogleMapController? _mapController;
//
//   // Default location
//   LatLng _initialPosition = LatLng(12.9716, 77.5946);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: CustomScrollView(
//         slivers: [
//           // SliverAppBar with a flexible map background
//           SliverAppBar(
//             expandedHeight: MediaQuery.of(context).size.height * 0.7,
//             floating: false,
//             pinned: true,
//             flexibleSpace: FlexibleSpaceBar(
//               background: GoogleMap(
//                 gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
//                   Factory<OneSequenceGestureRecognizer>(
//                           () => EagerGestureRecognizer()),
//                 },
//
//                 initialCameraPosition: CameraPosition(
//                   target: _initialPosition,
//                   zoom: 14,
//                 ),
//                 onMapCreated: (GoogleMapController controller) {
//                   _mapController = controller;
//                 },
//               ),
//             ),
//           ),
//
//           // SliverList with scrollable form fields
//           SliverList(
//             delegate: SliverChildListDelegate(
//               [
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Address Type Buttons
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           ChoiceChip(
//                             label: Text("Home"),
//                             selected: true,
//                           ),
//                           ChoiceChip(
//                             label: Text("Office"),
//                             selected: false,
//                           ),
//                           ChoiceChip(
//                             label: Text("Other"),
//                             selected: false,
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//
//                       // Address Fields
//                       TextField(
//                         decoration: InputDecoration(
//                           labelText: "House/Flat/Block No",
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       TextField(
//                         decoration: InputDecoration(
//                           labelText: "Apartment/Road/Area",
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       TextField(
//                         maxLines: 3,
//                         decoration: InputDecoration(
//                           labelText: "Instructions",
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//
//                       // Checkbox for Default Address
//                       Row(
//                         children: [
//                           Checkbox(value: false, onChanged: (value) {}),
//                           Text("Save it as a default address"),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//
//                       // Save Button
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: () {
//                             // Action on Save button press
//                           },
//                           style: ElevatedButton.styleFrom(
//                             padding: EdgeInsets.symmetric(vertical: 16),
//                           ),
//                           child: Text("SAVE"),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
