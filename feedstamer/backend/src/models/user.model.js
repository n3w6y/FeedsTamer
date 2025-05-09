const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const validator = require('validator');

const userSchema = new mongoose.Schema({
  email: {
    type: String,
    required: [true, 'Email is required'],
    unique: true,
    lowercase: true,
    validate: [validator.isEmail, 'Please provide a valid email']
  },
  password: {
    type: String,
    required: [true, 'Password is required'],
    minlength: 8,
    select: false
  },
  name: {
    type: String,
    required: [true, 'Name is required']
  },
  profilePicture: {
    type: String,
    default: ''
  },
  subscription: {
    type: {
      type: String,
      enum: ['free', 'premium', 'family', 'enterprise'],
      default: 'free'
    },
    startDate: {
      type: Date
    },
    endDate: {
      type: Date
    },
    status: {
      type: String,
      enum: ['active', 'cancelled', 'expired'],
      default: 'active'
    }
  },
  connectedPlatforms: [{
    platform: {
      type: String,
      enum: ['twitter', 'instagram', 'youtube', 'reddit', 'linkedin']
    },
    accessToken: {
      type: String
    },
    refreshToken: {
      type: String
    },
    tokenExpiry: {
      type: Date
    },
    userId: {
      type: String
    },
    username: {
      type: String
    },
    connected: {
      type: Boolean,
      default: true
    }
  }],
  preferences: {
    theme: {
      type: String,
      enum: ['light', 'dark', 'system'],
      default: 'system'
    },
    notifications: {
      enabled: {
        type: Boolean,
        default: true
      },
      types: {
        newContent: {
          type: Boolean,
          default: true
        },
        accountActivity: {
          type: Boolean,
          default: true
        },
        usageReminders: {
          type: Boolean,
          default: true
        }
      }
    },
    FeedsSettings: {
      defaultView: {
        type: String,
        enum: ['unified', 'platform'],
        default: 'unified'
      },
      contentOrder: {
        type: String,
        enum: ['chronological', 'platform'],
        default: 'chronological'
      },
      showReadPosts: {
        type: Boolean,
        default: false
      }
    },
    sessionLimits: {
      enabled: {
        type: Boolean,
        default: false
      },
      dailyLimit: {
        type: Number,
        default: 60 // minutes
      },
      reminderInterval: {
        type: Number,
        default: 20 // minutes
      }
    }
  },
  analytics: {
    timeSpent: [{
      date: {
        type: Date
      },
      minutes: {
        type: Number,
        default: 0
      },
      platform: {
        type: String
      }
    }],
    contentViewed: [{
      date: {
        type: Date
      },
      count: {
        type: Number,
        default: 0
      },
      platform: {
        type: String
      }
    }]
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  passwordChangedAt: Date,
  passwordResetToken: String,
  passwordResetExpires: Date,
  active: {
    type: Boolean,
    default: true,
    select: false
  }
});

// Hash the password before saving
userSchema.pre('save', async function(next) {
  // Only run this function if password was modified
  if (!this.isModified('password')) return next();

  // Hash the password with cost of 12
  this.password = await bcrypt.hash(this.password, 12);

  next();
});

userSchema.pre('save', function(next) {
  if (!this.isModified('password') || this.isNew) return next();

  this.passwordChangedAt = Date.now() - 1000;
  next();
});

userSchema.pre(/^find/, function(next) {
  // this points to the current query
  this.find({ active: { $ne: false } });
  next();
});

// Instance method to check if password is correct
userSchema.methods.correctPassword = async function(candidatePassword, userPassword) {
  return await bcrypt.compare(candidatePassword, userPassword);
};

// Check if password was changed after token was issued
userSchema.methods.changedPasswordAfter = function(JWTTimestamp) {
  if (this.passwordChangedAt) {
    const changedTimestamp = parseInt(
      this.passwordChangedAt.getTime() / 1000,
      10
    );
    return JWTTimestamp < changedTimestamp;
  }
  return false;
};

const User = mongoose.model('User', userSchema);

module.exports = User;