conflictDetected = ->
  notify "The course you're trying to add conflicts with your schedule.", true, 3000

updateSchedule = (schedule) ->
  console.log 'new schedule', schedule
  window.theSchedule.updateCourseData(schedule)

getAndUpdateSchedule = (schedule) ->
  $.getJSON '/schedule', (schedule) ->
    updateSchedule schedule

addSection = (section) ->
  $.ajax
    type: 'POST'
    url: "/schedule/#{section}"
    data: {section}
    dataType: 'json'
    success: (newSections) ->
      scheduledSections = newSections
      getAndUpdateSchedule()
    error: ->
      conflictDetected()

removeSection = (section) ->
  $.ajax
    type: 'DELETE'
    url: "/schedule/#{section}"
    data: {section}
    dataType: 'json'
    success: ->
      getAndUpdateSchedule()

getSchedule = ->
  $.getJSON '/schedule', (schedule) ->
    console.log JSON.stringify schedule

getAllSections = ->
  $.getJSON '/debug/sections', (sections) ->
      console.log sections

starCourse = (courseid) ->
  $.ajax
    type: 'POST'
    url: "/star/#{courseid}"
    dataType: 'json'
    success: (newStarred) ->
      starredCourses = newStarred.map (c) -> parseInt c

unstarCourse = (courseid) ->
  $.ajax
    type: 'DELETE'
    url: "/star/#{courseid}"
    dataType: 'json'
    success: (newStarred) ->
      starredCourses = newStarred.map (c) -> parseInt c

getStarredCourses = ->
  $.getJSON '/starred', (starred) ->
    starredCourses = starred.map (c) -> parseInt c

filterForSubject = (courses, subj) ->
  resultsByDept = buildCourseResults courses
  resultsByDept[subj] or []

filterForStarred = (courses) ->
  ret = []
  for course in courses
    if course.id in starredCourses
      ret.push course
  ret

filterForScheduled = (courses) ->
  courseids = courses.map ({id}) -> id
  ret = []
  for scheduled in scheduledSections
    idx = courseids.indexOf allSections[scheduled]
    if idx != -1
      ret.push courses[idx]
  ret
