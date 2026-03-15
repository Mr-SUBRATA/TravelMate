import mongoose, { Document, Schema } from 'mongoose';

export interface IWeatherAdaptation extends Document {
  tripId: mongoose.Types.ObjectId;
  userId: string;
  adaptationDate: Date;
  originalActivity: string;
  newActivity: string;
  reason: string;
  rainProb: number;
  temperature: number;
  createdAt: Date;
}

const WeatherAdaptationSchema = new Schema<IWeatherAdaptation>({
  tripId: { type: Schema.Types.ObjectId, ref: 'Trip', required: true },
  userId: { type: String, required: true },
  adaptationDate: { type: Date, required: true },
  originalActivity: { type: String },
  newActivity: { type: String },
  reason: { type: String, required: true },
  rainProb: { type: Number },
  temperature: { type: Number },
  createdAt: { type: Date, default: Date.now }
});

export default mongoose.model<IWeatherAdaptation>('WeatherAdaptation', WeatherAdaptationSchema);