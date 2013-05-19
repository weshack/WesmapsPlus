import uuid
from pymongo import MongoClient

client = MongoClient()
db = client.wesmaps
users = client.wesmaps.users

def generate_user_id():
    return str(uuid.uuid4())

def create_user():
    user_id = generate_user_id()
    user = {'id': user_id, 
            'sections': [],
            'starred': []}
    users.insert(user)
    return user

def get_user_info(session):
    userid = session.get('userid', None)

    if userid:
        user = users.find_one({'id': userid})
        if user:
            return user

    user = create_user()
    session['userid'] = user['id']
    session.modified = True

    return user

def update_user_schedule(userid, new_sections):
    return users.update({'id': userid}, {'$set': {'sections': new_sections}})

def update_user_starred(userid, new_starred):
    return users.update({'id': userid}, {'$set': {'starred': new_starred}})

def count_stars(courseid):
    return users.find({'starred': {'$in': [str(courseid)]}}).count()


