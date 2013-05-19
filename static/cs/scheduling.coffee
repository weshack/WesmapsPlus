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

noConflict = (currentSchedule, newCourse) ->
  for courseid in currentSchedule
    currentCourse = currentSchedule[courseid]
    for day in days
      if day in currentCourse
        for courseTime in currentCourse[day]
          [startTime, endTime] = courseTime
          if day in newCourse
            for time in newCourse[day]
              if startTime <= time[0] <= endTime or time[0] <= startTime <= time[1]
                return false
  true


