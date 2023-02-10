import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:peliculas_app/helpers/debouncer.dart';
import 'package:peliculas_app/models/models.dart';
import 'package:peliculas_app/models/search_response.dart';

class MoviesProvider extends ChangeNotifier {
  final String _baseUrl = 'api.themoviedb.org';
  final String _apiKey = '0b5279f39d0d0dd7a426ae1f4200d2ec';
  final String _language = 'es-ES';

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];

  Map<int, List<Cast>> moviesCast = {};
  final deboncer = Debouncer(duration: const Duration(milliseconds: 500));
  int _PopularPage = 0;

  final StreamController<List<Movie>> _suggestionsStreamController =
      new StreamController.broadcast();
  Stream<List<Movie>> get sugestionsStream =>
      this._suggestionsStreamController.stream;
  MoviesProvider() {
    print('MoviesProvidar corriendo');
    this.getOnDisplayMovies();
    this.getPopularMovies();
  }

  Future<String> _getJsonData(String endpoint, [int page = 1]) async {
    final url = Uri.https(_baseUrl, endpoint,
        {'api_key': _apiKey, 'language': _language, 'page': '$page'});
    final response = await http.get(url);
    return response.body;
  }

  getOnDisplayMovies() async {
    final jsonData = await _getJsonData('3/movie/now_playing');
    final nowPlayingResponse = NowPlayingResponse.fromJson(jsonData);
    onDisplayMovies = nowPlayingResponse.results;
    notifyListeners();
  }

  getPopularMovies() async {
    _PopularPage++;
    final jsonData = await _getJsonData('3/movie/popular', _PopularPage);
    final popularResponse = PopularResponse.fromJson(jsonData);
    popularMovies = [...popularMovies, ...popularResponse.results];
    notifyListeners();
  }

  Future<List<Cast>> getMovieCast(int movieId) async {
    if (moviesCast.containsKey(movieId)) return moviesCast[movieId]!;
    print('pidiendo info');
    final jsonData = await _getJsonData('3/movie/$movieId/credits');
    final creditsResponse = CreditsResponse.fromJson(jsonData);

    moviesCast[movieId] = creditsResponse.cast;
    return creditsResponse.cast;
  }

  Future<List<Movie>> searchMovie(String query) async {
    final url = Uri.https(_baseUrl, '3/search/movie',
        {'api_key': _apiKey, 'language': _language, 'query': query});
    final response = await http.get(url);
    final searchResponse = SearchResponse.fromJson(response.body);
    return searchResponse.results;
  }

  void getSuggestionsQuery(String searchTerm) {
    deboncer.value = '';
    deboncer.onValue = ((value) async {
      final results = await searchMovie(value);
      _suggestionsStreamController.add(results);
    });
    final timer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      deboncer.value = searchTerm;
    });

    Future.delayed(const Duration(milliseconds: 301))
        .then((value) => timer.cancel());
  }
}
