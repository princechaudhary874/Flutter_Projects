import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'hourly_forecast_item.dart';
import 'addtional_items.dart';
import 'package:weather_apps/secrets.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  double temp = 0;
  @override
  void initState() {
    super.initState();
    getCurrentWeather();
  }

  Future getCurrentWeather() async {
    try {
      String cityName = 'Kathmandu';
      final result = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey'),
      );
      final data = jsonDecode(result.body);
      if (data["cod"] != "200") {
        throw "An unexpected error occured";
      }
      // fetchong data from api of first list and showing it in main card temperature
      setState(() {
        temp = (data['list'][0]['main']['temp']) - 273.15;
      });
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // main card
            SizedBox(
              width: double.infinity,
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          Text(
                            '${temp.toStringAsPrecision(3)} °C',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          // setting cloud
                          const Icon(
                            Icons.cloud,
                            size: 64,
                          ),
                          const SizedBox(
                            height: 15,
                          ),

                          const Text(
                            'Rain',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // for gap
            const SizedBox(
              height: 20,
            ),
            // weather forecast card
            const Text(
              'Weather Forecast',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            const SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  HourlyForecastItem(
                    time: '3:00',
                    icon: Icons.cloud,
                    temperature: '78°F',
                  ),
                  HourlyForecastItem(
                    time: '6:00',
                    icon: Icons.sunny_snowing,
                    temperature: '84.4°F',
                  ),
                  HourlyForecastItem(
                    time: '9:00',
                    icon: Icons.cloud,
                    temperature: '81.32°F',
                  ),
                  HourlyForecastItem(
                    time: '12:00',
                    icon: Icons.sunny_snowing,
                    temperature: '88.62°F',
                  ),
                  HourlyForecastItem(
                    time: '15:00',
                    icon: Icons.sunny,
                    temperature: '93.23°F',
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 20,
            ),
            // additional information
            const Text(
              'Additional Information',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                AdditionalItems(
                  icon: Icons.water_drop,
                  label: 'Humidity',
                  value: '99',
                ),
                AdditionalItems(
                  icon: Icons.air,
                  label: 'Wind Speed',
                  value: '7.5',
                ),
                AdditionalItems(
                  icon: Icons.beach_access,
                  label: 'Pressure',
                  value: '1000',
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
