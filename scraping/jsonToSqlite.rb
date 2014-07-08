require 'json'
require 'sqlite3'

json_data = JSON.parse(IO.read("courses.json"))
courses = SQLite3::Database.new("courses.db")
#courses.execute "DROP TABLE courses"
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
gradingMode TEXT,
description TEXT,
sections TEXT
);
SQL

#courses.execute "DROP TABLE sections"
courses.execute <<-SQL
CREATE TABLE sections (
_uid INTEGER PRIMARY KEY,
course_uid INTEGER,
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
professor TEXT,
location TEXT,
major_readings TEXT,
enrollmentLimit INTEGER,
assignments_and_examinations TEXT
);
SQL
#courses.execute "DROP TABLE professors"
courses.execute <<-SQL
CREATE TABLE professors (
_uid INTEGER PRIMARY KEY,
name TEXT,
rating REAL
);
SQL


current_semester = (if Time.now.month < 4 then "Spring" else "Fall" end)  +  " " + Time.now.year.to_s

primaryKey = 0
professor_data = JSON.parse(IO.read("professors_with_ratings.json"))
professor_data.each do | prof |
	rating = -1
	rating = prof['rating'].to_s if prof['rating']
	courses.execute("INSERT INTO professors VALUES ( #{primaryKey.to_s}, \"#{prof['name'].gsub('"',"'")}\", #{rating} );")
	primaryKey += 1
end
primaryKey = 0
sPk = 0
total = json_data.size
coursesAdded = []
json_data.each do | course |
	if course['semester'] == current_semester and not coursesAdded.index(course['title'])
		coursesAdded << course['title']
		courseuid = primaryKey
		sections = ""
		course['sections'].each do | section |
			sqlStatement = 'INSERT INTO sections VALUES ( '
			sqlStatement << sPk.to_s
			sections << sPk.to_s
			sections << ";"
			sqlStatement << ', '
			sqlStatement << courseuid.to_s
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
			sqlStatement << '", "'
			profs = []
			section['instructors'].each do | prof |
				res = courses.execute("SELECT _uid FROM professors WHERE name = \"#{prof.gsub('"',"'").gsub(',',', ')}\"")
				profs << res[0][0].to_s if res and res[0] and res[0][0]
			end
			sqlStatement << profs.join(';')
			sqlStatement << '", "'
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
		sqlStatement << '", "'
		sqlStatement << course['description'].gsub('"',"'")
		sqlStatement << '", "'
		sqlStatement << sections
		sqlStatement << '");'
		courses.execute(sqlStatement)
		primaryKey += 1
		printf("\r%0.3f%%", primaryKey.to_f/total.to_f * 100)
	end
end
puts "... #{primaryKey} total added"
