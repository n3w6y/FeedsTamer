const User = require('../models/user.model');
const Account = require('../models/account.model');
const Content = require('../models/content.model');
const { catchAsync } = require('../utils/errorHandler');
const AppError = require('../utils/appError');

// Get user's Feeds
exports.getFeeds = catchAsync(async (req, res, next) => {
  const userId = req.user._id;
  
  // Get user's followed accounts
  const followedAccounts = await Account.find({ 
    user: userId,
    isActive: true 
  });
  
  if (followedAccounts.length === 0) {
    return res.status(200).json({
      status: 'success',
      results: 0,
      data: {
        content: []
      }
    });
  }
  
  const accountIds = followedAccounts.map(account => account._id);
  
  // Build Feeds options from query parameters
  const options = {
    limit: parseInt(req.query.limit) || 20,
    skip: parseInt(req.query.skip) || 0,
    platform: req.query.platform || null,
    onlySaved: req.query.saved === 'true',
    includeRead: req.query.includeRead === 'true',
    maxAge: req.query.maxAge ? parseInt(req.query.maxAge) : null
  };
  
  // Get content for Feeds
  const content = await Content.getFeedsForUser(userId, accountIds, options);
  
  // Return Feeds
  res.status(200).json({
    status: 'success',
    results: content.length,
    data: {
      content
    }
  });
});

// Mark content as read/seen
exports.markContentSeen = catchAsync(async (req, res, next) => {
  const { contentId } = req.params;
  const userId = req.user._id;
  
  const content = await Content.findById(contentId);
  
  if (!content) {
    return next(new AppError('Content not found', 404));
  }
  
  // Update user interaction to mark content as seen
  await content.updateUserInteraction(userId, { seen: true });
  
  res.status(200).json({
    status: 'success',
    data: {
      content
    }
  });
});

// Save/bookmark content
exports.toggleSaveContent = catchAsync(async (req, res, next) => {
  const { contentId } = req.params;
  const userId = req.user._id;
  const { saved } = req.body;
  
  const content = await Content.findById(contentId);
  
  if (!content) {
    return next(new AppError('Content not found', 404));
  }
  
  // Toggle saved status
  await content.updateUserInteraction(userId, { saved });
  
  res.status(200).json({
    status: 'success',
    data: {
      content
    }
  });
});

// Get saved content
exports.getSavedContent = catchAsync(async (req, res, next) => {
  const userId = req.user._id;
  
  // Get all account IDs that the user follows
  const followedAccounts = await Account.find({ 
    user: userId,
    isActive: true 
  });
  
  const accountIds = followedAccounts.map(account => account._id);
  
  // Build options for saved content
  const options = {
    limit: parseInt(req.query.limit) || 20,
    skip: parseInt(req.query.skip) || 0,
    platform: req.query.platform || null,
    onlySaved: true
  };
  
  // Get saved content
  const content = await Content.getFeedsForUser(userId, accountIds, options);
  
  res.status(200).json({
    status: 'success',
    results: content.length,
    data: {
      content
    }
  });
});

// Get Feeds grouped by platform
exports.getFeedsByPlatform = catchAsync(async (req, res, next) => {
  const userId = req.user._id;
  
  // Get user's followed accounts
  const followedAccounts = await Account.find({ 
    user: userId,
    isActive: true 
  });
  
  if (followedAccounts.length === 0) {
    return res.status(200).json({
      status: 'success',
      data: {}
    });
  }
  
  const accountIds = followedAccounts.map(account => account._id);
  
  // Get platforms the user has connected
  const platforms = [...new Set(followedAccounts.map(account => account.platform))];
  
  // Build options from query parameters
  const baseOptions = {
    limit: parseInt(req.query.limit) || 10,
    includeRead: req.query.includeRead === 'true',
    maxAge: req.query.maxAge ? parseInt(req.query.maxAge) : null
  };
  
  // Get content for each platform
  const result = {};
  
  for (const platform of platforms) {
    const options = {
      ...baseOptions,
      platform
    };
    
    const platformContent = await Content.getFeedsForUser(userId, accountIds, options);
    
    result[platform] = platformContent;
  }
  
  res.status(200).json({
    status: 'success',
    data: result
  });
});

// Get content for a specific account
exports.getAccountContent = catchAsync(async (req, res, next) => {
  const { accountId } = req.params;
  const userId = req.user._id;
  
  // Check if user follows this account
  const account = await Account.findOne({ 
    _id: accountId,
    user: userId,
    isActive: true
  });
  
  if (!account) {
    return next(new AppError('Account not found or you do not follow this account', 404));
  }
  
  // Get content for this account
  const options = {
    limit: parseInt(req.query.limit) || 20,
    skip: parseInt(req.query.skip) || 0,
    includeRead: req.query.includeRead === 'true'
  };
  
  const content = await Content.find({ account: accountId })
    .sort({ publishedAt: -1 })
    .skip(options.skip)
    .limit(options.limit);
  
  res.status(200).json({
    status: 'success',
    results: content.length,
    data: {
      account,
      content
    }
  });
});