from . import db


class Rating(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100))
    series_name = db.Column(db.String(100))
    rating = db.Column(db.Integer)  # 0 to 5
