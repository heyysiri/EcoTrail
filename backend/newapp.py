from flask import Flask, request, jsonify
from pymongo import MongoClient
from dotenv import load_dotenv
import os
from flask_cors import CORS
import base64
import requests

import googlemaps
from datetime import datetime

# Load environment variables
load_dotenv()

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

# MongoDB connection
MONGO_URI = os.getenv("MONGOSTRING")
API_KEY = os.getenv("API_KEY")
client = MongoClient(MONGO_URI)
db = client['test']  # Replace with your database name
users_collection = db['Users']  # Replace with your collection name

# Points multiplier and emission factors for different modes
POINTS_MULTIPLIER = {
    "walking": 12,
    "bicycling": 10,
    "transit": 8,
    "driving": 0  # No points for driving
}

EMISSION_FACTORS = {
    "driving": 180,   # Average car emissions
    "transit": 80,    # Bus emissions
    "walking": 0,     # Walking has no emissions
    "bicycling": 0    # Bicycling has no emissions
}

# Initialize Google Maps client
gmaps = googlemaps.Client(key=API_KEY)

def geocode_address(address):
    """Geocode an address to validate and get its formatted address."""
    try:
        geocode_result = gmaps.geocode(address)
        if not geocode_result:
            return None
        return geocode_result[0]["formatted_address"]
    except Exception as e:
        print(f"Error geocoding address '{address}': {e}")
        return None



def get_map_image(origin, destination, api_key):
    """Generate base64 encoded map image"""
    try:
        # Static Maps API URL
        map_url = (
            f"https://maps.googleapis.com/maps/api/staticmap?"
            f"size=600x400&"
            f"markers=color:red|{origin}&"
            f"markers=color:green|{destination}&"
            f"path=color:blue|weight:5|{origin}|{destination}&"
            f"key={api_key}"
        )
        
        # Fetch the image
        response = requests.get(map_url)
        print(map_url)
        # Convert to base64
        if response.status_code == 200:
            base64_image = base64.b64encode(response.content).decode('utf-8')
            return f"data:image/png;base64,{base64_image}"
        else:
            print(f"Failed to fetch map image. Status code: {response.status_code}")
            return None
    
    except Exception as e:
        print(f"Error generating map image: {e}")
        return None
    


