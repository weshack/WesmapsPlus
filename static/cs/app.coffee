make = (args..., options) ->
  e = document.createElement (args[0] or options?.tag or 'div')
  for k,v of options
    if k != 'tag'
      e[k] = v
  e

subjectCodes = {"ARAB":"Arabic","ARHA":"Art History","ARST":"Art Studio","ALIT":"Asian Languages and Literature","CHIN":"Chinese","CCIV":"Classical Civilization","COL":"College of Letters","DANC":"Dance","ENGL":"English","FILM":"Film Studies","FREN":"French","FRST":"French Studies","FIST":"French, Italian, Spanish in Translation","GELT":"German Literature in English","GRST":"German Studies","GRK":"Greek","HEBR":"Hebrew","HEST":"Hebrew Studies","IBST":"Iberian Studies","ITAL":"Italian Studies","JAPN":"Japanese Studies","KREA":"Korean Studies","LAT":"Latin Studies","LANG":"Less Commonly Taught Languages","MUSC":"Music","PORT":"Portugese","RUSS":"Russian","RULE":"Russian Literature in English","SPAN":"Spanish","THEA":"Theater","AMST":"American Studies","ANTH":"Anthropology","CSS":"College of Social Studies","ECON":"Economics","GOVT":"Government","HIST":"History","PHIL":"Philosophy","RELI":"Religion","SOC":"Sociology","CEC":"Civic Engagement","CES":"Environmental Studies","CIM":"Informatics and Modeling","CIR":"International Relations","CJS":"Jewish and Israel Studies","CMES":"Middle Eastern Studies","CMB":"Molecular Biophysics","CSCT":"Social, Cultural, and Critical Theory","CSA":"South Asian Studies","CSED":"The Study of Education","CWRC":"Writing","ASTR":"Astronomy","BIOL":"Biology","CHEM":"Chemistry","COMP":"Computer Science","EES":"Earth and Environmental Sciences","MATH":"Mathematics","MBB":"Molecular Biology and Biochemistry","NSB":"Neuroscience and Behavior","PHYS":"Physics","PSYC":"Psychology","XAFS":"African Studies","XCHS":"Christianity Studies","XDST":"Disability Studies","XPSC":"Planetary Science","XSER":"Service-Learning","XURS":"Urban Studies","AFAM":"African American Studies","ARCP":"Archaeology","CHUM":"Center for the Humanities","CSPL":"Center for the Study of Public Life","EAST":"East Asian Studies","ENVS":"Environmental Studies","FGSS":"Feminist, Gender, and Sexuality Studies","LAST":"Latin American Studies","MECO":"Mathematics-Economics","MDST":"Medieval Studies","QAC":"Quantitative Analysis Center","REES":"Russian, East European, and Eurasian Studies","SISP":"Science in Society","WRCT":"Writing Center","COE":"College of the Environment","CPLS":"Graduate Planetary Science Concentration","PHED":"Physical Education","FORM":"Student Forums","WLIT":"World Literature Courses"}

subjectCodes2 = {"ARAB":"Arabic","ARHA":"Art History","ARST":"Art Studio","ALIT":"Asian Languages and Literature","CHIN":"Chinese","CCIV":"Classical Civilization","COL":"College of Letters","DANC":"Dance","ENGL":"English","FILM":"Film Studies","FREN":"French","FRST":"French Studies","FIST":"French, Italian, Spanish in Translation","GELT":"German Literature in English","GRST":"German Studies","GRK":"Greek","HEBR":"Hebrew","HEST":"Hebrew Studies","IBST":"Iberian Studies","ITAL":"Italian Studies","JAPN":"Japanese Studies","KREA":"Korean Studies","LAT":"Latin Studies","LANG":"Less Commonly Taught Languages","MUSC":"Music","PORT":"Portugese","RUSS":"Russian","RULE":"Russian Literature in English","SPAN":"Spanish","THEA":"Theater","AMST":"American Studies","ANTH":"Anthropology","CSS":"College of Social Studies","ECON":"Economics","GOVT":"Government","HIST":"History","PHIL":"Philosophy","RELI":"Religion","SOC":"Sociology","CEC":"Civic Engagement","CES":"Environmental Studies","CIM":"Informatics and Modeling","CIR":"International Relations","CJS":"Jewish and Israel Studies","CMES":"Middle Eastern Studies","CMB":"Molecular Biophysics","CSCT":"Social, Cultural, and Critical Theory","CSA":"South Asian Studies","CSED":"The Study of Education","CWRC":"Writing","ASTR":"Astronomy","BIOL":"Biology","CHEM":"Chemistry","COMP":"Computer Science","EES":"Earth and Environmental Sciences","MATH":"Mathematics","MBB":"Molecular Biology and Biochemistry","NSB":"Neuroscience and Behavior","PHYS":"Physics","PSYC":"Psychology","XAFS":"African Studies","XCHS":"Christianity Studies","XDST":"Disability Studies","XPSC":"Planetary Science","XSER":"Service-Learning","XURS":"Urban Studies","AFAM":"African American Studies Program","ARCP":"Archaeology Program","CHUM":"Center for the Humanities","CSPL":"Center for the Study of Public Life","EAST":"East Asian Studies Program","ENVS":"Environmental Studies Program","FGSS":"Feminist, Gender, and Sexuality Studies Program","LAST":"Latin American Studies Program","MECO":"Mathematics-Economics Program","MDST":"Medieval Studies Program","QAC":"Quantitative Analysis Center","REES":"Russian, East European, and Eurasian Studies Program","SISP":"Science in Society Program","WRCT":"Writing Center","COE":"College of the Environment","CPLS":"Graduate Planetary Science Concentration","PHED":"Physical Education","FORM":"Student Forums","WLIT":"World Literature Courses"}

