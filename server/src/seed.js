import 'dotenv/config';

import { readFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';

import { connect, disconnect } from './db.js';
import { CatalogItem } from './models/catalog_item.js';
import { LocalPerson } from './models/local_person.js';
import { Spot } from './models/spot.js';
import { Taxonomy } from './models/taxonomy.js';
import { Tour } from './models/tour.js';

const seedDir = new URL('../seed/', import.meta.url);

async function readSeed(name) {
  return JSON.parse(await readFile(new URL(`${name}.json`, seedDir), 'utf8'));
}

// Wipes the collections and loads them from seed/*.json. Safe to re-run: the
// demo data is the only thing in there.
export async function seed() {
  const [tours, locals, spots, catalog, taxonomy] = await Promise.all([
    readSeed('tours'),
    readSeed('locals'),
    readSeed('spots'),
    readSeed('catalog'),
    readSeed('taxonomy'),
  ]);

  await Promise.all([
    Tour.deleteMany({}),
    LocalPerson.deleteMany({}),
    Spot.deleteMany({}),
    CatalogItem.deleteMany({}),
    Taxonomy.deleteMany({}),
  ]);

  await Promise.all([
    Tour.insertMany(tours),
    LocalPerson.insertMany(locals),
    Spot.insertMany(spots),
    CatalogItem.insertMany(catalog),
    Taxonomy.create({ key: 'default', ...taxonomy }),
  ]);

  return {
    tours: tours.length,
    locals: locals.length,
    spots: spots.length,
    catalog: catalog.length,
  };
}

// Run directly (`npm run seed`), not when imported by a test.
if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const connection = await connect();
  const counts = await seed();
  console.log(`Seeded ${connection.name}:`, counts);
  await disconnect();
}
