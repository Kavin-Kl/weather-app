import 'package:dio/dio.dart';

class GeocodingService {
  final Dio dio;
  GeocodingService(this.dio);

  Future<String?> getCityName(double lat, double lon) async {
    try {
      final response = await dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'format': 'json',
        },
        options: Options(headers: {'User-Agent': 'weather-app/1.0'}),
      );
      final data = response.data;
      if (data != null && data['address'] != null) {
        return data['address']['city'] ??
            data['address']['town'] ??
            data['address']['village'] ??
            data['address']['state'] ??
            data['address']['country'] ??
            null;
      }
      return null;
    } catch (e) {
      print('Geocoding error: $e');
      return null;
    }
  }

  Future<Map<String, String?>> getLocationDetails(
      double lat, double lon) async {
    try {
      final response = await dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'format': 'json',
        },
        options: Options(headers: {'User-Agent': 'weather-app/1.0'}),
      );
      final data = response.data;
      if (data != null && data['address'] != null) {
        return {
          'city': data['address']['city'] ??
              data['address']['town'] ??
              data['address']['village'],
          'state': data['address']['state'],
          'country': data['address']['country'],
          'display': data['display_name'],
        };
      }
      return {};
    } catch (e) {
      print('Geocoding error: $e');
      return {};
    }
  }
}
