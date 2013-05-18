from flask import Flask, render_template
app = Flask(__name__)

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/search_by_name", methods = ['POST'])
def search(name):
    pass

@app.route("/login", methods = ['POST'])
def login():
    pass

if __name__ == "__main__":
    app.run()

