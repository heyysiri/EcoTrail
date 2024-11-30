from flask import Flask, request, jsonify
from pymongo import MongoClient
from dotenv import load_dotenv
import os
from flask_cors import CORS
# Load environment variables
load_dotenv()



app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})
# MongoDB connection
MONGO_URI = os.getenv("MONGOSTRING")
client = MongoClient(MONGO_URI)
db = client['test']  # Replace with your database name
users_collection = db['Users']  # Replace with your collection name

@app.route('/signup', methods=['POST'])
def signup():
    data = request.json
    print(data)
    username = data.get('username')
    password = data.get('password')

    if not username or not password:
        return jsonify({"error": "Username and password are required"}), 400

    # Check if the user already exists
    if users_collection.find_one({"username": username}):
        return jsonify({"error": "User already exists"}), 409

    # Insert new user
    users_collection.insert_one({"username": username, "password": password})
    return jsonify({"message": "Signup successful"}), 201

@app.route('/login', methods=['POST'])
def login():
    print("Signup route hit")
    data = request.json
    username = data.get('username')
    password = data.get('password')

    if not username or not password:
        return jsonify({"error": "Username and password are required"}), 400

    # Authenticate user
    user = users_collection.find_one({"username": username, "password": password})
    if user:
        return jsonify({"message": "Login successful"}), 200
    else:
        return jsonify({"error": "Invalid username or password"}), 401

if __name__ == "__main__":
    app.run(host='127.0.0.1', port=5000, debug=True)
