import os
import requests
from flask import Flask, request, Response

file_path = os.path.dirname(__file__)
app = Flask(__name__)

def root_dir():
    return os.path.abspath(os.path.dirname(__file__))

def get_file(filename):
    try:
        src = os.path.join(root_dir(), filename)
        return open(src).read()
    except IOError as exc:
        return str(exc)
    
@app.route('/index.html', methods=['GET'])
def print_index_file():
    content = get_file('index.html')
    return Response(content, mimetype="text/html")

@app.route('/isAlive', methods=['GET'])
def return_ok():
    return Response("OK", mimetype="text/html")

@app.errorhandler(404) 
def invalid_route(e): 
    try:
        client_ip = request.headers.get('X-Forwarded-For')
    except:
        client_ip = request.remote_addr
    url = "https://ipapi.co/%s/json/" % client_ip
    try:
        http_response = requests.get(url)
        if (http_response.status_code == 200):
            http_response_json = http_response.json()
            try:
                country_name = http_response_json['country_name']
            except KeyError:
                country_name = "unknown"
            try:
                city = http_response_json['city']
            except KeyError:
                city = "unknown"
            address = f"You are coming from {city} {country_name}"
        else:
            address = "geo server return non 200"
    except:
        address = "cant access geo server" 
    try:
        response = []
        response.append("deploy mode env var %s" % os.getenv('DEPLOY_MODE'))
        response.append(f"url requsted:{request.base_url}")
        response.append(f"arguments:{request.args}")
        response.append(f"client_ip:{client_ip}")
        response.append(f"adress:{address}")
        #response.append(f"headers: %s" % request.headers)
        return "<BR>".join(response)   
    except Exception as e:
        return f"ERROR: {e}" 

    
    

if __name__ == '__main__':
    app.run(debug=True,host="0.0.0.0", port=9996)