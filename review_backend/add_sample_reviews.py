"""
Optimized sample review generator
Adds reviews using the new async API with background processing
"""
import requests
import time
import random

# Ngrok URL - change to "http://localhost:8000/api/reviews" for local testing
API_URL = "https://5fac33336699.ngrok-free.app/api/reviews"

# Sample reviews (20 per category)
FOOD_REVIEWS = [
    "The pasta was absolutely delicious! Highly recommend the carbonara.",
    "Best pizza I've ever had! The crust was perfect and toppings were fresh.",
    "Amazing food and excellent service. Will definitely come back!",
    "The steak was cooked to perfection. Great wine selection too.",
    "Fresh ingredients, great presentation, and friendly staff.",
    "The seafood platter was outstanding. Best restaurant in town!",
    "Food was cold when it arrived. Very disappointing.",
    "Overpriced for the quality. The steak was tough and bland.",
    "Terrible service. Waited 45 minutes for our food.",
    "The pasta was undercooked and sauce was watery.",
    "The chicken was dry and flavorless. Won't be back.",
    "Dirty tables and the food was mediocre at best.",
    "Great food but service was slow. Still enjoyed it overall.",
    "Nice atmosphere but the food was average. Could be better.",
    "Good pizza but the salad was wilted and sad.",
    "Excellent appetizers but the main course was disappointing.",
    "The desserts were to die for! Especially the tiramisu.",
    "Way too salty. Could barely eat my meal.",
    "Love the location but prices are too high.",
    "Delicious food, reasonable prices, and quick service."
]

HOTEL_REVIEWS = [
    "The room was spotless and very comfortable. Great stay!",
    "Amazing service! Staff went above and beyond.",
    "Beautiful location with stunning views. Highly recommend!",
    "The bed was so comfortable. Best sleep I've had in a hotel.",
    "Clean facilities and friendly staff. Will definitely return!",
    "The pool area is fantastic and well maintained.",
    "The room was dirty and the AC didn't work.",
    "Terrible experience. Room smelled musty and old.",
    "Noisy neighbors kept us up all night. No soundproofing.",
    "The beds were uncomfortable and sheets were scratchy.",
    "Rude staff and unhelpful front desk.",
    "Overpriced for what you get. Very disappointed.",
    "Great location but the room was small and dated.",
    "Friendly staff but facilities need updating.",
    "Clean room but very noisy at night.",
    "Nice pool but the gym equipment is old.",
    "Spacious rooms with modern amenities. Loved it!",
    "Excellent breakfast buffet with lots of variety.",
    "The spa services were incredible. So relaxing!",
    "Perfect location near all attractions. Very convenient."
]

COURSE_REVIEWS = [
    "Excellent content! The instructor explains everything clearly.",
    "This course changed my career. Highly recommend!",
    "Well structured and easy to follow. Great for beginners.",
    "The assignments really helped reinforce the concepts.",
    "Amazing instructor! Very knowledgeable and engaging.",
    "Perfect pacing. Not too fast, not too slow.",
    "Practical examples made complex topics simple.",
    "Great value for money. Learned so much!",
    "The course is too long and the videos are boring.",
    "Outdated information. Not relevant anymore.",
    "The instructor speaks too fast and unclear.",
    "Poor quality videos with bad audio.",
    "The assignments are way too difficult for beginners.",
    "Waste of money. Didn't learn anything new.",
    "Good content but videos could be shorter.",
    "Great material but the platform is buggy.",
    "Informative but assignments are too easy.",
    "Solid course but lacks hands-on practice.",
    "The capstone project was challenging but rewarding.",
    "Best online course I've taken. Worth every penny!"
]

CUSTOMER_NAMES = [
    "John Smith", "Emma Johnson", "Michael Brown", "Sarah Davis", "James Wilson",
    "Emily Taylor", "David Anderson", "Olivia Martinez", "Daniel Thomas", "Sophia Garcia",
    "Robert Rodriguez", "Isabella Lee", "William White", "Mia Harris", "Richard Clark",
    "Ava Lewis", "Joseph Young", "Charlotte Hall", "Thomas Allen", "Amelia King"
]


def add_review(business_id, model_type, review_text, customer_name, rating):
    """Add a single review via API"""
    try:
        data = {
            "business_id": business_id,
            "text": review_text,
            "customer_name": customer_name,
            "rating": rating,
            "model_type": model_type
        }
        
        response = requests.post(API_URL, json=data, timeout=10)
        return response.status_code == 200
    except Exception as e:
        print(f"Error: {str(e)}")
        return False


def add_reviews_batch(business_id, model_type, reviews, business_name):
    """Add multiple reviews for a business"""
    print(f"\n{'='*60}")
    print(f"Adding {len(reviews)} reviews for {business_name}")
    print(f"{'='*60}")
    
    success = 0
    for i, review_text in enumerate(reviews, 1):
        customer_name = random.choice(CUSTOMER_NAMES)
        rating = round(random.uniform(1.0, 5.0), 1)
        
        if add_review(business_id, model_type, review_text, customer_name, rating):
            success += 1
            print(f"[OK] [{i}/{len(reviews)}] {customer_name} - Rating: {rating}")
        else:
            print(f"[FAIL] [{i}/{len(reviews)}] Failed")
    
    print(f"\n[OK] Completed: {success}/{len(reviews)} reviews added")
    return success


def main():
    print("="*60)
    print("  OPTIMIZED SAMPLE REVIEW GENERATOR")
    print("  Fast async processing with background ML analysis")
    print("="*60)
    print("\nThis will add 60 reviews (20 per category)")
    print("Reviews are processed in the background - much faster!")
    print("\nUsing: https://5fac33336699.ngrok-free.app")
    print("\nPress Ctrl+C to cancel...")
    time.sleep(2)
    
    start_time = time.time()
    total_success = 0
    
    # Add Food Restaurant reviews
    total_success += add_reviews_batch(
        "amazon_business",
        "amazon",
        FOOD_REVIEWS,
        "Food Restaurant"
    )
    
    # Add Hotel reviews
    total_success += add_reviews_batch(
        "hotel_business",
        "hotel",
        HOTEL_REVIEWS,
        "Luxury Hotel"
    )
    
    # Add Course reviews
    total_success += add_reviews_batch(
        "coursera_business",
        "coursera",
        COURSE_REVIEWS,
        "Online Course Platform"
    )
    
    elapsed = time.time() - start_time
    
    print(f"\n{'='*60}")
    print("  FINAL SUMMARY")
    print(f"{'='*60}")
    print(f"Total Reviews Submitted: {total_success}/60")
    print(f"Time Taken: {elapsed:.1f} seconds (~{elapsed/60:.1f} minutes)")
    print(f"\n⚡ Reviews are being analyzed in the background!")
    print(f"   Check your mobile app to see them appear in real-time.")
    print(f"{'='*60}")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n[CANCELLED] Stopped by user")
    except Exception as e:
        print(f"\n\n[ERROR] {str(e)}")
