const mongoose = require('mongoose');

const contentSchema = new mongoose.Schema({
  account: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Account',
    required: true
  },
  platform: {
    type: String,
    required: true,
    enum: ['twitter', 'instagram', 'youtube', 'reddit', 'linkedin']
  },
  contentId: {
    type: String,
    required: true
  },
  contentType: {
    type: String,
    required: true,
    enum: ['post', 'tweet', 'photo', 'video', 'story', 'article', 'comment']
  },
  text: {
    type: String
  },
  mediaUrls: [{
    type: String
  }],
  mediaType: {
    type: String,
    enum: ['image', 'video', 'gif', 'audio', 'link', 'none']
  },
  link: {
    type: String
  },
  publishedAt: {
    type: Date,
    required: true
  },
  retrievedAt: {
    type: Date,
    default: Date.now
  },
  engagementStats: {
    likes: Number,
    comments: Number,
    shares: Number,
    views: Number
  },
  users: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    seen: {
      type: Boolean,
      default: false
    },
    seenAt: Date,
    saved: {
      type: Boolean,
      default: false
    },
    savedAt: Date,
    interaction: {
      liked: Boolean,
      commented: Boolean,
      shared: Boolean
    }
  }],
  rawData: {
    type: mongoose.Schema.Types.Mixed
  }
});

// Compound index to ensure uniqueness of content per platform
contentSchema.index({ platform: 1, contentId: 1 }, { unique: true });

// Index for efficient feed generation queries
contentSchema.index({ account: 1, publishedAt: -1 });
contentSchema.index({ platform: 1, publishedAt: -1 });

// Index for user-specific content queries
contentSchema.index({ 'users.user': 1, publishedAt: -1 });
contentSchema.index({ 'users.user': 1, 'users.saved': 1 });

// Instance method to add or update user interaction with content
contentSchema.methods.updateUserInteraction = async function(userId, interactionData) {
  const userIndex = this.users.findIndex(u => u.user.toString() === userId.toString());
  
  if (userIndex >= 0) {
    // Update existing record
    if (interactionData.seen) {
      this.users[userIndex].seen = true;
      this.users[userIndex].seenAt = new Date();
    }
    
    if (interactionData.saved !== undefined) {
      this.users[userIndex].saved = interactionData.saved;
      if (interactionData.saved) {
        this.users[userIndex].savedAt = new Date();
      }
    }
    
    if (interactionData.interaction) {
      this.users[userIndex].interaction = {
        ...this.users[userIndex].interaction,
        ...interactionData.interaction
      };
    }
  } else {
    // Add new user record
    this.users.push({
      user: userId,
      seen: interactionData.seen || false,
      seenAt: interactionData.seen ? new Date() : undefined,
      saved: interactionData.saved || false,
      savedAt: interactionData.saved ? new Date() : undefined,
      interaction: interactionData.interaction || {}
    });
  }
  
  return this.save();
};

// Static method to get content for a user's feed
contentSchema.statics.getFeedForUser = async function(userId, accounts, options = {}) {
  const {
    limit = 20,
    skip = 0,
    platform = null,
    onlySaved = false,
    includeRead = false,
    maxAge = null
  } = options;
  
  const query = {
    account: { $in: accounts }
  };
  
  if (platform) {
    query.platform = platform;
  }
  
  if (maxAge) {
    const maxAgeDate = new Date();
    maxAgeDate.setDate(maxAgeDate.getDate() - maxAge);
    query.publishedAt = { $gte: maxAgeDate };
  }
  
  if (onlySaved) {
    query['users.user'] = userId;
    query['users.saved'] = true;
  }
  
  if (!includeRead) {
    // Exclude content this user has already seen
    query.$or = [
      { 'users.user': { $ne: userId } },
      { 'users': { $elemMatch: { user: userId, seen: false } } }
    ];
  }
  
  return this.find(query)
    .sort({ publishedAt: -1 })
    .skip(skip)
    .limit(limit)
    .populate('account', 'username displayName profilePicture platform');
};

const Content = mongoose.model('Content', contentSchema);

module.exports = Content;