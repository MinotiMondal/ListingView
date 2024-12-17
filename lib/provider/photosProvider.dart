import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webskitterstask/model/homeScreenResponseModel.dart';

class PhotoProvider extends ChangeNotifier {
  final String _apiUrl = 'https://api.unsplash.com/photos/';
  final String _accessKey = '8fZZLAtYG6LkkNbNsa7-_35CESYO-62CM5zQfc_-Nas';

  List<HomeScreenResponseModel> _photos = [];
  bool _isLoading = false;
  bool _isFetchingMore = false;
  int _currentPage = 1;

  List<HomeScreenResponseModel> get photos => _photos;
  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;

  Future<void> fetchPhotos({bool isNextPage = false}) async {
    if (_isLoading || _isFetchingMore) return;

    if (isNextPage) {
      _isFetchingMore = true;
    } else {
      _isLoading = true;
    }
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_apiUrl?page=$_currentPage'),
        headers: {'Authorization': 'Client-ID $_accessKey'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<HomeScreenResponseModel> fetchedPhotos = data
            .map((photoJson) => HomeScreenResponseModel.fromJson(photoJson))
            .toList();

        if (isNextPage) {
          _photos.addAll(fetchedPhotos);
        } else {
          _photos = fetchedPhotos;
        }

        if (fetchedPhotos.isNotEmpty) _currentPage++;
      } else {
        throw Exception('Failed to load photos');
      }
    } catch (e) {
      debugPrint('Error fetching photos: $e');
    } finally {
      _isLoading = false;
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  void resetPhotos() {
    _photos = [];
    _currentPage = 1;
    fetchPhotos();
  }
}
