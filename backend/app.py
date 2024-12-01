import os
import requests
from dotenv import load_dotenv
import googlemaps
from datetime import datetime
from IPython.display import Image, display

# Load environment variables
load_dotenv()

# Replace with your Google API Key
API_KEY = os.getenv("API_KEY")
if not API_KEY:
    raise ValueError("API_KEY not found in .env file!")

gmaps = googlemaps.Client(key=API_KEY)

# Emission factors (grams CO₂ per km)
EMISSION_FACTORS = {
    "driving": 180,   # Average car emissions
    "transit": 80,    # Bus emissions
    "walking": 0,     # Walking has no emissions
    "bicycling":  0   # Bicycling has no emissions
}

def geocode_address(address):
    """Geocode an address to validate and get its latitude and longitude."""
    try:
        geocode_result = gmaps.geocode(address)
        if not geocode_result:
            print(f"Error: Address '{address}' could not be geocoded.")
            return None
        return geocode_result[0]["formatted_address"]
    except Exception as e:
        print(f"Error geocoding address '{address}': {e}")
        return None

def get_route_optimization(origins, destinations):
    """Optimize routes for multiple locations (Route Optimization API)."""
    try:
        # Request optimized route
        optimization_result = gmaps.directions(
            origin=origins[0],
            destination=destinations[-1],
            waypoints=destinations[1:-1],
            mode="driving",
            optimize_waypoints=True  # Optimize the order of waypoints
        )
        
        if optimization_result:
            optimized_route = optimization_result[0]["legs"][0]
            distance = optimized_route["distance"]["text"]  # e.g., "12.3 km"
            duration = optimized_route["duration"]["text"]  # e.g., "35 mins"
            print(f"Optimized Distance: {distance}")
            print(f"Optimized Duration: {duration}")
        else:
            print("No optimized route found.")
    
    except Exception as e:
        print(f"Error fetching optimized route: {e}")

def fetch_route_data(origin, destination, modes):
    """Fetch route data for multiple transportation modes."""
    routes = {}
    for mode in modes:
        try:
            directions = gmaps.directions(
                origin=origin,
                destination=destination,
                mode=mode
            )
            if directions:
                route = directions[0]["legs"][0]
                distance_km = route["distance"]["value"] / 1000  # Convert to km
                duration_min = route["duration"]["value"] / 60  # Convert to minutes
                routes[mode] = {
                    "distance_km": distance_km,
                    "duration_min": duration_min
                }
            else:
                print(f"No route found for mode '{mode}'.")
        except Exception as e:
            print(f"Error fetching data for mode '{mode}': {e}")
    return routes

def get_traffic_route_data(origin, destination):
    """Fetch route data with traffic conditions."""
    try:
        now = datetime.now()  # Get the current time
        
        # Request directions with traffic consideration
        directions = gmaps.directions(
            origin=origin,
            destination=destination,
            mode="driving",
            departure_time=now  # Set departure time to 'now' to include traffic data
        )
        
        if directions:
            route = directions[0]["legs"][0]
            distance = route["distance"]["text"]
            duration = route["duration_in_traffic"]["text"]  # Time considering traffic
            
            print(f"Distance: {distance}")
            print(f"Duration (with traffic): {duration}")
        else:
            print("No route found.")
    
    except Exception as e:
        print(f"Error fetching traffic data: {e}")

def calculate_carbon_footprint(routes):
    """Calculate carbon footprints for each mode."""
    footprints = {}
    for mode, data in routes.items():
        distance = data["distance_km"]
        emissions = EMISSION_FACTORS.get(mode, 0)
        footprints[mode] = distance * emissions  # Total CO₂ in grams
    return footprints

def suggest_eco_friendly_route(footprints, routes, max_duration=None):
    """Suggest the most eco-friendly route within time constraints."""
    # Filter routes based on time constraints
    filtered_routes = {
        mode: data for mode, data in routes.items()
        if max_duration is None or data["duration_min"] <= max_duration
    }

    if not filtered_routes:
        print("No routes meet the time constraint.")
        return None, None

    # Find the most eco-friendly route
    filtered_footprints = {
        mode: footprints[mode] for mode in filtered_routes.keys()
    }
    eco_friendly_mode = min(filtered_footprints, key=filtered_footprints.get)
    return eco_friendly_mode, filtered_routes[eco_friendly_mode]

