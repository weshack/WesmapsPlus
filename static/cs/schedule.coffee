window.theData = {
	'COMP112-02': {
		'Tuesday': [[9, 10.33]],
		'Thursday': [[9, 10.33]]
	},
	'COMP212-02': {
		'Monday': [[14.66, 16]],
		'Friday': [[14.66, 16]]
	},
}

class Schedule

	this.earliest = 8
	this.latest = 22

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







