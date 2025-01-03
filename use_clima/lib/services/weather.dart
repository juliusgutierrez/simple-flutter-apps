import 'package:clima/services/location.dart';
import 'package:clima/services/networking.dart';

const apiKey = '39c560523774448537222fa257132285';
const openWeatherMapURL = 'https://api.openweathermap.org/data/2.5/weather';

class WeatherModel {

  Future<dynamic> getCityWeather(String cityName) async {
    String url = '$openWeatherMapURL?q=$cityName&appid=$apiKey&units=metric';
    print('URL : ${url}');
    NetworkHelper networkHelper = NetworkHelper(url);
    var weatherData = await networkHelper.getData();
    return weatherData;
  }

  Future<dynamic> getLocationWeather() async {
    Location location = Location();
    await location.getCurrentLocation();

    String url = '$openWeatherMapURL?lat=${location.latitude}&lon=${location.longitude}&appid=$apiKey&units=metric';
    print('URL : ${url}');
    NetworkHelper networkHelper = NetworkHelper(url);

    var weatherData = await networkHelper.getData();
    return weatherData;
  }

  String getWeatherIcon(int condition) {
    if (condition < 300) {
      return '🌩';
    } else if (condition < 400) {
      return '🌧';
    } else if (condition < 600) {
      return '☔️';
    } else if (condition < 700) {
      return '☃️';
    } else if (condition < 800) {
      return '🌫';
    } else if (condition == 800) {
      return '☀️';
    } else if (condition <= 804) {
      return '☁️';
    } else {
      return '🤷‍';
    }
  }

  String getMessage(int temp) {
    switch (temp) {
      case > 25:
        return 'It\'s 🍦 time';
      case > 20:
        return 'Time for shorts and 👕';
      case < 10:
        return 'You\'ll need 🧣 and 🧤';
      default:
        return 'Bring a 🧥 just in case';
    }
  }
}