# Function to display the map
def display_map_route(origin, destination, waypoints=[]):
    """Display a static map image with a route highlighted dynamically."""
    # Create markers for origin, destination, and waypoints
    markers = f"markers={origin}&markers={destination}"
    
    for point in waypoints:
        markers += f"&markers={point}"

    # Create a path to highlight the route dynamically (polyline)
    path = f"path=color:blue|weight:5"
    
    # Add points to the path (origin, waypoints, destination)
    path += f"|{origin}"
    
    for point in waypoints:
        path += f"|{point}"
    
    path += f"|{destination}"

    # Create the URL with the markers and the path
    static_map_url = f"https://maps.googleapis.com/maps/api/staticmap?size=600x400&{markers}&{path}&key={API_KEY}"
    
     # Optional: print the URL for debugging

    # Fetch the static map
    response = requests.get(static_map_url)

    if response.status_code == 200:
        # Display the map
        display(Image(response.content))
    else:
        print("Error fetching map.")


    """Display a static map image with a route."""
    static_map_url = f"https://maps.googleapis.com/maps/api/staticmap?size=600x400&markers={origin}&markers={destination}"
    # print(static_map_url) 
    
    
    for point in waypoints:
        static_map_url += f"&markers={point}"

    static_map_url += f"&key={API_KEY}"
    print(static_map_url)
    response = requests.get(static_map_url)

    if response.status_code == 200:
      
        display(Image(response.content))
    else:
        print("Error fetching map.")

# Main program
if __name__ == "__main__":
    print("Welcome to the Eco-Friendly Route Finder!")
    
    # Collect user inputs
    origin = input("Enter your starting point: ").strip()
    destination = input("Enter your destination: ").strip()
    
    # Validate addresses
    origin = geocode_address(origin)
    destination = geocode_address(destination)

    if not origin or not destination:
        print("Error: Unable to resolve one or both addresses. Please try again.")
        exit()

    print("Select preferred modes of transport (comma-separated, options: driving, transit, walking, bicycling):")
    modes_input = input("> ").strip().lower()
    modes = [mode.strip() for mode in modes_input.split(",") if mode.strip()] or ["driving", "transit", "walking", "bicycling"]

    # Ask for maximum acceptable duration
    try:
        max_duration = float(input("Enter your maximum acceptable travel time (in minutes, or 0 for no limit): ").strip())
        max_duration = max_duration if max_duration > 0 else None
    except ValueError:
        print("Invalid time constraint entered. Assuming no limit.")
        max_duration = None

    # Fetch route data
    routes = fetch_route_data(origin, destination, modes)
    if not routes:
        print("No routes found.")
        exit()

    # Calculate carbon footprints
    footprints = calculate_carbon_footprint(routes)

    # Suggest the most eco-friendly route
    eco_friendly_mode, eco_route = suggest_eco_friendly_route(footprints, routes, max_duration)

    if eco_route:
        print("\nMost Eco-Friendly Route:")
        print(f"Mode: {eco_friendly_mode.capitalize()}")
        print(f"Distance: {eco_route['distance_km']:.2f} km")
        print(f"Duration: {eco_route['duration_min']:.2f} minutes")
        print(f"Carbon Footprint: {footprints[eco_friendly_mode] / 1000:.2f} kg CO₂")
    else:
        print("No routes found meeting your time constraint.")

    print("\nAll Routes:")
    for mode, route in routes.items():
        print(f"\nMode: {mode.capitalize()}")
        print(f"  Distance: {route['distance_km']:.2f} km")
        print(f"  Duration: {route['duration_min']:.2f} minutes")
        print(f"  Carbon Footprint: {footprints[mode] / 1000:.2f} kg CO₂")

    display_map_route(origin, destination)
