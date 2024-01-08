from flask import Flask, render_template, request
from flask_bootstrap import Bootstrap5
from flask_sqlalchemy import SQLAlchemy
from flask_caching import Cache
import json

MYSQL_IP = "10.0.3.63" # Replace this with your DB IP address
MEMCACHE_IP = "10.0.3.206" # Replace this with your Cache IP address

app = Flask(__name__)

# Configure MySQL
app.config["SQLALCHEMY_DATABASE_URI"] = f"mysql+mysqlconnector://admin:admin@{MYSQL_IP}:3306/accounts"
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

# Configure Memcached
app.config["CACHE_TYPE"] = "memcached"
app.config["CACHE_MEMCACHED_SERVERS"] = [f"{MEMCACHE_IP}:11211"]
app.config["CACHE_DEFAULT_TIMEOUT"] = 60 # Cache for 60 seconds
cache = Cache(app)

Bootstrap5(app)
db = SQLAlchemy(app)


class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password = db.Column(db.String(255), nullable=False)


@app.route("/")
def home():
    users = User.query.all()
    print(users)

    value = cache.get("temp_user")
    print(f"Cache value: {value}")
    if value is not None:
        print(value)
    else:
        print("Not in cache")

    return render_template("index.html")

@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "GET":
        return render_template("login.html", sent=False)
    if request.method == "POST":
        response = request.form.to_dict()
        print(response)
        
        # Store data in database
        new_user = User(email=response["email"], password=response["password"])
        db.session.add(new_user)
        db.session.commit()

        # Store data in Memcached
        cache_result = cache.set("temp_user", "temp_value") # json.dumps(response)
        print(f"Cache set result: {cache_result}")

        return render_template("login.html", sent=True)

if __name__ == "__main__":
    with app.app_context():
        db.create_all()
    app.run(host="0.0.0.0", port=5000)
