import axios from 'axios';

const ML_BASE_URL = 'http://localhost:7000/api/ml'

interface MLRecommendation {
  id: string;
  name: string;
  categories: string[];
  cost: number;
  outdoor: boolean;
  city: string;
  match_score: number;
  scores: {
    similarity: number;
    weather: number;
    crowd: number;
    budget: number;
    time: number;
    popularity: number;
  };
  explanation: object;
}

interface MLResponse {
  user_id: string;
  recommendations: MLRecommendation[];
  processing_time_ms: number;
  model_version: string;
}

export const getRecommendations = async (payload: {
  user_id: string;
  quiz_answers: object;
  destination: string;
  weather: object;
  places: object[];
  top_k: number;
}): Promise<MLResponse> => {
  try {
    const response = await axios.post<MLResponse>(
      `${ML_BASE_URL}/recommend`,
      payload
    );
    return response.data;
  } catch (error) {
    throw new Error(`ML service error: ${error}`);
  }
};