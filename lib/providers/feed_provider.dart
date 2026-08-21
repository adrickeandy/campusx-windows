import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../services/post_service.dart';

class FeedProvider extends ChangeNotifier {
  final PostService _postService = PostService();

  List<PostModel> _feedPosts = [];
  List<PostModel> _confessions = [];
  bool _isLoadingFeed = true;
  bool _isLoadingConfessions = true;
  bool _isPosting = false;

  List<PostModel> get feedPosts => _feedPosts;
  List<PostModel> get confessions => _confessions;
  bool get isLoadingFeed => _isLoadingFeed;
  bool get isLoadingConfessions => _isLoadingConfessions;
  bool get isPosting => _isPosting;

  Future<void> loadFeed(String? userId) async {
    _isLoadingFeed = true;
    notifyListeners();
    try {
      _feedPosts = await _postService.fetchFeed(currentUserId: userId);
    } catch (e) {
      print('[FeedProvider] loadFeed error: $e');
    } finally {
      _isLoadingFeed = false;
      notifyListeners();
    }
  }

  Future<void> loadConfessions() async {
    _isLoadingConfessions = true;
    notifyListeners();
    try {
      _confessions = await _postService.fetchConfessions();
    } catch (e) {
      print('[FeedProvider] loadConfessions error: $e');
    } finally {
      _isLoadingConfessions = false;
      notifyListeners();
    }
  }

  Future<bool> createPost({
    required String authorId,
    required String content,
    List<String> imageUrls = const [],
    String? videoUrl,
    bool isConfession = false,
  }) async {
    _isPosting = true;
    notifyListeners();
    try {
      final newPost = await _postService.createPost(
        authorId: authorId,
        content: content,
        imageUrls: imageUrls,
        videoUrl: videoUrl,
        isConfession: isConfession,
      );

      if (isConfession) {
        _confessions.insert(0, newPost);
      } else {
        _feedPosts.insert(0, newPost);
      }
      return true;
    } catch (e) {
      print('[FeedProvider] createPost error: $e');
      return false;
    } finally {
      _isPosting = false;
      notifyListeners();
    }
  }

  Future<void> toggleLike(String postId, String userId) async {
    final index = _feedPosts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = _feedPosts[index];
    final nextLiked = !post.likedByMe;
    final nextCount = post.likeCount + (nextLiked ? 1 : -1);

    _feedPosts[index] = post.copyWith(
      likedByMe: nextLiked,
      likeCount: nextCount < 0 ? 0 : nextCount,
    );
    notifyListeners();

    try {
      await _postService.toggleLike(postId, userId, post.likedByMe);
    } catch (e) {
      // Revert on error
      _feedPosts[index] = post;
      notifyListeners();
    }
  }

  Future<void> deletePost(String postId) async {
    _feedPosts.removeWhere((p) => p.id == postId);
    _confessions.removeWhere((p) => p.id == postId);
    notifyListeners();
    try {
      await _postService.deletePost(postId);
    } catch (e) {
      print('[FeedProvider] deletePost error: $e');
    }
  }

  Future<List<CommentModel>> getComments(String postId) async {
    return await _postService.fetchComments(postId);
  }

  Future<CommentModel?> addComment({
    required String postId,
    required String authorId,
    required String content,
  }) async {
    try {
      final comment = await _postService.addComment(
        postId: postId,
        authorId: authorId,
        content: content,
      );

      final index = _feedPosts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final p = _feedPosts[index];
        _feedPosts[index] = p.copyWith(commentCount: p.commentCount + 1);
        notifyListeners();
      }

      return comment;
    } catch (e) {
      print('[FeedProvider] addComment error: $e');
      return null;
    }
  }
}
