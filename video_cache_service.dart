import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class VideoCacheService {
  static final VideoCacheService _instance = VideoCacheService._internal();
  factory VideoCacheService() => _instance;
  VideoCacheService._internal();

  final Map<String, String> _cachedVideos = {};

  Future<String> getVideoPath(String videoPath) async {
    if (kIsWeb) return videoPath; // No caching on web

    // If it's a local asset, return as is
    if (videoPath.startsWith('assets/')) {
      return videoPath;
    }

    // Check if video is already cached
    if (_cachedVideos.containsKey(videoPath)) {
      final cachedFile = File(_cachedVideos[videoPath]!);
      if (await cachedFile.exists()) {
        return _cachedVideos[videoPath]!;
      }
    }

    // If it's a network URL, cache it
    if (videoPath.startsWith('http')) {
      try {
        final cacheDir = await getTemporaryDirectory();
        final fileName = 'cached_${DateTime.now().millisecondsSinceEpoch}.mp4';
        final cachedPath = '${cacheDir.path}/$fileName';
        
        final response = await http.get(Uri.parse(videoPath));
        await File(cachedPath).writeAsBytes(response.bodyBytes);
        
        _cachedVideos[videoPath] = cachedPath;
        return cachedPath;
      } catch (e) {
        debugPrint('Error caching video: $e');
        return videoPath; // Fallback to original path
      }
    }

    return videoPath;
  }

  Future<void> clearCache() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      await cacheDir.delete(recursive: true);
      _cachedVideos.clear();
    } catch (e) {
      debugPrint('Error clearing video cache: $e');
    }
  }

  Future<void> preloadVideos(List<String> videoPaths) async {
    if (kIsWeb) return; // No preloading on web

    for (final path in videoPaths) {
      try {
        await getVideoPath(path);
      } catch (e) {
        debugPrint('Error preloading video $path: $e');
      }
    }
  }
}