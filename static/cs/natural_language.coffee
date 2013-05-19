decTimeToString = (t) ->
  hours = Math.floor(t)
  if hours > 12
    hours -= 12
    suffix = 'pm'
  else
    suffix = 'am'
  minutes = Math.round((t - Math.floor(t)) * 60)
  minutes = minutes.toString()
  minutes = "0" + minutes if minutes.length < 2
  "#{hours}:#{minutes}#{suffix}"

decTimesToRangeString = (times) ->
  stringTimes = times.map(decTimeToString)
  "#{stringTimes[0]}-#{stringTimes[1]}"

arrayToNaturalList = (array) ->
  theString = ''
  if array.length == 1
    theString = array[0]
  else
    for i in [0..array.length-1]
      theString += array[i]
      if i < array.length - 3
        theString += ', '
      else
        theString += ' '
      if i == array.length - 2
        theString += 'and '
  theString

scheduleToString = (schedule) ->
  timeRanges = []
  phrase = []
  for day in Schedule.allDays
    if schedule[day] != undefined
      if schedule[day].length < 2
        keepGoing = true
        range = decTimesToRangeString schedule[day][0]
        i = 0

        while keepGoing and i < phrase.length
          if phrase[i]['time'].length < 2 and phrase[i]['time'][0] == range
            phrase[i]['days'].push(day)
            keepGoing = false
          i++

      if keepGoing
        phrase.push {'time': schedule[day].map(decTimesToRangeString), 'days': [day]}

  stringParts = []
  console.log 'phrase is', phrase
  for i in [0..phrase.length-1]
    thisPart = '<b>'
    if phrase[i]['time'].length < 2
      thisPart += phrase[i]['time'][0]
    else
      thisPart += phrase[i]['time'].join ' and '
    thisPart += '</b> on <b>'
    console.log 'all the days are ' + phrase[i]['days']
    thisPart += arrayToNaturalList phrase[i]['days']
    thisPart = thisPart.trim ' '
    thisPart += '</b>'
    stringParts.push thisPart

  arrayToNaturalList stringParts
