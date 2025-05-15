class GistItem {
  final String id;
  final String description;
  final DateTime createdAt;
  final bool isPublic;
  final Map<String, dynamic> files;

  GistItem({
    required this.id,
    required this.description,
    required this.createdAt,
    required this.isPublic,
    required this.files,
  });

  factory GistItem.fromJson(Map<String, dynamic> json) {
    return GistItem(
      id: json['id'],
      description: json['description'] ?? 'No description',
      createdAt: DateTime.parse(json['created_at']),
      isPublic: json['public'],
      files: json['files'] ?? {},
    );
  }

  String get fileNames => files.keys.join(', ');
}