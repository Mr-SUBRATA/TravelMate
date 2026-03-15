import mongoose, { Document, Schema } from 'mongoose';

export interface IUserPreference extends Document {
  userId: string;
  quizAnswers: {
    artInterest: number;
    foodieScore: number;
    adventureSeeking: number;
    crowdTolerance: number;
    budgetConscious: number;
    travelPace: string;
    interests: string[];
    dealBreakers: string[];
  };
  mlVector50: number[];
  travelPace: string;
  crowdTolerance: number;
  budgetRange: string;
  groupSizePreference: number;
  dealBreakers: string[];
  quizVersion: string;
  createdAt: Date;
  updatedAt: Date;
}

const UserPreferenceSchema = new Schema<IUserPreference>({
  userId: { type: String, required: true, unique: true },
  quizAnswers: {
    artInterest: { type: Number, default: 3 },
    foodieScore: { type: Number, default: 3 },
    adventureSeeking: { type: Number, default: 3 },
    crowdTolerance: { type: Number, default: 3 },
    budgetConscious: { type: Number, default: 3 },
    travelPace: { type: String, default: 'balanced' },
    interests: { type: [String], default: [] },
    dealBreakers: { type: [String], default: [] }
  },
  mlVector50: { type: [Number], default: [] },
  travelPace: { type: String, default: 'balanced' },
  crowdTolerance: { type: Number, min: 1, max: 5 },
  budgetRange: { type: String },
  groupSizePreference: { type: Number, default: 1 },
  dealBreakers: { type: [String], default: [] },
  quizVersion: { type: String, default: '1.0' },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

export default mongoose.model<IUserPreference>('UserPreference', UserPreferenceSchema);