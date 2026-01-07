# Business Review Analysis System

A comprehensive system for analyzing customer reviews using aspect-based sentiment analysis and machine learning.

## System Architecture

The system consists of three main components:

1. **Backend API** (FastAPI + PostgreSQL)
   - RESTful API for review processing
   - WebSocket support for real-time notifications
   - Asynchronous review processing
   - PostgreSQL database for data persistence

2. **Mobile Application** (Flutter)
   - Cross-platform mobile app for business owners
   - Real-time analytics dashboard
   - Review management interface
   - WebSocket integration for live updates

3. **Web Interface** (HTML/CSS/JavaScript)
   - Web-based review submission interface
   - Recent reviews display
   - Multiple business support

## Features

- Aspect-based sentiment analysis
- Real-time review processing
- Multi-business support (Food, Hotel, Education)
- Interactive analytics dashboard
- Category-based sentiment breakdown
- Top issues detection
- Automated recommendations
- WebSocket notifications

## Technology Stack

### Backend
- Python 3.13
- FastAPI
- PostgreSQL
- psycopg2
- VADER Sentiment Analysis
- Transformers (BERT-based models)

### Mobile App
- Flutter/Dart
- Provider (State Management)
- HTTP Client
- WebSocket Channel

### Web Interface
- HTML5
- CSS3
- Vanilla JavaScript

## Installation

### Backend Setup

1. Navigate to backend directory:
```bash
cd review_backend
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Configure database in `db_config.py`

4. Run the server:
```bash
python main.py
```

### Mobile App Setup

1. Navigate to app directory:
```bash
cd business_review_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Web Interface Setup

1. Navigate to web interface directory:
```bash
cd review_web_interface
```

2. Update API URL in `script.js`

3. Open `index.html` in a web browser

## Database Schema

- **businesses**: Business information
- **users**: Business owner accounts
- **reviews**: Customer reviews with overall sentiment
- **aspect_sentiments**: Aspect-level sentiment data
- **raw_reviews**: Review processing queue

## API Endpoints

- `POST /api/login` - User authentication
- `GET /api/businesses/{id}/reviews` - Fetch reviews
- `GET /api/businesses/{id}/analytics` - Get analytics
- `GET /api/businesses/{id}/stats` - Get statistics
- `POST /api/reviews` - Submit new review
- `WebSocket /ws/{business_id}` - Real-time updates

## Models

The system supports three different domain-specific models:
- Amazon (Food/Restaurant reviews)
- Hotel (Hospitality reviews)
- Coursera (Education/Course reviews)

## License

All rights reserved.
