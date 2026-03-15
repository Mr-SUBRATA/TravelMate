import mongoose, { Document, Schema } from 'mongoose';

export interface ITrip extends Document {
  userId: string;
  destinationCity: string;
  destinationCountry: string;
  startDate: Date;
  endDate: Date;
  groupSize: number;
  totalBudget: number;
  status: string;
  createdAt: Date;
  updatedAt: Date;
}

const TripSchema = new Schema<ITrip>({
  userId: { type: String, required: true },
  destinationCity: { type: String, required: true },
  destinationCountry: { type: String },
  startDate: { type: Date, required: true },
  endDate: { type: Date, required: true },
  groupSize: { type: Number, default: 1 },
  totalBudget: { type: Number },
  status: { type: String, default: 'planning' },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

export default mongoose.model<ITrip>('Trip', TripSchema);