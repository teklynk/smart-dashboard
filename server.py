from flask import Flask, request, jsonify, render_template
import subprocess
import json
import os
import re
import signal
import shlex

app = Flask(__name__, static_folder='static', template_folder='templates')

# Load app configs
with open('apps.json') as f:
    apps = json.load(f)

with open('weather.json') as f:
    weather = json.load(f)

with open('backgrounds.json') as f:
    backgrounds = json.load(f)

with open('tools.json') as f:
    tools = json.load(f)

def close_existing_webapp(app_var):
    pattern = re.compile(rf"WebApp-{re.escape(app_var)}")
    try:
        result = subprocess.run(
            ["ps", "-eo", "pid=,args="],
            capture_output=True,
            text=True,
            check=True,
        )
    except (FileNotFoundError, subprocess.CalledProcessError):
        return False

    pids_to_kill = []
    for line in result.stdout.splitlines():
        line = line.strip()
        if not line:
            continue

        parts = line.split(None, 1)
        if len(parts) != 2:
            continue

        pid_text, args = parts
        if pattern.search(args):
            try:
                pids_to_kill.append(int(pid_text))
            except ValueError:
                continue

    for pid in pids_to_kill:
        try:
            os.kill(pid, signal.SIGTERM)
        except ProcessLookupError:
            pass
        except PermissionError:
            pass

    return bool(pids_to_kill)

def find_tool_by_id(tool_id):
    return next((t for t in tools if t["id"] == tool_id), None)

@app.route("/tool")
def launch_tool():
    tool_id = request.args.get("tool")
    tool = find_tool_by_id(tool_id)
    if not tool:
        return jsonify(status="error", message="Unknown tool"), 400

    command = shlex.split(tool["command"])
    subprocess.Popen(
        command,
        start_new_session=True,
        stdin=subprocess.DEVNULL,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        close_fds=True,
    )

    return jsonify(status="success")

@app.route('/launch')
def launch_app():
    app_name = request.args.get('app')
    if not app_name:
        return jsonify({"error": "Missing app parameter"}), 400

    matched_app = next((a for a in apps if a["name"].lower() == app_name.lower()), None)
    if not matched_app:
        return jsonify({"error": "App not found"}), 404

    command = matched_app["command"]
    app_label = matched_app["name"]
    scale_factor = matched_app.get('force-device-scale-factor', '1.0')
    incognito_enabled = matched_app.get('incognito', False)

    if isinstance(incognito_enabled, str):
        incognito_enabled = incognito_enabled.lower() == 'true'
    else:
        incognito_enabled = bool(incognito_enabled)

    if command.startswith("http://") or command.startswith("https://"):
        close_existing_webapp(app_label)

        # Create a unique user data directory for this app
        user_data_dir = os.path.expanduser(f"~/.config/dashboard-webapp-{app_label.replace(' ', '_')}")
        os.makedirs(user_data_dir, exist_ok=True)

        browser_args = [
            "/usr/bin/brave-origin-stable",
            f"--app={command}",
            f"--class=WebApp-{app_label}",
            f"--name=WebApp-{app_label}",
            f"--user-data-dir={user_data_dir}",
            "--kiosk",
            "--no-first-run",
            "--noerrdialogs",
            "--disable-context-menu",
            "--allow-running-insecure-content",
            f"--force-device-scale-factor={scale_factor}"
        ]

        if incognito_enabled:
            browser_args.append("--incognito")

        subprocess.Popen(browser_args)
        
        return jsonify({"status": "launched in browser"})
    else:
        try:
            subprocess.Popen(command.split(), stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            return jsonify({"status": "app launched"})
        except Exception as e:
            return jsonify({"status": "error", "message": str(e)}), 500

@app.route('/')
def dashboard():
    return render_template('index.html', apps=apps, weather=weather, backgrounds=backgrounds, tools=tools)

if __name__ == "__main__":
    app.run(host='127.0.0.1', port=8080)