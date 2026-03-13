const express = require('express');
const router = express.Router();
const restaurant = require('../data/restaurant.json');

/**
 * GET /api/restaurant
 */
router.get('/', (_req, res) => {
  res.json({ data: restaurant });
});

module.exports = router;
