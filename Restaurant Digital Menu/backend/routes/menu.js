const express = require('express');
const router = express.Router();
const dishes = require('../data/menu.json');

/**
 * GET /api/dishes
 * Query params:
 *   category   – filter by category id  (starter | main | dessert | drinks)
 *   search     – full-text search across name, description, ingredients
 *   veg        – "true" / "false"
 *   spicy      – "true" / "false"
 *   bestseller – "true" / "false"
 *   sort       – "price_asc" | "price_desc" | "rating_desc" (default)
 *   page       – page number (default 1)
 *   limit      – items per page (default 20, max 50)
 */
router.get('/', (req, res) => {
  const {
    category,
    search,
    veg,
    spicy,
    bestseller,
    sort = 'rating_desc',
    page = '1',
    limit = '20',
  } = req.query;

  let result = [...dishes];

  // ─── Filters ──────────────────────────────────────────────────────────────
  if (category) {
    result = result.filter((d) => d.category === category);
  }

  if (search) {
    const q = search.toLowerCase();
    result = result.filter(
      (d) =>
        d.name.toLowerCase().includes(q) ||
        d.description.toLowerCase().includes(q) ||
        d.ingredients.some((ing) => ing.toLowerCase().includes(q))
    );
  }

  if (veg === 'true') result = result.filter((d) => d.isVeg);
  if (veg === 'false') result = result.filter((d) => !d.isVeg);
  if (spicy === 'true') result = result.filter((d) => d.isSpicy);
  if (bestseller === 'true') result = result.filter((d) => d.isBestseller);

  // ─── Sorting ──────────────────────────────────────────────────────────────
  if (sort === 'price_asc') result.sort((a, b) => a.price - b.price);
  else if (sort === 'price_desc') result.sort((a, b) => b.price - a.price);
  else result.sort((a, b) => b.rating - a.rating); // rating_desc

  // ─── Pagination ───────────────────────────────────────────────────────────
  const pageNum = Math.max(1, parseInt(page, 10));
  const limitNum = Math.min(50, Math.max(1, parseInt(limit, 10)));
  const total = result.length;
  const totalPages = Math.ceil(total / limitNum);
  result = result.slice((pageNum - 1) * limitNum, pageNum * limitNum);

  res.json({
    data: result,
    meta: { total, page: pageNum, limit: limitNum, totalPages },
  });
});

/**
 * GET /api/dishes/:id
 */
router.get('/:id', (req, res) => {
  const dish = dishes.find((d) => d.id === req.params.id);
  if (!dish) return res.status(404).json({ error: 'Dish not found' });
  res.json({ data: dish });
});

module.exports = router;
