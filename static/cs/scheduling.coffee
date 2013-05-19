convertTimeStringToDict = (timeString) ->
  times = timeString.split(';').slice(-1)
  schedule = {}
  for date in times
    for i in [0..6]
      if date[i] != '.'
        (schedule[days[i]] ?= []).push timeRangeToMilitary date.slice(8)
  schedule

timeRangeToMilitary = (ts) ->
  ta = ts.split '-'
  outTime = []

  for time in ta
    hour = time.split(':')[0]
    minute = time.split(':')[1].slice(0, 2)
    m = time.slice(-2, time.length)
    if m == 'AM'
      hour = (parseInt(hour) % 12).toString()
    else
      hour = (parseInt(hour) % 12 + 12).toString()

    if hour.length < 2
      hour = '0' + hour

    outTime.push parseInt(hour) + (parseFloat(minute) / 60)

  outTime

isThereConflict = (currentSchedule, newCourse) ->
  for courseid, course of currentSchedule
    for day, times of course
      for [start, end] in times
        if newCourse[day]
          for [ostart, oend] in newCourse[day]
            if start <= ostart <= end or ostart <= start <= oend
                return yes
  no
