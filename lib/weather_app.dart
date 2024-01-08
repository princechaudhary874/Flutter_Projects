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
  final TextEditingController textEditingController = TextEditingController();

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = textEditingController.text.isNotEmpty
          ? textEditingController.text
          : 'Kathmandu';

      final result = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey'),
      );
      // jsondecode used to decode that data fetched from api
      final data = jsonDecode(result.body);
      if (data["cod"] != "200") {
        throw "An unexpected error occurs";
      }
      return data;
      // fetchong data from api of first list and showing it in main card temperature

      // temp = (data['list'][0]['main']['temp']) - 273.15;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentWeather();
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
            onPressed: () {
              setState(() {
                getCurrentWeather();
              });
            },
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: FutureBuilder(
          future: getCurrentWeather(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }

            // check data is not null

            final data = snapshot.data!;

            final currentWeatherData = data['list'][0];
            final currentWeather = currentWeatherData['main']['temp'];
            final currentSky = currentWeatherData['weather'][0]['main'];
            final currentHumidity = currentWeatherData['main']['humidity'];
            final currentWindSpeed = currentWeatherData['wind']['speed'];
            final currentPressure = currentWeatherData['main']['pressure'];
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // main card
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextField(
                      controller: textEditingController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20, // Text color inside the TextField
                      ),
                      decoration:  InputDecoration(
                        hintText: 'Enter your city',
                        hintStyle:const TextStyle(color: Colors.white60),
                        prefixIcon: IconButton(
                          icon:const Icon(Icons.search),
                          onPressed: () {setState(() {
                             getCurrentWeather();
                          });
                           
                          },
                        ),
                        prefixIconColor: Colors.white,
                        filled: true,
                        fillColor: Colors.black,
                      ),
                    ),
                  ),
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
                                  '${currentWeather.toString()} K',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                // setting cloud
                                Icon(
                                  currentSky == "Clouds" || currentSky == "Rain"
                                      ? Icons.cloud
                                      : Icons.sunny,
                                  size: 64,
                                ),
                                const SizedBox(
                                  height: 15,
                                ),

                                Text(
                                  '$currentSky',
                                  style: const TextStyle(
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
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (int i = 0; i < 20; i++)
                          HourlyForecastItem(
                            time: data['list'][i + 1]['dt'].toString(),
                            icon: ((data['list'][i + 1]['weather'][0]['main'] ==
                                        'Clouds') ||
                                    (data['list'][i + 1]['weather'][0]
                                            ['main'] ==
                                        "Rain"))
                                ? Icons.cloud
                                : Icons.sunny,
                            temperature:
                                data['list'][i + 1]['main']['temp'].toString(),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      AdditionalItems(
                        icon: Icons.water_drop,
                        label: 'Humidity',
                        value: currentHumidity.toString(),
                      ),
                      AdditionalItems(
                        icon: Icons.air,
                        label: 'Wind Speed',
                        value: currentWindSpeed.toString(),
                      ),
                      AdditionalItems(
                        icon: Icons.beach_access,
                        label: 'Pressure',
                        value: currentPressure.toString(),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
