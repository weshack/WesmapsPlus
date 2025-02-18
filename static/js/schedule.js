// Generated by CoffeeScript 1.7.1
var Schedule,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Schedule = (function() {
  Schedule.earliest = 8;

  Schedule.latest = 22;

  window.possColors = ['8c2318', '88a65e', 'bfb35a', '69D2E7', '21CA6F', '490A3D', 'BD1550', '34408C'];

  window.colorIndex = possColors.length - 1;

  Schedule.allDays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];

  function Schedule(courseData, $wrapper) {
    this.lowlightCourses = __bind(this.lowlightCourses, this);
    this.highlightCourse = __bind(this.highlightCourse, this);
    var $newDay, $rel, d, dayAbbrev, _i, _len, _ref;
    this.courseData = courseData;
    $rel = $('<div class="schedulerel"></div>');
    this.$wrapper = $wrapper;
    this.days = {};
    window.colors = {};
    this.$wrapper.append($rel);
    this.$wrapper = $rel;
    _ref = Schedule.allDays;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      d = _ref[_i];
      $newDay = $("<div class=day day-" + d + "'><div class='relative'></div></div>");
      this.$wrapper.append($newDay);
      dayAbbrev = d.substring(0, 3);
      $newDay.append("<div class='dayName'>" + dayAbbrev + "</div>");
      this.days[d] = $newDay.children('.relative');
    }
    this.draw();
  }

  Schedule.prototype.highlightCourse = function(course) {
    var title;
    title = allCourses[allSections[course]].title;
    $('.mtg').addClass('fade');
    $('.mtg-' + course).removeClass('fade');
    return notify(title);
  };

  Schedule.prototype.lowlightCourses = function() {
    $('.mtg').removeClass('fade');
    return notify("");
  };

  Schedule.prototype.draw = function() {
    var $el, $thisMtg, course, courseid, day, days, earliest, height, latest, t, thisColor, thisSchedule, times, top, _ref, _ref1, _results;
    _ref = this.days;
    for (day in _ref) {
      $el = _ref[day];
      $el.html('');
    }
    _ref1 = this.courseData;
    _results = [];
    for (course in _ref1) {
      days = _ref1[course];
      console.log('checking', course);
      if (window.colors[course]) {
        thisColor = window.colors[course];
        console.log('using existingi color', thisColor, 'for', course);
      } else {
        window.colors[course] = thisColor = window.possColors.pop();
      }
      _results.push((function() {
        var _results1;
        _results1 = [];
        for (day in days) {
          times = days[day];
          _results1.push((function() {
            var _fn, _i, _len, _results2;
            _fn = function(courseid) {
              return $thisMtg.click(function() {
                $("#subject-list").get(0).scrollTop = 0;
                return selectCourse(courseid, 'scheduled');
              });
            };
            _results2 = [];
            for (_i = 0, _len = times.length; _i < _len; _i++) {
              t = times[_i];
              earliest = Schedule.earliest;
              latest = Schedule.latest;
              top = (t[0] - earliest) * 100 / (latest - earliest);
              height = (t[1] - t[0]) * 100 / (latest - earliest);
              $thisMtg = $("<div class='mtg mtg-" + course + "'></div>");
              $thisMtg.css('top', top + '%').css('height', height + '%').css('background-color', '#' + thisColor).data('course', course);
              thisSchedule = this;
              $thisMtg.hover(function(evt) {
                return thisSchedule.highlightCourse($(this).data('course'), evt.pageX, evt.pageY);
              }, function() {
                return thisSchedule.lowlightCourses();
              });
              courseid = allSections[course];
              _fn(courseid);
              _results2.push(this.days[day].append($thisMtg));
            }
            return _results2;
          }).call(this));
        }
        return _results1;
      }).call(this));
    }
    return _results;
  };

  return Schedule;

})();
