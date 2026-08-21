import 'profile_model.dart';

class PostModel {
  final String id;
  final String authorId;
  final String? content;
  final List<String> imageUrls;
  final String? videoUrl;
  final bool isConfession;
  final String? clubId;
  final int likeCount;
  final int commentCount;
  final String createdAt;
  final String updatedAt;
  final ProfileModel? author;
  final bool likedByMe;

  PostModel({
    required this.id,
    required this.authorId,
    this.content,
    this.imageUrls = const [],
    this.videoUrl,
    this.isConfession = false,
    this.clubId,
    this.likeCount = 0,
    this.commentCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.author,
    this.likedByMe = false,
  });

  factory PostModel.fromJson(Map<String, dynamic> json, {bool likedByMe = false}) {
    ProfileModel? authorProfile;
    if (json['profiles'] != null && json['profiles'] is Map<String, dynamic>) {
      authorProfile = ProfileModel.fromJson(json['profiles'] as Map<String, dynamic>);
    }

    final rawImages = json['image_urls'];
    List<String> images = [];
    if (rawImages is List) {
      images = rawImages.map((e) => e.toString()).toList();
    }

    return PostModel(
      id: json['id'] as String? ?? '',
      authorId: json['author_id'] as String? ?? '',
      content: json['content'] as String?,
      imageUrls: images,
      videoUrl: json['video_url'] as String?,
      isConfession: json['is_confession'] as bool? ?? false,
      clubId: json['club_id'] as String?,
      likeCount: json['like_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      author: authorProfile,
      likedByMe: likedByMe,
    );
  }

  PostModel copyWith({
    int? likeCount,
    int? commentCount,
    bool? likedByMe,
    ProfileModel? author,
  }) {
    return PostModel(
      id: id,
      authorId: authorId,
      content: content,
      imageUrls: imageUrls,
      videoUrl: videoUrl,
      isConfession: isConfession,
      clubId: clubId,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      author: author ?? this.author,
      likedByMe: likedByMe ?? this.likedByMe,
    );
  }
}
