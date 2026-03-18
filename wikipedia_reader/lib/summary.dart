// lib/summary.dart

class Summary {
  final String title;
  final String displayTitle;
  final String? description;
  final String? extract;
  final Thumbnail? thumbnail;  // Cambiado de pageImageUrl a thumbnail
  final Titles titles;

  Summary({
    required this.title,
    required this.displayTitle,
    this.description,
    this.extract,
    this.thumbnail,  // Cambiado
    required this.titles,
  });

  // Getter para verificar si tiene imagen
  bool get hasImage => thumbnail != null;

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      title: json['title'] ?? '',
      displayTitle: json['displaytitle'] ?? json['title'] ?? '',
      description: json['description'],
      extract: json['extract'],
      thumbnail: json['thumbnail'] != null 
          ? Thumbnail.fromJson(json['thumbnail']) 
          : null,  // Cambiado para usar Thumbnail
      titles: Titles.fromJson(json['titles'] ?? {}),
    );
  }
}

class Titles {
  final String canonical;
  final String normalized;
  final String display;

  Titles({
    required this.canonical,
    required this.normalized,
    required this.display,
  });

  factory Titles.fromJson(Map<String, dynamic> json) {
    return Titles(
      canonical: json['canonical'] ?? '',
      normalized: json['normalized'] ?? '',
      display: json['display'] ?? '',
    );
  }
}

// NUEVA CLASE: Thumbnail
class Thumbnail {
  final String source;
  final int width;
  final int height;

  Thumbnail({
    required this.source,
    required this.width,
    required this.height,
  });

  factory Thumbnail.fromJson(Map<String, dynamic> json) {
    return Thumbnail(
      source: json['source'] ?? '',
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
    );
  }
}