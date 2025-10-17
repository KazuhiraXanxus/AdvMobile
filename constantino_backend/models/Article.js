const mongoose = require('mongoose');

const articleSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    unique: true,
  },
  title: {
    type: String,
    required: true,
  },
  content: {
    type: [String],
    required: true,
  },
  imageUrl: {
    type: String,
    default: null,
  },
  userId: {
    type: String,
  },
  username: {
    type: String,
  },
  likes: {
    type: Number,
    default: 0,
  },
  comments: {
    type: Number,
    default: 0,
  },
  likedBy: [
    {
      type: String, // Store user IDs who liked this article
    },
  ],
  commentsList: [
    {
      userId: {
        type: String,
        required: true,
      },
      username: {
        type: String,
        required: true,
      },
      comment: {
        type: String,
        required: true,
      },
      createdAt: {
        type: Date,
        default: Date.now,
      },
    },
  ],
  isActive: {
    type: Boolean,
    default: true,
  },
}, {
  timestamps: true,
});

module.exports = mongoose.model('Article', articleSchema);

