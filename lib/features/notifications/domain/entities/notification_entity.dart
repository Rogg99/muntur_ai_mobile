class NotificationEntity {
  final String id;
  final String title;
  final String text;
  final String image;
  final String url;
  final bool isRead;
  final int time;

  const NotificationEntity({
    required this.id,
    this.title = '',
    this.text = '',
    this.image = '',
    this.url = '',
    this.isRead = false,
    this.time = 0,
  });

  NotificationEntity copyWith({bool? isRead}) => NotificationEntity(
        id: id,
        title: title,
        text: text,
        image: image,
        url: url,
        isRead: isRead ?? this.isRead,
        time: time,
      );
}
