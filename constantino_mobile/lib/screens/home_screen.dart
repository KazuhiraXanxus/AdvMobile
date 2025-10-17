import 'package:flutter/material.dart';
import '../models/article_model.dart';
import '../services/article_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';
import 'article_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Article> _articles = [];
  List<Article> _filteredArticles = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    try {
      setState(() => _isLoading = true);
      final articles = await ArticleService.fetchArticles();
      
      // Check if current user has liked each article
      final userData = await UserService.getUserData();
      final currentUserId = userData?['id'];
      
      final articlesWithLikes = articles.map((article) {
        if (currentUserId != null) {
          final isLiked = article.likedBy.contains(currentUserId);
          return article.copyWith(isLiked: isLiked);
        }
        return article;
      }).toList();
      
      setState(() {
        _articles = articlesWithLikes;
        _filteredArticles = articlesWithLikes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading articles: $e')),
        );
      }
    }
  }

  void _filterArticles(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredArticles = _articles;
      } else {
        _filteredArticles = _articles
            .where((article) =>
                article.title.toLowerCase().contains(query.toLowerCase()) ||
                article.body.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _toggleLike(Article article) async {
    try {
      final userData = await UserService.getUserData();
      if (userData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to like articles')),
        );
        return;
      }

      final currentUserId = userData['id'];
      final result = await ArticleService.toggleLike(article.id, currentUserId);
      
      setState(() {
        final index = _articles.indexWhere((a) => a.id == article.id);
        if (index != -1) {
          _articles[index] = article.copyWith(
            likes: result['likes'],
            isLiked: result['isLiked'],
          );
        }
        final filteredIndex = _filteredArticles.indexWhere((a) => a.id == article.id);
        if (filteredIndex != -1) {
          _filteredArticles[filteredIndex] = article.copyWith(
            likes: result['likes'],
            isLiked: result['isLiked'],
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating like: $e')),
      );
    }
  }

  void _showAddArticleDialog() {
    final nameController = TextEditingController();
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    final imageUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Article'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name (Unique)',
                  hintText: 'Enter unique article name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter article title',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bodyController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  hintText: 'Enter article content',
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL (Optional)',
                  hintText: 'https://example.com/image.jpg',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty || 
                  titleController.text.trim().isEmpty || 
                  bodyController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in all fields')),
                );
                return;
              }

              try {
                // Get current user info
                final userData = await UserService.getUserData();
                final userId = userData?['id'] ?? 'unknown';
                final username = userData?['name'] ?? 'Unknown User';

                await ArticleService.createArticle({
                  'name': nameController.text.trim(),
                  'title': titleController.text.trim(),
                  'content': [bodyController.text.trim()],
                  'userId': userId,
                  'username': username,
                  if (imageUrlController.text.trim().isNotEmpty)
                    'imageUrl': imageUrlController.text.trim(),
                });
                
                if (!mounted) return;
                Navigator.pop(context);
                _loadArticles();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Article created successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error creating article: $e')),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomText.heading2('Articles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Toggle search bar visibility
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddArticleDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Article'),
      ),
      body: Column(
        children: [
          // Search Bar Enhancement 1
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search articles...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterArticles('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
              ),
              onChanged: _filterArticles,
            ),
          ),
          
          // Articles List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredArticles.isEmpty
                    ? Center(
                        child: CustomText.body(
                          _searchQuery.isEmpty
                              ? 'No articles available'
                              : 'No articles found for "$_searchQuery"',
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadArticles,
                        child: ListView.builder(
                          itemCount: _filteredArticles.length,
                          itemBuilder: (context, index) {
                            return _ArticleCard(
                              article: _filteredArticles[index],
                              onLike: () => _toggleLike(_filteredArticles[index]),
                              onTap: () async {
                                // Enhancement 2: Navigate to details page
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ArticleScreen(
                                      article: _filteredArticles[index],
                                    ),
                                  ),
                                );
                                // If article was deleted, refresh the list
                                if (result == true) {
                                  _loadArticles();
                                }
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onLike;
  final VoidCallback onTap;

  const _ArticleCard({
    required this.article,
    required this.onLike,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info and time
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      article.username.isNotEmpty
                          ? article.username[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText.heading2(article.username),
                        CustomText.caption(article.getTimeAgo()),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {},
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Article title
              CustomText.heading2(article.title),
              
              const SizedBox(height: 8),
              
              // Article body
              CustomText.body(
                article.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Article image if available
              if (article.imageUrl != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    article.imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  ),
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Like and comment counts
              Row(
                children: [
                  if (article.likes > 0) ...[
                    Icon(
                      Icons.thumb_up,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    CustomText.caption('${article.likes}'),
                  ],
                  const Spacer(),
                  if (article.comments > 0) ...[
                    CustomText.caption('${article.comments} comments'),
                  ],
                ],
              ),
              
              const Divider(),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ActionButton(
                    icon: article.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    label: 'Like',
                    onPressed: onLike,
                    isActive: article.isLiked,
                  ),
                  _ActionButton(
                    icon: Icons.comment_outlined,
                    label: 'Comment',
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isActive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
            const SizedBox(width: 4),
            CustomText.caption(
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