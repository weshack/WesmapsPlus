conflictDetected = ->
  console.log 'conflict detected!'

updateSchedule = (schedule) ->
  console.log 'new schedule', schedule
  window.theSchedule.courseData = schedule
  window.theSchedule.draw()

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
      scheduledSections = newSections
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
      starredCourses = newStarred

unstarCourse = (courseid) ->
  $.ajax
    type: 'DELETE'
    url: "/star/#{courseid}"
    dataType: 'json'
    success: (newStarred) ->
      starredCourses = newStarred

getStarredCourses = ->
  $.getJSON '/starred', (starred) ->
    starredCourses = starred

filterForSubject = (courses, subj) ->
  resultsByDept = buildCourseResults results
  resultsByDept[subj] or []

filterForStarred = (courses) ->
  ret = []
  for course in courses
    if course.id.toString() in starredCourses
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
