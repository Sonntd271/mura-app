from flask import Flask, render_template, request
from flask_bootstrap import Bootstrap5
from flask_sqlalchemy import SQLAlchemy
from flask_caching import Cache

DB_IP = "my-db-ip"
CACHE_IP = "my-mc-ip"

app = Flask(__name__)
app.config["SQLALCHEMY_DATABASE_URI"] = f"mysql+mysqlconnector://admin:admin@{DB_IP}:3306/accounts"
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
app.config["CACHE_TYPE"] = "memcached"
app.config["CACHE_MEMCACHED_SERVERS"] = [f"{CACHE_IP}:11211"]

Bootstrap5(app)
db = SQLAlchemy(app)
cache = Cache(app)


class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password = db.Column(db.String(255), nullable=False)


@app.route("/")
def home():
    users = cache.get("users")
    if users is None:
        users = User.query.all()
        cache.set("users", users, timeout=60)  # 60 seconds
    print(users)
    return render_template("index.html")

@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "GET":
        return render_template("login.html", sent=False)
    if request.method == "POST":
        response = request.form.to_dict()
        print(response)
        new_user = User(email=response["email"], password=response["password"])
        db.session.add(new_user)
        db.session.commit()

        # Clear the cache so it will be refreshed on next request
        cache.delete("users")

        return render_template("login.html", sent=True)

if __name__ == "__main__":
    with app.app_context():
        db.create_all()
    app.run(debug=True)
