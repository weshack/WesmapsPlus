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
			'section_uid': row[12],
			#'course_uid': row[13], # already in dictionary from top
			'permissionRequired': row[14],
			'name': row[15],
			'FR': row[16],
			'SO': row[17],
			'JR_NonMajor': row[18],
			'JR_major': row[19],
			'SR_NonMajor': row[20],
			'SR_major': row[21],
			'GRAD_major': row[22],
			'additional_requirements': row[23],
			'times': row[24],
			'seatsAvailable': row[25],
			'professor': row[26],
			'location': row[27],
			'major_readings': row[28],
			'enrollmentLimit': row[29],
			'assignments_and_examinations': row[30] }
	
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

def get_sections_and_times_for_course(conn, courseid):
    c = conn.cursor()
    return c.execute("select * from sections where courseid = " + str(courseid))

def get_sections_and_times_for_course(conn, courseid):
    c = conn.cursor()
    return c.execute("select times from sections where courseid = " + str(courseid)).next()[0]

def get_all_information(conn, courseid):
	c = conn.cursor()
	return build_full_course_obj(c.execute("select * from courses JOIN sections ON courses._uid = sections.course_uid WHERE courses._uid = " + str(courseid)).next())




