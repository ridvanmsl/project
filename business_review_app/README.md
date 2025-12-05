# Business Review Analytics App

A modern Flutter mobile application for businesses to analyze customer reviews using Aspect-Based Sentiment Analysis (ABSA).

## Features

- 🔐 **Authentication**: Simple login system
- 📊 **Dashboard**: Real-time review statistics and sentiment analysis
- 💬 **Reviews Management**: View, search, and filter customer reviews
- 🔍 **Detailed Analysis**: Aspect-based sentiment breakdown for each review
- 🌍 **Multi-language**: English and Turkish language support
- 🎨 **Modern UI**: Clean, professional design with custom color palette

## Color Palette

- `#E6FAFC` - Light Cyan (Backgrounds, highlights)
- `#9CFC97` - Light Green (Secondary actions)
- `#6BA368` - Medium Green (Primary brand color)
- `#515B3A` - Dark Olive (Secondary text)
- `#353D2F` - Dark Gray (Primary text)

## Project Structure

```
lib/
├── core/
│   ├── theme/           # App theme and colors
│   └── localization/    # Language translations
├── models/              # Data models
├── providers/           # State management
├── screens/             # App screens
│   ├── login/
│   ├── main/
│   ├── dashboard/
│   ├── reviews/
│   └── settings/
├── data/                # Mock data
└── utils/               # Utility functions
```

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / VS Code
- Android Emulator or iOS Simulator

### Installation

1. Clone the repository
```bash
cd business_review_app
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

## Demo Credentials

```
Email: demo@business.com
Password: demo123
```

## Mock Data

The app uses mock data based on the M-ABSA (Multilingual Aspect-Based Sentiment Analysis) dataset structure. All reviews and analysis data are currently hardcoded for demonstration purposes.

### Dataset Structure

- **Domains**: Restaurant, Hotel, Food, Laptop, Phone, Coursera, Sight
- **Languages**: 21 languages including English and Turkish
- **Analysis Format**: `[aspect_term, category, sentiment_polarity]`

Example:
```
"The food was amazing but service was slow."
[['food', 'food_quality', 'positive'], ['service', 'service_general', 'negative']]
```

## Features Breakdown

### 1. Login Screen
- Email/Password authentication (mock)
- Language selector (EN/TR)
- Modern, clean design

### 2. Dashboard
- Total reviews count
- Sentiment distribution (Positive/Negative/Neutral)
- Interactive pie chart
- Recent reviews preview

### 3. Reviews Screen
- Full list of all reviews
- Search functionality
- Filter by sentiment
- Quick access to details

### 4. Review Detail Screen
- Full review text
- Customer information
- Overall sentiment
- Aspect-based analysis breakdown
- Category classification

### 5. Settings Screen
- Language selection
- Account information
- App version
- Logout functionality

## State Management

The app uses the **Provider** package for state management:

- `AuthProvider`: Manages authentication state
- `LanguageProvider`: Handles language switching and persistence

## Localization

Supports English (EN) and Turkish (TR) with easy-to-extend localization system in `app_localization.dart`.

## Future Integration Points

The app is designed to easily integrate with:

1. **Backend API**: Replace mock data with real API calls
2. **ML Model**: Connect to sentiment analysis model endpoints
3. **Database**: Store business and review data
4. **Authentication**: Implement real auth system (Firebase, custom backend)
5. **Real-time Updates**: Add WebSocket support for live review updates

## Dependencies

- **flutter**: SDK
- **provider**: State management
- **google_fonts**: Custom fonts (Inter)
- **fl_chart**: Charts and data visualization
- **intl**: Internationalization and date formatting
- **shared_preferences**: Local data persistence

## Design Philosophy

- **Clean Architecture**: Separation of concerns
- **Reusable Widgets**: Component-based structure
- **No Code Repetition**: DRY principle
- **Commented Code**: Important sections are documented
- **Modern UI/UX**: Material Design 3 principles

## License

This project is created for educational purposes as a graduation project.

## Contributing

This is a graduation project and not open for contributions at this time.

