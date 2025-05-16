from flask import Flask, request, jsonify, send_from_directory, render_template
import subprocess
#import webbrowser
import json
#import os

app = Flask(__name__, static_folder='static', template_folder='templates')

# Load app config
with open('apps.json') as f:
    apps = json.load(f)

@app.route('/')
def dashboard():
    return render_template('index.html', apps=apps)

@app.route('/launch')
def launch_app():
    app_name = request.args.get('app')
    if not app_name:
        return jsonify({"error": "Missing app parameter"}), 400

    matched_app = next((a for a in apps if a["name"].lower() == app_name.lower()), None)
    if not matched_app:
        return jsonify({"error": "App not found"}), 404

    command = matched_app["command"]

    if command.startswith("http://") or command.startswith("https://"):
        subprocess.Popen(["chromium", "--new-window", "--kiosk", command])
        return jsonify({"status": "launched in browser"})
    else:
        try:
            subprocess.Popen(command.split(), stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            return jsonify({"status": "app launched"})
        except Exception as e:
            return jsonify({"status": "error", "message": str(e)}), 500

if __name__ == "__main__":
    app.run(host='127.0.0.1', port=8080)
