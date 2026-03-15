import mongoose, { Document, Schema } from 'mongoose';

export interface IItineraryDay extends Document {
  tripId: mongoose.Types.ObjectId;
  dayNumber: number;
  tripDate: Date;
  weatherForecast: object;
  weatherAdapted: boolean;
  adaptationReason: string;
  dailyBudget: number;
  dailySpent: number;
}

const ItineraryDaySchema = new Schema<IItineraryDay>({
  tripId: { type: Schema.Types.ObjectId, ref: 'Trip', required: true },
  dayNumber: { type: Number, required: true },
  tripDate: { type: Date, required: true },
  weatherForecast: { type: Object },
  weatherAdapted: { type: Boolean, default: false },
  adaptationReason: { type: String },
  dailyBudget: { type: Number },
  dailySpent: { type: Number, default: 0 }
});

export default mongoose.model<IItineraryDay>('ItineraryDay', ItineraryDaySchema);