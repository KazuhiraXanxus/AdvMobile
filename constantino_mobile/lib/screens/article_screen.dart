import 'package:flutter/material.dart';
import '../models/article_model.dart';
import '../services/article_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';

class ArticleScreen extends StatefulWidget {
  final Article article;

  const ArticleScreen({
    super.key,
    required this.article,
  });

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  late Article _article;
  bool _isLiked = false;
  bool _isOwner = false;

  @override
  void initState() {
    super.initState();
    _article = widget.article;
    _isLiked = _article.isLiked;
    _checkOwnership();
  }

  Future<void> _checkOwnership() async {
    final userData = await UserService.getUserData();
    if (userData != null) {
      final currentUserId = userData['id'];
      setState(() {
        _isOwner = currentUserId == _article.userId;
        _isLiked = _article.likedBy.contains(currentUserId);
      });
    }
  }

  Future<void> _toggleLike() async {
    try {
      final userData = await UserService.getUserData();
      if (userData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to like articles')),
        );
        return;
      }

      final currentUserId = userData['id'];
      final result = await ArticleService.toggleLike(_article.id, currentUserId);
      
      setState(() {
        _isLiked = result['isLiked'];
        _article = _article.copyWith(
          likes: result['likes'],
          isLiked: result['isLiked'],
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating like: $e')),
      );
    }
  }

  Future<void> _deleteArticle() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Article'),
        content: const Text(
          'Are you sure you want to delete this article? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ArticleService.deleteArticle(_article.id);
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Article deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate deletion
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting article: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomText.heading2('Post Details'),
        actions: [
          if (_isOwner)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete Article',
              onPressed: _deleteArticle,
            ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showMoreOptions(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      _article.username.isNotEmpty
                          ? _article.username[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText.heading2(_article.username),
                        CustomText.caption(
                          '${_article.getTimeAgo()} • Public',
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      _showMoreOptions(context);
                    },
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText.heading1(_article.title),
                  
                  const SizedBox(height: 16),
                  
                  CustomText.body(_article.body),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),

            if (_article.imageUrl != null)
              Image.network(
                _article.imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (_article.likes > 0) ...[
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.thumb_up,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CustomText.body('${_article.likes}'),
                  ],
                  const Spacer(),
                  if (_article.comments > 0)
                    CustomText.caption('${_article.comments} Comments'),
                ],
              ),
            ),

            const Divider(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _DetailActionButton(
                    icon: _isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    label: 'Like',
                    onPressed: _toggleLike,
                    isActive: _isLiked,
                  ),
                  _DetailActionButton(
                    icon: Icons.comment_outlined,
                    label: 'Comment',
                    onPressed: () {
                      // Comment functionality will be inline
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            _CommentsSection(
              articleId: _article.id,
              initialComments: _article.commentsList,
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.bookmark_outline),
                title: const Text('Save Post'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Post saved!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.report_outlined),
                title: const Text('Report Post'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Post reported!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy Link'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link copied!')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

}

class _DetailActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isActive;

  const _DetailActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 8),
            CustomText.body(
              label,
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentsSection extends StatefulWidget {
  final String articleId;
  final List<Map<String, dynamic>> initialComments;

  const _CommentsSection({
    required this.articleId,
    this.initialComments = const [],
  });

  @override
  State<_CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<_CommentsSection> {
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _comments = List.from(widget.initialComments);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final userData = await UserService.getUserData();
    if (userData == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to comment')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ArticleService.addComment(
        widget.articleId,
        userData['id'],
        userData['name'],
        _commentController.text.trim(),
      );

      setState(() {
        _comments = List<Map<String, dynamic>>.from(result['commentsList']);
        _isLoading = false;
      });

      _commentController.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment posted!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error posting comment: $e')),
      );
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText.heading2('Comments (${_comments.length})'),
          const SizedBox(height: 16),
          
          // Comment Input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Write a comment...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    enabled: !_isLoading,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          Icons.send,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  onPressed: _isLoading ? null : _postComment,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Comments List
          if (_comments.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.comment_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    CustomText.body(
                      'No comments yet',
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(height: 8),
                    CustomText.caption(
                      'Be the first to comment!',
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._comments.map((comment) {
              final createdAt = comment['createdAt'] != null
                  ? DateTime.parse(comment['createdAt'])
                  : DateTime.now();

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            (comment['username'] ?? 'U')[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText.body(
                                comment['username'] ?? 'Unknown User',
                                fontWeight: FontWeight.w600,
                              ),
                              CustomText.caption(
                                _formatTime(createdAt),
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    CustomText.body(comment['comment'] ?? ''),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}