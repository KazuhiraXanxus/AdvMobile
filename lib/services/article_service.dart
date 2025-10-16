import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/article_model.dart';

class ArticleService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  
  static final List<String> _sampleImages = [
    'https://picsum.photos/600/400?random=1',
    'https://picsum.photos/600/400?random=2',
    'https://picsum.photos/600/400?random=3',
    'https://picsum.photos/600/400?random=4',
    'https://picsum.photos/600/400?random=5',
    'https://picsum.photos/600/400?random=6',
    'https://picsum.photos/600/400?random=7',
    'https://picsum.photos/600/400?random=8',
  ];

  static Future<List<Article>> fetchArticles() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/posts'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        
        return jsonData.map((json) {
          final enhancedJson = <String, dynamic>{
            ...Map<String, dynamic>.from(json),
            'imageUrl': _getRandomImage(),
            'createdAt': _getRandomDateTime().toIso8601String(),
            'likes': _getRandomLikes(),
            'comments': _getRandomComments(),
            'isLiked': false,
          };
          
          return Article.fromJson(enhancedJson);
        }).toList();
      } else {
        throw Exception('Failed to load articles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching articles: $e');
    }
  }

  static Future<Article> fetchArticleById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/posts/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = 
            Map<String, dynamic>.from(json.decode(response.body));
        
        final enhancedJson = <String, dynamic>{
          ...jsonData,
          'imageUrl': _getRandomImage(),
          'createdAt': _getRandomDateTime().toIso8601String(),
          'likes': _getRandomLikes(),
          'comments': _getRandomComments(),
          'isLiked': false,
        };
        
        return Article.fromJson(enhancedJson);
      } else {
        throw Exception('Failed to load article: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching article: $e');
    }
  }

  static Future<List<Article>> searchArticles(String query) async {
    try {
      final allArticles = await fetchArticles();
      
      if (query.isEmpty) {
        return allArticles;
      }
      
      return allArticles.where((article) {
        return article.title.toLowerCase().contains(query.toLowerCase()) ||
               article.body.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      throw Exception('Error searching articles: $e');
    }
  }

  static Future<Article> toggleLike(Article article) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return article.copyWith(
      isLiked: !article.isLiked,
      likes: article.isLiked 
          ? article.likes - 1 
          : article.likes + 1,
    );
  }

  static String? _getRandomImage() {
    final random = Random();
    if (random.nextDouble() < 0.5) {
      return _sampleImages[random.nextInt(_sampleImages.length)];
    }
    return null;
  }

  static int _getRandomLikes() {
    final random = Random();
    return random.nextInt(100) + 1;
  }

  static int _getRandomComments() {
    final random = Random();
    return random.nextInt(20) + 1;
  }

  static DateTime _getRandomDateTime() {
    final random = Random();
    final now = DateTime.now();
    final hoursAgo = random.nextInt(48);
    
    return now.subtract(Duration(hours: hoursAgo));
  }
}