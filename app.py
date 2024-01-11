from flask import Flask, render_template, request, redirect, url_for, flash
from flask_bootstrap import Bootstrap5
from flask_sqlalchemy import SQLAlchemy
from flask_caching import Cache

MYSQL_IP = "35.153.209.129" # Replace this with your DB IP address
MEMCACHE_IP = "54.208.251.237" # Replace this with your Cache IP address

app = Flask(__name__)
app.config["SECRET_KEY"] = "hello_world"

# Configure MySQL
app.config["SQLALCHEMY_DATABASE_URI"] = f"mysql+mysqlconnector://admin:admin@{MYSQL_IP}:3306/accounts"
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

# Configure Memcached
app.config["CACHE_TYPE"] = "memcached"
app.config["CACHE_MEMCACHED_SERVERS"] = [f"{MEMCACHE_IP}:11211"]
app.config["CACHE_DEFAULT_TIMEOUT"] = 300 # Cache for 300 seconds
cache = Cache(app)

Bootstrap5(app)
db = SQLAlchemy(app)


class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(255), unique=True, nullable=False)
    password = db.Column(db.String(255), nullable=False)
    courses = db.relationship("Course", secondary="user_course", backref=db.backref("users", lazy="dynamic"))


class Course(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    course_name = db.Column(db.String(255), nullable=False)
    instructor = db.Column(db.String(255), nullable=False)
    time = db.Column(db.String(255), nullable=False)


class UserCourse(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("user.id"), nullable=False)
    course_id = db.Column(db.Integer, db.ForeignKey("course.id"), nullable=False)


@app.route("/")
def home():
    return redirect(url_for("schedule"))


@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "GET":
        flashed = "_flashes" in request.args
        return render_template("login.html", flashed=flashed)
    
    if request.method == "POST":
        response = request.form.to_dict()
        username = response["username"]
        password = response["password"]

        # Check if the username and password match a user in the database
        user = User.query.filter_by(username=username, password=password).first()

        if user:
            # Cache the user's information
            cache_result = cache.set("current_user", user.id)
            print(f"Cache set result: {cache_result}")
            return redirect(url_for("schedule"))
        else:
            flash("Invalid username or password", "error")
            return render_template("login.html")


@app.route("/register", methods=["GET", "POST"])
def register():
    if request.method == "GET":
        return render_template("register.html")
    if request.method == "POST":
        response = request.form.to_dict()
        print(response)
        
        # Store data in database
        new_user = User(username=response["username"], password=response["password"])
        db.session.add(new_user)
        db.session.commit()

        # Show that user is successfully registered
        flash("Registration successful!", "success")
        return redirect(url_for("login", _flashed_joined='true'))


@app.route("/schedule", methods=["GET", "POST"])
def schedule():
    # Retrieve the cached user ID
    user_id = cache.get("current_user")

    if user_id is not None:
        # Fetch user ID from cache
        user = db.session.get(User, user_id)
        return render_template("schedule.html", user=user)

    # Redirect to the login page if any issues
    return redirect(url_for("login"))


@app.route("/course", methods=["GET", "POST"])
def insert_course():
    if request.method == "GET":
        return render_template("course.html")
    elif request.method == "POST":
        course_name = request.form.get("course_name")
        instructor = request.form.get("instructor")
        time = request.form.get("time")

        new_course = Course(course_name=course_name, instructor=instructor, time=time)
        db.session.add(new_course)
        db.session.commit()

        flash("Course successfully added!", "success")
        return redirect(url_for("insert_course"))


@app.route("/schedule/available", methods=["GET", "POST"])
def select_courses():
    # Retrieve the cached user ID
    user_id = cache.get("current_user")

    if user_id is not None:
        # Fetch user ID from cache
        user = User.query.get(user_id)

        if user:
            if request.method == "GET":
                # Retrieve all available courses
                all_courses = Course.query.all()
                return render_template("available.html", all_courses=all_courses)
            if request.method == "POST":
                # Retrieve the selected course IDs from the form submission
                selected_course_ids = request.form.getlist("selected_courses[]")

                # Fetch the selected courses from the database
                selected_courses = Course.query.filter(Course.id.in_(selected_course_ids)).all()
                user.courses = selected_courses
                db.session.commit()

                return redirect(url_for("schedule"))

    # Redirect to the login page if any issues
    return redirect(url_for("login"))


@app.route("/logout")
def logout():
    cache.clear()
    return render_template("login.html")


if __name__ == "__main__":
    with app.app_context():
        db.create_all()
    app.run(host="0.0.0.0", port=5000)
