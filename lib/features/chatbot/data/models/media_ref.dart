import '../../../../core/network/api_client.dart';

/// A single attached media item, normalized to the same shape regardless of
/// source: this device's own upload response, the immediate 202 echo's
/// "media" key, or the WS AI-reply push's "medias" key (same MediaSerializer
/// shape server-side, just a different field name between the two).
class MediaRef {
  final String id;
  final String file; // always resolved to an absolute URL
  final String kind; // "image" | "audio" | "video" | "unknown"

  const MediaRef({required this.id, required this.file, required this.kind});

  factory MediaRef.fromJson(Map<String, dynamic> json) {
    return MediaRef(
      id: json['id']?.toString() ?? '',
      file: ApiClient.resolveMediaUrl(json['file']?.toString() ?? ''),
      kind: json['kind']?.toString() ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'file': file, 'kind': kind};
}
