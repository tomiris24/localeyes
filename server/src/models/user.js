import mongoose from 'mongoose';

const { Schema } = mongoose;

export const ROLES = ['traveller', 'guide'];

const userSchema = new Schema(
  {
    name: { type: String, required: true, trim: true },
    // Stored lowercase so "Tomiris@..." and "tomiris@..." are one account.
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },
    passwordHash: { type: String, required: true },
    role: { type: String, enum: ROLES, default: 'traveller' },
  },
  { timestamps: true, versionKey: false },
);

// What the app is allowed to see: never the hash.
userSchema.methods.toPublic = function toPublic() {
  return {
    id: this._id.toString(),
    name: this.name,
    email: this.email,
    role: this.role,
    memberSince: this.createdAt,
  };
};

export const User = mongoose.model('User', userSchema);
