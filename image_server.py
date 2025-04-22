import os
from flask import Flask, render_template_string, send_from_directory
import argparse

app = Flask(__name__)

# --- Configuration ---
# Default image directory (can be overridden by command line argument)
# MAKE SURE THIS MATCHES THE HOST SIDE OF YOUR DOCKER VOLUME MAPPING
DEFAULT_IMAGE_DIR = r"D:\comfy\output"
ALLOWED_EXTENSIONS = {'.png', '.jpg', '.jpeg', '.gif', '.webp'}
# ---------------------

IMAGE_DIR = DEFAULT_IMAGE_DIR

# HTML Template for the image grid
HTML_TEMPLATE = """
<!doctype html>
<html>
<head>
    <title>Image Gallery</title>
    <style>
        body { font-family: sans-serif; }
        .grid-container {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 10px;
            padding: 10px;
        }
        .grid-item img {
            width: 100%;
            height: auto;
            display: block;
            border: 1px solid #ddd;
            box-shadow: 2px 2px 5px rgba(0,0,0,0.1);
        }
        .grid-item p {
            text-align: center;
            font-size: 0.8em;
            margin-top: 5px;
            word-wrap: break-word;
        }
    </style>
</head>
<body>
    <h1>Image Gallery</h1>
    <p>Displaying images from: {{ image_dir }}</p>
    <div class="grid-container">
        {% for image in images %}
        <div class="grid-item">
            <a href="{{ url_for('serve_image', filename=image) }}" target="_blank">
                <img src="{{ url_for('serve_image', filename=image) }}" alt="{{ image }}">
            </a>
            <p>{{ image }}</p>
        </div>
        {% else %}
        <p>No images found in the directory.</p>
        {% endfor %}
    </div>
</body>
</html>
"""

@app.route('/')
def index():
    try:
        all_files = os.listdir(IMAGE_DIR)
        image_files = sorted([f for f in all_files if os.path.splitext(f)[1].lower() in ALLOWED_EXTENSIONS])
    except FileNotFoundError:
        image_files = []
        print(f"Error: Image directory not found: {IMAGE_DIR}")
    except Exception as e:
        image_files = []
        print(f"Error reading directory {IMAGE_DIR}: {e}")

    return render_template_string(HTML_TEMPLATE, images=image_files, image_dir=IMAGE_DIR)

@app.route('/images/<filename>')
def serve_image(filename):
    try:
        return send_from_directory(IMAGE_DIR, filename)
    except FileNotFoundError:
        return "File not found", 404

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Simple Flask image server.')
    parser.add_argument('--dir', type=str, default=DEFAULT_IMAGE_DIR,
                        help=f'Directory containing images (default: {DEFAULT_IMAGE_DIR})')
    parser.add_argument('--port', type=int, default=5000,
                        help='Port to run the server on (default: 5000)')
    args = parser.parse_args()

    IMAGE_DIR = args.dir

    if not os.path.isdir(IMAGE_DIR):
        print(f"Warning: The specified image directory does not exist: {IMAGE_DIR}")
        print("Please ensure the directory exists and ComfyUI is saving outputs there.")

    print(f"Serving images from: {IMAGE_DIR}")
    print(f"Image server running on http://localhost:{args.port}")
    app.run(host='0.0.0.0', port=args.port, debug=False) # Use debug=False for production
