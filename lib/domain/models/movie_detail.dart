import '../../core/constants/api_constants.dart';

class CastMember {
  final int id;
  final String name;
  final String character;
  final String? profilePath;

  const CastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
  });

  String? get fullProfileUrl => profilePath != null
      ? '${ApiConstants.tmdbImageBaseW500}$profilePath'
      : null;

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      character: json['character'] as String? ?? '',
      profilePath: json['profile_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'character': character,
    'profile_path': profilePath,
  };
}

class MovieDetail {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String releaseDate;
  final double voteAverage;
  final int voteCount;
  final int? runtime;
  final String? tagline;
  final List<String> genres;
  final List<CastMember> cast;
  final String? trailerKey;

  const MovieDetail({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    this.runtime,
    this.tagline,
    required this.genres,
    this.cast = const [],
    this.trailerKey,
  });

  String? get fullPosterUrl => posterPath != null
      ? '${ApiConstants.tmdbImageBaseW500}$posterPath'
      : null;

  String? get fullBackdropUrl => backdropPath != null
      ? '${ApiConstants.tmdbImageBaseOriginal}$backdropPath'
      : null;

  String get formattedRuntime {
    if (runtime == null || runtime == 0) return 'N/A';
    final hours = runtime! ~/ 60;
    final minutes = runtime! % 60;
    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
  }

  factory MovieDetail.fromJson(
    Map<String, dynamic> json, {
    List<CastMember> cast = const [],
    String? trailerKey,
  }) {
    final genresList =
        (json['genres'] as List<dynamic>?)
            ?.map((g) => (g as Map<String, dynamic>)['name'] as String? ?? '')
            .where((name) => name.isNotEmpty)
            .toList() ??
        [];

    return MovieDetail(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Sans titre',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: json['release_date'] as String? ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] as int? ?? 0,
      runtime: json['runtime'] as int?,
      tagline: json['tagline'] as String?,
      genres: genresList,
      cast: cast,
      trailerKey: trailerKey,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'overview': overview,
    'poster_path': posterPath,
    'backdrop_path': backdropPath,
    'release_date': releaseDate,
    'vote_average': voteAverage,
    'vote_count': voteCount,
    'runtime': runtime,
    'tagline': tagline,
    'genres': genres,
    'cast': cast.map((c) => c.toJson()).toList(),
    'trailer_key': trailerKey,
  };

  factory MovieDetail.fromCacheJson(Map<String, dynamic> json) {
    final rawCast = json['cast'] as List<dynamic>? ?? [];
    final castList = rawCast
        .map((c) => CastMember.fromJson(Map<String, dynamic>.from(c as Map)))
        .toList();

    return MovieDetail(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: json['release_date'] as String? ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] as int? ?? 0,
      runtime: json['runtime'] as int?,
      tagline: json['tagline'] as String?,
      genres: List<String>.from(json['genres'] as List? ?? []),
      cast: castList,
      trailerKey: json['trailer_key'] as String?,
    );
  }
}
