import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WeatherApp(),
      debugShowCheckedModeBanner: false,
    );
  }
}
class WeatherApp extends StatefulWidget {
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  TextEditingController _cityController = TextEditingController();
  String _cityName = 'Islamabad';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.sizeOf(context).height,
          width: MediaQuery.sizeOf(context).width,
          decoration: const BoxDecoration(
            image: DecorationImage(
            image: AssetImage('assets/sky.jpg'),
            fit: BoxFit.cover,
          ),),
          child: Center(
            child: Column(
              children: [
                _buildSearchBar(),
                Text(_cityName+" current weather",
                style: TextStyle(
                  fontSize: 20
                ),),
                FutureBuilder(
                  future: fetchWeatherData(_cityName),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      // Access the weather data from snapshot.data
                      final weatherData = snapshot.data;
                      double temperatureInFahrenheit = weatherData?["main"]["temp"];
                      double temperatureInCelsius =
                          (temperatureInFahrenheit - 32) * 5 / 9;

                      // Get the main weather icon
                      String mainIconCode = weatherData?["weather"][0]["icon"];
                      String mainIconUrl = "http://openweathermap.org/img/w/$mainIconCode.png";

                      return Column(
                        children: [
                          Container(
                            width: 100, // Set the desired width
                            height: 100, // Set the desired height
                            child: Image.network(mainIconUrl),
                          ),
                          _buildWeatherProperty('Temperature', '${temperatureInCelsius.toStringAsFixed(2)}°C', Icons.thermostat),
                          _buildWeatherProperty('Description', '${weatherData?["weather"][0]["description"]}', Icons.description),
                          _buildWeatherProperty('Humidity', '${weatherData?["main"]["humidity"]}%', Icons.opacity),
                          _buildWeatherProperty('Wind Speed', '${weatherData?["wind"]["speed"]} mph', Icons.air),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _cityController,
              decoration:  InputDecoration(
                filled: true,
                fillColor: Colors.blue,
                labelText: 'enter city name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20)
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _cityName = _cityController.text;
              });
            },
            child: Text('Search'),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherProperty(String title, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 30,
        ),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(value),
          ],
        ),
      ],
    );
  }

  Future<Map<String, dynamic>> fetchWeatherData(String cityName) async {
    final String apiKey = "4f1ec51637d182a56fe580afeb640f1f";
    final String apiUrl =
        "https://api.openweathermap.org/data/2.5/weather?q=$cityName&units=imperial&appid=$apiKey";
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      // Parse the response body
      return json.decode(response.body);
    } else {
      // If the server did not return a 200 OK response,
      // throw an exception.
      throw Exception('Failed to load weather data');
    }
  }
}
