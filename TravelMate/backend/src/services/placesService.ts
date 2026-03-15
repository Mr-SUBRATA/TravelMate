import axios from 'axios';
import dotenv from 'dotenv';

dotenv.config();

const GEOAPIFY_API_KEY = process.env.GEOAPIFY_API_KEY;
const GEOAPIFY_BASE_URL = 'https://api.geoapify.com/v2';
const GEOAPIFY_GEO_URL = 'https://api.geoapify.com/v1/geocode/search';

interface GeoProperties {
  lat: number;
  lon: number;
  city: string;
  country: string;
}

interface GeoFeature {
  properties: GeoProperties;
}

interface GeoResponse {
  features: GeoFeature[];
}

interface GeoapifyPlace {
  properties: {
    place_id: string;
    name: string;
    categories: string[];
    city: string;
    lat: number;
    lon: number;
  };
}

interface GeoapifyResponse {
  features: GeoapifyPlace[];
}

export const getPlaces = async (city: string) => {
  try {
    // Step 1 - Get coordinates of city
    const geoResponse = await axios.get<GeoResponse>(GEOAPIFY_GEO_URL, {
      params: {
        text: city,
        limit: 1,
        apiKey: GEOAPIFY_API_KEY
      }
    });

    const location = geoResponse.data.features[0].properties;
    const { lat, lon } = location;

    console.log('COORDINATES:', lat, lon);

    // Step 2 - Get places near city
    const placesResponse = await axios.get<GeoapifyResponse>(
      `${GEOAPIFY_BASE_URL}/places`,
      {
        params: {
          categories: 'entertainment,accommodation,activity,airport,commercial,catering,emergency,education,childcare ,entertainment,healthcare,heritage,highway,leisure,man_made,natural,national_park,office,parking,pet,power,production,railway,rental,service,tourism,religion,camping,amenity,beach,adult,building,ski,sport,public_transport,political,populated_place,memorial',


          filter: `circle:${lon},${lat},25000`,
          bias: `proximity:${lon},${lat}`,
          limit: 50,
          lang: 'en',
          apiKey: GEOAPIFY_API_KEY
        }
      }
    );

    console.log('TOTAL PLACES FOUND:', placesResponse.data.features.length);

    // Step 3 - Format for ML dev
    const places = placesResponse.data.features
      .filter((place: GeoapifyPlace) => place.properties.name)
      .map((place: GeoapifyPlace) => ({
        place_id: place.properties.place_id,
        name: place.properties.name,
        categories: place.properties.categories,
        price_level: 2,
        rating: 4.0,
        city: place.properties.city || city
      }));

    return places;

  } catch (error) {
    throw new Error(`Places service error: ${error}`);
  }
};
