import mongoose from 'mongoose';

const DEFAULT_URI = 'mongodb://127.0.0.1:27017/localeyes';

export async function connect(uri = process.env.MONGODB_URI || DEFAULT_URI) {
  mongoose.set('strictQuery', true);
  await mongoose.connect(uri);
  return mongoose.connection;
}

export async function disconnect() {
  await mongoose.disconnect();
}
