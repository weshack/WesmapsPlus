from flask import Flask, render_template
app = Flask(__name__)

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/course")
def course_page():
    pass

@app.route("/search_by_name")
def search(name):
    pass

@app.route("/schedule")
def get_schedule():
    pass

@app.route("/schedule", methods = ['PUT'])
def update_schedule():
    pass

@app.route("/schedule", methods = ['POST'])
def create_schedule():
    pass

@app.route("/login", methods = ['POST'])
def login():
    pass

if __name__ == "__main__":
    app.run()

