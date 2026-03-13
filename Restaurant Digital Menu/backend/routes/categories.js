const express = require('express');
const router = express.Router();
const dishes = require('../data/menu.json');

/**
 * GET /api/categories
 * Returns all categories with a dish count.
 */
router.get('/', (_req, res) => {
  const categories = [
    { id: 'starter', label: 'Starters', emoji: '🥗' },
    { id: 'main', label: 'Main Course', emoji: '🍛' },
    { id: 'dessert', label: 'Desserts', emoji: '🍮' },
    { id: 'drinks', label: 'Drinks', emoji: '🥤' },
  ];

  const result = categories.map((cat) => ({
    ...cat,
    count: dishes.filter((d) => d.category === cat.id).length,
  }));

  res.json({ data: result });
});

module.exports = router;
