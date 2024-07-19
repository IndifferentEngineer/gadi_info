import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VehicleNumberScreen(),
    );
  }
}

class VehicleNumberScreen extends StatefulWidget {
  @override
  _VehicleNumberScreenState createState() => _VehicleNumberScreenState();
}

class _VehicleNumberScreenState extends State<VehicleNumberScreen> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic> _vehicleDetails = {};
  bool _loading = false;
  String _errorMessage = '';

  // Function to fetch vehicle details from the API
  Future<void> _fetchVehicleDetails(String vehicleNumber) async {
    final url = Uri.parse("https://rto-vehicle-information-verification-india.p.rapidapi.com/api/v1/rc/vehicleinfo");
    final payload = jsonEncode({
      "reg_no": vehicleNumber,
      "consent": "Y",
      "consent_text": "I hear by declare my consent agreement for fetching my information via AITAN Labs API"
    });

    final headers = {
      'x-rapidapi-key': "your api key",
      'x-rapidapi-host': "rto-vehicle-information-verification-india.p.rapidapi.com",
      'Content-Type': "application/json"
    };

    setState(() {
      _loading = true;
      _errorMessage = '';
    });

    final response = await http.post(url, headers: headers, body: payload);

    setState(() {
      _loading = false;
      if (response.statusCode == 200) {
        _vehicleDetails = jsonDecode(response.body)['result'];
      } else if (response.statusCode == 429) {
        _vehicleDetails = {};
        _errorMessage = 'API limit exceeded. Please upgrade your plan.';
      } else {
        _vehicleDetails = {};
        _errorMessage = 'An error occurred: ${response.statusCode}'; //error handeling
      }
    });
  }

  // Method to handle button press
  void _handleOkPress() {
    final vehicleNumber = _controller.text;
    if (vehicleNumber.isNotEmpty) {
      _fetchVehicleDetails(vehicleNumber);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle Number Input'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter Vehicle Number',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleOkPress,
              child: Text('OK'),
            ),
            SizedBox(height: 20),
            _loading
                ? CircularProgressIndicator()
                : _errorMessage.isNotEmpty
                ? Text(_errorMessage, style: TextStyle(color: Colors.red))
                : _vehicleDetails.isNotEmpty
                ? Expanded(
              child: ListView(
                children: _vehicleDetails.entries
                    .map((entry) => ListTile(
                  title: Text(entry.key),
                  subtitle: Text(entry.value.toString()),
                ))
                    .toList(),
              ),
            )
                : Text('Enter a vehicle number to see details.'),
          ],
        ),
      ),
    );
  }
}
