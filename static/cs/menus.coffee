class Menus


	constructor: (courses) ->
		@$subjectMenu = $('#subject-list ul')
		@$courseMenu = $('#course-list ul')
		this.fillCourses(courses)


	fillCourses: (courses) ->
		for cid, course of courses
			@$courseMenu.append($(courseTemplate course))