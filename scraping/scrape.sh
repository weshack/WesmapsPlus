/bin/rm /srv/weshack/WesmapsPlus/scraping/courses.db;
/usr/bin/python /srv/weshack/WesmapsPlus/scraping/scrape_courses.py && \
/usr/bin/python /srv/weshack/WesmapsPlus/scraping/rate_my_professor.py && \
/usr/bin/ruby /srv/weshack/WesmapsPlus/scraping/jsonToSqlite.rb && \
/bin/mv /srv/weshack/WesmapsPlus/scraping/courses.db /srv/weshack/WesmapsPlus/db/courses.db
