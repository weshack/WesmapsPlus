make = (args..., options) ->
  e = document.createElement (args[0] or options?.tag or 'div')
  for k,v of options
    if k != 'tag'
      e[k] = v
  e

subjectCodes = {"ARAB":"Arabic","ARHA":"Art History","ARST":"Art Studio","ALIT":"Asian Languages and Literature","CHIN":"Chinese","CCIV":"Classical Civilization","COL":"College of Letters","DANC":"Dance","ENGL":"English","FILM":"Film Studies","FREN":"French","FRST":"French Studies","FIST":"French, Italian, Spanish in Translation","GELT":"German Literature in English","GRST":"German Studies","GRK":"Greek","HEBR":"Hebrew","HEST":"Hebrew Studies","IBST":"Iberian Studies","ITAL":"Italian Studies","JAPN":"Japanese Studies","KREA":"Korean Studies","LAT":"Latin Studies","LANG":"Less Commonly Taught Languages","MUSC":"Music","PORT":"Portugese","RUSS":"Russian","RULE":"Russian Literature in English","SPAN":"Spanish","THEA":"Theater","AMST":"American Studies","ANTH":"Anthropology","CSS":"College of Social Studies","ECON":"Economics","GOVT":"Government","HIST":"History","PHIL":"Philosophy","RELI":"Religion","SOC":"Sociology","CEC":"Civic Engagement","CES":"Environmental Studies","CIM":"Informatics and Modeling","CIR":"International Relations","CJS":"Jewish and Israel Studies","CMES":"Middle Eastern Studies","CMB":"Molecular Biophysics","CSCT":"Social, Cultural, and Critical Theory","CSA":"South Asian Studies","CSED":"The Study of Education","CWRC":"Writing","ASTR":"Astronomy","BIOL":"Biology","CHEM":"Chemistry","COMP":"Computer Science","EES":"Earth and Environmental Sciences","MATH":"Mathematics","MBB":"Molecular Biology and Biochemistry","NSB":"Neuroscience and Behavior","PHYS":"Physics","PSYC":"Psychology","XAFS":"African Studies","XCHS":"Christianity Studies","XDST":"Disability Studies","XPSC":"Planetary Science","XSER":"Service-Learning","XURS":"Urban Studies","AFAM":"African American Studies","ARCP":"Archaeology","CHUM":"Center for the Humanities","CSPL":"Center for the Study of Public Life","EAST":"East Asian Studies","ENVS":"Environmental Studies","FGSS":"Feminist, Gender, and Sexuality Studies","LAST":"Latin American Studies","MECO":"Mathematics-Economics","MDST":"Medieval Studies","QAC":"Quantitative Analysis Center","REES":"Russian, East European, and Eurasian Studies","SISP":"Science in Society","WRCT":"Writing Center","COE":"College of the Environment","CPLS":"Graduate Planetary Science Concentration","PHED":"Physical Education","FORM":"Student Forums","WLIT":"World Literature Courses"}

subjectCodes2 = {"ARAB":"Arabic","ARHA":"Art History","ARST":"Art Studio","ALIT":"Asian Languages and Literature","CHIN":"Chinese","CCIV":"Classical Civilization","COL":"College of Letters","DANC":"Dance","ENGL":"English","FILM":"Film Studies","FREN":"French","FRST":"French Studies","FIST":"French, Italian, Spanish in Translation","GELT":"German Literature in English","GRST":"German Studies","GRK":"Greek","HEBR":"Hebrew","HEST":"Hebrew Studies","IBST":"Iberian Studies","ITAL":"Italian Studies","JAPN":"Japanese Studies","KREA":"Korean Studies","LAT":"Latin Studies","LANG":"Less Commonly Taught Languages","MUSC":"Music","PORT":"Portugese","RUSS":"Russian","RULE":"Russian Literature in English","SPAN":"Spanish","THEA":"Theater","AMST":"American Studies","ANTH":"Anthropology","CSS":"College of Social Studies","ECON":"Economics","GOVT":"Government","HIST":"History","PHIL":"Philosophy","RELI":"Religion","SOC":"Sociology","CEC":"Civic Engagement","CES":"Environmental Studies","CIM":"Informatics and Modeling","CIR":"International Relations","CJS":"Jewish and Israel Studies","CMES":"Middle Eastern Studies","CMB":"Molecular Biophysics","CSCT":"Social, Cultural, and Critical Theory","CSA":"South Asian Studies","CSED":"The Study of Education","CWRC":"Writing","ASTR":"Astronomy","BIOL":"Biology","CHEM":"Chemistry","COMP":"Computer Science","EES":"Earth and Environmental Sciences","MATH":"Mathematics","MBB":"Molecular Biology and Biochemistry","NSB":"Neuroscience and Behavior","PHYS":"Physics","PSYC":"Psychology","XAFS":"African Studies","XCHS":"Christianity Studies","XDST":"Disability Studies","XPSC":"Planetary Science","XSER":"Service-Learning","XURS":"Urban Studies","AFAM":"African American Studies Program","ARCP":"Archaeology Program","CHUM":"Center for the Humanities","CSPL":"Center for the Study of Public Life","EAST":"East Asian Studies Program","ENVS":"Environmental Studies Program","FGSS":"Feminist, Gender, and Sexuality Studies Program","LAST":"Latin American Studies Program","MECO":"Mathematics-Economics Program","MDST":"Medieval Studies Program","QAC":"Quantitative Analysis Center","REES":"Russian, East European, and Eurasian Studies Program","SISP":"Science in Society Program","WRCT":"Writing Center","COE":"College of the Environment","CPLS":"Graduate Planetary Science Concentration","PHED":"Physical Education","FORM":"Student Forums","WLIT":"World Literature Courses"}

