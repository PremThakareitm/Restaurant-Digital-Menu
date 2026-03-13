const express = require('express');
const router = express.Router();
const dishes = require('../data/menu.json');

/**
 * POST /api/orders
 * Body: { items: [{ dishId: string, quantity: number }] }
 */
router.post('/', (req, res) => {
  const { items } = req.body;

  // ─── Basic input validation ────────────────────────────────────────────────
  if (!Array.isArray(items) || items.length === 0) {
    return res.status(400).json({ error: 'items must be a non-empty array' });
  }

  const orderLines = [];
  let subtotal = 0;

  for (const item of items) {
    const { dishId, quantity } = item;

    if (typeof dishId !== 'string' || !Number.isInteger(quantity) || quantity < 1) {
      return res.status(400).json({
        error: `Invalid item: dishId must be a string and quantity a positive integer`,
      });
    }

    const dish = dishes.find((d) => d.id === dishId);
    if (!dish) {
      return res.status(404).json({ error: `Dish not found: ${dishId}` });
    }

    const lineTotal = dish.price * quantity;
    subtotal += lineTotal;
    orderLines.push({
      dish: { id: dish.id, name: dish.name, price: dish.price },
      quantity,
      lineTotal: +lineTotal.toFixed(2),
    });
  }

  const tax = +(subtotal * 0.08).toFixed(2);
  const total = +(subtotal + tax).toFixed(2);
  const orderId = `ORD-${Date.now()}`;

  // In a real system this would be persisted to a database.
  res.status(201).json({
    data: {
      orderId,
      items: orderLines,
      subtotal: +subtotal.toFixed(2),
      tax,
      total,
      estimatedWaitMinutes: 25 + Math.floor(Math.random() * 11),
      placedAt: new Date().toISOString(),
    },
  });
});

module.exports = router;
