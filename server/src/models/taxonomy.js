import mongoose from 'mongoose';

const { Schema } = mongoose;

// The fixed vocabularies the app filters by: tour categories, the interests a
// traveller and a local are matched on, city areas and the public places the
// app suggests for a first meetup. One document, key "default".
const taxonomySchema = new Schema(
  {
    key: { type: String, required: true, unique: true, default: 'default' },
    tourCategories: { type: [String], default: [] },
    interests: { type: [String], default: [] },
    areas: { type: [String], default: [] },
    publicMeetingPlaces: { type: [String], default: [] },
  },
  { timestamps: true, versionKey: false },
);

export const Taxonomy = mongoose.model('Taxonomy', taxonomySchema);
