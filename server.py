import uuid
import simplejson
import scheduling

from flask import Flask, render_template, request, jsonify, g, session
from db import search_for_course_by_title, connect_db, get_courses_from_cursor
from pymongo import MongoClient

client = MongoClient()
db = client.wesmaps
users = client.wesmaps.users

def generate_user_id():
    return str(uuid.uuid4())

def create_user():
    user_id = generate_user_id()
    users.insert({'id': user_id, 
                  'schedule': [],
                  'starred': []})
    return user_id

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
    sections = get_user_info(session['userid'])['sections']
	times = {}
	for section in sections:
		times['section'] = convertTimeStringToDictionary(get_times_for_section(g.db, section))
	return simplejson.dumps(times)

@app.route("/schedule", methods = ['POST, DELETE'])
def update_schedule():
	section = request.form['sections']
	sections = get_user_info(session['userid'])['sections']
	if request.method == 'DELETE' and section in sections: # Removing a course
		sections = sections[:sections.index(section)] + sections[sections.index(section)+1:]
	else: # Adding a course
		allTimes = {}
		for s in sections:
			allTimes[s] = convertTimeStringToDictionary(get_times_for_section(g.db, s)
		if noConflict(allTimes, convertTimeStringToDictionary(get_times_for_section(g.db, section))):
			sections.append(section)
	update_user_schedule(session['userid'], sections)
	
				
		
if __name__ == "__main__":
    app.debug = True
    app.run(host='0.0.0.0')

