import 'dotenv/config';

import { createApp } from './app.js';
import { connect } from './db.js';

const port = Number(process.env.PORT) || 3000;

const connection = await connect();
console.log(`MongoDB connected: ${connection.name}`);

createApp().listen(port, () => {
  console.log(`LocalEyes API on http://localhost:${port}`);
});