def fetch_route_data(origin, destination, modes):
    """Fetch route data for multiple transportation modes."""
    routes = {}
    no_route = {}
    for mode in modes:
        try:
            directions = gmaps.directions(
                origin=origin,
                destination=destination,
                mode=mode,
                alternatives = True
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
                no_route = {mode}
        except Exception as e:
            print(f"Error fetching data for mode '{mode}': {e}")
    return routes,no_route

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
    filtered_routes = {
        mode: data for mode, data in routes.items()
        if max_duration is None or data["duration_min"] <= max_duration
    }

    if not filtered_routes:
        return None, None

    filtered_footprints = {
        mode: footprints[mode] for mode in filtered_routes.keys()
    }
    eco_friendly_mode = min(filtered_footprints, key=filtered_footprints.get)
    return eco_friendly_mode, filtered_routes[eco_friendly_mode]

@app.route('/calculate_route_points', methods=['POST'])
def calculate_route_points():
    data = request.json
    username = data.get('username')
    origin = data.get('origin')
    destination = data.get('destination')
    modes = data.get('modes', [])

    # Geocode addresses
    origin = geocode_address(origin)
    destination = geocode_address(destination)

    if not origin or not destination:
        return jsonify({"error": "Invalid addresses"}), 400

    # Validate modes
    invalid_modes = [mode for mode in modes if mode not in POINTS_MULTIPLIER]
    if invalid_modes:
        return jsonify({"error": f"Invalid modes: {invalid_modes}"}), 400

    # Fetch route data
    routes, no_route = fetch_route_data(origin, destination, modes)
    if not routes:
        return jsonify({"error": "No routes found"}), 404

    # Calculate carbon footprints
    footprints = calculate_carbon_footprint(routes)

    # Suggest eco-friendly route
    eco_friendly_mode, eco_route = suggest_eco_friendly_route(footprints, routes)

    # Calculate points for each route
    route_details = []
    total_points = 0

    for mode, route_info in routes.items():
        points = int(route_info["distance_km"] * POINTS_MULTIPLIER[mode])
        total_points += points

        route_details.append({
            "mode": mode,
            "distance": route_info["distance_km"],
            "duration": route_info["duration_min"],
            "points_earned": points,
            "carbon_footprint": footprints[mode] / 1000  # Convert to kg
        })

    # Create static map URL
    markers = f"markers={origin}&markers={destination}"
    path = f"path=color:blue|weight:5|{origin}|{destination}"
    map_image = get_map_image(origin, destination, API_KEY)
    # print(f"Generated Map URL: {map_url}")

    # Update user's points in MongoDB
    result = users_collection.update_one(
        {"username": username},
        {"$inc": {"sustainability_points": total_points}}
    )

    # Retrieve updated user document
    user = users_collection.find_one({"username": username})
    current_points = user.get('sustainability_points', total_points)

    return jsonify({
        "message": "Points calculated and updated",
        "route_details": route_details,
        "total_points_earned": total_points,
        "total_points": current_points,
        "eco_friendly_route": {
            "mode": eco_friendly_mode,
            "details": eco_route
        } if eco_friendly_mode else None,
        "map_image": map_image  # Add map URL to the response
    }), 200



    
@app.route('/get_leaderboard', methods=['GET'])
def get_leaderboard():
    try:
        # Retrieve all users, sort by sustainability points in descending order
        # Limit to top 10 users
        leaderboard = list(users_collection.find(
            {},  # No filter, get all users
            {
                'username': 1, 
                'sustainability_points': 1, 
                '_id': 0
            }  # Project only needed fields
        ).sort('sustainability_points', -1).limit(10))

        # Ensure all entries have default values if missing
        processed_leaderboard = [
            {
                'username': entry.get('username', 'Unknown'),
                'sustainability_points': entry.get('sustainability_points', 0)
            } 
            for entry in leaderboard
        ]

        return jsonify({
            "leaderboard": processed_leaderboard
        }), 200

    except Exception as e:
        print(f"Error retrieving leaderboard: {e}")
        return jsonify({
            "error": "Unable to retrieve leaderboard",
            "details": str(e),
            "leaderboard": []  # Return empty list to prevent null errors
        }), 500

@app.route('/signup', methods=['POST'])
def signup():
    data = request.json
    username = data.get('username')
    password = data.get('password')

    if not username or not password:
        return jsonify({"error": "Username and password are required"}), 400

    # Check if the user already exists
    if users_collection.find_one({"username": username}):
        return jsonify({"error": "User already exists"}), 409

    # Insert new user with initial sustainability points and trip counters
    users_collection.insert_one({
        "username": username, 
        "password": password,
        "sustainability_points": 0,
        "transit_trips": 0,
        "walking_trips": 0,
        "driving_trips": 0,
        "bicycling_trips": 0
    })
    return jsonify({"message": "Signup successful"}), 201

@app.route('/login', methods=['POST'])
def login():
    data = request.json
    username = data.get('username')
    password = data.get('password')

    if not username or not password:
        return jsonify({"error": "Username and password are required"}), 400

    # Authenticate user
    user = users_collection.find_one({"username": username, "password": password})
    if user:
        return jsonify({
            "message": "Login successful",
            "username": username,
            "sustainability_points": user.get('sustainability_points', 0)
        }), 200
    else:
        return jsonify({"error": "Invalid username or password"}), 401

@app.route('/get_user_points', methods=['GET'])
def get_user_points():
    username = request.args.get('username')
    
    if not username:
        return jsonify({"error": "Username is required"}), 400

    user = users_collection.find_one({"username": username})
    
    if user:
        return jsonify({
            "username": username,
            "sustainability_points": user.get('sustainability_points', 0),
            "walking_trips": user.get('walking_trips', 0),
            "driving_trips": user.get('driving_trips', 0),
            "transit_trips": user.get('transit_trips', 0),
            "bicycling_trips": user.get('bicycling_trips', 0)
        }), 200
        
    else:
        return jsonify({"error": "User not found"}), 404

@app.route('/updatepassword', methods=['POST'])
def update_password():
    print("trying to update password")
    data = request.json
    old_password = data.get('old_password')
    new_password = data.get('new_password')
    print("this is old password " + old_password)
    print("this is new password " + new_password)
    if not old_password or not new_password:
        return jsonify({"error": "Old password and new password are required"}), 400
    
    # Verify user credentials (assuming current logged-in user's credentials)
    user = users_collection.find_one({"password": old_password})
    print(user)
    if not user:
        return jsonify({"error": "Invalid old password"}), 401
    
    # Update password
    users_collection.update_one(
        {"_id": user['_id']},
        {"$set": {"password": new_password}}
    )
    return jsonify({"message": "Password updated successfully"}), 200

if __name__ == "__main__":
    app.run(host='192.168.12.171', port=5000, debug=True)
