import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/image_model.dart';

class ImageProvider with ChangeNotifier {
  List<ImageModel> _images = [];
  List<ImageModel> get images => _images;
  int _page = 1;
  String _currentSizeKey = '';
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  int get page => _page;
  String get currentSizeKey => _currentSizeKey;

  dynamic changeImageSize(String newSizeKey) {
      _currentSizeKey = newSizeKey;
      notifyListeners();
  }


  void pageLoadMore(){
    _page++;
    notifyListeners();
  }

  Future<ImageModel> fetchImageById(String id) async {
    final response = await http.get(
      Uri.parse('https://api.pexels.com/v1/photos/$id'),
      headers: {
        'Authorization': '8FFUaJCPvIdmVseszETUua6AsaeZGRpThFVdJynqPWvC5Ycmqo22Tx0z',
      },
    );

    if (response.statusCode == 200) {
      return ImageModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load image');
    }
  }

  Future<void> fetchImages(String category) async {
    _isLoading = true;
    notifyListeners();

    final response = await http.get(
      Uri.parse('https://api.pexels.com/v1/search?query=$category&page=$_page&per_page=20'),
      headers: {
        'Authorization': '8FFUaJCPvIdmVseszETUua6AsaeZGRpThFVdJynqPWvC5Ycmqo22Tx0z',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['photos'];
      _images = data.map((json) => ImageModel.fromJson(json)).toList();

    } else {
      throw Exception('Failed to load images');
    }

    _isLoading = false;
    notifyListeners();
  }
}
