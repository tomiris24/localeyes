import { Router } from 'express';

import { Taxonomy } from '../models/taxonomy.js';

export const taxonomyRouter = Router();

taxonomyRouter.get('/', async (_req, res) => {
  const taxonomy = await Taxonomy.findOne({ key: 'default' }).lean();
  if (!taxonomy) return res.status(404).json({ error: 'Taxonomy not seeded' });
  res.json(taxonomy);
});
