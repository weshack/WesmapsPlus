import datetime

def convertTimeStringToDictionary(timeString):
	times = timeString.split(";")[:-1]
	schedule = {}
	for date in times:
		for i in range(0,7):
			if date.strip()[i] != '.':
				if datetime.datetime(1,1,i+7).strftime('%A') in schedule:
					schedule[datetime.datetime(1,1,i+7).strftime('%A')] += [timeRangeToMilitary(date.strip()[8:])]
				else:
					schedule[datetime.datetime(1,1,i+7).strftime('%A')] = [timeRangeToMilitary(date.strip()[8:])]
	return schedule
	

def noConflict(currSchedule, newCourse):
	''' Tests two times, and returns True if they do not conflict '''
	for newTimeK in newCourse:
		newTimes = newCourse[newTimeK]
		for newTime in newTimes:
			for timeK in currSchedule:
				times = currSchedule[TimeK]
				for time in times:
					if (time[0] >= newTime[0] and time[0] <= newTime[1]) or (newTime[0] >= time[0] and newTime[0] <= time[1]):
						return False
	return True

def timeRangeToMilitary(timeString):
	timeArray = timeString.split('-')
	outTime = []
	for time in timeArray:
		hour = time.split(":")[0]
		minute = time.split(":")[1][0:2]
		m = time[-2:]
		if m == 'AM':
			hour = str(int(hour) % 12)
		else:
			hour = str(int(hour) % 12 + 12)
		if len(hour) < 2:
			hour = '0' + hour
		outTime.append(int(hour)+(float(minute) / 60.0))
	return outTime
