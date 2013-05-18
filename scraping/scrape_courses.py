import re
import requests
import simplejson
from scrapy.selector import HtmlXPathSelector

def remove_tags(t):
    ret = ''
    inTag = False
    for s in t:
        if s == '<':
            inTag = True

        elif s == '>':
            inTag = False
        
        elif not inTag:
            ret += s

    return ret

seen = {}

def seen_course(cid, term):
    return (cid + "," + term) in seen

professors = []

year_pages = {
    '2006-2007': "https://iasext.wesleyan.edu/regprod/!wesmaps_page.html?term=1069",
    '2007-2008': "https://iasext.wesleyan.edu/regprod/!wesmaps_page.html?term=1079",
    '2008-2009': "https://iasext.wesleyan.edu/regprod/!wesmaps_page.html?term=1089",
    '2009-2010': "https://iasext.wesleyan.edu/regprod/!wesmaps_page.html?term=1099",
    '2010-2011': "https://iasext.wesleyan.edu/regprod/!wesmaps_page.html?term=1109",
    '2011-2012': "https://iasext.wesleyan.edu/regprod/!wesmaps_page.html?term=1119",
    '2012-2013': "https://iasext.wesleyan.edu/regprod/!wesmaps_page.html?term=1129",
    '2013-2014': "https://iasext.wesleyan.edu/regprod/!wesmaps_page.html"
}

term_codes = {
    'Summer 2006': '1066',
    'Summer 2007': '1076',
    'Summer 2008': '1086',
    'Summer 2009': '1096',
    'Summer 2010': '1106',
    'Summer 2011': '1116',
    'Summer 2012': '1126',
    'Summer 2013': '1136',
    'Fall 2006': "1069",
    'Fall 2007': "1079",
    'Fall 2008': "1089",
    'Fall 2009': "1099",
    'Fall 2010': "1109",
    'Fall 2011': "1119",
    'Fall 2012': "1129",
    'Fall 2013': "1139",
    'Spring 2007': '1071',
    'Spring 2008': '1081',
    'Spring 2009': '1091',
    'Spring 2010': '1101',
    'Spring 2011': '1111',
    'Spring 2012': '1121',
    'Spring 2013': '1131',
    'Spring 2014': '1141',
}

def get_courses_offered_urls_from_year_page(url):
    c = requests.get(url).content
    selector = HtmlXPathSelector(text = c)
    urls = selector.select("//tr/td[@valign='top']/a/@href").extract()
    filtered_urls = filter(lambda url: 'subj_page' in url, urls)
    courses_offered_urls = []
    for url in filtered_urls:
        (subject, term) = re.findall(r"subj_page=([^&]*)&term=(.*)", url)[0]
        courses_offered_url = "https://iasext.wesleyan.edu/regprod/!wesmaps_page.html?crse_list=%s&term=%s&offered=Y" % (subject, term)
        courses_offered_urls.append(courses_offered_url)
    return courses_offered_urls

def get_course_urls_from_courses_offered_page(url):
    c = requests.get(url).content
    selector = HtmlXPathSelector(text = c)
    try:
        course_links = selector.select("//tr/td[@width='5%']/a/@href").extract()
    except:
        course_links = []
    return map(lambda l: "https://iasext.wesleyan.edu/regprod/" + l, course_links)

def get_url_for_course(courseid, term):
    return "https://iasext.wesleyan.edu/regprod/!wesmaps_page.html?crse=%s&term=%s" % (courseid, term)

