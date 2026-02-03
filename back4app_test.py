import os
import requests
from dotenv import load_dotenv
import time

load_dotenv()
APP_ID = os.getenv('BACK4APP_APP_ID')
MASTER_KEY = os.getenv('BACK4APP_MASTER_KEY')
SERVER = os.getenv('BACK4APP_SERVER_URL', 'https://parseapi.back4app.com')

headers_master = {
    'X-Parse-Application-Id': APP_ID,
    'X-Parse-Master-Key': MASTER_KEY,
    'Content-Type': 'application/json'
}
headers_rest = {
    'X-Parse-Application-Id': APP_ID,
    'X-Parse-REST-API-Key': MASTER_KEY,
    'Content-Type': 'application/json'
}

print('APP_ID present:', bool(APP_ID))
print('MASTER_KEY present:', bool(MASTER_KEY))
print('SERVER:', SERVER)

# Test getCourseCompletion with REST key
print('\n==> Calling getCourseCompletion with X-Parse-REST-API-Key')
r = requests.post(f"{SERVER}/parse/functions/getCourseCompletion", headers=headers_rest, json={})
print('status', r.status_code)
try:
    print(r.json())
except Exception as e:
    print('no json:', r.text[:1000])

# Test getCourseCompletion with Master key
print('\n==> Calling getCourseCompletion with X-Parse-Master-Key')
r2 = requests.post(f"{SERVER}/parse/functions/getCourseCompletion", headers=headers_master, json={})
print('status', r2.status_code)
try:
    print(r2.json())
except Exception as e:
    print('no json:', r2.text[:1000])

# Create test user
timestamp = int(time.time())
username = f"test_user_{timestamp}"
password = "P@ssw0rd123"
print('\n==> Creating user', username)
create = requests.post(f"{SERVER}/parse/users", headers=headers_master, json={'username': username, 'password': password})
print('create status', create.status_code)
print(create.text[:1000])

# Login
ess = requests.get(f"{SERVER}/parse/login?username={username}&password={password}", headers={'X-Parse-Application-Id': APP_ID})
print('\n==> Login', ess.status_code if 'ess' in locals() else 'n/a')
try:
    login_json = ess.json()
    print(login_json)
    session_token = login_json.get('sessionToken')
except Exception as e:
    print('login failed', e)
    session_token = None

if session_token:
    headers_session = {
        'X-Parse-Application-Id': APP_ID,
        'X-Parse-Session-Token': session_token,
        'Content-Type': 'application/json'
    }
    # createTodo
    print('\n==> Calling createTodo')
    ct = requests.post(f"{SERVER}/parse/functions/createTodo", headers=headers_session, json={'title': 'Test todo via script'})
    print('createTodo', ct.status_code, ct.text[:1000])
    # getTodos
    print('\n==> Calling getTodos')
    gt = requests.post(f"{SERVER}/parse/functions/getTodos", headers=headers_session, json={})
    print('getTodos', gt.status_code)
    try:
        print(gt.json())
    except Exception as e:
        print('no json', gt.text)

    # cleanup: delete user using master key
    obj_id = login_json.get('objectId')
    if obj_id:
        print('\n==> Deleting test user', obj_id)
        d = requests.delete(f"{SERVER}/parse/users/{obj_id}", headers=headers_master)
        print('delete', d.status_code, d.text[:500])
else:
    print('No session token; aborting todo tests')
