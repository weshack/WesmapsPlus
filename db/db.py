import sqlite3
import json
import re


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
      where (upper(title) like upper("""+json.dumps("%"+term+"%")+""") or upper(department) like upper("""+json.dumps('%'+term+'%')+"""))""")

def search_for_course_by_code(conn, code):
    subjectCodes = {"ARAB":"Arabic","ARHA":"Art History","ARST":"Art Studio","ALIT":"Asian Languages and Literature","CHIN":"Chinese","CCIV":"Classical Civilization","COL":"College of Letters","DANC":"Dance","ENGL":"English","FILM":"Film Studies","FREN":"French","FRST":"French Studies","FIST":"French, Italian, Spanish in Translation","GELT":"German Literature in English","GRST":"German Studies","GRK":"Greek","HEBR":"Hebrew","HEST":"Hebrew Studies","IBST":"Iberian Studies","ITAL":"Italian Studies","JAPN":"Japanese Studies","KREA":"Korean Studies","LAT":"Latin Studies","LANG":"Less Commonly Taught Languages","MUSC":"Music","PORT":"Portugese","RUSS":"Russian","RULE":"Russian Literature in English","SPAN":"Spanish","THEA":"Theater","AMST":"American Studies","ANTH":"Anthropology","CSS":"College of Social Studies","ECON":"Economics","GOVT":"Government","HIST":"History","PHIL":"Philosophy","RELI":"Religion","SOC":"Sociology","CEC":"Civic Engagement","CES":"Environmental Studies","CIM":"Informatics and Modeling","CIR":"International Relations","CJS":"Jewish and Israel Studies","CMES":"Middle Eastern Studies","CMB":"Molecular Biophysics","CSCT":"Social, Cultural, and Critical Theory","CSA":"South Asian Studies","CSED":"The Study of Education","CWRC":"Writing","ASTR":"Astronomy","BIOL":"Biology","CHEM":"Chemistry","COMP":"Computer Science","EES":"Earth and Environmental Sciences","MATH":"Mathematics","MBB":"Molecular Biology and Biochemistry","NSB":"Neuroscience and Behavior","PHYS":"Physics","PSYC":"Psychology","XAFS":"African Studies","XCHS":"Christianity Studies","XDST":"Disability Studies","XPSC":"Planetary Science","XSER":"Service-Learning","XURS":"Urban Studies","AFAM":"African American Studies","ARCP":"Archaeology","CHUM":"Center for the Humanities","CSPL":"Center for the Study of Public Life","EAST":"East Asian Studies","ENVS":"Environmental Studies","FGSS":"Feminist, Gender, and Sexuality Studies","LAST":"Latin American Studies","MECO":"Mathematics-Economics","MDST":"Medieval Studies","QAC":"Quantitative Analysis Center","REES":"Russian, East European, and Eurasian Studies","SISP":"Science in Society","WRCT":"Writing Center","COE":"College of the Environment","CPLS":"Graduate Planetary Science Concentration","PHED":"Physical Education","FORM":"Student Forums","WLIT":"World Literature Courses"}
    c = conn.cursor()
    ret = []
    for row in c.execute("select _uid,department,number from courses"):
        courseCode = str(row[1])+str(row[2])
        if str(row[1]) in subjectCodes and (code.upper() in courseCode or code.upper() in subjectCodes[str(row[1])].upper()):
            print 'potCode', courseCode
            ret.append(row[0])
        elif code.upper() in courseCode:
            print 'potCode', courseCode
            ret.append(row[0])
    return ret
#     m = re.search(r'[0-9]', code)

#     if m:
#         idx = m.start()
#         dept = code[:idx]
#         num = code[idx:]
#     else:
#         dept = code
#         num = ''

#     print 'by code', dept, num

#     c = conn.cursor()
#     return c.execute("""
#       select _uid from courses
#       where (number like %""" + num + "% or upper(department) like upper("""+dept+"""))""")

def search_for_course_by_professor(conn, professor):
    c = conn.cursor()
    prof_ids = []
    for prof_id in c.execute("select _uid from professors where upper(name) like upper("+json.dumps('%'+str(professor)+'%')+")"):
        prof_ids.append(prof_id[0])
    if len(prof_ids):
        msg = "select course_uid from sections where "
        for prof_id in prof_ids:
            msg += " (professor like '"+str(prof_id)+";%' or professor like '%;"+str(prof_id)+";%' or professor = '" + str(prof_id)+"') OR "
        return c.execute(msg[:-3])
    else:
        return []

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
        if not professor: continue
        instructors.append( get_instructor(conn, professor) )

    return instructors

def get_instructors_for_course(conn, courseid):
    c = conn.cursor()
    cursor = c.execute("select professor from sections where course_uid = " + str(courseid))

    instructors = []

    for item in cursor:
        if not item[0]: continue
        for professor in item[0].split(';'):
            if not professor: continue
            instructors.append( get_instructor(conn, professor) )
    
    return instructors

