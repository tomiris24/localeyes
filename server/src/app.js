import cors from 'cors';
import express from 'express';
import mongoose from 'mongoose';

import { authRouter } from './routes/auth.js';
import { catalogRouter } from './routes/catalog.js';
import { localsRouter } from './routes/locals.js';
import { spotsRouter } from './routes/spots.js';
import { taxonomyRouter } from './routes/taxonomy.js';
import { toursRouter } from './routes/tours.js';

export function createApp() {
  const app = express();
  app.use(cors());
  app.use(express.json());

  app.get('/api/health', (_req, res) => {
    res.json({
      status: 'ok',
      db: mongoose.connection.readyState === 1 ? 'connected' : 'disconnected',
    });
  });

  app.use('/api/auth', authRouter);
  app.use('/api/tours', toursRouter);
  app.use('/api/locals', localsRouter);
  app.use('/api/spots', spotsRouter);
  app.use('/api/catalog', catalogRouter);
  app.use('/api/taxonomy', taxonomyRouter);

  app.use((_req, res) => res.status(404).json({ error: 'Not found' }));

  // One place where a thrown error becomes a JSON body, so no route needs a
  // try/catch of its own.
  app.use((error, _req, res, _next) => {
    console.error(error);
    res.status(500).json({ error: 'Internal server error' });
  });

  return app;
}
