class Menus

	constructor: (courses) ->
		@$subjectMenu = $('#subject-list ul')
		@$courseMenu = $('#course-list ul')
		for cid, course of courses
			@$courseMenu.append($(courseTemplate course))
