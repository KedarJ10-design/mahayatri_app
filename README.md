# Mahayatri - Your Smart Travel Companion 🏔️

A premium mobile application for exploring Maharashtra's rich cultural heritage, booking local guides, finding authentic stays, and planning AI-powered itineraries.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter 3.x / Dart 3.x |
| State Management | Riverpod |
| Navigation | GoRouter |
| Backend | Supabase (Auth + PostgreSQL + Realtime + Storage) |
| AI | Firebase AI Logic / Gemini |
| Payments | Razorpay |
| Maps | Google Maps Flutter SDK |
| Monitoring | Sentry + Firebase Analytics |

## Getting Started

### Prerequisites
- Flutter SDK 3.35+
- Dart SDK 3.9+
- Android Studio or VS Code with Flutter extensions

### Setup

1. Clone the repository:
```bash
git clone https://github.com/KedarJ10-design/mahayatri_app.git
cd mahayatri_app
```

2. Copy environment config:
```bash
cp .env.example .env
# Fill in your Supabase URL and anon key
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run code generation:
```bash
dart run build_runner build --delete-conflicting-outputs
```

5. Run the app:
```bash
flutter run
```

## Architecture

```
lib/
├── main.dart                    # Entry point
├── app.dart                     # Root MaterialApp widget
├── core/                        # App-wide infrastructure
│   ├── config/                  # Environment configuration
│   ├── constants/               # Constants & enums
│   ├── extensions/              # Dart extensions
│   ├── router/                  # GoRouter configuration
│   ├── theme/                   # Design system (colors, typography, theme)
│   └── utils/                   # Validators, logger, helpers
├── features/                    # Feature modules (domain-driven)
│   ├── auth/                    # Authentication
│   ├── home/                    # Home screen
│   ├── explore/                 # Explore/search
│   ├── planner/                 # AI trip planner
│   ├── booking/                 # Booking & payments
│   ├── chat/                    # Messaging
│   ├── profile/                 # User profile
│   ├── safety/                  # SOS & safety
│   ├── guide_dashboard/         # Guide-specific UI
│   └── admin/                   # Admin panel
├── shared/                      # Reusable components
│   ├── widgets/                 # Common widgets
│   └── models/                  # Shared data models
└── services/                    # Service layer (Supabase, etc.)
```

Each feature follows the structure:
```
feature/
├── data/        # Repositories, API calls
├── domain/      # Models, entities (Freezed)
├── providers/   # Riverpod providers
└── ui/
    ├── screens/ # Full page screens
    └── widgets/ # Feature-specific widgets
```

## Design System

- **Primary**: Deep Forest Green (`#1B4332`) — Western Ghats
- **Accent**: Sunset Orange (`#E07A5F`) — Arabian Sea sunsets
- **Background**: Soft Sand (`#F4F1DE`) — Konkan beaches
- **Typography**: Inter (UI) + Playfair Display (display)

## License

This project is proprietary. All rights reserved.
