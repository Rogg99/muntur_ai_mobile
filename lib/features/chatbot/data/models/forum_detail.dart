/// One member of a forum, mirroring the nested Profile shape already used
/// for MessageReadSerializer.emetteur elsewhere in the app.
class ForumMember {
  final String id;
  final String name;
  final String photo;

  const ForumMember({required this.id, required this.name, required this.photo});

  factory ForumMember.fromJson(Map<String, dynamic> json) {
    final name = '${json['nom'] ?? ''} ${json['prenom'] ?? ''}'.trim();
    return ForumMember(
      id: json['id']?.toString() ?? '',
      name: name.isEmpty ? 'Membre' : name,
      photo: json['photo']?.toString() ?? '',
    );
  }
}

/// A forum's extended detail — description, member count and list — fetched
/// fresh when the forum-details page/appbar needs it rather than cached in
/// Isar, since ForumReadSerializer doesn't return this on the list endpoint
/// the discussion list already caches.
class ForumDetail {
  final String id;
  final String title;
  final String description;
  final String photo;
  final int? membersCount;
  final List<ForumMember> members;

  const ForumDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.photo,
    required this.membersCount,
    required this.members,
  });

  factory ForumDetail.fromJson(Map<String, dynamic> json) {
    final rawCount = json['members_count'] ?? json['membersCount'];
    final rawMembers = json['members'];
    return ForumDetail(
      id: json['id']?.toString() ?? '',
      title: json['titre']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      photo: json['photo']?.toString() ?? '',
      membersCount: rawCount is num
          ? rawCount.toInt()
          : (rawMembers is List ? rawMembers.length : null),
      members: rawMembers is List
          ? rawMembers
              .whereType<Map>()
              .map((m) => ForumMember.fromJson(m.cast<String, dynamic>()))
              .toList()
          : const [],
    );
  }
}
