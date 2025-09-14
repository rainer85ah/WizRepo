from flask import Flask, render_template, request, redirect, url_for, session, flash
from pymongo import MongoClient
from pymongo.errors import CollectionInvalid, ServerSelectionTimeoutError
from bson.objectid import ObjectId
from bson.errors import InvalidId


app = Flask(__name__)
app.secret_key = "supersecret"  # use env variable in production

DB_HOST = "ec2-18-234-163-210.compute-1.amazonaws.com"
DB_NAME = "admin"

def get_user_client(username, password):
    """Create a MongoClient for the given username/password"""
    user_uri = f"mongodb://{username}:{password}@{DB_HOST}:27017/{DB_NAME}?serverSelectionTimeoutMS=5000"
    client = MongoClient(user_uri)
    # Trigger connection to verify credentials
    client.admin.command("ping")
    print("DB connection successful.")
    return client

@app.route("/", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        username = request.form["username"]
        password = request.form["password"]

        try:
            client = get_user_client(username, password)
            db = client[DB_NAME]

            # Verify user document exists (optional)
            user_doc = db.webapp_users.find_one({"username": username})
            if user_doc and user_doc["password"] == password:
                session["user"] = username
                session["is_admin"] = user_doc.get("is_admin", False)
                # store client info in session-like object (not actual client)
                session["mongo_uri"] = f"mongodb://{username}:{password}@{DB_HOST}:27017/{DB_NAME}"
                return redirect(url_for("dashboard"))
            else:
                flash("Invalid credentials", "danger")

        except ServerSelectionTimeoutError:
            flash("Cannot connect to MongoDB with these credentials", "danger")
        except Exception as e:
            flash(f"Unexpected error: {str(e)}", "danger")

    return render_template("login.html")


def get_client_from_session():
    """Return a MongoClient using the logged-in user's credentials"""
    if "mongo_uri" not in session:
        return None
    try:
        client = MongoClient(session["mongo_uri"])
        client.admin.command("ping")
        return client
    except ServerSelectionTimeoutError:
        return None


@app.route("/dashboard", methods=["GET", "POST"])
def dashboard():
    if "user" not in session:
        return redirect(url_for("login"))

    client = get_client_from_session()
    if not client:
        flash("MongoDB connection lost. Please log in again.", "danger")
        return redirect(url_for("logout"))

    db = client[DB_NAME]

    if request.method == "POST":
        collection_name = request.form.get("collection_name", "").strip()
        if collection_name:
            flash(f"Collection '{collection_name}' will be created on first item added.", "info")
            # no create_collection call needed; lazy creation will handle it
            return redirect(url_for("collection", name=collection_name))

    # List collections that currently have at least one document
    collections = db.list_collection_names()
    return render_template("dashboard.html", collections=collections)


@app.route("/collections/<name>", methods=["GET", "POST"])
def collection(name):
    if "user" not in session:
        return redirect(url_for("login"))

    client = get_client_from_session()
    if not client:
        flash("MongoDB connection lost. Please log in again.", "danger")
        return redirect(url_for("logout"))

    db = client[DB_NAME]
    coll = db[name]

    # Handle POST actions
    if request.method == "POST":
        try:
            if "add" in request.form:
                title = request.form.get("title", "").strip()
                desc = request.form.get("description", "").strip()
                if not title:
                    flash("Title is required", "warning")
                else:
                    coll.insert_one({
                        "title": title,
                        "description": desc,
                        "status": "open",
                        "owner": session.get("user")
                    })
                    flash("Item added", "success")

            elif "update" in request.form:
                item_id = request.form.get("item_id", "").strip()
                new_status = request.form.get("status", "open")
                try:
                    oid = ObjectId(item_id)
                    result = coll.update_one({"_id": oid}, {"$set": {"status": new_status}})
                    if result.matched_count == 0:
                        flash("Item not found", "warning")
                    else:
                        flash("Item updated", "success")
                except Exception:
                    flash("Invalid item ID", "danger")

            elif "delete" in request.form:
                item_id = request.form.get("item_id", "").strip()
                try:
                    oid = ObjectId(item_id)
                    result = coll.delete_one({"_id": oid})
                    if result.deleted_count == 0:
                        flash("Item not found", "warning")
                    else:
                        flash("Item deleted", "warning")
                except Exception:
                    flash("Invalid item ID", "danger")

            # Delete collection (admin only)
            elif "delete_collection" in request.form and session.get("is_admin"):
                db.drop_collection(name)
                flash(f"Collection '{name}' deleted.", "success")
                return redirect(url_for("dashboard"))

        except Exception as e:
            app.logger.exception("Database operation failed")
            flash(f"Database error: {str(e)}", "danger")

        return redirect(url_for("collection", name=name))

    # GET request: list items
    items_cursor = coll.find()
    items = []
    for doc in items_cursor:
        doc["_id"] = str(doc.get("_id", ""))
        doc["title"] = doc.get("title", "")
        doc["description"] = doc.get("description", "")
        doc["status"] = doc.get("status", "open")
        items.append(doc)

    return render_template("collections.html", name=name, items=items)



@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("login"))