currentCourseIds = null
currentMode = null
currentCourseId = null

relevantSubjects = {}

allCourseIds = _.values(allCourses).map (course) -> course.id

subjectCodesReverse = {}

for key, value of subjectCodes
  subjectCodesReverse[value] = key

showCourses = (courses) ->
  $clist = $("#course-list ul")
  $clist.html ""
  for course in courses
    $clist.append createCourseEl course

getListItemForMode = (mode) ->
  switch mode
    when "all"
      $("#category-all")

    when "starred"
      $("#category-starred")

    when "scheduled"
      $("#category-scheduled")

    else
      $("li[data-code='#{mode}']")

updateStarredCountIndicator = (courses) ->
  $("#category-starred .count-indicator").remove()
  starred = filterForStarred courses
  getListItemForMode('starred').append "<span class='count-indicator'>#{starred.length}</span>"

fixCategoriesBasedOn = (courses) ->
  relevantSubjects = {}

  $(".subject-category").hide()
  $(".count-indicator").remove()

  getListItemForMode('all').append "<span class='count-indicator'>#{courses.length}</span>"

  updateStarredCountIndicator courses

  scheduled = filterForScheduled courses
  getListItemForMode('scheduled').append "<span class='count-indicator'>#{scheduled.length}</span>"

  console.log 'buildCourseResults', courses
  resultsByDept = buildCourseResults courses

  for code, results of resultsByDept
    relevantSubjects[code] = true
    $el = $("li[data-code='#{code}']")
    $el.show()
    $el.append "<span class='count-indicator'>#{results.length}</span>"

refresh = ->
  refreshList currentCourseIds, currentMode, currentCourseId, true

getCourseResultEl = (id) ->
  $("#course-result-#{id}")

refreshList = (courseIds, mode, courseid, force = false) ->
  if (courseid? and currentCourseId != courseid) or force
    $(".course-result").removeClass 'selected-course-result'
    getCourseResultEl(courseid).addClass 'selected-course-result'

  if (courseIds != currentCourseIds or mode != currentMode) or force
    console.log 'refreshing list'
    fixCategoriesBasedOn courseIds

    if (!relevantSubjects[mode]) and !(mode in ['all', 'starred', 'scheduled'])
      console.log 'FIX'
      return refreshList courseIds, 'all', courseid

    $(".category").removeClass 'selected-category'
    getListItemForMode(mode).addClass 'selected-category'

    switch mode
      when "all"
        showCourses courseIds.map (id) -> allCourses[id]

      when "starred"
        relevant = filterForStarred courseIds
        showCourses relevant

      when "scheduled"
        relevant = filterForScheduled courseIds
        showCourses relevant

      else
        relevant = filterForSubject currentCourseIds, mode
        showCourses relevant

  if (courseid? and currentCourseId != courseid) or force
    $(".course-result").removeClass 'selected-course-result'
    getCourseResultEl(courseid).addClass 'selected-course-result'

  currentCourseIds = courseIds
  currentMode = mode
  currentCourseId = courseid

buildCourseResults = (courseIds) ->
  resultsByDepartment = {}

  for courseid in courseIds
    course = allCourses[courseid]
    (resultsByDepartment[course.departmentCode] ?= []).push course

  resultsByDepartment

getCourseSummary = (id, cb) ->
  $.getJSON "/course/#{id}/summary", (result) ->
    cb result

getFullCourseInfo = (id, cb) ->
  $.getJSON "/course/#{id}", (result) ->
    cb result

renderCourseInfo = (courseInfo) ->
  console.log courseInfo

selectCourse = (courseid, switchToMode) ->
  refreshList currentCourseIds, switchToMode or currentMode, courseid
  getFullCourseInfo courseid, (course) ->
    renderCourseInfo course

createCourseEl = (course) ->
  $el = $ courseTemplate course
  courseid = course.id
  do (courseid) ->
    $el.on 'click', ->
      selectCourse courseid

    $el.find(".star-character").on 'click', ->
      if courseid in window.starredCourses
        unstarCourse courseid, =>
          updateCourseEl courseid
          updateStarredCountIndicator currentCourseIds
      else
        starCourse courseid, =>
          updateCourseEl courseid
          updateStarredCountIndicator currentCourseIds

  $el

