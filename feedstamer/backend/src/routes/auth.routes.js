const express = require('express');
const authController = require('../controllers/auth.controller');

const router = express.Router();

// Public routes
router.post('/signup', authController.signup);
router.post('/login', authController.login);

// Protected routes
router.use(authController.protect);
router.get('/me', authController.getMe);
router.patch('/updateMe', authController.updateMe);
router.patch('/updatePassword', authController.updatePassword);
router.delete('/deleteMe', authController.deleteMe);

module.exports = router;