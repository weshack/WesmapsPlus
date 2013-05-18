make = (args..., options) ->
  e = document.createElement (args[0] or options?.tag or 'div')
  for k,v of options
    if k != 'tag'
      e[k] = v
  e

subjectCodes = {"ARAB":"Arabic","ARHA":"Art History","ARST":"Art Studio","ALIT":"Asian Languages and Literature","CHIN":"Chinese","CCIV":"Classical Civilization","COL":"College of Letters","DANC":"Dance","ENGL":"Englsh","FILM":"Film Studies","FREN":"French","FRST":"French Studies","FIST":"French, Italian, Spanish in Translation","GELT":"German Literature in English","GRST":"German Studies","GRK":"Greek","HEBR":"Hebrew","HEST":"Hebrew Studies","IBST":"Iberian Studies","ITAL":"Italian Studies","JAPN":"Japanese Studies","KREA":"Korean Studies","LAT":"Latin Studies","LANG":"Less Commonly Taught Languages","MUSC":"Music","PORT":"Portugese","RUSS":"Russian","RULE":"Russian Literature in English","SPAN":"Spanish","THEA":"Theater","AMST":"American Studies","ANTH":"Anthropology","CSS":"College of Social Studies","ECON":"Economics","GOVT":"Government","HIST":"History","PHIL":"Philosophy","RELI":"Religion","SOC":"Sociology","CEC":"Civic Engagement","CES":"Environmental Studies","CIM":"Informatics and Modeling","CIR":"International Relations","CJS":"Jewish and Israel Studies","CMES":"Middle Eastern Studies","CMB":"Molecular Biophysics","CSCT":"Social, Cultural, and Critical Theory","CSA":"South Asian Studies","CSED":"The Study of Education","CWRC":"Writing","ASTR":"Astronomy","BIOL":"Biology","CHEM":"Chemistry","COMP":"Computer Science","EES":"Earth and Environmental Sciences","MATH":"Mathematics","MBB":"Molecular Biology and Biochemistry","NSB":"Neuroscience and Behavior","PHYS":"Physics","PSYC":"Psychology","XAFS":"African Studies","XCHS":"Christianity Studies","XDST":"Disability Studies","XPSC":"Planetary Science","XSER":"Service-Learning","XURS":"Urban Studies","AFAM":"African American Studies Program","ARCP":"Archaeology Program","CHUM":"Center for the Humanities","CSPL":"Center for the Study of Public Life","EAST":"East Asian Studies Program","ENVS":"Environmental Studies Program","FGSS":"Feminist, Gender, and Sexuality Studies Program","LAST":"Latin American Studies Program","MECO":"Mathematics-Economics Program","MDST":"Medieval Studies Program","QAC":"Quantitative Analysis Center","REES":"Russian, East European, and Eurasian Studies Program","SISP":"Science in Society Program","WRCT":"Writing Center","COE":"College of the Environment","CPLS":"Graduate Planetary Science Concentration","PHED":"Physical Education","FORM":"Student Forums","WLIT":"World Literature Courses"}

subjectCodesReverse = {"Arabic":"ARAB","Art History":"ARHA","Art Studio":"ARST","Asian Languages and Literature":"ALIT","Chinese":"CHIN","Classical Civilization":"CCIV","College of Letters":"COL","Dance":"DANC","Englsh":"ENGL","Film Studies":"FILM","French":"FREN","French Studies":"FRST","French, Italian, Spanish in Translation":"FIST","German Literature in English":"GELT","German Studies":"GRST","Greek":"GRK","Hebrew":"HEBR","Hebrew Studies":"HEST","Iberian Studies":"IBST","Italian Studies":"ITAL","Japanese Studies":"JAPN","Korean Studies":"KREA","Latin Studies":"LAT","Less Commonly Taught Languages":"LANG","Music":"MUSC","Portugese":"PORT","Russian":"RUSS","Russian Literature in English":"RULE","Spanish":"SPAN","Theater":"THEA","American Studies":"AMST","Anthropology":"ANTH","College of Social Studies":"CSS","Economics":"ECON","Government":"GOVT","History":"HIST","Philosophy":"PHIL","Religion":"RELI","Sociology":"SOC","Civic Engagement":"CEC","Environmental Studies":"CES","Informatics and Modeling":"CIM","International Relations":"CIR","Jewish and Israel Studies":"CJS","Middle Eastern Studies":"CMES","Molecular Biophysics":"CMB","Social, Cultural, and Critical Theory":"CSCT","South Asian Studies":"CSA","The Study of Education":"CSED","Writing":"CWRC","Astronomy":"ASTR","Biology":"BIOL","Chemistry":"CHEM","Computer Science":"COMP","Earth and Environmental Sciences":"EES","Mathematics":"MATH","Molecular Biology and Biochemistry":"MBB","Neuroscience and Behavior":"NSB","Physics":"PHYS","Psychology":"PSYC","African Studies":"XAFS","Christianity Studies":"XCHS","Disability Studies":"XDST","Planetary Science":"XPSC","Service-Learning":"XSER","Urban Studies":"XURS","African American Studies Program":"AFAM","Archaeology Program":"ARCP","Center for the Humanities":"CHUM","Center for the Study of Public Life":"CSPL","East Asian Studies Program":"EAST","Environmental Studies Program":"ENVS","Feminist, Gender, and Sexuality Studies Program":"FGSS","Latin American Studies Program":"LAST","Mathematics-Economics Program":"MECO","Medieval Studies Program":"MDST","Quantitative Analysis Center":"QAC","Russian, East European, and Eurasian Studies Program":"REES","Science in Society Program":"SISP","Writing Center":"WRCT","College of the Environment":"COE","Graduate Planetary Science Concentration":"CPLS","Physical Education":"PHED","Student Forums":"FORM","World Literature Courses":"WLIT"}

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

courseTemplate = ({id, code, title, professor}) ->
  """
  <div class='course-result'>
    <a href='/course?id=#{id}'><p class='course-result-code'>#{code}</p>
    <p class='course-result-name'>#{title}</p></a>
    <p class='course-result-professor'>#{formatName professor}</p>
  </div>
  """

formatName = (name = 'STAFF') ->
  return name if name == 'STAFF'
  [last, first] = name.split ','
  "#{first} #{last}"

updateCourseResults = (results) ->
  $("#course-results").html ''

  resultsByDept = buildCourseResults results

  for dept, results of resultsByDept
    departmentName = subjectCodes[dept]

    departmentEl = $ (make 'div', className: 'course-results-department')

    departmentEl.append "<b class='course-results-department-name'>#{departmentName}</b>"

    for result in results
      departmentEl.append courseTemplate result

    $("#course-results").append departmentEl


autocomplete = (term, cb) ->
  $.getJSON '/search_by_title', name: term, (results) ->
    cb results

$ ->
  $("#course-search").on 'keyup', ->
    autocomplete @value, (courseResults) ->
      updateCourseResults courseResults

