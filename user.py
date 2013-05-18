from pymongo import MongoClient

client = MongoClient()
db = client.wesmaps
users = client.wesmaps.users

def generate_user_id():
    return str(uuid.uuid4())

def create_user():
    user_id = generate_user_id()
    users.insert({'id': user_id, 
                  'sections': [],
                  'starred': []})
    return user_id

def get_user_info(userid):
    return users.find_one({'id': userid})

def update_user_schedule(userid, new_sections):
    return users.update({'id': userid}, {'$set': {'sections': new_sections}})

def update_user_starred(userid, new_starred):
    return users.update({'id': userid}, {'$set': {'starred': new_starred}}))

 
