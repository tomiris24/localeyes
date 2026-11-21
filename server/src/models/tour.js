import mongoose from 'mongoose';

const { Schema } = mongoose;

const routeStopSchema = new Schema(
  { time: String, title: String, note: String },
  { _id: false },
);

const factsSchema = new Schema(
  {
    difficulty: String,
    walkingTime: String,
    groupSize: String,
    languageLevel: String,
    meetingPoint: String,
  },
  { _id: false },
);

// The guide rides inside the tour: every screen that shows a tour also shows
// its guide, so one document answers the whole detail screen in one read.
const guideSchema = new Schema(
  {
    id: { type: String, required: true },
    name: { type: String, required: true },
    yearsOfExperience: { type: Number, default: 0 },
    languages: { type: [String], default: [] },
    rating: { type: Number, default: 0 },
    tourCount: { type: Number, default: 0 },
    responseTime: String,
    bio: String,
    isVerified: { type: Boolean, default: true },
  },
  { _id: false },
);

const reviewSchema = new Schema(
  {
    author: String,
    country: String,
    rating: Number,
    timeAgo: String,
    text: String,
  },
  { _id: false },
);

const tourSchema = new Schema(
  {
    id: { type: String, required: true, unique: true },
    title: { type: String, required: true },
    area: String,
    image: String,
    imageCredit: String,
    category: { type: String, index: true },
    pricePerPerson: { type: Number, default: 0 },
    rating: { type: Number, default: 0 },
    reviewCount: { type: Number, default: 0 },
    duration: String,
    tags: { type: [String], default: [] },
    summary: String,
    included: { type: [String], default: [] },
    route: { type: [routeStopSchema], default: [] },
    facts: factsSchema,
    guide: guideSchema,
    reviews: { type: [reviewSchema], default: [] },
    availableDates: { type: [String], default: [] },
    maxGuests: { type: Number, default: 8 },
  },
  { timestamps: true, versionKey: false },
);

export const Tour = mongoose.model('Tour', tourSchema);
