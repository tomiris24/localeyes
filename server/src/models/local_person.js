import mongoose from 'mongoose';

const { Schema } = mongoose;

export const AVAILABILITY = ['today', 'tomorrow', 'weekend', 'laterOn'];
export const MEETUP_COST = ['free', 'coffee', 'hourly'];
export const HANGOUT_KINDS = [
  'coffee',
  'walk',
  'food',
  'photo',
  'nightOut',
  'music',
  'sport',
  'language',
];

const languageSchema = new Schema(
  { language: String, level: String },
  { _id: false },
);

const hangoutSchema = new Schema(
  { kind: { type: String, enum: HANGOUT_KINDS }, note: String },
  { _id: false },
);

const localPersonSchema = new Schema(
  {
    id: { type: String, required: true, unique: true },
    name: { type: String, required: true },
    age: Number,
    neighbourhood: { type: String, index: true },
    oneLiner: String,
    bio: String,
    languages: { type: [languageSchema], default: [] },
    interests: { type: [String], default: [] },
    hangouts: { type: [hangoutSchema], default: [] },
    availability: { type: String, enum: AVAILABILITY, index: true },
    usualTimes: String,
    cost: { type: String, enum: MEETUP_COST },
    hourlyRate: { type: Number, default: 0 },
    meetCount: { type: Number, default: 0 },
    rating: { type: Number, default: 0 },
    responseTime: String,
    memberSince: String,
    favouriteSpotIds: { type: [String], default: [] },
    isPhoneVerified: { type: Boolean, default: true },
  },
  { timestamps: true, versionKey: false },
);

export const LocalPerson = mongoose.model('LocalPerson', localPersonSchema);
