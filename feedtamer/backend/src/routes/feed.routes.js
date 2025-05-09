const express = require('express');
const feedController = require('../controllers/feed.controller');
const authController = require('../controllers/auth.controller');

const router = express.Router();

// Protect all feed routes
router.use(authController.protect);

// Feed routes
router.get('/', feedController.getFeed);
router.get('/by-platform', feedController.getFeedByPlatform);
router.get('/saved', feedController.getSavedContent);
router.get('/account/:accountId', feedController.getAccountContent);

// Content interaction routes
router.patch('/:contentId/seen', feedController.markContentSeen);
router.patch('/:contentId/save', feedController.toggleSaveContent);

module.exports = router;