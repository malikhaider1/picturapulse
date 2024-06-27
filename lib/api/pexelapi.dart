import 'dart:convert';
import 'package:http/http.dart' as http;

class PexelsApi {
  static const String _apiKey = '8FFUaJCPvIdmVseszETUua6AsaeZGRpThFVdJynqPWvC5Ycmqo22Tx0z';
  static const String _baseUrl = 'https://api.pexels.com/v1/';

  Future<List<dynamic>> fetchImages(String query) async {
    final response = await http.get(
      Uri.parse('${_baseUrl}search?query=$query&per_page=80'),
      headers: {'Authorization': _apiKey},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> imageUrls = data['photos'].map<dynamic>((photo) {
        return photo['src']['medium'];
      }).toList();
      return imageUrls;
    } else {
      throw Exception('Failed to load images');
    }
  }
}
