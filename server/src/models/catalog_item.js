import mongoose from 'mongoose';

const { Schema } = mongoose;

const catalogItemSchema = new Schema(
  {
    id: { type: String, required: true, unique: true },
    title: { type: String, required: true },
    category: String,
    rating: { type: Number, default: 0 },
    price: { type: Number, default: 0 },
    // Set on the rows pull-to-refresh adds, so the new item reads as new in
    // the app. Not called `isNew`: that name is reserved by Mongoose.
    recentlyAdded: { type: Boolean, default: false },
  },
  { timestamps: true, versionKey: false },
);

export const CatalogItem = mongoose.model('CatalogItem', catalogItemSchema);
