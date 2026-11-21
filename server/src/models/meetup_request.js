import mongoose from 'mongoose';

const { Schema } = mongoose;

// What the meetup form sends: who it is for, when, where and what was said.
const meetupRequestSchema = new Schema(
  {
    localId: { type: String, required: true, index: true },
    travellerName: { type: String, required: true },
    when: String,
    meetingPlace: String,
    message: String,
    status: {
      type: String,
      enum: ['pending', 'accepted', 'declined'],
      default: 'pending',
    },
  },
  { timestamps: true, versionKey: false },
);

export const MeetupRequest = mongoose.model(
  'MeetupRequest',
  meetupRequestSchema,
);
