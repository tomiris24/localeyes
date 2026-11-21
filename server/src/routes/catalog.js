import { readFile } from 'node:fs/promises';

import { Router } from 'express';

import { CatalogItem } from '../models/catalog_item.js';

export const catalogRouter = Router();

// The titles pull-to-refresh draws from. They live here, not on the phone, so
// every device sees the same catalog.
const GENERATED_TITLES = [
  'Big Almaty Lake before the crowds',
  'Night market and late supper',
  'Medeu steps at dusk',
  'Street art in the western districts',
  'Butakovka waterfall, easy pace',
  'Apple orchards of Alatau',
];

const GENERATED_CATEGORIES = [
  'Mountains',
  'Food',
  'City walk',
  'Culture',
  'Photography',
];

catalogRouter.get('/', async (_req, res) => {
  const items = await CatalogItem.find().sort({ createdAt: -1, id: 1 }).lean();
  res.json(items.map(toApi));
});

// Pull-to-refresh: one more item, invented by the server.
catalogRouter.post('/', async (req, res) => {
  const seq = (await CatalogItem.countDocuments()) + 1;
  const { id, title, category, rating, price } = req.body ?? {};
  const i = (seq - 1) % GENERATED_TITLES.length;

  // An id in the body means this is an undo: the row the app just deleted
  // comes back as it was, not as a new invention.
  const item = await CatalogItem.create({
    id: id ?? `c-${Date.now()}`,
    title: title ?? GENERATED_TITLES[i],
    category: category ?? GENERATED_CATEGORIES[i % GENERATED_CATEGORIES.length],
    // Keeps the demo data believable: 4.5 … 4.9, price 20 … 110.
    rating: rating ?? 4.5 + (seq % 5) * 0.1,
    price: price ?? 20 + (seq % 10) * 10,
    recentlyAdded: id == null,
  });
  res.status(201).json(toApi(item.toObject()));
});

// "Reset catalog" — back to the eight items the database was seeded with.
catalogRouter.post('/reset', async (_req, res) => {
  const seeded = JSON.parse(
    await readFile(new URL('../../seed/catalog.json', import.meta.url), 'utf8'),
  );
  await CatalogItem.deleteMany({});
  const items = await CatalogItem.insertMany(seeded);
  res.json(items.map((item) => toApi(item.toObject())));
});

// The app's field is `isNew`; the stored one cannot be — Mongoose reserves it.
function toApi({ recentlyAdded, ...item }) {
  return { ...item, isNew: Boolean(recentlyAdded) };
}

catalogRouter.delete('/:id', async (req, res) => {
  const result = await CatalogItem.deleteOne({ id: req.params.id });
  if (result.deletedCount === 0) {
    return res.status(404).json({ error: 'Catalog item not found' });
  }
  res.status(204).end();
});
