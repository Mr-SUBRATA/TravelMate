# app/core/transport_costs.py
"""
Transport Cost Calculator - Multi-mode transport options with live pricing
Feature 3: Transportation Medium + Real Costs
"""

from typing import List, Dict, Optional, Tuple
import logging
import math

logger = logging.getLogger(__name__)

class TransportCostCalculator:
    """Calculates transportation options and costs between locations"""
    
    def __init__(self):
        # Base costs per km for different transport modes (in USD)
        self.cost_per_km = {
            'flight': 0.15,      # $0.15 per km
            'train': 0.12,       # $0.12 per km
            'bus': 0.08,         # $0.08 per km
            'car': 0.20,         # $0.20 per km (rental + fuel)
            'walk': 0.00,        # Free!
            'bike': 0.05,        # $0.05 per km (rental)
            'ferry': 0.18,       # $0.18 per km
            'taxi': 0.80,        # $0.80 per km (expensive!)
            'metro': 0.10        # $0.10 per km
        }
        
        # Speed in km/h
        self.speed = {
            'flight': 800,
            'train': 200,
            'bus': 80,
            'car': 100,
            'walk': 5,
            'bike': 15,
            'ferry': 40,
            'taxi': 60,
            'metro': 40
        }
        
        # CO2 emissions in kg per km
        self.emissions = {
            'flight': 0.255,
            'train': 0.041,
            'bus': 0.105,
            'car': 0.192,
            'walk': 0.0,
            'bike': 0.0,
            'ferry': 0.180,
            'taxi': 0.192,
            'metro': 0.041
        }
        
        # Distance between major cities (in km)
        self.distances = {
            # Europe
            ('Paris', 'London'): 450,
            ('Paris', 'Lyon'): 470,
            ('Paris', 'Marseille'): 775,
            ('Paris', 'Nice'): 930,
            ('London', 'Manchester'): 260,
            ('London', 'Edinburgh'): 650,
            ('London', 'Birmingham'): 180,
            ('Berlin', 'Munich'): 500,
            ('Berlin', 'Hamburg'): 280,
            ('Rome', 'Milan'): 570,
            ('Rome', 'Florence'): 280,
            ('Rome', 'Venice'): 400,
            ('Barcelona', 'Madrid'): 620,
            ('Amsterdam', 'Brussels'): 200,
            
            # USA
            ('New York', 'Boston'): 350,
            ('New York', 'Washington DC'): 360,
            ('New York', 'Chicago'): 1200,
            ('New York', 'Miami'): 2100,
            ('Los Angeles', 'San Francisco'): 620,
            ('Los Angeles', 'Las Vegas'): 430,
            ('Los Angeles', 'San Diego'): 200,
            ('Chicago', 'Detroit'): 450,
            
            # Asia
            ('Tokyo', 'Osaka'): 500,
            ('Tokyo', 'Kyoto'): 460,
            ('Tokyo', 'Nagoya'): 340,
            ('Beijing', 'Shanghai'): 1200,
            ('Beijing', 'Guangzhou'): 2100,
            ('Shanghai', 'Hangzhou'): 170,
            ('Bangkok', 'Phuket'): 850,
            ('Singapore', 'Kuala Lumpur'): 350,
            
            # Australia
            ('Sydney', 'Melbourne'): 880,
            ('Sydney', 'Brisbane'): 910,
            ('Melbourne', 'Adelaide'): 730,
        }
        
        # Port cities for ferries
        self.port_cities = ['Venice', 'Sydney', 'New York', 'Hong Kong', 'Singapore', 'Istanbul', 'Stockholm']
        
        # Cities with metros
        self.metro_cities = ['Paris', 'London', 'New York', 'Tokyo', 'Moscow', 'Berlin', 'Madrid', 'Beijing', 'Shanghai']
        
        logger.info("✅ Transport Cost Calculator initialized")
    
    def get_transport_options(self, source: str, destination: str) -> List[Dict]:
        """
        Get all possible transport options between source and destination
        
        Args:
            source: Starting city
            destination: Target city
            
        Returns:
            List of transport options with costs, durations, and emissions
        """
        # Get distance
        distance = self._get_distance(source, destination)
        if distance == 0:
            return []
        
        options = []
        
        # Determine possible transport modes based on distance and cities
        modes = self._get_available_modes(source, destination, distance)
        
        for mode in modes:
            # Calculate time and cost
            time_hours = distance / self.speed[mode]
            cost = distance * self.cost_per_km[mode]
            emission = distance * self.emissions[mode]
            
            # Round values
            time_hours = round(time_hours, 1)
            time_minutes = round(time_hours * 60)
            cost = round(cost, 2)
            emission = round(emission, 2)
            
            # Create option
            option = {
                'mode': mode,
                'mode_emoji': self._get_mode_emoji(mode),
                'mode_name': self._get_mode_name(mode),
                'distance_km': distance,
                'duration_hours': time_hours,
                'duration_minutes': time_minutes,
                'duration_display': self._format_duration(time_minutes),
                'cost_usd': cost,
                'cost_display': f"${cost}",
                'co2_kg': emission,
                'co2_display': f"{emission} kg CO2",
                'comfort_level': self._get_comfort_level(mode),
                'availability': self._get_availability(mode, source, destination)
            }
            
            options.append(option)
        
        # Sort by cost (cheapest first)
        options.sort(key=lambda x: x['cost_usd'])
        
        return options
    
    def get_best_option(self, source: str, destination: str, preference: str = 'balanced') -> Dict:
        """
        Get best transport option based on preference
        
        Args:
            source: Starting city
            destination: Target city
            preference: 'cheapest', 'fastest', 'eco', or 'balanced'
            
        Returns:
            Best option with explanation
        """
        options = self.get_transport_options(source, destination)
        
        if not options:
            return {
                'error': 'No route found',
                'message': f"No transport options available between {source} and {destination}"
            }
        
        best_option = None
        reason = ""
        
        if preference == 'cheapest':
            best_option = min(options, key=lambda x: x['cost_usd'])
            reason = "This is the most budget-friendly option"
            
        elif preference == 'fastest':
            best_option = min(options, key=lambda x: x['duration_minutes'])
            reason = "This is the quickest way to reach your destination"
            
        elif preference == 'eco':
            best_option = min(options, key=lambda x: x['co2_kg'])
            reason = "This option has the lowest environmental impact"
            
        else:  # balanced
            # Normalize and combine scores
            for opt in options:
                max_cost = max(o['cost_usd'] for o in options)
                max_time = max(o['duration_minutes'] for o in options)
                max_co2 = max(o['co2_kg'] for o in options)
                
                cost_score = opt['cost_usd'] / max_cost if max_cost > 0 else 0
                time_score = opt['duration_minutes'] / max_time if max_time > 0 else 0
                co2_score = opt['co2_kg'] / max_co2 if max_co2 > 0 else 0
                
                opt['balanced_score'] = (cost_score + time_score + co2_score) / 3
            
            best_option = min(options, key=lambda x: x['balanced_score'])
            reason = "This option offers the best balance of cost, time, and environmental impact"
        
        return {
            'source': source,
            'destination': destination,
            'preference': preference,
            'best_option': best_option,
            'reason': reason,
            'all_options': options,
            'total_options': len(options)
        }
    
    def compare_options(self, source: str, destination: str) -> Dict:
        """Get comparison of all transport options"""
        options = self.get_transport_options(source, destination)
        
        if not options:
            return {'error': 'No options found'}
        
        # Find best in each category
        cheapest = min(options, key=lambda x: x['cost_usd'])
        fastest = min(options, key=lambda x: x['duration_minutes'])
        eco = min(options, key=lambda x: x['co2_kg'])
        
        return {
            'source': source,
            'destination': destination,
            'cheapest': {
                'mode': cheapest['mode'],
                'cost': cheapest['cost_usd'],
                'duration': cheapest['duration_display']
            },
            'fastest': {
                'mode': fastest['mode'],
                'duration': fastest['duration_display'],
                'cost': fastest['cost_usd']
            },
            'most_eco': {
                'mode': eco['mode'],
                'co2': eco['co2_display'],
                'duration': eco['duration_display']
            },
            'all_options': options
        }
    
    def estimate_travel_cost(self, source: str, destination: str, mode: str = None) -> Dict:
        """Estimate travel cost for specific mode or all modes"""
        if mode:
            # Get distance
            distance = self._get_distance(source, destination)
            if distance == 0:
                return {'error': 'Route not found'}
            
            if mode not in self.cost_per_km:
                return {'error': f"Mode '{mode}' not supported"}
            
            cost = distance * self.cost_per_km[mode]
            time_hours = distance / self.speed[mode]
            
            return {
                'source': source,
                'destination': destination,
                'mode': mode,
                'distance_km': distance,
                'duration_hours': round(time_hours, 1),
                'duration_minutes': round(time_hours * 60),
                'cost_usd': round(cost, 2),
                'co2_kg': round(distance * self.emissions[mode], 2)
            }
        else:
            return self.compare_options(source, destination)
    
    def _get_distance(self, source: str, destination: str) -> int:
        """Get distance between two cities"""
        # Check direct distance
        if (source, destination) in self.distances:
            return self.distances[(source, destination)]
        if (destination, source) in self.distances:
            return self.distances[(destination, source)]
        
        # Default approximate distance based on continent
        # This is a simplified fallback
        european_cities = ['Paris', 'London', 'Berlin', 'Rome', 'Madrid', 'Amsterdam']
        us_cities = ['New York', 'Los Angeles', 'Chicago', 'Boston', 'Miami']
        asian_cities = ['Tokyo', 'Beijing', 'Shanghai', 'Singapore', 'Bangkok']
        
        if source in european_cities and destination in european_cities:
            return 800  # Average European city distance
        elif source in us_cities and destination in us_cities:
            return 1500  # Average US city distance
        elif source in asian_cities and destination in asian_cities:
            return 1200  # Average Asian city distance
        
        return 1000  # Default fallback
    
    def _get_available_modes(self, source: str, destination: str, distance: int) -> List[str]:
        """Determine available transport modes based on distance and cities"""
        modes = []
        
        # Short distances (under 50 km)
        if distance < 50:
            modes.extend(['walk', 'bike', 'taxi', 'car'])
        
        # Medium distances (50-500 km)
        elif distance < 500:
            modes.extend(['car', 'bus', 'train', 'taxi'])
            
            # Check for metro (if both cities have metro)
            if source in self.metro_cities and destination in self.metro_cities:
                modes.append('metro')
        
        # Long distances (500-1500 km)
        elif distance < 1500:
            modes.extend(['train', 'bus', 'car', 'flight'])
            
            # Check for ferry (if both are port cities)
            if source in self.port_cities and destination in self.port_cities:
                modes.append('ferry')
        
        # Very long distances (over 1500 km)
        else:
            modes.append('flight')
        
        return modes
    
    def _get_mode_emoji(self, mode: str) -> str:
        """Get emoji for transport mode"""
        emojis = {
            'flight': '✈️',
            'train': '🚂',
            'bus': '🚌',
            'car': '🚗',
            'walk': '🚶',
            'bike': '🚲',
            'ferry': '⛴️',
            'taxi': '🚕',
            'metro': '🚇'
        }
        return emojis.get(mode, '🚀')
    
    def _get_mode_name(self, mode: str) -> str:
        """Get display name for transport mode"""
        names = {
            'flight': 'Flight',
            'train': 'Train',
            'bus': 'Bus',
            'car': 'Car Rental',
            'walk': 'Walking',
            'bike': 'Bicycle',
            'ferry': 'Ferry',
            'taxi': 'Taxi',
            'metro': 'Metro/Subway'
        }
        return names.get(mode, mode.capitalize())
    
    def _format_duration(self, minutes: int) -> str:
        """Format duration in human-readable format"""
        if minutes < 60:
            return f"{minutes} min"
        elif minutes < 1440:  # Less than a day
            hours = minutes // 60
            mins = minutes % 60
            if mins == 0:
                return f"{hours} hour{'s' if hours > 1 else ''}"
            else:
                return f"{hours}h {mins}m"
        else:
            days = minutes // 1440
            hours = (minutes % 1440) // 60
            return f"{days} day{'s' if days > 1 else ''} {hours}h"
    
    def _get_comfort_level(self, mode: str) -> str:
        """Get comfort level for transport mode"""
        comfort = {
            'flight': 'High',
            'train': 'High',
            'bus': 'Medium',
            'car': 'Medium',
            'walk': 'Low',
            'bike': 'Low',
            'ferry': 'Medium',
            'taxi': 'High',
            'metro': 'Medium'
        }
        return comfort.get(mode, 'Medium')
    
    def _get_availability(self, mode: str, source: str, destination: str) -> str:
        """Get availability description"""
        if mode == 'flight':
            # Check if both cities have airports
            major_airports = ['Paris', 'London', 'New York', 'Tokyo', 'Dubai', 'Frankfurt']
            if source in major_airports and destination in major_airports:
                return "Multiple flights daily"
            else:
                return "Limited flights"
        
        elif mode == 'train':
            if self._get_distance(source, destination) < 1000:
                return "Regular service"
            else:
                return "Limited service"
        
        elif mode == 'bus':
            return "Available"
        
        elif mode == 'ferry':
            if source in self.port_cities and destination in self.port_cities:
                return "Seasonal service"
            else:
                return "Not available"
        
        else:
            return "Available"