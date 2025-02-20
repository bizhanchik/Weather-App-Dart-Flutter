import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';

class WeatherDetail extends StatelessWidget {
  final Weather weather;
  final String formattedDate;
  final String formattedTime;

  const WeatherDetail({
    super.key,
    required this.weather,
    required this.formattedDate,
    required this.formattedTime,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _locationHeader(),
            _temperatureInfo(),
            const SizedBox(height: 20),
            _dateTimeInfo(),
            const SizedBox(height: 20),
            _weatherIcon(context), // Передаем context
            const SizedBox(height: 20),
            _weatherDetails(),
          ],
        ),
      ),
    );
  }


  Widget _locationHeader() {
    return Text(
      weather.areaName ?? "Unknown",
      style: const TextStyle(
        fontSize: 25,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }


  Widget _temperatureInfo() {
    return Column(
      children: [
        Text(
          "${weather.temperature?.celsius?.toStringAsFixed(1) ?? "--"}°C",
          style: const TextStyle(
            fontSize: 40,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (weather.weatherMain != null)
          Text(
            weather.weatherMain!,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }


  Widget _dateTimeInfo() {
    return Column(
      children: [
        Text(formattedDate, style: _infoTextStyle()),
        Text(formattedTime, style: _infoTextStyle()),
      ],
    );
  }


  Widget _weatherIcon(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.width * 0.3,
      width: MediaQuery.of(context).size.width * 0.3,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: weather.weatherIcon != null
              ? NetworkImage(
              "https://openweathermap.org/img/wn/${weather.weatherIcon}@4x.png")
              : const AssetImage("assets/default_weather.png") as ImageProvider,
        ),
      ),
    );
  }


  Widget _weatherDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _weatherInfoRow([
            _weatherDetail(Icons.water_drop, "Humidity",
                "${weather.humidity ?? "--"}%"),
            _weatherDetail(Icons.speed, "Pressure",
                "${weather.pressure?.toStringAsFixed(0) ?? "--"} hPa"),
            _weatherDetail(Icons.thermostat, "Feels Like",
                "${weather.tempFeelsLike?.celsius?.toStringAsFixed(1) ?? "--"}°C"),
          ]),
          const Divider(color: Colors.white),
          _weatherInfoRow([
            _weatherDetail(Icons.wb_sunny, "Max Temp",
                "${weather.tempMax?.celsius?.toStringAsFixed(1) ?? "--"}°C"),
            _weatherDetail(Icons.ac_unit, "Min Temp",
                "${weather.tempMin?.celsius?.toStringAsFixed(1) ?? "--"}°C"),
            _weatherDetail(Icons.air, "Wind Speed",
                "${weather.windSpeed?.toStringAsFixed(1) ?? "--"} km/h"),
          ]),
        ],
      ),
    );
  }

  Widget _weatherInfoRow(List<Widget> children) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: children,
    );
  }


  Widget _weatherDetail(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 30),
        const SizedBox(height: 5),
        Text(value, style: _infoTextStyle()),
        Text(title, style: _infoTextStyle()),
      ],
    );
  }

  TextStyle _infoTextStyle() => const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w500,
    fontSize: 16,
  );
}