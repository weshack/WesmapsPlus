import sqlite3

def connect_db():
    return sqlite3.connect('db/courses.db')

def build_course_obj(row):
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
	'professor': row[14],
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
      select * from courses
      where title like '%"""+term+"""%' and semester = 'Fall 2013'
   """)

def get_times_for_section(conn, sectionid):
    c = conn.cursor()
    return c.execute("select times from sections where _uid = " + str(sectionid)).next()[0]

def get_sections_for_course(conn, courseid):
    c = conn.cursor()
    return c.execute("select * from sections where course_uid = " + str(courseid))

def get_sections_and_times_for_course(conn, courseid):
    c = conn.cursor()
    return c.execute("select times from sections where course_uid = " + str(courseid)).next()[0]

def get_all_information(conn, courseid):
    c = conn.cursor()
    courseDict = build_full_course_obj(c.execute("select * from courses where _uid = " + str(courseid)).next())
	sectionCursor = get_sections_for_course(conn, courseid)
	while True
		try:
			courseDict['sections'].append(build_full_section_obj(sectionCursor.next()))
		except:
			break
	return courseDict
	
	

def get_instructors_for_course(conn, courseid):
    c = conn.cursor()
    prof_string = c.execute("select professor from sections where course_uid = " + str(courseid)).next()
    
    instructors = []

    for professor in prof_string.split(';'):
        instructors.append( c.execute("select * from professors where _uid = " + professor).next() )
    
    return instructors

    

