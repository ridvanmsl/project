# 🌍 Ngrok Setup Guide

Ngrok allows you to access your local backend from anywhere (including real mobile devices).

## 📥 Installation

### Windows:
1. Download: https://ngrok.com/download
2. Extract `ngrok.exe` to `C:\ngrok\`
3. Add to PATH or use full path

### Mac/Linux:
```bash
brew install ngrok
# or
sudo apt install ngrok
```

## 🔑 Setup (One-time)

1. Sign up: https://dashboard.ngrok.com/signup
2. Get your auth token: https://dashboard.ngrok.com/get-started/your-authtoken
3. Configure:
```bash
ngrok config add-authtoken YOUR_AUTH_TOKEN_HERE
```

## 🚀 Usage

### Step 1: Start Backend
```bash
cd review_backend
python main.py
```
Backend runs at: `http://localhost:8000`

### Step 2: Start Ngrok (New Terminal)
```bash
ngrok http 8000
```

You'll see:
```
Session Status                online
Account                       your@email.com
Version                       3.x.x
Region                        United States (us)
Forwarding                    https://abc123.ngrok-free.app -> http://localhost:8000
```

### Step 3: Use Ngrok URL

**Copy the forwarding URL:** `https://abc123.ngrok-free.app`

**Update mobile app:**
- Open: `business_review_app/lib/services/api_service.dart`
- Change:
```dart
static const String baseUrl = "https://abc123.ngrok-free.app/api";  // Your ngrok URL
```

**Update web interface:**
- Open: `review_web_interface/script.js`
- Change:
```javascript
const API_BASE_URL = "https://abc123.ngrok-free.app/api";  // Your ngrok URL
```

## ✅ Benefits

1. **Test on Real Device:** Use your actual phone instead of emulator
2. **Share with Others:** Anyone can access your backend
3. **Webhook Testing:** External services can call your API
4. **No Deployment Needed:** Test production-like environment locally

## 🔒 Security

- Ngrok URLs are **temporary** (expire when you stop ngrok)
- Free tier has **40 connections/minute** limit
- URLs change on restart (unless you pay for static URLs)
- Don't share your ngrok URL publicly if using demo accounts

## 💡 Pro Tips

### Keep Ngrok Running
```bash
# Terminal 1: Backend
cd review_backend
python main.py

# Terminal 2: Ngrok
ngrok http 8000

# Terminal 3: Mobile app
cd business_review_app
flutter run
```

### Static URL (Paid)
```bash
ngrok http 8000 --domain=your-custom-domain.ngrok-free.app
```

### Inspect Traffic
Open: http://localhost:4040 (Ngrok inspector)
- See all API requests
- Replay requests
- Debug issues

## 🐛 Troubleshooting

### "Connection Refused"
- Make sure backend is running first
- Check `python main.py` is running on port 8000

### "ERR_NGROK_6022" (Limit Reached)
- Wait 1 minute
- Or restart ngrok

### "Invalid Host Header"
- This is normal, ngrok handles it
- If persists, add to `main.py`:
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### Mobile App Can't Connect
- Check ngrok URL is correct in `api_service.dart`
- Ensure `/api` is at the end of URL
- Restart Flutter app after changing URL

## 📱 Alternative: Localhost on Same WiFi

If both your computer and phone are on the same WiFi:

```dart
// Find your computer's local IP (ipconfig on Windows, ifconfig on Mac/Linux)
static const String baseUrl = "http://192.168.1.XXX:8000/api";
```

No ngrok needed, but only works on same network.

---

**Need help?** Check: https://ngrok.com/docs

