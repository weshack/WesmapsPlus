import sqlite3

def connect_db():
    return sqlite3.connect('db/courses.db')

def build_course_obj(row):
    courseid = row[0]
    title = row[3]
    code = row[9] + row[6]
    departmentCode = row[9]
    return {'id': courseid, 'title': title, 'code': code, 'departmentCode': departmentCode}

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




