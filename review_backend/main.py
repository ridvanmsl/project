"""
FastAPI backend for business review analysis system
Optimized version with WebSocket support, async processing, and PostgreSQL
"""
from fastapi import FastAPI, HTTPException, BackgroundTasks, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional, Set
from contextlib import asynccontextmanager
import psycopg2
from psycopg2.extras import RealDictCursor
import datetime
from datetime import timedelta
import threading
import time
import asyncio
import uuid
import json
from ml_engine import load_all_models, get_engine
from db_config import get_db_connection, get_direct_connection, create_database_if_not_exists

# Database configuration handled by db_config.py


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Lifespan event handler for startup and shutdown"""
    # Startup
    print("="*60)
    print("STARTING BUSINESS REVIEW ANALYSIS API v2.0")
    print("="*60)
    
    # Initialize database
    init_db()
    
    # Load ML models
    load_all_models()
    
    # Start background processor
    print("Starting background review processor...")
    threading.Thread(target=background_review_processor, daemon=True).start()
    
    print("="*60)
    print("[OK] API READY!")
    print("="*60)
    
    yield
    
    # Shutdown (if needed)
    print("Shutting down...")


# Initialize FastAPI app with lifespan
app = FastAPI(
    title="Business Review Analysis API",
    description="AI-powered review analysis with real-time updates",
    version="2.0.0",
    lifespan=lifespan
)

# CORS middleware for web and mobile access
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Business accounts (email, password, name, type, business_id)
BUSINESS_ACCOUNTS = {
    "food@business.com": {
        "password": "food123",
        "name": "Food Restaurant",
        "type": "amazon",  # Amazon model for food/restaurant
        "business_id": "amazon_business"
    },
    "hotel@business.com": {
        "password": "hotel123",
        "name": "Luxury Hotel",
        "type": "hotel",  # Hotel model for hospitality
        "business_id": "hotel_business"
    },
    "coursera@business.com": {
        "password": "course123",
        "name": "Online Course Platform",
        "type": "coursera",  # Coursera model for education
        "business_id": "coursera_business"
    }
}


class ConnectionManager:
    """WebSocket connection manager for real-time updates"""
    
    def __init__(self):
        self.active_connections: Set[WebSocket] = set()
    
    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.add(websocket)
        print(f"[OK] WebSocket connected. Total: {len(self.active_connections)}")
    
    def disconnect(self, websocket: WebSocket):
        self.active_connections.discard(websocket)
        print(f"[X] WebSocket disconnected. Total: {len(self.active_connections)}")
    
    async def broadcast(self, message: dict):
        """Broadcast message to all connected clients"""
        if not self.active_connections:
            return
        
        disconnected = []
        for connection in self.active_connections:
            try:
                await connection.send_json(message)
            except Exception as e:
                print(f"Error broadcasting: {e}")
                disconnected.append(connection)
        
        # Clean up disconnected clients
        for conn in disconnected:
            self.disconnect(conn)


manager = ConnectionManager()


def init_db():
    """Initialize PostgreSQL database with required tables"""
    try:
        # Create database if it doesn't exist
        create_database_if_not_exists()
        
        # Get connection
        conn = get_direct_connection()
        cursor = conn.cursor()
        
        # Businesses table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS businesses (
                id VARCHAR(255) PRIMARY KEY,
                name VARCHAR(255) NOT NULL,
                type VARCHAR(100),
                description TEXT,
                image_url VARCHAR(500),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        # Users table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS users (
                id SERIAL PRIMARY KEY,
                email VARCHAR(255) NOT NULL UNIQUE,
                password VARCHAR(255) NOT NULL,
                business_id VARCHAR(255) NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (business_id) REFERENCES businesses(id)
            )
        ''')
        
        # Reviews table (one row per review with overall sentiment)
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS reviews (
                id VARCHAR(255) PRIMARY KEY,
                business_id VARCHAR(255) NOT NULL,
                text TEXT NOT NULL,
                customer_name VARCHAR(255),
                rating FLOAT,
                date TIMESTAMP,
                overall_sentiment VARCHAR(50)
            )
        ''')
        
        # Aspect sentiments table (many aspects per review)
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS aspect_sentiments (
                id SERIAL PRIMARY KEY,
                review_id VARCHAR(255) NOT NULL,
                aspect_term VARCHAR(255),
                category VARCHAR(100),
                sentiment VARCHAR(50),
                FOREIGN KEY (review_id) REFERENCES reviews(id)
            )
        ''')
        
        # Raw reviews table (queue for processing)
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS raw_reviews (
                id SERIAL PRIMARY KEY,
                business_id VARCHAR(255) NOT NULL,
                review_text TEXT NOT NULL,
                customer_name VARCHAR(255),
                rating FLOAT,
                date TIMESTAMP,
                status VARCHAR(50) DEFAULT 'pending',
                model_type VARCHAR(100),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        # Analytics table (cached analytics data)
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS analytics (
                id SERIAL PRIMARY KEY,
                business_id VARCHAR(255) NOT NULL,
                analytics_data JSONB,
                generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                period VARCHAR(50) DEFAULT 'weekly'
            )
        ''')
        
        # Insert demo businesses if not exist
        cursor.execute("SELECT COUNT(*) FROM businesses")
        if cursor.fetchone()[0] == 0:
            demo_businesses = [
                ('amazon_business', 'Food Restaurant', 'food', 'Local food restaurant with great reviews', ''),
                ('hotel_business', 'Luxury Hotel', 'hotel', 'Premium hotel with excellent service', ''),
                ('coursera_business', 'Online Course Platform', 'education', 'Top-rated online education platform', '')
            ]
            for biz in demo_businesses:
                cursor.execute(
                    "INSERT INTO businesses (id, name, type, description, image_url) VALUES (%s, %s, %s, %s, %s)",
                    biz
                )
            print("[OK] Demo businesses created")
        
        # Insert demo users if not exist
        cursor.execute("SELECT COUNT(*) FROM users")
        if cursor.fetchone()[0] == 0:
            demo_users = [
                ('food@demo.com', 'password123', 'amazon_business'),
                ('hotel@demo.com', 'password123', 'hotel_business'),
                ('course@demo.com', 'password123', 'coursera_business')
            ]
            for user in demo_users:
                cursor.execute(
                    "INSERT INTO users (email, password, business_id) VALUES (%s, %s, %s)",
                    user
                )
            print("[OK] Demo users created")
        
        conn.commit()
        cursor.close()
        conn.close()
        print("[OK] PostgreSQL database initialized")
        
    except Exception as e:
        print(f"[ERROR] Database initialization failed: {e}")
        import traceback
        traceback.print_exc()
        raise


# Pydantic models
class LoginRequest(BaseModel):
    email: str
    password: str


class ReviewInput(BaseModel):
    business_id: str
    text: str
    customer_name: Optional[str] = "Anonymous"
    rating: Optional[float] = 0.0
    model_type: str


# API Endpoints

@app.post("/api/login")
async def login(data: LoginRequest):
    """Authenticate business owner"""
    account = BUSINESS_ACCOUNTS.get(data.email)
    if not account or account["password"] != data.password:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    return {
        "success": True,
        "user": {
            "email": data.email,
            "name": account["name"]
        },
        "business": {
            "id": account["business_id"],
            "name": account["name"],
            "type": account["type"]
        }
    }


@app.get("/api/demo-accounts")
async def get_demo_accounts():
    """Get list of demo accounts for login screen"""
    accounts = []
    for email, account in BUSINESS_ACCOUNTS.items():
        accounts.append({
            "email": email,
            "password": account["password"],
            "businessName": account["name"],
            "businessType": account["type"]
        })
    return accounts


@app.get("/api/businesses/{business_id}/reviews")
async def get_reviews(business_id: str, sentiment: Optional[str] = None):
    """Get all reviews for a business with optional sentiment filter"""
    try:
        conn = get_direct_connection()
        cursor = conn.cursor()
        
        # Join with aspect_sentiments to get categories and sentiments
        query = '''
            SELECT DISTINCT r.id, r.text, a.category, a.sentiment, r.date, r.customer_name, r.rating, r.overall_sentiment
            FROM reviews r
            LEFT JOIN aspect_sentiments a ON r.id = a.review_id
            WHERE r.business_id = %s
        '''
        params = [business_id]
        
        if sentiment and sentiment != "all":
            query += " AND a.sentiment = %s"
            params.append(sentiment.lower())
        
        query += " ORDER BY r.date DESC, r.id DESC"
        
        cursor.execute(query, params)
        rows = cursor.fetchall()
        cursor.close()
        conn.close()
        
        # Group by review text to get all aspects for each review
        reviews_dict = {}
        for row in rows:
            review_id, text, category, aspect_sent, date, customer, rating, overall_sent = row
            
            if text not in reviews_dict:
                reviews_dict[text] = {
                    "id": review_id,
                    "text": text,
                    "customerName": customer or "Anonymous",
                    "rating": rating or 0.0,
                    "date": date,
                    "aspects": [],
                    "overallSentiment": overall_sent or "neutral"
                }
            
            if category and aspect_sent:
                reviews_dict[text]["aspects"].append({
                    "category": category,
                    "sentiment": aspect_sent
                })
        
        return list(reviews_dict.values())
    except Exception as e:
        print(f"[ERROR] /reviews endpoint: {type(e).__name__}: {e}")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/businesses/{business_id}/stats")
async def get_business_stats(business_id: str):
    """Get dashboard statistics for a business"""
    conn = get_direct_connection()
    cursor = conn.cursor()
    
    # Get unique reviews count (using 'text' column, not 'review_text')
    cursor.execute(
        "SELECT COUNT(*) FROM reviews WHERE business_id = %s",
        (business_id,)
    )
    total_reviews = cursor.fetchone()[0]
    
    # Get sentiment breakdown using overall_sentiment field (using 'text' column)
    cursor.execute(
        "SELECT overall_sentiment FROM reviews WHERE business_id = %s",
        (business_id,)
    )
    rows = cursor.fetchall()
    
    # Count reviews by overall sentiment (not aspect sentiment!)
    positive = negative = neutral = 0
    for (overall_sentiment,) in rows:
        sent = (overall_sentiment or "neutral").lower()
        if sent == "positive":
            positive += 1
        elif sent == "negative":
            negative += 1
        else:
            neutral += 1
    
    # Get 7-day trend
    trend_data = []
    today = datetime.date.today()
    for i in range(6, -1, -1):
        target_date = today - timedelta(days=i)
        date_str = target_date.strftime("%Y-%m-%d")
        
        cursor.execute(
            "SELECT COUNT(*) FROM reviews WHERE business_id = %s AND DATE(date) = %s AND overall_sentiment = 'positive'",
            (business_id, date_str)
        )
        daily_positive = cursor.fetchone()[0]
        trend_data.append(daily_positive)
    
    cursor.close()
    conn.close()
    
    return {
        "totalReviews": total_reviews,
        "positive": positive,
        "negative": negative,
        "neutral": neutral,
        "trend": trend_data
    }


@app.post("/api/reviews")
async def add_review(data: ReviewInput, background_tasks: BackgroundTasks):
    """Add a new review (queued for async processing)"""
    try:
        conn = get_direct_connection()
        cursor = conn.cursor()
        
        date_str = datetime.datetime.now().strftime("%Y-%m-%d")
        timestamp = datetime.datetime.now()
        
        # Add to raw_reviews queue
        cursor.execute('''
            INSERT INTO raw_reviews 
            (business_id, review_text, customer_name, rating, date, status, model_type, created_at)
            VALUES (%s, %s, %s, %s, %s, 'pending', %s, %s)
            RETURNING id
        ''', (data.business_id, data.text, data.customer_name, data.rating, date_str, data.model_type, timestamp))
        
        raw_review_id = cursor.fetchone()[0]
        conn.commit()
        cursor.close()
        conn.close()
        
        # Notify connected clients
        try:
            await manager.broadcast({
                "type": "new_review",
                "message": "New review received!",
                "data": {
                    "id": raw_review_id,
                    "business_id": data.business_id,
                    "customer_name": data.customer_name,
                    "rating": data.rating,
                    "preview": data.text[:100] + "..." if len(data.text) > 100 else data.text,
                    "status": "pending"
                }
            })
        except Exception as e:
            print(f"Warning: Broadcast failed: {e}")
        
        # Process review in background
        background_tasks.add_task(process_review, raw_review_id)
        
        return {
            "success": True,
            "message": "Review received! Analysis in progress...",
            "review_id": raw_review_id
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error adding review: {str(e)}")


@app.get("/api/businesses/{business_id}/analytics")
async def get_analytics(business_id: str):
    """Get AI-generated analytics for a business"""
    conn = get_direct_connection()
    cursor = conn.cursor()
    
    # Get all reviews for this business (using correct column names: 'text', not 'review_text')
    cursor.execute(
        "SELECT id, text, overall_sentiment FROM reviews WHERE business_id = %s",
        (business_id,)
    )
    reviews = cursor.fetchall()
    
    if not reviews:
        conn.close()
        return {
            "totalReviews": 0,
            "topIssues": [],
            "recommendations": [],
            "categoryBreakdown": [],
            "positiveCount": 0,
            "negativeCount": 0,
            "neutralCount": 0
        }
    
    # Calculate overall sentiment counts using overall_sentiment field (not aspect sentiments!)
    overall_positive = overall_negative = overall_neutral = 0
    for review_id, text, overall_sentiment in reviews:
        sent = (overall_sentiment or "neutral").lower()
        if sent == "positive":
            overall_positive += 1
        elif sent == "negative":
            overall_negative += 1
        else:
            overall_neutral += 1
    
    # Analyze categories from aspect_sentiments table (not reviews table!)
    cursor.execute('''
        SELECT a.category, a.sentiment
        FROM aspect_sentiments a
        JOIN reviews r ON a.review_id = r.id
        WHERE r.business_id = %s
    ''', (business_id,))
    aspect_rows = cursor.fetchall()
    
    category_stats = {}
    for category, sentiment in aspect_rows:
        if not category:
            continue
        if category not in category_stats:
            category_stats[category] = {"positive": 0, "negative": 0, "neutral": 0}
        
        sent = sentiment.lower() if sentiment else "neutral"
        if sent in category_stats[category]:
            category_stats[category][sent] += 1
    
    # Find top issues (categories with most negative sentiment)
    top_issues = []
    for category, stats in sorted(category_stats.items(), key=lambda x: x[1]["negative"], reverse=True)[:5]:
        if stats["negative"] > 0:
            # Count unique reviews with this negative aspect (JOIN with aspect_sentiments)
            cursor.execute('''
                SELECT COUNT(DISTINCT r.id)
                FROM reviews r
                JOIN aspect_sentiments a ON r.id = a.review_id
                WHERE r.business_id = %s AND a.category = %s AND a.sentiment = 'negative'
            ''', (business_id, category))
            unique_review_count = cursor.fetchone()[0]
            
            # Get example reviews for this issue (unique reviews only)
            cursor.execute('''
                SELECT DISTINCT r.id, r.customer_name, r.text, r.date 
                FROM reviews r
                JOIN aspect_sentiments a ON r.id = a.review_id
                WHERE r.business_id = %s AND a.category = %s AND a.sentiment = 'negative'
                ORDER BY r.date DESC
            ''', (business_id, category))
            example_reviews = cursor.fetchall()
            
            examples = []
            for (review_id, customer_name, review_text, review_date) in example_reviews:
                examples.append({
                    "term": category,
                    "review_text": review_text[:100] + "..." if len(review_text) > 100 else review_text
                })
            
            top_issues.append({
                "category": category,
                "count": unique_review_count,  # Use unique review count, not aspect mention count
                "severity": "high" if unique_review_count > 10 else "medium" if unique_review_count > 5 else "low",
                "examples": examples
            })
    
    # Generate recommendations based on issues
    recommendations = []
    for issue in top_issues[:3]:
        recommendations.append(
            f"Address {issue['category']} complaints - {issue['count']} customer{' complains' if issue['count'] > 1 else ' complains'} detected"
        )
    
    # Category breakdown
    category_breakdown = []
    for category, stats in category_stats.items():
        total = sum(stats.values())
        category_breakdown.append({
            "name": category,
            "positive": stats["positive"],
            "negative": stats["negative"],
            "neutral": stats["neutral"],
            "total": total
        })
    
    cursor.close()
    conn.close()
    
    return {
        "totalReviews": len(reviews),
        "positiveCount": overall_positive,
        "negativeCount": overall_negative,
        "neutralCount": overall_neutral,
        "topIssues": top_issues,
        "recommendations": recommendations,
        "categoryBreakdown": category_breakdown
    }


@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    """WebSocket endpoint for real-time updates"""
    await manager.connect(websocket)
    try:
        while True:
            data = await websocket.receive_text()
            if data == "ping":
                await websocket.send_text("pong")
    except WebSocketDisconnect:
        manager.disconnect(websocket)


def process_review(raw_review_id: int):
    """Process a review through ML model (runs in background)"""
    try:
        conn = get_direct_connection()
        cursor = conn.cursor()
        
        # Get review from queue
        cursor.execute('''
            SELECT business_id, review_text, customer_name, rating, date, model_type
            FROM raw_reviews 
            WHERE id = %s AND status = 'pending'
        ''', (raw_review_id,))
        
        row = cursor.fetchone()
        if not row:
            cursor.close()
            conn.close()
            return
        
        business_id, review_text, customer_name, rating, date_str, model_type = row
        
        # Get ML engine and analyze
        engine = get_engine(model_type)
        if engine and engine.model:
            result = engine.analyze(review_text)
            analysis_items = result.get("analysis", [])
        else:
            analysis_items = []
        
        # Determine dominant sentiment (overall_sentiment)
        dominant_sentiment = "neutral"
        if analysis_items:
            sentiment_counts = {"positive": 0, "negative": 0, "neutral": 0}
            for item in analysis_items:
                sent = item.get("sentiment", "neutral").lower()
                if sent in sentiment_counts:
                    sentiment_counts[sent] += 1
            
            max_sent = max(sentiment_counts, key=sentiment_counts.get)
            if sentiment_counts[max_sent] > 0:
                dominant_sentiment = max_sent
        
        # Save review to reviews table (using correct schema: id, business_id, text, customer_name, rating, date, overall_sentiment)
        review_id = str(uuid.uuid4())
        cursor.execute('''
            INSERT INTO reviews 
            (id, business_id, text, customer_name, rating, date, overall_sentiment)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        ''', (review_id, business_id, review_text, customer_name, rating, date_str, dominant_sentiment))
        
        # Save aspects to aspect_sentiments table
        if analysis_items:
            for item in analysis_items:
                cursor.execute('''
                    INSERT INTO aspect_sentiments 
                    (review_id, aspect_term, category, sentiment)
                    VALUES (%s, %s, %s, %s)
                ''', (review_id, item.get("term", ""), item.get("category", "general"), item.get("sentiment", "neutral")))
        
        # Mark as completed
        cursor.execute("UPDATE raw_reviews SET status = 'completed' WHERE id = %s", (raw_review_id,))
        conn.commit()
        cursor.close()
        conn.close()
        
        print(f"[OK] Review {raw_review_id} processed: {len(analysis_items)} aspects found")
        
        # Broadcast completion
        asyncio.run(manager.broadcast({
            "type": "review_analyzed",
            "message": "Review analysis completed!",
            "data": {
                "id": raw_review_id,
                "business_id": business_id,
                "customer_name": customer_name,
                "rating": rating,
                "preview": review_text[:100] + "..." if len(review_text) > 100 else review_text,
                "aspect_count": len(analysis_items),
                "sentiment": dominant_sentiment
            }
        }))
        
    except Exception as e:
        print(f"[ERROR] Processing review {raw_review_id}: {str(e)}")
        try:
            conn = get_direct_connection()
            cursor = conn.cursor()
            cursor.execute("UPDATE raw_reviews SET status = 'failed' WHERE id = %s", (raw_review_id,))
            conn.commit()
            cursor.close()
            conn.close()
        except:
            pass


def background_review_processor():
    """Background thread to process pending reviews"""
    while True:
        try:
            conn = get_direct_connection()
            cursor = conn.cursor()
            
            # Get up to 5 pending reviews
            cursor.execute('''
                SELECT id FROM raw_reviews 
                WHERE status = 'pending' 
                ORDER BY created_at ASC 
                LIMIT 5
            ''')
            pending = cursor.fetchall()
            cursor.close()
            conn.close()
            
            if pending:
                for (raw_id,) in pending:
                    threading.Thread(target=process_review, args=(raw_id,), daemon=True).start()
            
            time.sleep(5)  # Check every 5 seconds
            
        except Exception as e:
            print(f"Background processor error: {str(e)}")
            time.sleep(5)


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