def get_course_info_from_course_page(url):
    c = requests.get(url).content
    course = {}
    selector = HtmlXPathSelector(text = c)
    course['title'] = selector.select("//span[@class='title']/text()").extract()[0]
    course['department'] = selector.select("//td/b/a/text()").extract()[0]
    course['number'] = selector.select("//td/b/text()").extract()[0].split(' ')[1]
    course['semester'] = selector.select("//td/b/text()").extract()[1].replace('\n', '')

    descriptionSelector = None
    for sel in selector.select("//td[@colspan='3']"):
        if len(sel.select("br")):
            descriptionSelector = sel

    try:
        course['description'] = descriptionSelector.select("text()").extract()[0].strip('\n')
    except:    
        course['description'] = 'This course has no description.'

    try:
        course['term_code'] = term_codes[course['semester']]
    except:
        course['term_code'] = ''


    course['url'] = url
    course['courseid'] = url[60:66]

    if seen_course(course['courseid'], course['term_code']):
        return None

    try:
        course['credit'] = float( re.findall('Credit: </b>([^<]*)', c)[0] )
    except:
        course['credit'] = 1

    try:
        course['prerequisites'] = re.findall('Prerequisites: </b>([^<]*)', c)[0]
    except:
        course['prerequisites'] = "None"

    try:
        course['genEdArea'] = re.findall('Gen Ed Area Dept: </b>([^<]*)', c)[0].replace('\n','')
    except:
        course['genEdArea'] = "None"

    try:
        course['gradingMode'] = re.findall('Grading Mode: </b>([^<]*)', c)[0].replace('\n','')
    except:
        course['gradingMode'] = "None"

    sectionsSelector = selector.select("//table[@border='1']")
    
    course['sections'] = []

    for sectionSelector in sectionsSelector:
        section = {}

        content = sectionSelector.extract()

        try:
            section['name'] = re.findall('SECTION ([^<]*)', content)[0]
        except:
            section['name'] = "None"

        try:
            section['times'] = re.findall('Times:</b> ([^<]*)', content)[0].replace('\n','').replace('&nbsp;', '')
        except:
            section['times'] = "None"

        try:
            section['location'] = re.findall('Location:</b> ([^<]*)', content)[0].replace('\n','')
        except:
            section['location'] = "None"

        try:
            section['enrollmentLimit'] = int( re.findall('Total Enrollment Limit: </a>([^<]*)', content)[0] )
        except:
            section['enrollmentLimit'] = 0

        try:
            section['seatsAvailable'] = int( re.findall('Seats Available: ([^<]*)', content)[0] )
        except:
            section['seatsAvailable'] = 0

        try:
            section['GRAD_Major'] = re.findall('GRAD: ([^<]*)', content)[0]
            section['SR_NonMajor'] = re.findall('SR non-major: ([^<]*)', content)[0]
            section['SR_Major'] = re.findall('SR major: ([^<]*)', content)[0]
            section['JR_NonMajor'] = re.findall('JR non-major: ([^<]*)', content)[0]
            section['JR_Major'] = re.findall('JR major: ([^<]*)', content)[0]
            section['SO'] = re.findall('SO: ([^<]*)', content)[0]
            section['FR'] = re.findall('FR: ([^<]*)', content)[0]
            section['permissionRequired'] = False
        except:
            section['permissionRequired'] = True


        majorReadingsSelector = sectionSelector.select("tr/td")[1]
        try:
            section['major_readings'] = '\n'.join( majorReadingsSelector.select("text()").extract() )
        except:
            section['major_readings'] = ''

        assignmentsSelector = sectionSelector.select("tr/td")[2]
        try:
            section['assignments_and_examinations'] = '\n'.join( assignmentsSelector.select("text()").extract() )
        except:
            section['assignments_and_examinations'] = ''
            
        additionalRequirementsSelector = sectionSelector.select("tr/td")[3]
        try:
            section['additional_requirements'] = '\n'.join( additionalRequirementsSelector.select("text()").extract() )
        except:
            section['additional_requirements'] = ''        

        instructorsSelector = None

        for sel in sectionSelector.select("tr/td"):
            try:
                if 'Instructor' in sel.select("b").extract()[0]:
                    instructorsSelector = sel
                    break
            except:
                pass

        try:
            section['instructors'] = instructorsSelector.select("a/text()").extract()
            section['instructors'] = map(lambda inst: inst.strip(' '), section['instructors'])

            for instructor in section['instructors']:
                if not (instructor in professors):
                    professors.append(instructor)
        except:
            section['instructors'] = []

        course['sections'].append(section)

    return course

def get_all_instructors_for_course(course):
    instructors = []
    for section in course['sections']:
        for instructor in section['instructors']:
            if not (instructor in instructors):
                instructors.append(instructor)
    return instructors

def get_current_courses():
    courses = []
    url = "https://iasext.wesleyan.edu/regprod/!wesmaps_page.html"
    courses_offered_urls = get_courses_offered_urls_from_year_page(url)
    for courses_offered_url in courses_offered_urls:
        course_urls = get_course_urls_from_courses_offered_page(courses_offered_url)
        for course_url in course_urls:
            course = get_course_info_from_course_page(course_url)
            print "Adding", course['title'], course['description'], get_all_instructors_for_course(course)
            if course:
                courses.append(course)
    return courses

def get_all_courses():
    courses = []
    for year_page_url in year_pages.values():
        courses_offered_urls = get_courses_offered_urls_from_year_page(year_page_url)
        for courses_offered_url in courses_offered_urls:
            course_urls = get_course_urls_from_courses_offered_page(courses_offered_url)
            for course_url in course_urls:
                course = get_course_info_from_course_page(course_url)
                print "Adding", course['title'], course['description'], get_all_instructors_for_course(course)
                courses.append(get_course_info_from_course_page(course_url))
    return courses

if __name__ == '__main__':
    #courses = get_all_courses()
    courses = get_current_courses()
    open('courses.json', 'w').write(simplejson.dumps(courses))
    open('instructors.json', 'w').write(simplejson.dumps(professors))
