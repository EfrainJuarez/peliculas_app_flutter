import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:flutter/material.dart';
import 'package:peliculas_app/providers/movies_provider.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';

class CastingCards extends StatelessWidget {
  final int movieId;
  const CastingCards({super.key, required this.movieId});

  @override
  Widget build(BuildContext context) {
    final moviesProvider = Provider.of<MoviesProvider>(context, listen: false);
    return FutureBuilder(
        future: moviesProvider.getMovieCast(movieId),
        builder: (_, AsyncSnapshot<List<Cast>> snapshot) {
          if (!snapshot.hasData) {
            return Container(
              constraints: const BoxConstraints(maxHeight: 150),
              height: 190,
              child: const CupertinoActivityIndicator(),
            );
          }

          final List<Cast> cast = snapshot.data!;

          return Container(
            margin: const EdgeInsets.only(bottom: 30),
            width: double.infinity,
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 10,
              itemBuilder: (_, int index) => _CastCard(
                actor: cast[index],
              ),
            ),
          );
        });
  }
}

class _CastCard extends StatelessWidget {
  final Cast actor;

  const _CastCard({super.key, required this.actor});
  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      width: 110,
      height: 100,
      child: Column(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: FadeInImage(
            placeholder: AssetImage('assets/no-image.jpg'),
            image: NetworkImage(actor.fullProfilePath),
            height: 140,
            width: 100,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          actor.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        Text(
          actor.knownForDepartment,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: textTheme.bodySmall,
        )
      ]),
    );
  }
}
