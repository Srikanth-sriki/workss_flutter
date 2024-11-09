import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

const String apiKey = "LAsrzl2ESmfvpp4F9II8HBmU3lDekPTEb76reivs";

final uuid = Uuid();

Future<Map<String, String>> getAddress(double lat, double lng) async {
  final latlng = "$lat,$lng";
  final requestId = uuid.v4();
  final correlationId = uuid.v4();

  try {
    final response = await http.get(
      Uri.parse(
          'https://api.olamaps.io/places/v1/reverse-geocode?latlng=$latlng&api_key=$apiKey'),
      headers: {
        'X-Request-Id': requestId,
        'X-Correlation-Id': correlationId,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Parse the response
      final data = json.decode(response.body);
      print('Full Response: $data');

      final formattedAddress =
          data['results'][0]['formatted_address'] ?? 'Address not found';
      print('Formatted Address: $formattedAddress');

      final RegExp pincodeRegex = RegExp(r'\b\d{6}\b');
      final pincodeMatch = pincodeRegex.firstMatch(formattedAddress);
      final pincode = pincodeMatch?.group(0) ?? '';
      print('Extracted Pincode: $pincode');

      return {'address': formattedAddress, 'pincode': pincode};
    } else {
      print('Failed to fetch address: ${response.statusCode}');
      return {'address': 'Address not found', 'pincode': ''};
    }
  } catch (error) {
    print('Error fetching address: $error');
    return {'address': 'Error', 'pincode': ''};
  }
}


Future<Map<String, double>> getLatLngFromPinCode(String pincode) async {
  final uuid = Uuid();
  final requestId = uuid.v4();
  final correlationId = uuid.v4();


  try {
    final response = await http.get(
      Uri.parse(
        'https://api.olamaps.io/places/v1/geocode?address=$pincode&api_key=$apiKey', // Adjust the URL for forward geocoding if available
      ),
      headers: {
        'X-Request-Id': requestId,
        'X-Correlation-Id': correlationId,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Full Response: $data');

      if (data['geocodingResults'].isNotEmpty) {
        final location = data['geocodingResults'][0]['geometry']['location'];
        final lat = location['lat'];
        final lng = location['lng'];
        print('Latitude: $lat, Longitude: $lng');

        return {'lat': lat, 'lng': lng};
      } else {
        print('No geocoding results found');
        return {'lat': 0.0, 'lng': 0.0};
      }
    } else {
      print('Failed to fetch coordinates: ${response.statusCode}');
      return {'lat': 0.0, 'lng': 0.0};
    }
  } catch (error) {
    print('Error fetching coordinates: $error');
    return {'lat': 0.0, 'lng': 0.0};
  }
}
