import 'dart:convert';

enum AdPlatform { instagram, facebook, twitter, linkedin }

enum AdFormat { square, story, banner, portrait }

enum AdStatus { draft, generated, exported }

extension AdPlatformLabel on AdPlatform {
  String get label => name[0].toUpperCase() + name.substring(1);
}

extension AdFormatLabel on AdFormat {
  String get label => name[0].toUpperCase() + name.substring(1);
}

class AdRequest {
  final String prompt;
  final AdPlatform platform;
  final AdFormat format;
  final bool includeHashtags;
  final bool generateImagePrompt;
  final bool applyBrandTone;

  const AdRequest({
    required this.prompt,
    this.platform = AdPlatform.instagram,
    this.format = AdFormat.square,
    this.includeHashtags = true,
    this.generateImagePrompt = true,
    this.applyBrandTone = true,
  });
}

class GeneratedAd {
  final String id;
  final String headline;
  final String body;
  final List<String> hashtags;
  final String? imagePrompt;
  final String? imageUrl;
  final AdPlatform platform;
  final AdFormat format;
  final AdStatus status;
  final DateTime createdAt;
  final String originalPrompt;

  const GeneratedAd({
    required this.id,
    required this.headline,
    required this.body,
    required this.hashtags,
    this.imagePrompt,
    this.imageUrl,
    required this.platform,
    required this.format,
    this.status = AdStatus.draft,
    required this.createdAt,
    required this.originalPrompt,
  });

  GeneratedAd copyWith({
    String? imageUrl,
    AdStatus? status,
  }) =>
      GeneratedAd(
        id: id,
        headline: headline,
        body: body,
        hashtags: hashtags,
        imagePrompt: imagePrompt,
        imageUrl: imageUrl ?? this.imageUrl,
        platform: platform,
        format: format,
        status: status ?? this.status,
        createdAt: createdAt,
        originalPrompt: originalPrompt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'headline': headline,
        'body': body,
        'hashtags': hashtags,
        'imagePrompt': imagePrompt,
        'imageUrl': imageUrl,
        'platform': platform.name,
        'format': format.name,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'originalPrompt': originalPrompt,
      };

  factory GeneratedAd.fromJson(Map<String, dynamic> json) => GeneratedAd(
        id: json['id'],
        headline: json['headline'],
        body: json['body'],
        hashtags: List<String>.from(json['hashtags'] ?? []),
        imagePrompt: json['imagePrompt'],
        imageUrl: json['imageUrl'],
        platform: AdPlatform.values.firstWhere(
          (e) => e.name == json['platform'],
          orElse: () => AdPlatform.instagram,
        ),
        format: AdFormat.values.firstWhere(
          (e) => e.name == json['format'],
          orElse: () => AdFormat.square,
        ),
        status: AdStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => AdStatus.draft,
        ),
        createdAt: DateTime.parse(json['createdAt']),
        originalPrompt: json['originalPrompt'] ?? '',
      );

  String toJsonString() => jsonEncode(toJson());
  factory GeneratedAd.fromJsonString(String s) =>
      GeneratedAd.fromJson(jsonDecode(s));
}
