from flask import Flask, render_template, request
from flask_bootstrap import Bootstrap5
from flask_sqlalchemy import SQLAlchemy
from pymemcache.client.base import Client as MemcacheClient

DB_IP = "my-db-ip"
ELASTICACHE_ENDPOINT = "my-elasticache-endpoint"

app = Flask(__name__)
app.config["SQLALCHEMY_DATABASE_URI"] = f"mysql+mysqlconnector://admin:admin@{DB_IP}:3306/accounts"
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

Bootstrap5(app)
db = SQLAlchemy(app)
memcache_client = MemcacheClient((ELASTICACHE_ENDPOINT, 11211))


class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password = db.Column(db.String(255), nullable=False)


@app.route("/")
def home():
    users = User.query.all()
    print(users)
    # value = memcache_client.get("email@email.com")
    # if value is not None:
    #     print(value)
    # else:
    #     print("Not in cache")
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
        memcache_client.set(response["email"], response["password"], expire=60)  # Cache for 60 seconds

        return render_template("login.html", sent=True)

if __name__ == "__main__":
    with app.app_context():
        db.create_all()
    app.run(debug=True)
