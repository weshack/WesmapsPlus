otherColor = "rgb(102, 102, 102)"
noConflictColor = 'rgb(94, 140, 106)'
conflictColor = "rgb(230, 64, 64)"

class SectionSchedule
  this.earliest = 8
  this.latest = 22

  this.possColors = ['8c2318', '5e8c6a', '88a65e', 'bfb35a','f2c45a']

  constructor: (@currentSchedule, @candidate, @$wrapper) ->
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

    for course, days of @currentSchedule
      for day, times of days
        for t in times
          earliest = Schedule.earliest
          latest = Schedule.latest
          top = (t[0] - earliest)*100 / (latest - earliest)
          height = (t[1] - t[0])*100 / (latest - earliest)

          $thisMtg = $("<div class='mtg'></div>")

          console.log 'making it ', otherColor

          $thisMtg
            .css('top', top + '%')
            .css('height', height + '%')
            .css('border-color', otherColor)
            .css('background-color', 'rgba(0,0,0,0.05)')

          @days[day].append($thisMtg)

    if isThereConflict @currentSchedule, @candidate
      color = conflictColor
    else
      color = noConflictColor

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
          .css('background-color', color)

        @days[day].append($thisMtg)




