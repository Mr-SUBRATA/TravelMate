import axios from 'axios';
import dotenv from 'dotenv';

dotenv.config();

const WEATHER_BASE_URL = 'https://api.openweathermap.org/data/2.5';
const GEO_BASE_URL = 'http://api.openweathermap.org/geo/1.0';

interface GeoResponse {
  lat: number;
  lon: number;
  name: string;
  country: string;
}

interface WeatherItem {
  dt_txt: string;
  main: {
    temp: number;
    temp_min: number;
    temp_max: number;
  };
  weather: {
    main: string;
    description: string;
  }[];
  pop: number;
}

interface ForecastResponse {
  list: WeatherItem[];
  city: {
    name: string;
    country: string;
  };
}

// Step 1 - Get lat/lon from city name
const getCoordinates = async (city: string) => {
  const response = await axios.get<GeoResponse[]>(
    `${GEO_BASE_URL}/direct`,
    {
      params: {
        q: city,
        limit: 1,
        appid: process.env.WEATHER_API_KEY
      }
    }
  );

  if (!response.data || response.data.length === 0) {
    throw new Error(`City not found: ${city}`);
  }

  return {
    lat: response.data[0].lat,
    lon: response.data[0].lon,
    name: response.data[0].name,
    country: response.data[0].country
  };
};

// Step 2 - Get forecast using lat/lon
export const getWeather = async (city: string) => {
  try {
    // First get coordinates
    const coords = await getCoordinates(city);

    // Then get forecast
    const response = await axios.get<ForecastResponse>(
      `${WEATHER_BASE_URL}/forecast`,
      {
        params: {
          lat: coords.lat,
          lon: coords.lon,
          appid: process.env.WEATHER_API_KEY,
          units: 'metric'
        }
      }
    );

    const data = response.data;

    // Get daily forecasts
    const dailyForecasts = data.list
      .filter((item: WeatherItem) => item.dt_txt.includes('12:00:00'))
      .map((item: WeatherItem) => ({
        date: item.dt_txt.split(' ')[0],
        temp: item.main.temp,
        temp_min: item.main.temp_min,
        temp_max: item.main.temp_max,
        condition: item.weather[0].main.toLowerCase(),
        description: item.weather[0].description,
        rain_prob: item.pop
      }));

    // Return in format ML dev expects
    return {
      city: coords.name,
      country: coords.country,
      forecasts: dailyForecasts,
      rain_prob: dailyForecasts[0]?.rain_prob || 0.1,
      temp: dailyForecasts[0]?.temp || 20,
      condition: dailyForecasts[0]?.condition || 'clear'
    };

  } catch (error) {
    throw new Error(`Weather service error: ${error}`);
  }
};