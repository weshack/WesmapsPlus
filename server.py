import simplejson
import scheduling

from flask import Flask, render_template, request, jsonify, g, session
from db import search_for_course_by_title, connect_db, get_courses_from_cursor, get_all_information, get_times_for_section
from pymongo import MongoClient
from user import create_user, get_user_info, update_user_schedule, update_user_starred
from scheduling import noConflict, convertTimeStringToDictionary

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
    
@app.route('/starred')
def get_starred():
    starred = get_user_info(session)['starred']
    return simplejson.dumps(starred)

@app.route('/star/<courseid>', methods = ['POST', 'DELETE'])
def update_starred(courseid = ''):
    starred = set( get_user_info(session)['starred'] )
    
    if request.method == 'DELETE':
        try:
            starred.remove(courseid)
        except:
            pass
        starred = list(starred)
        update_user_starred(session['userid'], starred)
        return simplejson.dumps(starred)

    else:
        starred.add(courseid)
        starred = list(starred)
        update_user_starred(session['userid'], starred)
        return simplejson.dumps(starred)

def merge_dictionaries(dicts):
    ret = {}
    for d in dicts:
        for k, v in d.items():
            for r in v:
                if k in ret:
                    ret[k].append(r)
                else:
                    ret[k] = [r]
    return ret

def get_sections_for_user(session):
    userinfo = get_user_info(session)
    sections = set(userinfo['sections'])
    ret = {}

    for section in sections:
        ret[section] = convertTimeStringToDictionary(get_times_for_section(g.db, section))
 
    return ret

@app.route('/debug/sections')
def get_sections():
    userinfo = get_user_info(session)
    sections = userinfo['sections']
    return simplejson.dumps(sections)

@app.route('/schedule/<section>', methods = ['POST', 'DELETE'])
def handle_section(section):
    userinfo = get_user_info(session)
    sections = set(userinfo['sections'])

    if request.method == 'DELETE': 
        # Removing a course
        print 'rargs', request.args.get('section')
        try:
            sections.remove(section)
        except:
            pass
        sections = list(sections)
        update_user_schedule(session['userid'], sections)
        return simplejson.dumps(sections)

    else: 
        # Adding a course
        allTimes = {}
        conflictDetected = False

        if section in sections:
            return simplejson.dumps( get_sections_for_user(session) )

        for s in sections:
            allTimes[s] = convertTimeStringToDictionary(get_times_for_section(g.db, s))
            if not (noConflict(allTimes, convertTimeStringToDictionary(get_times_for_section(g.db, section)))):
                conflictDetected = True
                break

        if conflictDetected:
            return "Conflict detected", 400

        else:
            sections.add(section)
            update_user_schedule(session['userid'], list(sections))
            return simplejson.dumps( get_sections_for_user(session) )

@app.route("/schedule")
def get_schedule():
    return simplejson.dumps( get_sections_for_user(session) )

    
	
if __name__ == "__main__":
    app.secret_key = 'b6a7ab74af724b1e948b42a30c959cb8'
    app.debug = True
    app.run(host='0.0.0.0')

