class Article {
  final String id;
  final String userId;
  final String username;
  final String title;
  final String body;
  final String? imageUrl;
  final DateTime? createdAt;
  final int likes;
  final int comments;
  final bool isLiked;
  final List<String> likedBy;
  final List<Map<String, dynamic>> commentsList;

  Article({
    required this.id,
    required this.userId,
    required this.username,
    required this.title,
    required this.body,
    this.imageUrl,
    this.createdAt,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
    this.likedBy = const [],
    this.commentsList = const [],
  });

  // Factory constructor to create Article from JSON
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '0',
      username: json['username'] ?? 'Unknown User',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      imageUrl: json['imageUrl'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      likedBy: json['likedBy'] != null 
          ? List<String>.from(json['likedBy'])
          : [],
      commentsList: json['commentsList'] != null
          ? List<Map<String, dynamic>>.from(json['commentsList'])
          : [],
    );
  }

  // Convert Article to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'createdAt': createdAt?.toIso8601String(),
      'likes': likes,
      'comments': comments,
      'isLiked': isLiked,
      'likedBy': likedBy,
      'commentsList': commentsList,
    };
  }

  // Create a copy of Article with updated fields
  Article copyWith({
    String? id,
    String? userId,
    String? username,
    String? title,
    String? body,
    String? imageUrl,
    DateTime? createdAt,
    int? likes,
    int? comments,
    bool? isLiked,
    List<String>? likedBy,
    List<Map<String, dynamic>>? commentsList,
  }) {
    return Article(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
      likedBy: likedBy ?? this.likedBy,
      commentsList: commentsList ?? this.commentsList,
    );
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