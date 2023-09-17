from math import radians, cos, sin, asin, sqrt, atan2
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask import request, jsonify, render_template
from dotenv import load_dotenv
import os
from twilio.rest import Client

client = Client('AC6afa4a770f4fce6477e24a74fc44789c', 'ce47946c104c538cb9e5f5d2bc1a3ff2')


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

	def __init__(self, latitude, longitude, radius):
		self.latitude = latitude
		self.longitude = longitude
		self.radius = radius

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

    def __init__(self, phone_number, location):
        self.phone_number = phone_number
        self.location = location

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
class Regions(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    region = db.Column(db.String(80))
    location_id = db.Column(db.Integer, db.ForeignKey('location.id', name = 'fk_location_id'))
    location = db.relationship('Location', backref=db.backref('regions', lazy='dynamic'))

    def __init__(self, region, location):
        self.region = region
        self.location = location

    def __repr__(self):
        return '<Region %r>' % self.region
class PolyRegion(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    Long = db.Column(db.Float)
    lat = db.Column(db.Float)
    region_id = db.Column(db.Integer, db.ForeignKey('regions.id', name = 'fk_region_id'))
    region = db.relationship('Regions', backref=db.backref('polyregion', lazy='dynamic'))

    def __init__(self, area, location):
        self.area = area
        self.location = location

    def __repr__(self):
        return '<Area %r>' % self.area
     

@app.route('/locations', methods=['POST'])
def receive_location():
    try:
        data = request.get_json()  # Parse JSON data from the request
        if 'latitude' in data and 'longitude' in data:
            latitude = data['latitude']
            longitude = data['longitude']

            hits = find_locations_in_radius(latitude, longitude)

            output = []

            for hit in hits:
                location = Location.query.get(hit)
                for protocol in location.protocols:
                     temp = {
                          'name' : protocol.protocol,
                            'message' : protocol.messages.message,
                            'phone_number' : protocol.phonetocall.phone_number
                     }
            return jsonify(output), 200
        else:
            return jsonify({'error': 'Invalid data format'}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500


#an html page to add locations    
@app.route('/add', methods=['GET'])
def add():
    return render_template('add.html', googlemaps_key=googlemaps_key)





@app.route('/sndtxt', methods = ['POST'])
def sendText():
    def receive_location():
        try:
            data = request.get_json()  # Parse JSON data from the request
            if 'latitude' in data and 'longitude' in data:
                latitude = data['latitude']
                longitude = data['longitude']

                hits = find_locations_in_radius(latitude, longitude)

                output = []

                for hit in hits:
                    location = Location.query.get(hit)
                    for protocol in location.protocols:
                        temp = {
                            'name' : protocol.protocol,
                                'message' : protocol.messages.message,
                                'phone_number' : protocol.phonetocall.phone_number
                        }
                        message = client.messages \
                            .create(
                            from_='+18449973963',
                            body= temp["message"],
                            to='+16144464294'
     )
                return jsonify(output), 200
            else:
                return jsonify({'error': 'Invalid data format'}), 400
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
    locations_in_radius = []
    for location in Location.query.all():
        distance = haversine(target_lat, target_lon, location.latitude, location.longitude)
        if distance <= location.radius:
            locations_in_radius.append(location.id)
    return locations_in_radius

if __name__ == '__main__':
    app.run()