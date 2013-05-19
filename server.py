import simplejson
import scheduling

from flask import Flask, render_template, request, jsonify, g, session
from db import search_for_course_by_title, connect_db, get_courses_from_cursor, get_all_information
from pymongo import MongoClient
from user import create_user, get_user_info, update_user_schedule, update_user_starred
from scheduling import noConflict

app = Flask(__name__)

@app.before_request
def before_request():
    g.db = connect_db()

@app.route("/")
def index():
    userinfo = get_user_info(session)
    return render_template("index.html", sections = userinfo['sections'], starred = userinfo['starred'])

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

@app.route('/course/<courseid>')
def course_info(courseid):
    return simplejson.dumps(get_all_information(g.db, courseid))
    
@app.route('/star', methods = ['GET', 'POST', 'DELETE'])
def update_starred():
    starred = set( get_user_info(session)['starred'] )
    
    if request.method == 'GET':
        return simplejson.dumps(list(starred))

    elif request.method == 'DELETE':
        courseid = request.form['courseid']
        starred.add(courseid)
        update_user_starred(starred)
        return simplejson.dumps(list(starred))

    else:
        courseid = request.form['courseid']
        starred.add(courseid)
        update_user_starred(starred)
        return simplejson.dumps(list(starred))

@app.route("/schedule", methods = ['GET', 'POST, DELETE'])
def update_schedule():
    userinfo = get_user_info(session)
    sections = userinfo['sections']

    if request.method == 'GET':
        times = {}
        for section in sections:
            times['section'] = convertTimeStringToDictionary(get_times_for_section(g.db, section))
        return simplejson.dumps(times)

    elif request.method == 'DELETE' and section in sections: 
        # Removing a course
        section = request.form['section']
        sections = sections[:sections.index(section)] + sections[sections.index(section)+1:]
        update_user_schedule(session['userid'], sections)
        return 200

    else: 
        # Adding a course
        section = request.form['section']
        allTimes = {}
        for s in sections:
            allTimes[s] = convertTimeStringToDictionary(get_times_for_section(g.db, s))
            if noConflict(allTimes, convertTimeStringToDictionary(get_times_for_section(g.db, section))):
                sections.append(section)
            else:
                pass

    update_user_schedule(session['userid'], sections)
	
if __name__ == "__main__":
    app.secret_key = 'b6a7ab74af724b1e948b42a30c959cb8'
    app.debug = True
    app.run(host='0.0.0.0')

