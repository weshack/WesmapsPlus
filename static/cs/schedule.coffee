class Schedule

	this.earliest = 8
	this.latest = 22

	this.possColors = ['8c2318', '5e8c6a', '88a65e', 'bfb35a','f2c45a']

	constructor: (courseData, $wrapper) ->
		@courseData = courseData
		$rel = $('<div class="schedulerel"></div>')
		@$wrapper = $wrapper
		@days = {}
		@colors = {}

		@$wrapper.append($rel)

		@$wrapper = $rel


		for d in ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
			$newDay = $("<div class=day day-#{d}'><div class='relative'></div></div>")
			@$wrapper.append($newDay)
			dayAbbrev = d.substring(0,3)
			$newDay.append("<div class='dayName'>#{dayAbbrev}</div>")
			@days[d] = $newDay.children('.relative')

		this.draw()

	highlightCourse: (course, x, y) =>
    {title} = allCourses[allSections[course]]
    $('.mtg').addClass('fade')
    $('.mtg-' + course).removeClass('fade')
    #@popup = @displayPopup title, x, y
    notify title

  # displayPopup: (title, x, y) ->
  #   @popup = $ "<p class='popup'>#{title}</p>"
  #   @popup.css left: x, top: y
  #   $("#wrapper").append @popup
  #   @popup

	lowlightCourses: =>
    $('.mtg').removeClass('fade')
    notify ""
    #@popup.remove()
    #delete @popup

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

					$thisMtg = $("<div class='mtg mtg-#{course}'></div>")

					$thisMtg
						.css('top', top + '%')
						.css('height', height + '%')
						.css('background-color', '#' + thisColor)
						.data('course', course)


					thisSchedule = this
					$thisMtg.hover( (evt) ->
						thisSchedule.highlightCourse($(this).data('course'), evt.pageX, evt.pageY)
					,() ->
						thisSchedule.lowlightCourses()
					)

					@days[day].append($thisMtg)
