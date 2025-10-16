class Article {
  final int id;
  final int userId;
  final String title;
  final String body;
  final String? imageUrl;
  final DateTime? createdAt;
  final int likes;
  final int comments;
  final bool isLiked;

  Article({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.imageUrl,
    this.createdAt,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
  });

  // Factory constructor to create Article from JSON
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      imageUrl: json['imageUrl'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      likes: json['likes'] ?? _generateRandomLikes(),
      comments: json['comments'] ?? _generateRandomComments(),
      isLiked: json['isLiked'] ?? false,
    );
  }

  // Convert Article to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'createdAt': createdAt?.toIso8601String(),
      'likes': likes,
      'comments': comments,
      'isLiked': isLiked,
    };
  }

  // Create a copy of Article with updated fields
  Article copyWith({
    int? id,
    int? userId,
    String? title,
    String? body,
    String? imageUrl,
    DateTime? createdAt,
    int? likes,
    int? comments,
    bool? isLiked,
  }) {
    return Article(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  // Generate random likes for demo purposes
  static int _generateRandomLikes() {
    return (DateTime.now().millisecondsSinceEpoch % 100) + 1;
  }

  // Generate random comments for demo purposes
  static int _generateRandomComments() {
    return (DateTime.now().millisecondsSinceEpoch % 20) + 1;
  }

  // Get formatted time ago string
  String getTimeAgo() {
    if (createdAt == null) return 'Just now';
    
    final now = DateTime.now();
    final difference = now.difference(createdAt!);
    
    if (difference.inDays > 7) {
      return '${difference.inDays ~/ 7}w';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Just now';
    }
  }

  @override
  String toString() {
    return 'Article{id: $id, userId: $userId, title: $title, likes: $likes, comments: $comments}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Article &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}