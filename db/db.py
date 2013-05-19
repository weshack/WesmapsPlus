import sqlite3

def connect_db():
    return sqlite3.connect('db/courses.db')

def build_course_obj(row):
    courseid = row[0]
    title = row[3]
    code = row[9] + row[6]
    departmentCode = row[9]
    return {'id': courseid, 'title': title, 'code': code, 'departmentCode': departmentCode}

def build_course_summary_obj(row):
    courseid = row[0]
    title = row[3]
    code = row[9] + row[6]
    departmentCode = row[9]
    
    return {'id': courseid, 'title': title, 'code': code, 'departmentCode': departmentCode}

def build_full_course_obj(row):
    return { '_uid': row[0],
             'genEdArea': row[1],
             'prerequisites': row[2],
             'title': row[3],
             'url': row[4],
             'credit': row[5],
             'number': row[6],
             'courseid': row[7],
             'semester': row[8],
             'department': row[9],
             'gradingMode': row[10],
             'description': row[11],
             'sections': [] }
	
def build_full_section_obj(row):
	return { '_uid': row[0],
	'course_uid': row[1],
	'permissionRequired': row[2],
	'name': row[3],
	'FR': row[4],
	'SO': row[5],
	'JR_NonMajor': row[6],
	'JR_major': row[7],
	'SR_NonMajor': row[8],
	'SR_major': row[9],
	'GRAD_major': row[10],
	'additional_requirements': row[11],
	'times': row[12],
	'seatsAvailable': row[13],
	'location': row[15],
	'major_readings': row[16],
	'enrollmentLimit': row[17],
	'assignments_and_examinations': row[18] }
	
def get_courses_from_cursor(res):
    ret = []
    for result in res:
        ret.append(build_course_obj(result))
    return ret

def get_all_courses():
    return c.execute('select * from courses')

# def search_for_course_by_title(conn, term):
#     c = conn.cursor()
#     return c.execute("""
#       select * from courses
#       where ( title like '%s%'
#       or department like '%s%'
#       ) and semester = 'Fall 2013'
#     """  % (term, term) )

def search_for_course_by_title(conn, term):
    c = conn.cursor()
    return c.execute("""
      select _uid from courses
      where (upper(title) like upper('%"""+term+"""%') or upper(department) like upper('%"""+term+"""%'))""")

def search_for_course_by_professor(conn, professor):
    c = conn.cursor()
    try:
        prof_id = c.execute("select _uid from professors where upper(name) like upper('%"+str(professor)+"%')").next()[0]
    except:
        return []
    cursor = c.execute("select course_uid from sections where professor like '"+str(prof_id)+";%' or professor like '%;"+str(prof_id)+";%' or professor = '" + str(prof_id)+"'")
    courses = "1=2 OR "
    for item in cursor:
        courses += "_uid = " + str(item[0]) + ' OR '
    return c.execute("select _uid from courses where " + str(courses[:-3]))

def get_course_summary(conn, courseid):
    c = conn.cursor()
    
    summary = build_course_summary_obj( c.execute("select * from courses where _uid = " + str(courseid)).next() )
    
    #summary['sections'] = get_section_ids_for_course(conn, courseid)
    return summary

def get_times_for_section(conn, sectionid):
    c = conn.cursor()
    return c.execute("select times from sections where _uid = " + str(sectionid)).next()[0]

def get_sections_for_course(conn, courseid):
    c = conn.cursor()
    return c.execute("select * from sections where course_uid = " + str(courseid))

def get_section_ids_for_course(conn, courseid):
    c = conn.cursor()
    return c.execute("select _uid from sections where course_uid = " + str(courseid))

def get_sections_and_times_for_course(conn, courseid):
    c = conn.cursor()
    return c.execute("select times from sections where course_uid = " + str(courseid)).next()[0]

def get_courseids_for_all_sections(conn):
    c = conn.cursor()
    ret = {}
    cursor = c.execute("select _uid, course_uid from sections")
    for item in cursor:
        try:
            [section_id, course_id] = item
            ret[section_id] = course_id
        except:
            break
    return ret

def get_all_information(conn, courseid):
    c = conn.cursor()
    courseDict = build_full_course_obj(c.execute("select * from courses where _uid = " + str(courseid)).next())
    sectionCursor = get_sections_for_course(conn, courseid)
    for section in sectionCursor:
        sectionObj = build_full_section_obj(section)
        sectionObj['instructors'] = get_instructors_for_section(conn, section[0])
        courseDict['sections'].append(sectionObj)
    courseDict['instructors'] = get_instructors_for_course(conn, courseid)
    return courseDict

def get_instructor(conn, inst_id):
    c = conn.cursor()
    row = c.execute("select * from professors where _uid = " + inst_id).next()
    return {
        'instid': row[0],
        'name': row[1],
        'rating': row[2]
        }
        
def get_instructors_for_section(conn, section):
    c = conn.cursor()
    prof_string = c.execute("select professor from sections where _uid = " + str(section)).next()[0]

    instructors = []

    for professor in prof_string.split(';'):
        instructors.append( get_instructor(conn, professor) )

    return instructors

def get_instructors_for_course(conn, courseid):
    c = conn.cursor()
    cursor = c.execute("select professor from sections where course_uid = " + str(courseid))

    instructors = []

    for item in cursor:
        if not item[0]: continue
        for professor in item[0].split(';'):
            instructors.append( get_instructor(conn, professor) )
    
    return instructors

