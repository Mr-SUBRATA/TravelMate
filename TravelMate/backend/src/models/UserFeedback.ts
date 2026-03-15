import mongoose, { Document, Schema } from 'mongoose';

export interface IUserFeedback extends Document {
  userId: string;
  recommendationId: mongoose.Types.ObjectId;
  rating: number;
  actuallyVisited: boolean;
  feedbackText: string;
  mlPredictedScore: number;
  actualEnjoyment: number;
  createdAt: Date;
}

const UserFeedbackSchema = new Schema<IUserFeedback>({
  userId: { type: String, required: true },
  recommendationId: { type: Schema.Types.ObjectId, ref: 'Recommendation' },
  rating: { type: Number, min: 1, max: 5 },
  actuallyVisited: { type: Boolean },
  feedbackText: { type: String },
  mlPredictedScore: { type: Number },
  actualEnjoyment: { type: Number },
  createdAt: { type: Date, default: Date.now }
});

export default mongoose.model<IUserFeedback>('UserFeedback', UserFeedbackSchema);