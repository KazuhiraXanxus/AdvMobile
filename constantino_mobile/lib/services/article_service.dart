import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article_model.dart';
import '../utils/constants.dart';

class ArticleService {
  static const String _baseUrl = host;

  static Future<List<Article>> fetchArticles() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/articles'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> articlesList = jsonData['articles'] ?? [];
        
        return articlesList.map((json) {
          final articleData = Map<String, dynamic>.from(json);
          
          final enhancedJson = <String, dynamic>{
            'id': articleData['_id']?.toString() ?? articleData['id']?.toString() ?? '',
            'body': articleData['content'] is List 
                ? (articleData['content'] as List).join('\n\n')
                : articleData['content'] ?? '',
            'title': articleData['title'] ?? '',
            'imageUrl': articleData['imageUrl'], // Use actual imageUrl from backend
            'userId': articleData['userId']?.toString() ?? '0',
            'username': articleData['username'] ?? 'Unknown User',
            'createdAt': articleData['createdAt'] ?? DateTime.now().toIso8601String(),
            'likes': articleData['likes'] ?? 0,
            'comments': articleData['comments'] ?? 0,
            'isLiked': false,
            'likedBy': articleData['likedBy'] ?? [],
            'commentsList': articleData['commentsList'] ?? [],
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

  static Future<Article> fetchArticleById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/articles/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = 
            Map<String, dynamic>.from(json.decode(response.body));
        
        final enhancedJson = <String, dynamic>{
          'id': jsonData['_id']?.toString() ?? jsonData['id']?.toString() ?? '',
          'body': jsonData['content'] is List 
              ? (jsonData['content'] as List).join('\n\n')
              : jsonData['content'] ?? '',
          'title': jsonData['title'] ?? '',
          'imageUrl': jsonData['imageUrl'], // Use actual imageUrl from backend
          'userId': jsonData['userId']?.toString() ?? '0',
          'username': jsonData['username'] ?? 'Unknown User',
          'createdAt': jsonData['createdAt'] ?? DateTime.now().toIso8601String(),
          'likes': jsonData['likes'] ?? 0,
          'comments': jsonData['comments'] ?? 0,
          'isLiked': false,
          'likedBy': jsonData['likedBy'] ?? [],
          'commentsList': jsonData['commentsList'] ?? [],
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

  static Future<Map> createArticle(dynamic article) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/articles'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(article),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final mapData = jsonDecode(response.body);
      return mapData;
    } else {
      throw Exception(
        'Failed to create article: ${response.statusCode} ${response.body}',
      );
    }
  }

  static Future<Map> updateArticle(String id, dynamic article) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/articles/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(article),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final mapData = jsonDecode(response.body);
      return mapData;
    } else {
      throw Exception(
        'Failed to update article: ${response.statusCode} ${response.body}',
      );
    }
  }

  static Future<void> deleteArticle(String id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/articles/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Failed to delete article: ${response.statusCode} ${response.body}',
      );
    }
  }

  static Future<Map<String, dynamic>> toggleLike(String articleId, String userId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/articles/$articleId/like'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'userId': userId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed to toggle like: ${response.statusCode} ${response.body}',
      );
    }
  }

  static Future<Map<String, dynamic>> addComment(
    String articleId,
    String userId,
    String username,
    String comment,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/articles/$articleId/comment'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'userId': userId,
        'username': username,
        'comment': comment,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed to add comment: ${response.statusCode} ${response.body}',
      );
    }
  }

  static Future<Map<String, dynamic>> getComments(String articleId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/articles/$articleId/comments'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed to get comments: ${response.statusCode} ${response.body}',
      );
    }
  }
}