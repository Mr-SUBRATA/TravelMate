# app/core/transport_router.py
import heapq
from typing import List, Dict, Tuple

class TransportRouter:
    """Handles routing between locations with nearest airport/station fallback"""
    
    def __init__(self):
        # Sample transport graph (cities and connections)
        self.transport_graph = {
            'Paris': {'London': {'flight': 60, 'train': 120}, 'Lyon': {'train': 120}},
            'London': {'Paris': {'flight': 60}, 'Manchester': {'train': 120}},
            'Lyon': {'Paris': {'train': 120}, 'Marseille': {'train': 90}},
            'Marseille': {'Lyon': {'train': 90}, 'Nice': {'train': 120}},
            'Nice': {'Marseille': {'train': 120}},
            'New York': {'Boston': {'flight': 45}, 'Chicago': {'flight': 180}},
            'Boston': {'New York': {'flight': 45}},
            'Chicago': {'New York': {'flight': 180}}
        }
        
        # Nearest airports for small towns
        self.nearby_airports = {
            'Versailles': 'Paris',
            'Fontainebleau': 'Paris',
            'Cambridge': 'London',
            'Oxford': 'London',
            'Canterbury': 'London'
        }
    
    def find_route(self, source: str, destination: str) -> Dict:
        """
        Find best route between source and destination
        If direct not available, suggest nearest airport
        """
        # Check if source is a small town
        if source in self.nearby_airports:
            nearest = self.nearby_airports[source]
            return {
                'type': 'nearest_airport',
                'original_source': source,
                'nearest_airport': nearest,
                'message': f"No direct connectivity from {source}. Using nearest airport: {nearest}",
                'route': self._dijkstra(nearest, destination)
            }
        
        # Try direct route
        route = self._dijkstra(source, destination)
        if route:
            return {
                'type': 'direct',
                'route': route
            }
        
        # No route found
        return {
            'type': 'impossible',
            'message': f"No route found between {source} and {destination}"
        }
    
    def _dijkstra(self, start: str, end: str) -> List[Tuple[str, str, int]]:
        """Dijkstra's algorithm for shortest path"""
        if start not in self.transport_graph:
            return []
        
        # Priority queue: (total_time, current_node, path)
        pq = [(0, start, [])]
        visited = set()
        
        while pq:
            total_time, current, path = heapq.heappop(pq)
            
            if current in visited:
                continue
            
            visited.add(current)
            path = path + [current]
            
            if current == end:
                # Convert path to route with transport modes
                route = []
                for i in range(len(path)-1):
                    from_city = path[i]
                    to_city = path[i+1]
                    mode = list(self.transport_graph[from_city][to_city].keys())[0]
                    time = self.transport_graph[from_city][to_city][mode]
                    route.append((from_city, to_city, mode, time))
                return route
            
            for neighbor, connections in self.transport_graph.get(current, {}).items():
                if neighbor not in visited:
                    mode = list(connections.keys())[0]
                    time = connections[mode]
                    heapq.heappush(pq, (total_time + time, neighbor, path))
        
        return []