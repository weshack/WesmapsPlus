otherColor = 'rgba(0,0,0,0.05)'
noConflictColor = 'rgb(94, 140, 106)'
conflictColor = "rgb(230, 64, 64)"

class SectionSchedule
  this.earliest = 8
  this.latest = 22

  this.possColors = ['8c2318', '5e8c6a', '88a65e', 'bfb35a','f2c45a']

  constructor: (@currentSchedule, @candidate, @$wrapper, @candidateId) ->
    console.log 'section schedule creation'

    $rel = $('<div class="schedulerel"></div>')
    @days = {}
    @colors = {}
    console.log 'section schedule appendage'

    @$wrapper.append($rel)

    @$wrapper = $rel

    for d in ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
      $newDay = $("<div class=day day-#{d}'><div class='relative'></div></div>")
      @$wrapper.append($newDay)
      dayAbbrev = d.substring(0,3)
      $newDay.append("<div class='dayName'>#{dayAbbrev}</div>")
      @days[d] = $newDay.children('.relative')

    console.log 'bf drawing'

    @draw()

  draw: ->
    for day, $el of @days
      $el.html('')
    courseInSchedule = false
    for course, days of @currentSchedule
      if parseInt(course) == parseInt(@candidateId)
        color = '#' + window.colors[course]
        courseInSchedule = true
      else
        color = otherColor
      for day, times of days
        for t in times
          earliest = Schedule.earliest 
          latest = Schedule.latest
          top = (t[0] - earliest)*100 / (latest - earliest)
          height = (t[1] - t[0])*100 / (latest - earliest)

          $thisMtg = $("<div class='mtg'></div>")

          console.log 'making it ', color

          $thisMtg
            .css('top', top + '%')
            .css('height', height + '%')
            .css('background-color', color)

          @days[day].append($thisMtg)
    console.log 'course in schedule', courseInSchedule
    console.log 'is there conflict? ', (isThereConflict @currentSchedule, @candidate)
    if isThereConflict @currentSchedule, @candidate
      if not courseInSchedule
        console.log 'there is conflict and course in schedule'
        color = ['background-image', 'url(/static/images/stripes.png)']
    else
      color = ['background-color', '#' + window.possColors[window.possColors.length - 1]]
    console.log color

    for day, times of @candidate
      for t in times
        earliest = Schedule.earliest
        latest = Schedule.latest
        top = (t[0] - earliest)*100 / (latest - earliest)
        height = (t[1] - t[0])*100 / (latest - earliest)

        $thisMtg = $("<div class='mtg'></div>")
        $thisMtg
          .css('top', top + '%')
          .css('height', height + '%')
          .css('background-color','transparent')
          .css('background-image','none')
          .css(color[0], color[1])

        @days[day].append($thisMtg)




