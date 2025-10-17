const express = require('express');
const {
  getArticles,
  createArticle,
  updateArticle,
  toggleArticleStatus,
  getArticleByName,
  deleteArticle,
  toggleLike,
  addComment,
  getComments,
} = require('../controllers/articleController');

const router = express.Router();

router.get('/', getArticles);
router.get('/:name', getArticleByName);
router.post('/', createArticle);
router.put('/:id', updateArticle);
router.patch('/:id/toggle', toggleArticleStatus);
router.delete('/:id', deleteArticle);
router.post('/:id/like', toggleLike);
router.post('/:id/comment', addComment);
router.get('/:id/comments', getComments);

module.exports = router;

