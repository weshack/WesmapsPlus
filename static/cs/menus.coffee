class Menus

	constructor: (courses) ->
		@$subjectMenu = $('#subject-list ul')
		@$courseMenu = $('#course-list ul')
		@courses = courses
		@fillCourses(courses)

	fillCourses: (courses) ->
		for cid, course of courses
			@$courseMenu.append($(courseTemplate course))

	showSubject: (subject) ->
		subjectCourses = filterForSubject(@courses, subject)
		@fillCourses(subjectCourses)
		subjectCourses