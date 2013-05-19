import simplejson
import scheduling

from flask import Flask, render_template, request, jsonify, g, session
from db import search_for_course_by_title, connect_db, get_courses_from_cursor, get_all_information, get_times_for_section, get_course_summary, get_courseids_for_all_sections, get_instructors_for_course
from user import create_user, get_user_info, update_user_schedule, update_user_starred, count_stars
from scheduling import noConflict, convertTimeStringToDictionary

app = Flask(__name__)

@app.before_request
def before_request():
    g.db = connect_db()

def get_all_courses(conn):
    ret = {}
    c = conn.cursor()
    for courseid in range(int(c.execute("select COUNT(*) from courses").next()[0])):
        #ret.append(get_all_information(conn, courseid))
        summary = get_course_summary(conn, courseid)
        summary['stars'] = count_stars(courseid)
        summary['instructors'] = get_instructors_for_course(g.db, courseid)
        ret[summary['id']] = summary
    return ret

# @app.route('/all')
# def get_all():
#     return simplejson.dumps(get_all_courses(g.db))

@app.route("/")
def index():
    userinfo = get_user_info(session)
    return render_template("index.html", sections = userinfo['sections'], starred = map(int, userinfo['starred']), allSections = get_courseids_for_all_sections(g.db))

@app.route("/search_by_title")
def search():
    term = request.args.get('name', '')
    print 'term', term
    if len(term):
        #results = get_courses_from_cursor(search_for_course_by_title(g.db, term))
        ret = []
        cursor = search_for_course_by_title(g.db, term)
        for item in cursor:
            ret.append(item[0])
        return simplejson.dumps(ret)
    else:
        return simplejson.dumps([])

@app.route("/search_by_professor")
def search_prof():
    prof = request.args.get('prof', '')
    print 'prof', prof
    if len(prof):
        ret = []
        cursor = search_for_course_by_professor(g.db, prof)
        for item in cursor:
            ret.append(item[0])
        return simplejson.dumps(ret)
    return simplejson.dumps([])

@app.route('/course/<courseid>')
def course_info(courseid):
    all_info = get_all_information(g.db, courseid)
    for section in all_info['sections']:
        section['times'] = convertTimeStringToDictionary(section['times'])
    return simplejson.dumps(all_info)

@app.route('/course/<courseid>/summary')
def course_summary(courseid):
    summary = get_course_summary(g.db, courseid)
    summary['stars'] = count_stars(courseid)
    summary['instructors'] = get_instructors_for_course(g.db, courseid)
    return simplejson.dumps(summary)
    
@app.route('/starred')
def get_starred():
    starred = get_user_info(session)['starred']
    return simplejson.dumps(starred)

@app.route('/course/<courseid>/schedule')
def course_schedule(courseid):
	sections = get_sections_for_course(g.db, courseid)
	times = {}
	for section in sections:
		times['section'] = convertTimeStringToDictionary(get_times_for_section(g.db, section))
	return simplejson.dumps(times)

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
    sections = get_user_info(session)['sections']
    return simplejson.dumps(sections)

@app.route('/debug/reset_sections')
def reset_sections():
    update_user_schedule(session['userid'], [])
    sections = get_user_info(session)['sections']
    return simplejson.dumps(sections)

@app.route('/debug/reset_stars')
def reset_stars():
    update_user_starred(session['userid'], [])
    starred = get_user_info(session)['starred']
    return simplejson.dumps(starred)    

@app.route('/schedule/<section>', methods = ['POST', 'DELETE'])
def handle_section(section):
    userinfo = get_user_info(session)
    sections = set(userinfo['sections'])

    if request.method == 'DELETE': 
        # Removing a course
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