updateCourseEl = (id) ->
  getCourseSummary id, (course) ->
    allCourses[id].stars = course.stars
    $("#course-result-#{id}").replaceWith createCourseEl(course)

courseInfoTemplate = ({department, number, sections}) ->
  code = "#{department}#{number}"


  ret = """


  """

  for section in sections
    ret += sectionInfoTemplate section

  ret

sectionInfoTemplate = ({times}) ->
  """



  """

days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]



courseTemplate = ({id, code, title, instructors, departmentCode, stars}) ->
  isStarred = id in window.starredCourses
  starredClass = if isStarred then "starred-course-result" else ""
  # starredImageSrc = if isStarred then "/static/images/course_starred.png" else "/static/images/course_unstarred.png"
  # starImage = "<img src='#{starredImageSrc}'></img>"

  formattedInstructors = _.uniq (instructors or []).map( (inst) -> formatName inst.name)
  formattedInstructors = formattedInstructors.join ', '

  """
  <li class='course-result dept-#{departmentCode} #{starredClass}' id='course-result-#{id}'>
    <div class='star-container'>
      <span class='star-character'>&#9734;</span>
      <span class='star-count'>#{stars}</span>
    </div>
    <div class='course-result-main'>
      <p class='course-result-code'>#{code}</p>
      <p class='course-result-name'>#{title}</p>
      <p class='course-result-instructors'>#{formattedInstructors}</p>
    </div>

  </li>
  """
  # """
  # <li class='course-result dept-#{departmentCode} #{starredClass}'>
  #   <a href='/course?id=#{id}'><p class='course-result-code'>#{code}</p>
  #   <p class='course-result-name'>#{title}</p></a>

  # </li>
  # """
    #<p class='course-result-professor'>#{formatName professor}</p>

formatName = (name = 'STAFF') ->
  return name if name == 'STAFF'
  [last, first] = name.split ','
  "#{first} #{last}"

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
    thisPart = ''
    if phrase[i]['time'].length < 2
      thisPart += phrase[i]['time'][0]
    else
      thisPart += phrase[i]['time'].join ' and '
    thisPart += ' on '
    console.log 'all the days are ' + phrase[i]['days']
    thisPart += arrayToNaturalList phrase[i]['days']
    stringParts.push thisPart

  arrayToNaturalList stringParts

notify = (msg, error = false, duration) ->
  if error
    $("#notification").html "<span class='color-red'>#{msg}</span>"
  else
    $("#notification").html msg

  if duration
    setTimeout ( -> notify ""), duration

# createCourseListItem = (courseid) ->
#   if typeof courseid == 'string'
#     courseid = parseInt courseid

#   courses[courseid]

additionalCategories =
  all: 'All'
  starred: 'Starred'
  scheduled: 'In your schedule'

fillSubjectList = ->
  $subjectList = $('#subject-list ul')

  for categoryName, categoryTitle of additionalCategories
    if categoryName == 'scheduled'
      additionalImage = "<img src='/static/images/calendar.png' width='20px' height='20px'></img>"
    else if categoryName == 'starred'
      additionalImage = "<img src='/static/images/star_category.png' width='20px' height='20px'></img>"
    else
      additionalImage = ''
    categoryEl = $("<li class='category special-category' id='category-#{categoryName}'>#{additionalImage}<span class='category-title'>#{categoryTitle}</span></li>")
    do (categoryName, categoryTitle) ->
      categoryEl.on 'click', =>
        refreshList currentCourseIds, categoryName
    $subjectList.append categoryEl

  $subjectList.append "<li class='category-separator'></li>"

  for code in _.keys(subjectCodes).sort()
    subj = subjectCodes[code]
    subjectEl = $("<li class='category subject-category' data-code='#{code}'>#{subj}</li>")
    do (code, subj) ->
      subjectEl.on 'click', =>
        refreshList currentCourseIds, code
    $subjectList.append subjectEl

updateCourseResults = (results) ->


  # $courseList = $("#course-list ul")
  # $courseList.html ''

  # resultsByDept = buildCourseResults results

  # for dept, results of resultsByDept
  #   departmentName = subjectCodes[dept]

  #   for result in results
  #     $courseList.append courseTemplate result


autocomplete = (term, cb) ->
  $.getJSON '/search_by_professor', prof: term, (results1) ->
    $.getJSON '/search_by_title', name: term, (results) ->
      cb results1.concat(results)

$ ->
  $("#course-search").on 'keyup', ->
    if @value.length
      autocomplete @value, (courseResults) ->
        #updateCourseResults courseResults
        refreshList courseResults, currentMode
    else
      refreshList allCourseIds, currentMode

  window.theSchedule = new Schedule({}, $('#schedule'))
  getAndUpdateSchedule()

  getStarredCourses()

  fillSubjectList()

  console.log scheduleToString({'Monday': [[14.66, 16.00]], 'Friday': [[14.66, 16.00]]})

  refreshList allCourseIds, 'all', null


