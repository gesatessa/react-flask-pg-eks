from flask import Blueprint, request, jsonify
from .models import Rating
from . import db

bp = Blueprint('api', __name__)


@bp.route('/rate', methods=['POST'])
def rate():
    data = request.json
    new_rating = Rating(
        name=data['name'],
        series_name=data['series_name'],
        rating=int(data['rating'])
    )
    db.session.add(new_rating)
    db.session.commit()
    return jsonify({'message': 'Rating added'}), 201


@bp.route('/recent', methods=['GET'])
def recent():
    last_five = Rating.query.order_by(Rating.id.desc()).limit(3).all()
    return jsonify([
        {'name': r.name, 'series_name': r.series_name, 'rating': r.rating}
        for r in last_five
    ])


@bp.route('/stats/<series_name>', methods=['GET'])
def stats(series_name):
    ratings = Rating.query.filter_by(series_name=series_name).all()
    if not ratings:
        return jsonify({'message': 'No ratings found'}), 404
    avg = sum(r.rating for r in ratings) / len(ratings)
    return jsonify({
        'series_name': series_name,
        'count': len(ratings),
        'average': round(avg, 2)
    })
