const mongoose = require('mongoose');

const accountSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  platform: {
    type: String,
    required: true,
    enum: ['twitter', 'instagram', 'youtube', 'reddit', 'linkedin']
  },
  accountId: {
    type: String,
    required: true
  },
  username: {
    type: String,
    required: true
  },
  displayName: {
    type: String
  },
  profilePicture: {
    type: String
  },
  description: {
    type: String
  },
  category: {
    type: String
  },
  followerCount: {
    type: Number
  },
  followingCount: {
    type: Number
  },
  postCount: {
    type: Number
  },
  isVerified: {
    type: Boolean,
    default: false
  },
  lastUpdated: {
    type: Date,
    default: Date.now
  },
  isActive: {
    type: Boolean,
    default: true
  },
  categories: [{
    type: String
  }],
  tags: [{
    type: String
  }],
  notificationSettings: {
    enabled: {
      type: Boolean,
      default: true
    },
    frequency: {
      type: String,
      enum: ['all', 'daily', 'none'],
      default: 'all'
    }
  },
  pinned: {
    type: Boolean,
    default: false
  },
  pinnedOrder: {
    type: Number
  },
  userNotes: {
    type: String
  },
  lastContent: {
    id: String,
    timestamp: Date,
    type: String
  },
  stats: {
    averagePostsPerWeek: Number,
    averageEngagementRate: Number,
    readPercentage: Number,
    lastInteraction: Date
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

// Compound index to ensure a user can't follow the same account more than once
accountSchema.index({ user: 1, platform: 1, accountId: 1 }, { unique: true });

// Index for faster lookups by platform
accountSchema.index({ platform: 1 });

// Pre-save middleware to ensure pinned accounts have a pinnedOrder
accountSchema.pre('save', async function(next) {
  if (this.pinned && !this.pinnedOrder) {
    // Get highest current pinnedOrder for this user
    const highestPinned = await this.constructor.findOne({ 
      user: this.user, 
      pinned: true 
    }).sort('-pinnedOrder');
    
    this.pinnedOrder = highestPinned ? highestPinned.pinnedOrder + 1 : 1;
  }
  next();
});

const Account = mongoose.model('Account', accountSchema);

module.exports = Account;