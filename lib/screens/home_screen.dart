import 'package:flutter/material.dart';
import 'package:peliculas_app/providers/movies_provider.dart';
import 'package:peliculas_app/search/search_delegate.dart';
import 'package:peliculas_app/widgets/widgets.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final moviesProvider = Provider.of<MoviesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Peliculas en cine'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_sharp),
            onPressed: () =>
                showSearch(context: context, delegate: MovieSearchDelegate()),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          //TODO Cards
          CardSwiper(
            movies: moviesProvider.onDisplayMovies,
          ),
          //  Listado
          MovieSlider(
            movies: moviesProvider.popularMovies,
            title: 'Popular!',
            onNextPage: () => moviesProvider.getPopularMovies(),
          ),
        ]),
      ),
    );
  }
}
