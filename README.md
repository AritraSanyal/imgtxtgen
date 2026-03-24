# AdGen Flutter

![Flutter](https://img.shields.io/badge/Flutter-3.11+-02569B?style=flat-square&logo=flutter)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

AI-powered advertisement generator using Claude API. Create compelling ad copy, hashtags, and image prompts for social media platforms.

## Features

- **Multi-platform support**: Generate ads for Instagram, Facebook, Twitter/X, and LinkedIn
- **Multiple formats**: Square, Story, Banner, and Portrait layouts
- **AI-generated content**: Headlines, body copy, CTAs, and hashtags powered by Claude Sonnet 4
- **Image prompt generation**: Get AI-generated prompts for creating ad visuals
- **Business profile**: Store your brand details, target audience, and tone for consistent ad generation
- **History tracking**: View, reuse, and manage your previously generated ads
- **Field regeneration**: Regenerate individual fields (headline, body, hashtags) without regenerating the entire ad

## Screenshots

The app features a 4-tab navigation:
- **Profile**: Set up your business name, industry, tagline, brand tones, target audience, and key benefits
- **Create**: Generate new ads with platform/format selection and content options
- **History**: Browse and manage all previously generated ads
- **Settings**: Configure app preferences

## Installation

### Prerequisites

- Flutter SDK 3.11 or higher
- A valid Anthropic API key (Claude API)

### Setup

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd adgen_flutter
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure environment variables:
   Create a `.env` file in the project root:
   ```
   ANTHROPIC_API_KEY=your_anthropic_api_key_here
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Usage

### Setting Up Your Profile

Before generating ads, configure your business profile (Profile tab):
- **Business Name**: Your brand or company name
- **Industry**: Your business industry
- **Tagline**: Your brand tagline (optional)
- **Brand Tones**: e.g., professional, friendly, playful, luxury
- **Target Audience**: Age range, gender focus, interests
- **Key Benefits**: What makes your product/service valuable
- **Current Product**: The product/service you're advertising

### Creating an Ad

1. Go to the **Create** tab
2. Enter your ad prompt describing what you want to promote
3. Select target **Platform** (Instagram, Facebook, Twitter/X, LinkedIn)
4. Choose **Format** (Square, Story, Banner, Portrait)
5. Toggle options:
   - Include **Hashtags**
   - **Image Prompt** generation
   - **Apply Brand Tone**
6. Tap **Generate** and wait for Claude to create your ad
7. Preview the generated ad with full details
8. **Regenerate** individual fields if needed, or **Export** the ad

### Viewing History

All generated ads are saved to History tab where you can:
- View ad details
- Copy content to clipboard
- Delete old ads

## Architecture

### State Management

Uses **Riverpod** with multiple state notifiers:

| Provider | Type | Purpose |
|----------|------|---------|
| `profileProvider` | `StateNotifier` | Business profile data |
| `adHistoryProvider` | `StateNotifier` | List of generated ads |
| `generationProvider` | `StateNotifier` | Ad generation state |
| `adRequestProvider` | `StateNotifier` | Current ad request form |
| `currentAdProvider` | `StateProvider` | Ad being viewed/edited |

### Data Models

```
AdRequest          - User's ad generation request
GeneratedAd        - Complete generated ad with all fields
BusinessProfile    - Brand and audience configuration
```

### Services

- **ClaudeService**: Handles API communication with Anthropic's Claude API
- **StorageService**: Persists data to local storage using SharedPreferences

## Project Structure

```
lib/
├── main.dart              # App entry point with ProviderScope
├── models/
│   ├── ad_models.dart     # AdRequest, GeneratedAd, enums
│   └── business_profile.dart  # BusinessProfile model
├── providers/
│   └── providers.dart     # All Riverpod providers
├── screens/
│   ├── main_shell.dart    # Bottom navigation shell
│   ├── profile_screen.dart
│   ├── create_screen.dart
│   ├── preview_screen.dart
│   ├── history_screen.dart
│   └── settings_screen.dart
├── services/
│   ├── claude_service.dart   # Anthropic API integration
│   └── storage_service.dart  # Local persistence
└── widgets/
    ├── ad_preview_card.dart
    ├── section_card.dart
    └── tag_input_field.dart
```

## Tech Stack

| Technology | Purpose |
|------------|---------|
| Flutter | UI framework |
| Riverpod | State management |
| Anthropic Claude API | AI content generation |
| SharedPreferences | Local data persistence |
| Google Fonts | Typography |
| http | API requests |
| flutter_dotenv | Environment variables |

## API Details

- **Model**: Claude Sonnet 4 (`claude-sonnet-4-20250514`)
- **Endpoint**: `https://api.anthropic.com/v1/messages`
- **Max Tokens**: 1024 for ad generation, 256 for field regeneration

## Requirements

- Flutter SDK 3.11+
- Valid Anthropic API key with available credits

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Feel free to submit issues and pull requests.
