require 'json'
require 'sqlite3'

json_data = JSON.parse(IO.read("courses.json"))
courses = SQLite3::Database.new("courses.db")
courses.execute "DROP TABLE courses"
courses.execute <<-SQL
CREATE TABLE courses (
_uid INTEGER PRIMARY KEY,
genEdArea TEXT,
preqrequisites TEXT,
title text,
url TEXT,
credit REAL,
number TEXT,
courseid INTEGER,
semester TEXT,
department TEXT,
gradingMode TEXT
);
SQL

courses.execute "DROP TABLE sections"
courses.execute <<-SQL
CREATE TABLE sections (
_uid INTEGER PRIMARY KEY,
courseid INTEGER,
permissionRequired TEXT,
name INTEGER,
FR TEXT,
SO TEXT,
JR_NonMajor TEXT,
JR_major TEXT,
SR_NonMajor TEXT,
SR_major TEXT,
GRAD_major TEXT,
additional_requirements TEXT,
times TEXT,
seatsAvailable TEXT,
professor INTEGER,
location TEXT,
major_readings TEXT,
enrollmentLimit INTEGER,
assignments_and_examinations TEXT
);
SQL

primaryKey = 0
sPk = 0
total = 20026
json_data.each do | course |
	courseid = course['courseid']
	course['sections'].each do | section |
		sqlStatement = 'INSERT INTO sections VALUES ( '
		sqlStatement << sPk.to_s
		sqlStatement << ', '
		sqlStatement << courseid
		sqlStatement << ', "'
		sqlStatement << section['permissionRequired'].to_s
		sqlStatement << '", "'
		sqlStatement << section['name'].gsub('"',"'")
		sqlStatement << '", "'
		if section['FR']
			sqlStatement << section['FR']
		else
			sqlStatement << 'X'
		end
		sqlStatement << '", "'
		if section['SO']
			sqlStatement << section['SO']
		else
			sqlStatement << 'X'
		end
		sqlStatement << '", "'
		if section['JR_NonMajor']
			sqlStatement << section['JR_NonMajor']
		else
			sqlStatement << 'X'
		end
		sqlStatement << '", "'
		if section['JR_Major']
			sqlStatement << section['JR_Major']
		else
			sqlStatement << 'X'
		end
		sqlStatement << '", "'
		if section['SR_NonMajor']
			sqlStatement << section['SR_NonMajor']
		else
			sqlStatement << 'X'
		end
		sqlStatement << '", "'
		if section['SR_Major']
			sqlStatement << section['SR_Major']
		else
			sqlStatement << 'X'
		end
		sqlStatement << '", "'
		if section['GRAD_Major']
			sqlStatement << section['GRAD_Major']
		else
			sqlStatement << 'X'
		end
		sqlStatement << '", "'
		#sqlStatement << section['additional_requirements']
		sqlStatement << "None"
		sqlStatement << '", "'
		sqlStatement << section['times']
		sqlStatement << '", "'
		sqlStatement << section['seatsAvailable'].to_s
		sqlStatement << '", '
		sqlStatement << "0" #section['professor']
		sqlStatement << ', "'
		sqlStatement << section['location']
		sqlStatement << '", "'
		sqlStatement << section['major_readings'].gsub("\n",";").gsub('"',"'")
		sqlStatement << '", '
		sqlStatement << section['enrollmentLimit'].to_s
		sqlStatement << ', "'
		sqlStatement << section['assignments_and_examinations'].gsub('"',"'")
		sqlStatement << '");'
		courses.execute(sqlStatement)
		sPk += 1
	end
	sqlStatement = 'INSERT INTO courses VALUES ( '
	sqlStatement << primaryKey.to_s
	sqlStatement << ', "'
	sqlStatement << course['genEdArea']
	sqlStatement << '", "'
	sqlStatement << course['prerequisites']
	sqlStatement << '", "'
	sqlStatement << course['title'].gsub('"',"'")
	sqlStatement << '", "'
	sqlStatement << course['url']
	sqlStatement << '", '
	sqlStatement << course['credit'].to_s
	sqlStatement << ', "'
	sqlStatement << course['number']
	sqlStatement << '", '
	sqlStatement << course['courseid']
	sqlStatement << ', "'
	sqlStatement << course['semester']
	sqlStatement << '", "'
	sqlStatement << course['department']
	sqlStatement << '", "'
	sqlStatement << course['gradingMode']
	sqlStatement << '");'
	courses.execute(sqlStatement)
	primaryKey += 1
	printf("\r%0.3f", primaryKey.to_f/total.to_f * 100)

end