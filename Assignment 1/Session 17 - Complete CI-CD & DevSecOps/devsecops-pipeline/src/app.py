import os
import re
from flask import Flask, jsonify, request

app = Flask(__name__)

# Sanitize inputs to prevent injection vulnerabilities
def validate_username(username):
    if not username or not isinstance(username, str):
        return False
    # Only allow alphanumeric characters between 3 and 20 chars
    return bool(re.match(r'^[a-zA-Z0-9_-]{3,20}$', username))

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({
        "status": "HEALTHY",
        "service": "devsecops-secure-api",
        "author": "Sambhav D Bohra",
        "regNo": "24bcs10090"
    }), 200

@app.route('/api/users/validate', methods=['POST'])
def validate_user_endpoint():
    data = request.get_json(silent=True)
    if not data or 'username' not in data:
        return jsonify({"error": "Missing username in request body"}), 400
    
    username = data['username']
    if not validate_username(username):
        return jsonify({"error": "Invalid username format. Must be alphanumeric (3-20 chars)."}), 422
    
    return jsonify({
        "status": "valid",
        "username": username,
        "message": "User validation succeeded with zero vulnerabilities."
    }), 200

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)
