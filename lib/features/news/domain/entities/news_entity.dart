class NewsEntity {
  final String id;
  final String title;
  final String image;
  final String contenu;
  final String path;
  final String statut;
  final int time;
  final int likes;
  final int comments;
  final bool liked;

  const NewsEntity({
    required this.id,
    this.title = '',
    this.image = '',
    this.contenu = '',
    this.path = '',
    this.statut = 'none',
    this.time = 0,
    this.likes = 0,
    this.comments = 0,
    this.liked = false,
  });

  NewsEntity copyWith({bool? liked, int? likes}) => NewsEntity(
        id: id,
        title: title,
        image: image,
        contenu: contenu,
        path: path,
        statut: statut,
        time: time,
        likes: likes ?? this.likes,
        comments: comments,
        liked: liked ?? this.liked,
      );
}