currentCourses = null
currentMode = null

subjectCodesReverse = {}

for key, value of subjectCodes
  subjectCodesReverse[value] = key

window.Router = Backbone.Router.extend
  routes:
    '/': 'index'
    '/course/:id': 'course'

  index: ->


  course: (id) ->

showCourses = (courses) ->
  $clist = $("#course-list ul")
  $clist.html ""
  for course in courses
    $clist.append courseTemplate course

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

fixCategoriesBasedOn = (courses) ->
  $(".subject-category").hide()
  $(".count-indicator").remove()

  getListItemForMode('all').append "<span class='count-indicator'>#{courses.length}</span>"

  starred = filterForStarred courses
  getListItemForMode('starred').append "<span class='count-indicator'>#{starred.length}</span>"

  scheduled = filterForScheduled courses
  getListItemForMode('scheduled').append "<span class='count-indicator'>#{scheduled.length}</span>"

  resultsByDept = buildCourseResults courses
  for code, results of resultsByDept
    $el = $("li[data-code='#{code}']")
    $el.show()
    $el.append "<span class='count-indicator'>#{results.length}</span>"

refreshList = (courses, mode) ->
  currentCourses = courses
  currentMode = mode

  fixCategoriesBasedOn courses

  $(".category").removeClass 'selected-category'
  getListItemForMode(mode).addClass 'selected-category'

  switch mode
    when "all"
      showCourses courses

    when "starred"
      relevant = filterForStarred courses
      showCourses relevant

    when "scheduled"
      relevant = filterForScheduled courses
      showCourses relevant

    else
      relevant = filterForSubject currentCourses, mode
      showCourses relevant

buildCourseResults = (results) ->
  resultsByDepartment = {}

  for result in results
    (resultsByDepartment[result.departmentCode] ?= []).push result

  resultsByDepartment

courseTemplate = ({id, code, title, professor, departmentCode}) ->
  starredClass = if id in starredCourses then "starred-course-result" else ""
  """
  <li class='course-result dept-#{departmentCode} #{starredClass}'>
    <p class='course-result-code'>#{code}</p>
    <p class='course-result-name'>#{title}</p>

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
    console.log categoryName, categoryTitle
    categoryEl = $("<li class='category special-category' id='category-#{categoryName}'>#{categoryTitle}</li>")
    do (categoryName, categoryTitle) ->
      categoryEl.on 'click', =>
        refreshList currentCourses, categoryName
    $subjectList.append categoryEl

  $subjectList.append "<li class='category-separator'></li>"

  for code in _.keys(subjectCodes).sort()
    subj = subjectCodes[code]
    subjectEl = $("<li class='category subject-category' data-code='#{code}'>#{subj}</li>")
    do (code, subj) ->
      subjectEl.on 'click', =>
        refreshList currentCourses, code
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
  $.getJSON '/search_by_title', name: term, (results) ->
    cb results

$ ->
  $("#course-search").on 'keyup', ->
    if @value.length
      autocomplete @value, (courseResults) ->
        #updateCourseResults courseResults
        refreshList courseResults, currentMode
    else
      refreshList _.values(allCourses), currentMode

  window.theSchedule = new Schedule({}, $('#schedule'))
  getAndUpdateSchedule()

  getStarredCourses()

  fillSubjectList()

  refreshList _.values(allCourses), 'all'


