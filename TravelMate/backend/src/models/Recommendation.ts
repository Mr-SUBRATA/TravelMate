import mongoose, { Document, Schema } from 'mongoose';

export interface IRecommendation extends Document {
  tripId: mongoose.Types.ObjectId;
  placeId: string;
  placeName: string;
  placeTypes: string[];
  matchScore: number;
  mlScoreDetails: object;
  reasons: string[];
  priceLevel: number;
  rating: number;
  totalRatings: number;
  openNow: boolean;
  outdoor: boolean;
  durationHours: number;
  photoReferences: string[];
  locationLat: number;
  locationLng: number;
  rankPosition: number;
  createdAt: Date;
}

const RecommendationSchema = new Schema<IRecommendation>({
  tripId: { type: Schema.Types.ObjectId, ref: 'Trip', required: true },
  placeId: { type: String, required: true },
  placeName: { type: String, required: true },
  placeTypes: { type: [String], default: [] },
  matchScore: { type: Number, required: true, min: 0, max: 100 },
  mlScoreDetails: { type: Object },
  reasons: { type: [String], default: [] },
  priceLevel: { type: Number, min: 0, max: 4 },
  rating: { type: Number, min: 0, max: 5 },
  totalRatings: { type: Number, default: 0 },
  openNow: { type: Boolean },
  outdoor: { type: Boolean, default: false },
  durationHours: { type: Number },
  photoReferences: { type: [String], default: [] },
  locationLat: { type: Number },
  locationLng: { type: Number },
  rankPosition: { type: Number, min: 1, max: 10 },
  createdAt: { type: Date, default: Date.now }
});

export default mongoose.model<IRecommendation>('Recommendation', RecommendationSchema);