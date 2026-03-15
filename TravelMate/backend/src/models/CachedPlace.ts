import mongoose, { Document, Schema } from 'mongoose';

export interface ICachedPlace extends Document {
  placeId: string;
  placeData: object;
  searchCity: string;
  expiresAt: Date;
  createdAt: Date;
}

const CachedPlaceSchema = new Schema<ICachedPlace>({
  placeId: { type: String, required: true, unique: true },
  placeData: { type: Object, required: true },
  searchCity: { type: String },
  expiresAt: { type: Date, required: true },
  createdAt: { type: Date, default: Date.now }
});

export default mongoose.model<ICachedPlace>('CachedPlace', CachedPlaceSchema);