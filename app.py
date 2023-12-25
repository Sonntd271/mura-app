from flask import Flask, render_template, request
from flask_bootstrap import Bootstrap5

app = Flask(__name__)
Bootstrap5(app)

@app.route("/")
def home():
    return render_template("index.html")

@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "GET":
        return render_template("login.html", sent=False)
    if request.method == "POST":
        response = request.form.to_dict()
        print(response)
        return render_template("login.html", sent=True)

if __name__ == "__main__":
    app.run(debug=True)
