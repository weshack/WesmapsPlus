make = (args..., options) ->
  e = document.createElement (args[0] or options?.tag or 'div')
  for k,v of options
    if k != 'tag'
      e[k] = v
  e

subjectCodes = {"ARAB":"Arabic","ARHA":"Art History","ARST":"Art Studio","ALIT":"Asian Languages and Literature","CHIN":"Chinese","CCIV":"Classical Civilization","COL":"College of Letters","DANC":"Dance","ENGL":"English","FILM":"Film Studies","FREN":"French","FRST":"French Studies","FIST":"French, Italian, Spanish in Translation","GELT":"German Literature in English","GRST":"German Studies","GRK":"Greek","HEBR":"Hebrew","HEST":"Hebrew Studies","IBST":"Iberian Studies","ITAL":"Italian Studies","JAPN":"Japanese Studies","KREA":"Korean Studies","LAT":"Latin Studies","LANG":"Less Commonly Taught Languages","MUSC":"Music","PORT":"Portugese","RUSS":"Russian","RULE":"Russian Literature in English","SPAN":"Spanish","THEA":"Theater","AMST":"American Studies","ANTH":"Anthropology","CSS":"College of Social Studies","ECON":"Economics","GOVT":"Government","HIST":"History","PHIL":"Philosophy","RELI":"Religion","SOC":"Sociology","CEC":"Civic Engagement","CES":"Environmental Studies","CIM":"Informatics and Modeling","CIR":"International Relations","CJS":"Jewish and Israel Studies","CMES":"Middle Eastern Studies","CMB":"Molecular Biophysics","CSCT":"Social, Cultural, and Critical Theory","CSA":"South Asian Studies","CSED":"The Study of Education","CWRC":"Writing","ASTR":"Astronomy","BIOL":"Biology","CHEM":"Chemistry","COMP":"Computer Science","EES":"Earth and Environmental Sciences","MATH":"Mathematics","MBB":"Molecular Biology and Biochemistry","NSB":"Neuroscience and Behavior","PHYS":"Physics","PSYC":"Psychology","XAFS":"African Studies","XCHS":"Christianity Studies","XDST":"Disability Studies","XPSC":"Planetary Science","XSER":"Service-Learning","XURS":"Urban Studies","AFAM":"African American Studies Program","ARCP":"Archaeology Program","CHUM":"Center for the Humanities","CSPL":"Center for the Study of Public Life","EAST":"East Asian Studies Program","ENVS":"Environmental Studies Program","FGSS":"Feminist, Gender, and Sexuality Studies Program","LAST":"Latin American Studies Program","MECO":"Mathematics-Economics Program","MDST":"Medieval Studies Program","QAC":"Quantitative Analysis Center","REES":"Russian, East European, and Eurasian Studies Program","SISP":"Science in Society Program","WRCT":"Writing Center","COE":"College of the Environment","CPLS":"Graduate Planetary Science Concentration","PHED":"Physical Education","FORM":"Student Forums","WLIT":"World Literature Courses"}

subjectCodesReverse = {}

for key, value of subjectCodes
  subjectCodesReverse[value] = key

window.Router = Backbone.Router.extend
  routes:
    '/': 'index'
    '/course/:id': 'course'

  index: ->


  course: (id) ->


buildCourseResults = (results) ->
  resultsByDepartment = {}

  for result in results
    (resultsByDepartment[result.departmentCode] ?= []).push result

  resultsByDepartment

courseTemplate = ({id, code, title, professor, departmentCode}) ->
  """
  <li class='course-result dept-#{departmentCode}'>
    <a href='/course?id=#{id}'><p class='course-result-code'>#{code}</p>
    <p class='course-result-name'>#{title}</p></a>
    <p class='course-result-professor'>#{formatName professor}</p>
  </li>
  """

formatName = (name = 'STAFF') ->
  return name if name == 'STAFF'
  [last, first] = name.split ','
  "#{first} #{last}"

fillSubjectList = ->
  $subjectList = $('#subject-list ul')
  for code, subj of subjectCodes
    subjectEl = $("<li data-code='#{code}'>#{subj}</li>")
    $subjectList.append subjectEl

updateCourseResults = (results) ->
  $courseList = $("#course-list ul")
  $courseList.html ''

  resultsByDept = buildCourseResults results

  for dept, results of resultsByDept
    departmentName = subjectCodes[dept]

    for result in results
      $courseList.append courseTemplate result


autocomplete = (term, cb) ->
  $.getJSON '/search_by_title', name: term, (results) ->
    cb results

$ ->
  $("#course-search").on 'keyup', ->
    autocomplete @value, (courseResults) ->
      updateCourseResults courseResults

  window.theSchedule = new Schedule({}, $('#schedule'))
  window.theMenu = new Menus(courses)
  getAndUpdateSchedule()
  fillSubjectList()


