import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import 'package:weatherapp/API/weather_api.dart';
import 'package:weatherapp/pages/day_weather_screen.dart';
import 'package:weatherapp/widgets/weather_detail.dart';
import 'package:weatherapp/location_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  WeatherFactory wf = WeatherFactory(OPEN_WEATHER_API_KEY);
  Weather? weather;
  List<Weather> forecast = [];
  bool isLoading = true;
  String city = 'Unknown';
  List<String> favoriteCities = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadFavorites();
    getCityFromCoordinates();
  }

  Future<void> getCityFromCoordinates() async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
        UserLocation.lat, UserLocation.long);

    setState(() {
      city = placemarks.isNotEmpty ? placemarks[0].locality ?? "Unknown" : "Unknown";
    });

    getData(city);
  }

  Future<void> loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    favoriteCities = prefs.getStringList('favorites') ?? [];
    setState(() {});
  }

  Future<void> saveFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favorites', favoriteCities);
  }

  Future<void> getData(String cityName) async {
    setState(() => isLoading = true);

    weather = await wf.currentWeatherByCityName(cityName);
    List<Weather> allForecasts = await wf.fiveDayForecastByCityName(cityName);

    Map<String, Weather> dailyForecasts = {};
    for (var f in allForecasts) {
      String date = DateFormat('yyyy-MM-dd').format(f.date!);
      if (!dailyForecasts.containsKey(date)) {
        dailyForecasts[date] = f;
      }
    }

    forecast = dailyForecasts.values.take(7).toList();
    setState(() => isLoading = false);
  }

  void toggleFavorite(String city) {
    if (favoriteCities.contains(city)) {
      favoriteCities.remove(city);
    } else {
      favoriteCities.add(city);
    }
    saveFavorites();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
        children: [
          Expanded(
            flex: 3,
            child: WeatherDetail(
              weather: weather!,
              formattedDate:
              DateFormat('EEEE d, MMMM yyyy').format(DateTime.now()),
              formattedTime:
              DateFormat('hh:mm a').format(DateTime.now()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Enter city",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        city = value;
                        getData(city);
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    if (searchController.text.isNotEmpty) {
                      city = searchController.text;
                      getData(city);
                    }
                  },
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => toggleFavorite(city),
            child: Text(favoriteCities.contains(city)
                ? "Remove from Favorites"
                : "Add to Favorites"),
          ),
          Expanded(flex: 1, child: _forecastListView()),
        ],
      ),
    );
  }

  Widget _forecastListView() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: forecast.length,
      itemBuilder: (context, index) {
        Weather day = forecast[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DayWeatherScreen(weather: day),
              ),
            );
          },
          child: _forecastCard(day),
        );
      },
    );
  }

  Widget _forecastCard(Weather weather) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      padding: const EdgeInsets.all(10),
      width: 120,
      decoration: BoxDecoration(
        color: Colors.deepPurple[400],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(DateFormat('EEEE').format(weather.date ?? DateTime.now()),
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          Image.network(
            "https://openweathermap.org/img/wn/${weather.weatherIcon}@2x.png",
            height: 50,
            width: 50,
          ),
          Text("Max: ${weather.tempMax?.celsius?.toStringAsFixed(1) ?? "--"}°C",
              style: const TextStyle(color: Colors.white, fontSize: 14)),
          Text("Min: ${weather.tempMin?.celsius?.toStringAsFixed(1) ?? "--"}°C",
              style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

}