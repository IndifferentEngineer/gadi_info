# Vehicle Information Fetcher

This Flutter project allows users to fetch vehicle details by entering a vehicle number. The app makes use of the AITAN Labs API for fetching the vehicle information.

## Features

- **User Input**: Allows users to enter a vehicle number.
- **API Integration**: Fetches vehicle details from the AITAN Labs API.
- **Loading Indicator**: Displays a loading indicator while fetching data.
- **Error Handling**: Handles API errors, including rate limit exceedance.
- **Vehicle Details Display**: Displays fetched vehicle details in a list format.

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/IndifferentEngineer/vehicle-information-fetcher.git
   cd vehicle-information-fetcher
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

## Usage

1. **Enter Vehicle Number**: Enter the vehicle number in the input field.
2. **Fetch Details**: Press the 'OK' button to fetch the vehicle details.
3. **View Details**: The fetched details will be displayed below the input field.

## Code Overview

### Main Entry Point

```dart
void main() {
  runApp(MyApp());
}
```

### MyApp Widget

This is the root widget of the application.

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VehicleNumberScreen(),
    );
  }
}
```

### VehicleNumberScreen Widget

This widget contains the main functionality of the app.

```dart
class VehicleNumberScreen extends StatefulWidget {
  @override
  _VehicleNumberScreenState createState() => _VehicleNumberScreenState();
}

class _VehicleNumberScreenState extends State<VehicleNumberScreen> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic> _vehicleDetails = {};
  bool _loading = false;
  String _errorMessage = '';

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
        _errorMessage = 'An error occurred: ${response.statusCode}';
      }
    });
  }

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
```

## Dependencies

- `flutter/material.dart`
- `dart:convert`
- `package:http/http.dart` as `http`

## API Key

Replace `'your api key'` with your actual API key in the `_fetchVehicleDetails` method.

## GitHub Repository

For more details and to contribute, visit the [GitHub repository](https://github.com/IndifferentEngineer/vehicle-information-fetcher).

---

