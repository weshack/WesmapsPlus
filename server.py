from flask import Flask, render_template, request, jsonify, g

import pymongo
import uuid
import simplejson

from db import search_for_course_by_title, connect_db, get_courses_from_cursor

def generate_user_id():
    return str(uuid.uuid4())

app = Flask(__name__)

@app.before_request
def before_request():
    g.db = connect_db()

def get_user_info(userid):
    pass

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/search_by_title")
def search():
    term = request.args.get('name', '')
    print 'term', term
    if len(term):
        results = get_courses_from_cursor(search_for_course_by_title(g.db, term))
        print results
        return simplejson.dumps(results)
    else:
        return simplejson.dumps([])

@app.route("/schedule")
def get_schedule():
    pass

@app.route("/schedule", methods = ['PUT'])
def update_schedule():
    pass

@app.route("/schedule", methods = ['POST'])
def create_schedule():
    pass

if __name__ == "__main__":
    app.debug = True
    app.run(host='0.0.0.0')

