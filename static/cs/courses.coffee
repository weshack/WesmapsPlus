# We are assuming that the server will return
# data like below:
#{
#	"genEdArea": "HA ART",
#	"prerequisites": "None",
#	"title": "European Architecture to 1750",
#	"url": "https://iasext.wesleyan.edu/regprod/!wesmaps_page.html?crse=008011&term=1099",
#	"credit": 1,
#	"number": "151",
#	"courseid": "008011",
#	"semester": "Fall 2009",
#	"department": "ARHA",
#	"gradingMode": "Graded",
#	"sections":
#	[
#		{
#			"FR": "18",
#			"permissionRequired": false,
#			"name": "01",
#			"JR_Major": "6",
#			"additional_requirements": "None",
#			"SR_Major": "6",
#			"times": ".M.W... 02:40PM-04:00PM; \u00a0\u00a0\u00a0\u00a0\u00a0\u00a0",
#			"seatsAvailable": 15,
#			"JR_NonMajor": "6",
#			"location": "CFAHALL; ",
#			"major_readings": " ;;;Marvin Trachtenberg and Isabel Hyman, ARCHITECTURE, FROM PREHISTORY TO POSTMODERNISM;Robin R. Rhodes, ARCHITECTURE AND MEANING ON THE ATHENIAN ACROPOLIS;William MacDonald, THE PANTHEON.;Roger Stalley, EARLY MEDIEVAL ARCHITECTURE;Otto von Simson, THE GOTHIC CATHEDRAL;Peter Murray, ARCHITECTURE OF THE ITALIAN RENAISSANCE.;Robert W. Berger, A ROYAL PASSION: LOUIS XIV AS PATRON OF ARCHITECTURE",
#			"SO": "18",
#			"GRAD_Major": "X",
#			"SR_NonMajor": "6",
#			"enrollmentLimit": 60,
#			"assignments_and_examinations": "Three short papers, two in-class exams and a final exam."
#		}
#	]
#}
#
# And we will take this data and build the webpage client-side using
# this Coffeescript.
#
#

data = JSON.parse($.getJSON('courses/'))
#$("head").html('''
#		<link href='http://fonts.googleapis.com/css?family=Roboto+Slab:400,700' rel='stylesheet' type='text/css'>
#		<link href='styles.css' rel='stylesheet' type='text/css'> ''')

		

$("body").html('''
<h1><div class=course-code>#{data['department']}#{data['number']}</div><span class=course-name>#{data['title']}</span></h1>
<div class=container>
	<div class=header>Credit</div>
	<div class=data>#{data['credit']}</div>
	<div class=header>GenEd</div>
	<div class=data>#{data['genEdArea']}</div>
	<div class=header>Graded?</div>
	<div class=data>#{gradingMode}</div>
	<div class=header>Prerequisites</div>
	<div class=data>#{data['prerequisites']}</div>
</div>
<p>data['description']</p>''')
