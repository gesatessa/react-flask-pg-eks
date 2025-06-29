import os
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS

db = SQLAlchemy()


def create_app():
    app = Flask(__name__)
    default_db_url = 'postgresql://postgres:postgres@db:5432/postgres'
    app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get('DATABASE_URL', default_db_url)
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

    db.init_app(app)

    # Enable CORS for all routes, origins can be restricted for production
    CORS(app)

    from .routes import bp as api_bp
    app.register_blueprint(api_bp)

    with app.app_context():
        db.create_all()

    return app
