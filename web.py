import os
import time

from flask import Flask, request, jsonify, send_file, after_this_request
from flask_api import status
from werkzeug.utils import secure_filename

from scanner.scan import scan

ALLOWED_EXTENSIONS = {'jpg', 'jpeg', 'png'}

app = Flask(__name__)
app.config.from_pyfile('config.py')
app.config.from_envvar('SCANNER_ADDITIONAL_CONFIG', silent=True)


def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1] in ALLOWED_EXTENSIONS


@app.route('/', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return jsonify(message='No file part'), status.HTTP_400_BAD_REQUEST
    file = request.files['file']

    if not file or file.filename == '':
        return jsonify(message='No file'), status.HTTP_400_BAD_REQUEST

    if not allowed_file(file.filename):
        return jsonify(message='Supported only jpeg, jpg, png'), status.HTTP_400_BAD_REQUEST

    filename = os.path.join(app.config['UPLOAD_FOLDER'], secure_filename(str(time.time()) + file.filename))
    file.save(filename)

    try:
        scan(filename)
    except Exception:
        return jsonify(message='Cannot recognise document'), status.HTTP_400_BAD_REQUEST


    @after_this_request
    def remove_file(response):
        try:
            os.remove(filename)
        except Exception as error:
            app.logger.error("Error removing file", error)
        return response

    return send_file(filename)


if __name__ == "__main__":
    app.run(debug=app.config['DEBUG'], host='0.0.0.0')
