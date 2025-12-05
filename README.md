# 🎯 Multi-Business Review Analysis System

A comprehensive AI-powered review analysis platform that provides aspect-based sentiment analysis for multiple business types using fine-tuned T5 models.

## 📋 Overview

This system analyzes customer reviews for three business types:
- **Food Restaurants** 🍽️
- **Online Courses** 📚  
- **Hotels** 🏨

Each business type uses a specialized fine-tuned T5 model for accurate aspect-based sentiment analysis (ABSA).

## ✨ Features

### 🤖 AI-Powered Analysis
- **Aspect-Based Sentiment Analysis**: Identifies specific aspects (food quality, service, cleanliness, etc.) and their sentiments
- **Multi-Model Architecture**: Separate fine-tuned models for each business domain
- **Real-time Processing**: Asynchronous review processing with WebSocket updates
- **GPU Acceleration**: Automatic GPU detection and utilization

### 📱 Mobile Application (Flutter)
- Cross-platform iOS/Android support
- Real-time dashboard with sentiment distribution
- Detailed review browsing with filtering
- Advanced analytics and insights
- Multi-account support for different businesses
- Offline data caching

### 🌐 Web Interface
- Modern, responsive design
- Real-time review submission
- Live sentiment visualization
- Review management dashboard

### 🔧 Backend API (FastAPI)
- RESTful API endpoints
- WebSocket support for real-time updates
- SQLite database with optimized queries
- Background task processing
- CORS-enabled for cross-origin requests

## 🏗️ Architecture

```
├── business_review_app/     # Flutter mobile application
│   ├── lib/
│   │   ├── models/          # Data models
│   │   ├── providers/       # State management
│   │   ├── screens/         # UI screens
│   │   ├── services/        # API & database services
│   │   └── utils/           # Helper functions
│   └── android/             # Android-specific files
│
├── review_backend/          # FastAPI backend server
│   ├── main.py             # Main server with API routes
│   ├── ml_engine.py        # ML model processing engine
│   ├── requirements.txt    # Python dependencies
│   ├── add_sample_reviews.py  # Sample data generator
│   └── START_BACKEND.bat   # Quick start script
│
└── review_web_interface/   # Web dashboard
    ├── index.html          # Main HTML page
    ├── script.js           # JavaScript logic
    └── styles.css          # Styling

Note: ML models (amazon_model, coursera_model, hotel_model) are not 
included due to size constraints. You need to train or obtain these models separately.
```

## 🚀 Getting Started

### Prerequisites

- **Python 3.8+**
- **Flutter 3.0+** (for mobile app)
- **CUDA-compatible GPU** (optional, for faster processing)
- **ngrok** (for exposing local server)

### Backend Setup

1. **Install Python dependencies:**
```bash
cd review_backend
pip install -r requirements.txt
```

2. **Obtain ML Models:**

Place the following models in the project root:
- `amazon_model/` - Fine-tuned T5 for food/product reviews
- `coursera_model/` - Fine-tuned T5 for course reviews  
- `hotel_model/` - Fine-tuned T5 for hotel reviews

Each model folder should contain:
- `config.json`
- `generation_config.json`
- `model.safetensors`
- `tokenizer files`

3. **Start the backend:**
```bash
python main.py
```

Or use the batch script:
```bash
START_BACKEND.bat
```

The server will start on `http://localhost:8000`

4. **Setup ngrok (for mobile access):**
```bash
ngrok http 8000
```

Update the ngrok URL in:
- `business_review_app/lib/services/api_service.dart`
- `review_web_interface/script.js`
- `review_backend/add_sample_reviews.py`

### Mobile App Setup

1. **Navigate to the app directory:**
```bash
cd business_review_app
```

2. **Install Flutter dependencies:**
```bash
flutter pub get
```

3. **Update API URL:**

Edit `lib/services/api_service.dart`:
```dart
static const String baseUrl = "https://YOUR_NGROK_URL.ngrok-free.app/api";
```

4. **Run the app:**
```bash
flutter run
```

### Web Interface Setup

