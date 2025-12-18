# SwiftDating

A native SwiftUI dating + community app with a stunning black & white glass morphism aesthetic.

## Features

- **Swipe-Based Matching** - Tinder-style card deck with gesture controls
- **Browse Profiles** - Grid/list view with filters
- **Community Feed** - Twitter-style posts and discussions
- **Real-Time Chat** - Messaging between matched users
- **Proximity Discovery** - Find nearby users

## Tech Stack

- **SwiftUI** (iOS 17+)
- **Supabase** (Auth, PostgreSQL, Realtime, Storage)
- **Core Location** & **MapKit**

## Design

- Pure black & white color scheme
- Glass morphism with `.ultraThinMaterial`
- Blur effects and translucency
- SF Symbols throughout

## Setup

### 1. Clone the Repository

```bash
git clone https://github.com/gregdeveloper1/SwiftDating.git
```

### 2. Open in Xcode

Open the project folder in Xcode 15+ and let Swift Package Manager resolve dependencies.

### 3. Configure Supabase

The Supabase credentials are already configured in `Services/SupabaseClient.swift`.

### 4. Run the SQL Schema

Go to your Supabase SQL Editor and run the schema from `database/schema.sql` to create all tables.

### 5. Build & Run

Select your target device/simulator and run the app.

## Project Structure

```
NativeDating/
├── App/                    # App entry point
├── Core/
│   ├── Design/            # Theme, glass modifiers, components
│   ├── Extensions/        # View & type extensions
│   └── Utilities/         # Constants, haptics
├── Models/                # User, Match, Message, Post
├── Services/              # Supabase, Auth, Location
├── Features/
│   ├── Auth/              # Welcome, Login, SignUp
│   ├── Onboarding/        # Profile setup flow
│   ├── Discover/          # Swipe cards
│   ├── Browse/            # Grid/list views
│   ├── Profile/           # User profile
│   ├── Matches/           # Match list & chat
│   └── Community/         # Feed & posts
└── Navigation/            # Tab bar & routing
```

## Requirements

- iOS 17.0+
- iPadOS 17.0+
- macOS 14.0+ (Designed for iPad)
- Xcode 15.0+

## License

MIT License
