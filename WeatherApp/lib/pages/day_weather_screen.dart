import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import 'package:weatherapp/widgets/weather_detail.dart';

class DayWeatherScreen extends StatelessWidget {
  final Weather weather;

  const DayWeatherScreen({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    DateTime now = weather.date ?? DateTime.now();
    String formattedDate = DateFormat('EEEE d, MMMM yyyy').format(now);
    String formattedTime = DateFormat('hh:mm a').format(now);

    return Scaffold(
      backgroundColor: const Color(0xFF676BD0),
      appBar: AppBar(
        title: const Text("Прогноз на день"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: WeatherDetail(
            weather: weather,
            formattedDate: formattedDate,
            formattedTime: formattedTime,
          ),
        ),
      ),
    );
  }
}