1. **Update API URL:**

Edit `script.js`:
```javascript
const API_URL = 'https://YOUR_NGROK_URL.ngrok-free.app/api';
```

2. **Open in browser:**
```bash
# Simply open index.html in your browser
```

## 📊 Database Schema

### businesses
- Business profiles (Food, Course, Hotel)
- Includes name, type, description, image URL

### users  
- Demo account credentials
- Linked to specific businesses

### reviews
- Customer reviews with overall sentiment
- Includes text, rating, date, customer name

### aspect_sentiments
- Detailed aspect-level sentiment analysis
- Multiple aspects per review

### raw_reviews
- Processing queue for incoming reviews
- Tracks processing status

### analytics
- Cached analytics data
- Aggregated insights and statistics

## 🔑 Demo Accounts

The system includes pre-configured demo accounts:

| Business Type | Email | Password |
|--------------|-------|----------|
| Food Restaurant | food@demo.com | demo123 |
| Online Course | course@demo.com | demo123 |
| Hotel | hotel@demo.com | demo123 |

## 📡 API Endpoints

### Authentication
- `POST /api/login` - User login
- `GET /api/demo-accounts` - Get demo credentials

### Reviews
- `GET /api/businesses/{id}/reviews` - Get all reviews
- `POST /api/businesses/{id}/reviews` - Submit new review
- `GET /api/businesses/{id}/reviews/{review_id}` - Get specific review

### Analytics
- `GET /api/businesses/{id}/stats` - Get business statistics
- `GET /api/businesses/{id}/analytics` - Get detailed analytics

### WebSocket
- `WS /ws` - Real-time review processing updates

## 🎨 Key Features Detail

### Aspect-Based Sentiment Analysis

The system identifies specific aspects within reviews:

**Food Restaurant:**
- Food Quality, Taste, Presentation
- Service Speed, Staff Attitude
- Ambiance, Cleanliness
- Price, Value for Money

**Online Course:**
- Content Quality, Relevance
- Instructor Performance
- Platform Usability
- Value, Engagement

**Hotel:**
- Room Quality, Cleanliness
- Staff Service, Friendliness
- Location, Accessibility
- Amenities, Facilities
- Value for Money

### Real-time Processing

1. Review submitted via mobile/web
2. Added to processing queue
3. ML model analyzes aspects and sentiments
4. Results stored in database
5. WebSocket notifies connected clients
6. Dashboard updates in real-time

## 🛠️ Technologies Used

### Backend
- **FastAPI** - Modern Python web framework
- **PyTorch** - Deep learning framework
- **Transformers** - Hugging Face model library
- **SQLite** - Lightweight database
- **Uvicorn** - ASGI server

### Mobile
- **Flutter** - Cross-platform framework
- **Provider** - State management
- **HTTP** - API communication
- **sqflite** - Local database

### Web
- **Vanilla JavaScript** - No frameworks
- **CSS3** - Modern styling
- **Fetch API** - HTTP requests

## 🔧 Configuration

### Backend Configuration
Edit `main.py` to adjust:
- Server host/port
- CORS origins
- Database path
- Model paths

### ML Engine Configuration
Edit `ml_engine.py` to adjust:
- Generation parameters
- GPU/CPU usage
- Model loading strategy

## 📈 Performance

- **Processing Speed**: ~2-5 seconds per review (GPU)
- **Concurrent Processing**: Asynchronous background tasks
- **Database**: Indexed queries for fast retrieval
- **Caching**: Analytics data cached to reduce computation

## 🤝 Contributing

This is a graduation project. For questions or suggestions, please open an issue.

## 📄 License

This project is part of a graduation thesis.

## 🙏 Acknowledgments

- Fine-tuned T5 models based on Google's T5-base
- ABSA methodology from recent NLP research
- Flutter framework and community
- FastAPI framework and community

## 📞 Contact

For questions or issues, please create an issue in this repository.

---

**Note**: This system requires trained ML models that are not included in this repository due to size constraints. You need to train your own models or obtain them separately.
