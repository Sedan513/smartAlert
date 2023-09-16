from math import radians, cos, sin, asin, sqrt, atan2
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask import request, jsonify, render_template
from dotenv import load_dotenv
import math
import json
import os
from shapely.geometry import Point, Polygon
load_dotenv()

googlemaps_key = os.getenv('GOOGLE_MAPS_API_KEY')



app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///app.db'

db = SQLAlchemy(app)
migrate = Migrate(app, db,render_as_batch=True)

class Location(db.Model):
	id = db.Column(db.Integer, primary_key=True)
	latitude = db.Column(db.Float)
	longitude = db.Column(db.Float)
	radius = db.Column(db.Float)
	polyregion = db.Column(db.JSON)

	def __init__(self, latitude, longitude, radius, polyregion):
		self.latitude = latitude
		self.longitude = longitude
		self.radius = radius
		self.polyregion = polyregion

	def __repr__(self):
		return '<Location %d>' % self.id
	
# phone numbers for location
class Phone(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    phone_number = db.Column(db.String(80))
    protocol_id = db.Column(db.Integer, db.ForeignKey('protocols.id', name = 'fk_protocol_id'))
    location_id = db.Column(db.Integer, db.ForeignKey('location.id', name = 'fk_location_id'))
    location = db.relationship('Location', backref=db.backref('phone', lazy='dynamic'))
    protocol = db.relationship('Protocols', backref=db.backref('phone', lazy='dynamic'))
    message = db.Column(db.String(1000))

    def __init__(self, phone_number, location, protocol, message):
        self.phone_number = phone_number
        self.location = location
        self.protocol = protocol
        self.message = message

    def __repr__(self):
        return '<Phone %r>' % self.phone_number
class Protocols(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    protocol = db.Column(db.String(80))
    location_id = db.Column(db.Integer, db.ForeignKey('location.id', name = 'fk_location_id'))
    location = db.relationship('Location', backref=db.backref('protocols', lazy='dynamic'))

    def __init__(self, protocol, location):
        self.protocol = protocol
        self.location = location

    def __repr__(self):
        return '<Protocol %r>' % self.protocol
class Messages(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    message = db.Column(db.String(80))
    protocol_id = db.Column(db.Integer, db.ForeignKey('protocols.id', name = 'fk_protocol_id'))
    protocol = db.relationship('Protocols', backref=db.backref('messages', lazy='dynamic'))
    def __init__(self, message, protocol):
        self.message = message
        self.protocol = protocol
    def __repr__(self):
        return '<Messages %r>' % self.message
    
class PhonetoCall(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    phone_number = db.Column(db.String(80))
    protocol_id = db.Column(db.Integer, db.ForeignKey('protocols.id', name = 'fk_protocol_id'))
    protocol = db.relationship('Protocols', backref=db.backref('phonetocall', lazy='dynamic'))

    def __init__(self, phone_number, protocol):
        self.phone_number = phone_number
        self.protocol = protocol

    def __repr__(self):
        return '<PhonetoCall %r>' % self.phone_number
     
	
@app.route('/locations', methods=['POST'])
def receive_location():
    try:
        data = request.get_json()  # Parse JSON data from the request
        if 'latitude' in data and 'longitude' in data:
            latitude = data['latitude']
            longitude = data['longitude']

            hits = find_locations_in_radius(latitude, longitude)
            print(hits)

            output = []



            for hit in hits:
                location = Location.query.get(hit)
                for protocol in location.protocols:
                     messages = []
                     for message in protocol.messages:
                         messages.append(str(message.message))
                     phone_numbers = []
                     for phone_number in protocol.phonetocall:
                         phone_numbers.append(str(phone_number.phone_number))
                    
                     temp = {
                        'name' : protocol.protocol,
                        'message' : messages,
                        'phone_number' : phone_numbers}
                     output.append(temp)

                


            return jsonify(output), 200
        else:
            return jsonify({'error': 'Invalid data format'}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    
#an html page to add locations    
@app.route('/add', methods=['GET'])
def add():
    return render_template('add.html', googlemaps_key=googlemaps_key)



@app.route('/get_polygon_data', methods=['GET'])
def get_polygon_data():
    # Get the polygon data from the database
    polygons = Location.query.all()
    output = []
    for polygon in polygons:
         output.append(polygon.polyregion)
    return jsonify(output), 200


@app.route('/save_polygon', methods=['POST'])
def save_polygon():
	try:
		data = request.get_json()
		print(data)
		coordinates = data['coordinates']
        # Process and store the polygon data as needed
        # For example, you can save it to a database or perform other actions

		#output coordinates

        #write to txt
        
            
        
          
		new_loc = find_center(coordinates)
          

		radii = find_circumradius(coordinates)
          
		

        #create new location
		location = Location(latitude = new_loc[0], longitude = new_loc[1], radius = radii, polyregion = coordinates)
        #create new protocol
		protocol = Protocols(protocol = data['protocol'], location = location)
        #create new message
		for message in data['message']:
			messages = Messages(message = message, protocol = protocol)
			db.session.add(messages)
        #create new phone number  
		for phone_number in data['phone']:
			phone = PhonetoCall(phone_number = phone_number, protocol = protocol)
			db.session.add(phone)
        
     
		db.session.add(location)
		db.session.commit()


        # Send a response back to the client if needed
		response_data = {'message': location.id}
		return jsonify(response_data), 200
	except Exception as e:
		return jsonify({'error': str(e)}), 500



def haversine(lat1, lon1, lat2, lon2):
    # Radius of the Earth in kilometers
    R = 6371.0

    # Convert latitude and longitude from degrees to radians
    lat1 = radians(lat1)
    lon1 = radians(lon1)
    lat2 = radians(lat2)
    lon2 = radians(lon2)

    # Calculate the differences in coordinates
    dlon = lon2 - lon1
    dlat = lat2 - lat1

    # Use the Haversine formula to calculate the distance
    a = sin(dlat / 2)**2 + cos(lat1) * cos(lat2) * sin(dlon / 2)**2
    c = 2 * atan2(sqrt(a), sqrt(1 - a))

    distance = R * c

    return distance

def find_locations_in_radius(target_lat, target_lon):
    point = Point(target_lat, target_lon)
    locations_in_radius = []
    for location in Location.query.all():
        polyregion = [(item["lat"],item["lng"]) for item in location.polyregion]
        polygon = Polygon(polyregion)
        if polygon.contains(point):
            locations_in_radius.append(location.id)
    return locations_in_radius

def find_center(coordinates):
    if not coordinates:
        return None

    num_points = len(coordinates)
    sum_x = 0
    sum_y = 0
    for coord in coordinates:
        sum_x += coord['lat']
        sum_y += coord['lng']
    

    center_x = sum_x / num_points
    center_y = sum_y / num_points

    return (center_x, center_y)

def find_circumradius(coordinates):
    if not coordinates:
        return None

    center = find_center(coordinates)  # You can use the previously defined find_center function
    max_distance = 0

    for coord in coordinates:
        distance = math.sqrt((coord['lat'] - center[0])**2 + (coord['lng'] - center[1])**2)
        max_distance = max(max_distance, distance)

    return max_distance

if __name__ == '__main__':
    app.run()