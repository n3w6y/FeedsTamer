const express = require('express');
const FeedsController = require('../controllers/Feeds.controller');
const authController = require('../controllers/auth.controller');

const router = express.Router();

// Protect all Feeds routes
router.use(authController.protect);

// Feeds routes
router.get('/', FeedsController.getFeeds);
router.get('/by-platform', FeedsController.getFeedsByPlatform);
router.get('/saved', FeedsController.getSavedContent);
router.get('/account/:accountId', FeedsController.getAccountContent);

// Content interaction routes
router.patch('/:contentId/seen', FeedsController.markContentSeen);
router.patch('/:contentId/save', FeedsController.toggleSaveContent);

module.exports = router;