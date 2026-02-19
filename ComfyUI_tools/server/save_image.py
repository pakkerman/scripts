# open local port to receive files from tempermonkey script

import http.server
import os

# Where you want the images to be saved
SAVE_PATH = "/Users/pakk/Downloads/comfy_downloads"
if not os.path.exists(SAVE_PATH):
    os.makedirs(SAVE_PATH)

class SaveHandler(http.server.BaseHTTPRequestHandler):
    def do_OPTIONS(self):
        # Handle CORS so the browser is allowed to talk to your local machine
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'POST')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, X-Filename')
        self.end_headers()

    def do_POST(self):
        filename = self.headers.get('X-Filename', 'image.png')
        content_length = int(self.headers['Content-Length'])
        data = self.rfile.read(content_length)
        
        with open(os.path.join(SAVE_PATH, filename), 'wb') as f:
            f.write(data)
            
        print(f"\033[33mSaved: {filename}, content_length: {content_length}\033[0m")
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()


pathname = "/".join(SAVE_PATH.split('/')[-2:])
print(f"\033[30;43;1;3m Listening for images on port 6969... Saving to ~/{pathname} \033[0m")

http.server.HTTPServer(('127.0.0.1', 6969), SaveHandler).serve_forever()


