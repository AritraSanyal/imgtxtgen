# imgtxtgen

AI-powered advertisement generator using Claude API. Create compelling ad copy, hashtags, and image prompts for social media platforms.

## Features

- **Multi-platform support**: Generate ads for Instagram, Facebook, Twitter, and LinkedIn
- **Multiple formats**: Square, Story, Banner, and Portrait layouts
- **AI-generated content**: Headlines, body copy, and hashtags powered by Claude
- **Image prompt generation**: Get AI-generated prompts for creating ad visuals
- **Business profile**: Store your brand details for consistent ad generation
- **History tracking**: View and reuse your previously generated ads

## Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd imgtxtgen
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure environment variables:
   - Create a `.env` file in the project root
   - Add your Claude API key:
     ```
     CLAUDE_API_KEY=your-api-key-here
     ```

4. Run the app:
   ```bash
   flutter run
   ```

## Usage

1. **Set up your business profile** (Profile tab) with your brand name, description, and tone
2. **Create an ad** (Create tab):
   - Enter your ad prompt describing what you want to promote
   - Select target platform (Instagram, Facebook, Twitter, LinkedIn)
   - Choose format (Square, Story, Banner, Portrait)
   - Toggle options for hashtags and image prompt generation
3. **Preview and export** your generated ad
4. **View history** of all generated ads in the History tab

## Tech Stack

- Flutter with Riverpod for state management
- Claude API for AI generation
- SharedPreferences for local storage
- Google Fonts for typography

## Project Structure

```
lib/
├── main.dart           # App entry point
├── models/            # Data models (AdRequest, GeneratedAd, BusinessProfile)
├── providers/         # Riverpod providers for state management
├── screens/           # UI screens (Create, Preview, History, Profile, Settings)
├── services/          # API and storage services
└── widgets/           # Reusable UI components
```

## Requirements

- Flutter SDK 3.11+
- Valid Claude API key
