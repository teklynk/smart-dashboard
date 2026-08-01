# Smart Dashboard
A simple smart-TV style dashboard web app that launches desktop or web apps via a Python Flask backend.

<a target="_blank" rel="noopener noreferrer" href="https://github.com/teklynk/smart-dashboard/blob/main/screenshots/screenshot.png?raw=true"><img src="https://github.com/teklynk/smart-dashboard/blob/main/screenshots/screenshot.png?raw=true" style="max-width: 100%;"></a>

## Features

Loads app data (wallpapers, icons, apps) from JSON files

Frontend dashboard with clickable app icons

Launches local desktop apps or opens URLs

Runs on localhost:8080

## Prerequisites

Python 3.8+ installed

pip package manager

(Optional but recommended) virtualenv support

## Getting Started

- Clone this repository
```bash
git clone https://github.com/teklynk/smart-dashboard.git
cd smart-dashboard
```
- Create a Python virtual environment and activate it
```bash
python3 -m venv venv
source venv/bin/activate   # On Windows: venv\Scripts\activate
```
- Install dependencies
```bash
pip install -r requirements.txt
```
- Run the server
```bash
python3 server.py
```
The dashboard will be available at http://localhost:8080

## Usage

Click any app icon on the dashboard to launch the associated app or open its URL.

Edit apps.json to add, remove, or update apps.

## Notes

Virtual environment folders (venv/) are ignored in .gitignore.

To install Flask system-wide without a virtual environment:

```bash
sudo apt update
sudo apt install python3-flask
```

## Optional: Running Chromium in Kiosk Mode

To have the dashboard open automatically on boot/login in fullscreen kiosk mode, run:

```bash
chromium --kiosk http://localhost:8080
```

## Troubleshooting

If Flask is not found, ensure your virtual environment is activated before running the server.

Use pip freeze > requirements.txt to update dependencies after installing new packages.
