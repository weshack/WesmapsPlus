import requests
import simplejson
import urllib

def get_professor_rating(name):
    try:
        url = "http://www.ratemyprofessors.com/solr/interim.jsp?select?facet=true&q=" + urllib.quote(name) + "&facet.field=schoolname_s&facet.field=teacherdepartment_s&facet.field=schoolcountry_s&facet.field=schoolstate_s&facet.limit=50&rows=20&facet.mincount=1&json.nl=map&fq=content_type_s%3ATEACHER&wt=json"
        resp = requests.get(url)
        results = simplejson.loads(resp.content)['response']['docs']
        for result in results:
            if result['schoolname_s'] == 'Wesleyan University':
                return result['averageratingscore_rf']
            
    except:
        pass

    return None

