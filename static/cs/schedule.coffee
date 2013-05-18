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
	this.latest = 24

	constructor: (courseData, $wrapper) ->
		@courseData = courseData
		@$wrapper = $wrapper
		@days = {}


		for d in ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
			$newDay = $('<div class="day day-' + d + '"><div class="relative"></div></div>')
			@$wrapper.append($newDay)
			@days[d] = $newDay.children('.relative')

		this.draw()

	draw: ->
		for d in @days
			do(sup) ->
				d.html('')

		for course, days of @courseData
			for day, times of days
				for t in times
					earliest = Schedule.earliest
					latest = Schedule.latest
					top = (t[0] - earliest)*100 / (latest - earliest)
					height = (t[1] - t[0])*100 / (latest - earliest)

					$thisMtg = $('<div class="mtg"></div>')

					$thisMtg.css('top', top + '%').css('height', height + '%')

					@days[day].children('.relative').append($thisMtg)





