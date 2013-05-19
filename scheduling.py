import datetime

days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

def convertTimeStringToDictionary(timeString):
	times = timeString.split(";")[:-1]
	schedule = {}
	for date in times:
                date = date.strip()
                for i in range(0,7):
			if date[i] != '.':
				if days[i] in schedule:
                                        schedule[days[i]].append( timeRangeToMilitary(date[8:]) )
				else:
					schedule[days[i]] = [timeRangeToMilitary(date[8:])]
	return schedule
	

def noConflict(currSchedule, newCourse):
	''' Tests two times, and returns True if they do not conflict '''
	for currCourseID in currSchedule:
		currCourse = currSchedule[currCourseID]
		for day in days:
			if day in currCourse:
				for courseTime in currCourse[day]:
					startTime = courseTime[0]
					endTime = courseTime[1]
					if day in newCourse:
						for time in newCourse[day]:
							if (time[0] >= startTime and time[0] <= endTime) or (startTime >= time[0] and startTime <= time[1]):
								return False
	return True

def timeRangeToMilitary(timeString):
	timeArray = timeString.split('-')
	outTime = []
	for time in timeArray:
		print 'TIME IS ' + time
		hour = time.split(":")[0]
		minute = time.split(":")[1][0:2]
		m = time[-2:]
		if m == 'AM':
			hour = str(int(hour) % 12)
		else:
			hour = str(int(hour) % 12 + 12)
		if len(hour) < 2:
			hour = '0' + hour
                outTime.append(int(hour)+(float(minute) / 60))
		#outTime.append(int(hour)+(float('0.' + minute)))
        
	return outTime
