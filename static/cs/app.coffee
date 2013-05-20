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

# courseIsVisible = (courseid) ->
#   $el = getCourseResultEl(courseid)
#   if $el.length
#     return $("#course-list").scrollTop() <= $el.get(0).offsetTop <= $("#course-list").scrollTop() + $("#course-list").height()
#   false


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
    # unless getCourseResultEl(courseid).length
    #   return refreshList courseIds, 'all', courseid

    # else
    #   unless courseIsVisible courseid
    #     $("#course-list").animate (
    #       scrollTop: getCourseResultEl(courseid).offset().top ), 500

    loadCourse courseid

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
  $el = createCourseInfoEl courseInfo
  $("#content").html $el

loadCourse = (courseid) ->
  getFullCourseInfo courseid, (course) ->
    renderCourseInfo course

selectCourse = (courseid, switchToMode) ->
  refreshList currentCourseIds, switchToMode or currentMode, courseid

createCourseEl = (course) ->
  $el = $ courseTemplate course
  courseid = course.id
  do (courseid) ->
    $el.on 'click', ->
      selectCourse courseid

    $el.find(".star-character").on 'click', ->
      if courseid in window.starredCourses
        unstarCourse courseid, =>
          #updateCourseEl courseid
          #updateStarredCountIndicator currentCourseIds
          refresh()
      else
        starCourse courseid, =>
          refresh()
          # updateCourseEl courseid
          # updateStarredCountIndicator currentCourseIds

  $el

updateCourseEl = (id) ->
  getCourseSummary id, (course) ->
    allCourses[id].stars = course.stars
    $("#course-result-#{id}").replaceWith createCourseEl(course)

isSectionInSchedule = (section) ->
  section._uid.toString() in window.scheduledSections

createCourseInfoEl = (courseInfo) ->
  console.log courseInfoTemplate courseInfo

  $el = $ courseInfoTemplate courseInfo

  $el.find(".star-character").on 'click', ->
    courseid = courseInfo._uid
    if courseid in window.starredCourses
      unstarCourse courseid, =>
        refresh()
    else
      starCourse courseid, =>
        refresh()
  $inner = $('<div class="sections"></div>')
  $el.append $inner
  for section, index in courseInfo.sections
    console.log 'section index', index
    $inner.append createSectionInfoEl index, section

  $el

courseInfoTemplate = ({department, number, sections, title, description, _uid}) ->
  code = "#{department}#{number}"
  console.log 'courseinfotempl'
  isStarred = _uid in window.starredCourses
  starredClass = if isStarred then "starred-course-result" else ""

  ret = """
    <div class='course-info'>
      <div class='star-container #{starredClass}'>
        <span class='star-character'>&#9734;</span>
      </div>
      <header>
        <h1>#{code}</h1>
        <h3>#{title}</h3>
      </header>
      <p class='course-info-description'>#{description}</p>
    </div>
  """
#        <span class='star-count'>#{allCourses[_uid].stars}</span>

  ret

createSectionInfoEl = (index, section) ->
  console.log 'sss'
  $el = $ sectionInfoTemplate index, section
  if isSectionInSchedule section
    $el.find('.section-update').addClass("remove-section") # won't work since this needs
    $el.find('.section-update').removeClass("add-section") # to be run before click!
    $el.find('.section-update').on 'click', ->
      removeSection section._uid
  else
    $el.find('.section-update').addClass("add-section") # won't work since this needs
    $el.find('.section-update').removeClass("remove-section") # to be run before click!
    $el.find('.section-update').on 'click', ->
      if not isThereConflict window.theSchedule.courseData, section
        addSection section._uid

  $el.find(".course-transition").click ->
    selectCourse $(@).data('courseid')

  $scheduleEl = $el.find '.section-schedule'

  if isSectionInSchedule section
    new SectionSchedule window.theSchedule.courseData, {}, $scheduleEl

  else
    new SectionSchedule window.theSchedule.courseData, section.times, $scheduleEl

  $el


