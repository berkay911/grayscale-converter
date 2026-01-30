from flask import Flask, request, send_file
from PIL import Image
import io

app = Flask(__name__)

@app.route('/convert', methods=['POST'])
def convert_file():
    file = request.files['file']
    img = Image.open(file.stream)
    img = img.convert('L')  # Convert to grayscale
    
    temp = io.BytesIO()
    img.save(temp, format='PNG')
    temp.seek(0)

    return send_file(temp, mimetype='image/png')


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=4000, debug=True)