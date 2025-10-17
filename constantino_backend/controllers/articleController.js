const Article = require('../models/Article');

const getArticles = async (req, res) => {
  try {
    const articles = await Article.find();
    res.json({ articles });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const createArticle = async (req, res) => {
  try {
    const article = await Article.create(req.body);
    res.status(201).json(article);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const updateArticle = async (req, res) => {
  try {
    const article = await Article.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true }
    );
    res.json(article);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const toggleArticleStatus = async (req, res) => {
  try {
    const article = await Article.findById(req.params.id);
    article.isActive = !article.isActive;
    await article.save();
    res.json(article);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const getArticleByName = async (req, res) => {
  try {
    const article = await Article.findOne({
      name: req.params.name,
      isActive: true,
    });
    if (!article) {
      return res.status(404).json({ message: 'Article not found' });
    }
    res.json({ article });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const deleteArticle = async (req, res) => {
  try {
    const article = await Article.findByIdAndDelete(req.params.id);
    if (!article) {
      return res.status(404).json({ message: 'Article not found' });
    }
    res.json({ message: 'Article deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const toggleLike = async (req, res) => {
  try {
    const { userId } = req.body;
    const article = await Article.findById(req.params.id);
    
    if (!article) {
      return res.status(404).json({ message: 'Article not found' });
    }

    // Check if user already liked
    const likedIndex = article.likedBy.indexOf(userId);
    
    if (likedIndex > -1) {
      // Unlike - remove user from array
      article.likedBy.splice(likedIndex, 1);
      article.likes = article.likedBy.length;
    } else {
      // Like - add user to array
      article.likedBy.push(userId);
      article.likes = article.likedBy.length;
    }

    await article.save({ validateBeforeSave: false });
    res.json({
      likes: article.likes,
      isLiked: article.likedBy.includes(userId),
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const addComment = async (req, res) => {
  try {
    const { userId, username, comment } = req.body;
    const article = await Article.findById(req.params.id);
    
    if (!article) {
      return res.status(404).json({ message: 'Article not found' });
    }

    // Add comment to the array
    article.commentsList.push({
      userId,
      username,
      comment,
      createdAt: new Date(),
    });

    // Update comment count
    article.comments = article.commentsList.length;

    await article.save({ validateBeforeSave: false });
    res.json({
      comments: article.comments,
      commentsList: article.commentsList,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getComments = async (req, res) => {
  try {
    const article = await Article.findById(req.params.id);
    
    if (!article) {
      return res.status(404).json({ message: 'Article not found' });
    }

    res.json({
      comments: article.comments,
      commentsList: article.commentsList,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  getArticles,
  createArticle,
  updateArticle,
  toggleArticleStatus,
  getArticleByName,
  deleteArticle,
  toggleLike,
  addComment,
  getComments,
};

