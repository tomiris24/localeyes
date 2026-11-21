import { Router } from 'express';

import { Spot } from '../models/spot.js';

export const spotsRouter = Router();

// GET /api/spots?addedById=l1 — the map, and a local's favourite places.
spotsRouter.get('/', async (req, res) => {
  const { addedById } = req.query;
  const filter = addedById ? { addedById } : {};
  const spots = await Spot.find(filter).sort({ saveCount: -1 }).lean();
  res.json(spots);
});

spotsRouter.get('/:id', async (req, res) => {
  const spot = await Spot.findOne({ id: req.params.id }).lean();
  if (!spot) return res.status(404).json({ error: 'Spot not found' });
  res.json(spot);
});
