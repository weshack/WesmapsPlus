import logging,sys
sys.path.insert(0, '/srv/weshack/WesmapsPlus/')
logging.basicConfig(stream=sys.stderr)
from server import app as application
application.secret_key = 'this is a secret key for awafaweofawoefaewifiowef'