naturalLanguageJoin = (names) ->
  if names.length == 1 then return names[0]
  if names.length == 2 then return names.join(' and ')
  [fsts..., lst] = [names.slice(0, -1), names.slice(-1)]
  fsts.join(' , ') + " and " + lst

toOrdinal = ['first', 'second', 'third', 'fourth', 'sixth', 'seventh', 'eighth', 'ninth', 'tenth', 'eleventh', 'twelfth', 'thirteenth', 'fourteenth', 'sixteenth', 'seventeenth']

RMPtoNaturalLanguage =
  5: "a once-in-a-lifetime professor"
  4: "a really good professor"
  3: "an above-average professor"
  2: "an average professor"
  1: "a below-average professor"
  0: "not a good professor"

sectionInfoTemplate = (sectionIndex, {_uid, times, instructors, seatsAvailable, enrollmentLimit}) ->
  sectionInSchedule = _uid.toString() in window.scheduledSections
  console.log "SECTION IN SCHEDULE"
  sectionInScheduleClass = if sectionInSchedule then 'session-in-schedule' else ''
  conflict = isThereConflict window.theSchedule.courseData, times
  sectionConflicts = not sectionInSchedule and conflict
  sectionConflictClass = if sectionConflicts then 'session-conflicts' else ''

  formattedInstructors = instructors.map( (x) -> "<b>#{formatName x.name}</b>" )
  formattedInstructorsJoined = naturalLanguageJoin formattedInstructors

  profText = ''
  profArray = []
  for {name, rating}, profIndex in instructors
    if rating != -1
      profArray.push("#{formattedInstructors[profIndex]} (#{RMPtoNaturalLanguage[Math.floor(rating)]}, according to classmates)")
    else
      profArray.push("#{formattedInstructors[profIndex]}")

  profText =  'Taught by ' + ( if instructors.length then naturalLanguageJoin(profArray) else 'staff')

  if sectionInSchedule
    scheduleIndication = "<p class='color-darkblue'>You have already added this section to your schedule.</p>"
  else if sectionConflicts
    scheduleIndication = "<p class='color-red'><b>You cannot add this section to your schedule because you have another class, <a data-courseid='#{conflict}' class='course-transition'>#{allCourses[conflict].title}</a>, scheduled at the same time.</p></p>"

  naturalLanguageText = """
    <button class='section-update #{sectionConflictClass}'></button>
    <h4>Section #{sectionIndex + 1}</h4>
    <div class='courseInfo'>
      #{profText}, meets <b>#{scheduleToString( times )}</b>.
      <p>There are currently <b>#{seatsAvailable}</b> seats available out of a total enrollment limit of <b>#{enrollmentLimit}</b>.</p>
      #{scheduleIndication or ''}
    </div>
  """



  """
  <div class='section' id='section-#{_uid}'>
    <div class='section-schedule #{sectionInScheduleClass}'></div>
    <p class='section-natural-language-text'>
      #{naturalLanguageText}
    </p>
  </div>
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
#      <span class='star-count'>#{stars}</span>
    #<p class='course-result-professor'>#{formatName professor}</p>

formatName = (name = 'STAFF') ->
  return name if name == 'STAFF'
  [last, first] = name.split ','
  "#{first} #{last}"

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
      $.getJSON '/search_by_code', code: term, (results2) ->
        cb (results.concat(results1)).concat(results2)

updateSearchField = (v) ->
  if v.length
    autocomplete v, (courseResults) ->
      #updateCourseResults courseResults
      refreshList courseResults, currentMode
  else
    refreshList allCourseIds, currentMode

$ ->
  $("#course-search").on 'keyup', ->
    updateSearchField @value

  window.theSchedule = new Schedule({}, $('#schedule'))
  getAndUpdateSchedule()

  getStarredCourses()

  fillSubjectList()

  console.log scheduleToString({'Monday': [[14.66, 16.00]], 'Friday': [[14.66, 16.00]]})

  refreshList allCourseIds, 'all', null




