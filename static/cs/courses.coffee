
class SectionSchedule

	this.earliest = 75
	this.latest = 90

	this.possColors = ['8c2318', '5e8c6a', '88a65e', 'bfb35a','f2c45a']

	constructor: (courseData, $wrapper) ->
		@courseData = courseData
		@$wrapper = $wrapper
		@days = {}
		@colors = {}


		for d in ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
			$newDay = $('<div class="day day-' + d + '"><div class="relative"></div></div>')
			@$wrapper.append($newDay)
			$newDay.append('<div class="dayName">' + d.substring(0,3) + '</div>')
			@days[d] = $newDay.children('.relative')

		this.draw()

	highlightCourse: (course) ->
		$('.mtg').addClass('fade');
		$('.mtg-' + course).removeClass('fade');

	lowlightCourses: ->
		$('.mtg').removeClass('fade')

	draw: ->
		for day, $el of @days
			$el.html('')

		for course, days of @courseData

			if course in @colors
				thisColor = colors[course]
			else
				thisColor = Schedule.possColors.pop()


			for day, times of days
				for t in times
					earliest = Schedule.earliest
					latest = Schedule.latest
					top = (t[0] - earliest)*100 / (latest - earliest)
					height = (t[1] - t[0])*100 / (latest - earliest)

					$thisMtg = $('<div class="mtg mtg-' + course + '"></div>')

					$thisMtg
						.css('top', top + '%')
						.css('height', height + '%')
						.css('background-color', '#' + thisColor)
						.data('course', course)


					thisSchedule = this
					$thisMtg.hover(() ->
						thisSchedule.highlightCourse($(this).data('course'))
					,() ->
						thisSchedule.lowlightCourses()
					)

					@days[day].append($thisMtg)


@handleSection = (section) ->
	data = JSON.parse($.getJSON("/courses"))
	currSchedule = JSON.parse($.getJSON("/schedule"))
	if data['_uid'] in currSchedule
		removeSection(section)
		$('#course-updater').addClass('add')
		$('#course-updater').removeClass('remove')
	else
		addSection(section)
		$('#course-updater').addClass('remove')
		$('#course-updater').removeClass('add')
	
addSection = (section) ->
	$.ajax
		type: 'POST'
		url: "/schedule/#{section}"
		data: {section}
		success: (newSections) ->
			console.log newSections
		error: ->
			conflictDetected()

removeSection = (section) ->
	$.ajax
		type: 'DELETE'
		url: "/schedule/#{section}"
		data: {section}
		success: (newSections) ->
			console.log newSections
		error: ->
			conflictDetected()

load = (course_id) ->
	currSchedule = JSON.parse($.getJSON("/schedule"))
	data = JSON.parse($.getJSON("/course/#{course_id}"))
	inSection = false
	for section in data['sections']
		if section['_uid'] in currSchedule.keys
			inSection = true
			break
	if inSection
		$('#course-updater').addClass('add')
	else
		$('#course-updater').addClass('remove')
	window.theSchedule = new SectionSchedule($.getJSON("/course/#{course_id}/schedule"), $('#sections-schedule'))
	
	$("body").html('''
<h1><div class=course-code>#{data['department']}#{data['number']}</div><span class=course-name>#{data['title']}</span></h1>
<div class=container>
	<button id='course-updater' onClick="addSection"></button>
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
