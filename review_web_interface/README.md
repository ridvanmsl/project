# Business Review Web Interface

Simple web interface for submitting reviews to the AI analysis system.

## Setup

1. **Make sure the backend is running:**
```bash
cd ../review_backend
python main.py
```

2. **Open the web interface:**
Simply open `index.html` in your web browser.

Or use a local server:
```bash
python -m http.server 8080
```
Then visit: `http://localhost:8080`

## Usage

1. Select the business type (Amazon, Coursera, or Hotel)
2. Optionally enter customer name and rating
3. Enter the review text
4. Click "Analyze Review"
5. The AI will analyze the review and show sentiment results
6. View recent reviews below the form

## Features

- Real-time sentiment analysis using trained ML models
- Aspect extraction from reviews
- Clean, modern UI
- Responsive design for mobile and desktop
- Recent reviews display
- Character counter for review text


