import { Router } from 'express';

import { Tour } from '../models/tour.js';

export const toursRouter = Router();

// GET /api/tours?category=Food&q=bazaar
// The feed filters server-side so a phone only downloads what it shows.
toursRouter.get('/', async (req, res) => {
  const { category, q } = req.query;
  const filter = {};
  if (category && category !== 'All') filter.category = category;
  if (q) {
    const term = new RegExp(escapeRegExp(String(q)), 'i');
    filter.$or = [{ title: term }, { area: term }, { summary: term }];
  }
  const tours = await Tour.find(filter).sort({ id: 1 }).lean();
  res.json(tours);
});

toursRouter.get('/:id', async (req, res) => {
  const tour = await Tour.findOne({ id: req.params.id }).lean();
  if (!tour) return res.status(404).json({ error: 'Tour not found' });
  res.json(tour);
});

function escapeRegExp(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}
