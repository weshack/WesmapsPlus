conflictDetected = ->
  notify "The course you're trying to add conflicts with your schedule.", true, 3000

updateSchedule = (schedule) ->
  console.log 'new schedule', schedule
  window.theSchedule.courseData = schedule
  window.theSchedule.draw()
  refresh()

getAndUpdateSchedule = (schedule) ->
  getAllSections (sections) ->
    console.log 'new window.scheduledSections', sections
    window.scheduledSections = sections
    $.getJSON '/schedule', (schedule) ->
      updateSchedule schedule

addSection = (section) ->
  $.ajax
    type: 'POST'
    url: "/schedule/#{section}"
    data: {section}
    dataType: 'json'
    success: (newSections) ->
      window.scheduledSections = newSections
      getAndUpdateSchedule()
    error: ->
      conflictDetected()

removeSection = (section) ->
  $.ajax
    type: 'DELETE'
    url: "/schedule/#{section}"
    data: {section}
    dataType: 'json'
    success: (newSections) ->
      window.scheduledSections = newSections
      getAndUpdateSchedule()

getSchedule = ->
  $.getJSON '/schedule', (schedule) ->
    console.log JSON.stringify schedule

getAllSections = (cb) ->
  $.getJSON '/debug/sections', (sections) ->
      cb sections

starCourse = (courseid, cb) ->
  $.ajax
    type: 'POST'
    url: "/star/#{courseid}"
    dataType: 'json'
    success: ->
      getStarredCourses ->
        cb?()

unstarCourse = (courseid, cb) ->
  $.ajax
    type: 'DELETE'
    url: "/star/#{courseid}"
    dataType: 'json'
    success: (newStarred) ->
      getStarredCourses ->
        cb?()

getStarredCourses = (cb) ->
  $.getJSON '/starred', (starred) ->
    window.starredCourses = starred.map (c) -> parseInt c
    cb? starred

filterForSubject = (courseIds, subj) ->
  resultsByDept = buildCourseResults courseIds
  resultsByDept[subj] or []

filterForStarred = (courseIds) ->
  ret = []
  for courseid in courseIds
    if courseid in window.starredCourses
      ret.push allCourses[courseid]
  ret

filterForScheduled = (courseIds) ->
  ret = []
  for scheduled in window.scheduledSections
    idx = courseIds.indexOf allSections[scheduled]
    if idx != -1
      ret.push allCourses[courseIds[idx]]
  ret
