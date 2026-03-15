import mongoose, { Document, Schema } from 'mongoose';

export interface ICachedWeather extends Document {
  city: string;
  forecastDate: Date;
  weatherData: object;
  expiresAt: Date;
}

const CachedWeatherSchema = new Schema<ICachedWeather>({
  city: { type: String, required: true },
  forecastDate: { type: Date, required: true },
  weatherData: { type: Object, required: true },
  expiresAt: { type: Date, required: true }
});

// Unique combination of city + forecastDate
CachedWeatherSchema.index({ city: 1, forecastDate: 1 }, { unique: true });

export default mongoose.model<ICachedWeather>('CachedWeather', CachedWeatherSchema);