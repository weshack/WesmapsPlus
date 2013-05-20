class Schedule

  this.earliest = 8
  this.latest = 22

  window.possColors = ['8c2318', '5e8c6a', '88a65e', 'bfb35a','f2c45a', '69D2E7', 'E0E4CC', 'F38630', '490A3D', 'BD1550']
  window.colorIndex = possColors.length - 1
  this.allDays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

  constructor: (courseData, $wrapper) ->
    @courseData = courseData
    $rel = $('<div class="schedulerel"></div>')
    @$wrapper = $wrapper
    @days = {}
    window.colors = {}

    @$wrapper.append($rel)

    @$wrapper = $rel

    for d in Schedule.allDays
      $newDay = $("<div class=day day-#{d}'><div class='relative'></div></div>")
      @$wrapper.append($newDay)
      dayAbbrev = d.substring(0,3)
      $newDay.append("<div class='dayName'>#{dayAbbrev}</div>")
      @days[d] = $newDay.children('.relative')

    this.draw()

  highlightCourse: (course) =>
    {title} = allCourses[allSections[course]]
    $('.mtg').addClass('fade')
    $('.mtg-' + course).removeClass('fade')
    #@popup = @displayPopup title, x, y
    notify title

  lowlightCourses: =>
    $('.mtg').removeClass('fade')
    notify ""
    #@popup.remove()
    #delete @popup

  draw: ->
    for day, $el of @days
      $el.html('')

    for course, days of @courseData

      console.log 'checking', course

      if window.colors[course]
        thisColor = window.colors[course]
        console.log 'using existingi color', thisColor, 'for', course
      else
        window.colors[course] = thisColor = window.possColors.pop()

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

          courseid = allSections[course]
          do (courseid) ->
            $thisMtg.click ->
              $("#subject-list").get(0).scrollTop = 0
              selectCourse courseid, 'scheduled'

          @days[day].append($thisMtg)
