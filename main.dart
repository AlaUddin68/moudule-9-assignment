import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:cached_network_image/cached_network_image.dart';
void main() {
  runApp(WeatherApp());
}

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  bool isLoading = true;
  bool hasError = false;
  String location = '';
  String temperature = '';
  String description = '';
  String iconUrl = '';

  PermissionStatus _permissionStatus = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
    _requestPermission();
    fetchWeatherData();
  }

  _requestPermission() async {
    PermissionStatus _permissionStatus = await Permission.location.request();
    LocationPermission permission = await Geolocator.checkPermission();
  }


  Future<void> fetchWeatherData() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double latitude = position.latitude;
      double longitude = position.longitude;

      String apiKey = '3d34cdc60317acac6095b058aae2f7bb';
      String apiUrl =
          'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric';

      http.Response response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        setState(() {
          location = data['name'];
          temperature = '${data['main']['temp'].round()}°C';
          description = data['weather'][0]['description'];
          iconUrl =
          'http://openweathermap.org/img/w/${data['weather'][0]['icon']}.png';
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
        actions: [
          IconButton(onPressed: (){
            fetchWeatherData();
            setState(() {});
          }, icon: Icon(Icons.refresh))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) CircularProgressIndicator()

            else
              Column(
                children: [
                  Text(
                    location,
                    style: TextStyle(fontSize: 24.0),
                  ),
                  SizedBox(height: 16.0),
                  CachedNetworkImage(
                    imageUrl: iconUrl,
                    placeholder: (context, url) =>
                        CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    width: 100.0,
                    height: 100.0,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    temperature,
                    style: TextStyle(
                      fontSize: 36.0,
                      fontFamily: 'Your Custom Font',
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontFamily: 'Your Custom Font',
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

