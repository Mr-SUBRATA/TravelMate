import mongoose, { Document, Schema } from 'mongoose';

export interface IItineraryActivity extends Document {
  dayId: mongoose.Types.ObjectId;
  activityName: string;
  activityTime: string;
  durationHours: number;
  cost: number;
  recommendationId: mongoose.Types.ObjectId;
  originalActivity: string;
  adaptedReason: string;
  weatherAlert: boolean;
  activityOrder: number;
  locationLat: number;
  locationLng: number;
}

const ItineraryActivitySchema = new Schema<IItineraryActivity>({
  dayId: { type: Schema.Types.ObjectId, ref: 'ItineraryDay', required: true },
  activityName: { type: String, required: true },
  activityTime: { type: String },
  durationHours: { type: Number },
  cost: { type: Number },
  recommendationId: { type: Schema.Types.ObjectId, ref: 'Recommendation' },
  originalActivity: { type: String },
  adaptedReason: { type: String },
  weatherAlert: { type: Boolean, default: false },
  activityOrder: { type: Number, required: true },
  locationLat: { type: Number },
  locationLng: { type: Number }
});

export default mongoose.model<IItineraryActivity>('ItineraryActivity', ItineraryActivitySchema);