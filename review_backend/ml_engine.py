"""
Optimized ML Engine for sentiment analysis using trained models
Based on Ahsen's optimized implementation with GPU support and efficient generation
"""
import torch
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM, GenerationConfig
import os


class UniversalSentimentAnalyzer:
    """High-performance sentiment analyzer with GPU support and optimized generation"""
    
    def __init__(self, model_folder_name):

        base_path = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        model_path = os.path.join(base_path, model_folder_name)
        

        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        print(f"Loading: {model_folder_name} on {self.device}...")
        
        try:
            self.tokenizer = AutoTokenizer.from_pretrained(model_path)
            self.model = AutoModelForSeq2SeqLM.from_pretrained(model_path).to(self.device)
            self.model.eval()
            print(f"INFO: Model Ready: {model_folder_name}")
        except Exception as e:
            print(f"ERROR: {model_folder_name} could not be loaded. Path: {model_path}")
            print(f"ERROR: {e}")
            self.model = None

    def analyze(self, review_text):
        """Analyze review and extract aspect-sentiment pairs with optimized generation"""
        if not self.model:
            return {"original_review": review_text, "analysis": []}


        input_text = "absa: " + review_text
        inputs = self.tokenizer(input_text, return_tensors="pt").input_ids.to(self.device)
        

        generation_config = GenerationConfig(
            max_length=128,
            num_beams=5,
            early_stopping=True,
            repetition_penalty=2.5,
            length_penalty=1.0,
            eos_token_id=self.tokenizer.eos_token_id,
            pad_token_id=self.tokenizer.pad_token_id,
        )

        with torch.no_grad():
            outputs = self.model.generate(inputs, generation_config=generation_config)
        
        prediction = self.tokenizer.decode(outputs[0], skip_special_tokens=True)
        

        results = []
        seen = set()


        parts = prediction.replace(";", ",").split(",") 

        for piece in parts:
            if ":" in piece:
                try:
                    cat, sent = piece.split(":", 1)
                    cat = cat.strip()
                    sent = sent.strip().lower()
                    

                    if 'pos' in sent:
                        sent = 'positive'
                    elif 'neg' in sent:
                        sent = 'negative'
                    elif 'neu' in sent:
                        sent = 'neutral'
                    

                    unique_key = f"{cat}-{sent}"
                    if unique_key not in seen and sent in ['positive', 'negative', 'neutral']:
                        results.append({"category": cat, "sentiment": sent})
                        seen.add(unique_key)
                except:
                    continue
        
        return {"original_review": review_text, "analysis": results}


# Global instances (loaded once at startup for performance)
ENGINES = {}

def load_all_models():
    """Load all ML models at startup for better performance"""
    global ENGINES
    print("="*60)
    print("LOADING ML MODELS...")
    print("="*60)
    
    ENGINES = {
        "amazon": UniversalSentimentAnalyzer("amazon_model"),
        "hotel": UniversalSentimentAnalyzer("hotel_model"),
        "coursera": UniversalSentimentAnalyzer("coursera_model")
    }
    

    loaded = [name for name, engine in ENGINES.items() if engine.model is not None]
    failed = [name for name, engine in ENGINES.items() if engine.model is None]
    
    print("="*60)
    print(f"INFO: Successfully loaded: {', '.join(loaded) if loaded else 'None'}")
    if failed:
        print(f"[FAILED] Could not load: {', '.join(failed)}")
    print("="*60)
    
    return ENGINES


def get_engine(model_type: str):
    """Get the appropriate ML engine for a business type"""
    return ENGINES.get(model_type)

