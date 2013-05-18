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
  for result in results
    $("#course-results").append courseTemplate result

autocomplete = (term, cb) ->
  $.getJSON '/search_by_title', name: term, (results) ->
    cb results

$ ->
  $("#course-search").on 'keyup', ->
    autocomplete @value, (courseResults) ->
      updateCourseResults courseResults







