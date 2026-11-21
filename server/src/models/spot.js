import mongoose from 'mongoose';

const { Schema } = mongoose;

const spotSchema = new Schema(
  {
    id: { type: String, required: true, unique: true },
    name: { type: String, required: true },
    area: String,
    kind: String,
    why: String,
    addedById: { type: String, index: true },
    addedByName: String,
    saveCount: { type: Number, default: 0 },
    bestTime: { type: String, default: 'Any time' },
    lat: { type: Number, required: true },
    lng: { type: Number, required: true },
  },
  { timestamps: true, versionKey: false },
);

export const Spot = mongoose.model('Spot', spotSchema);
