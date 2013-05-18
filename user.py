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
    userid = session['userid']
    if user = users.find_one({'id': userid}):
        return user
    else:
        user = create_user()
        session['userid'] = user['userid']
        return user

def update_user_schedule(userid, new_sections):
    return users.update({'id': userid}, {'$set': {'sections': new_sections}})

def update_user_starred(userid, new_starred):
    return users.update({'id': userid}, {'$set': {'starred': new_starred}}))

 
