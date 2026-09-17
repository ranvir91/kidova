Kidova — Small Games, Big Learning

A kid-friendly Flutter app for growing vocabulary through a daily word,
dictionary lookups, and playful word games.

## Modules

- **Word of the Day** — a new word every day with its meaning and pronunciation, from the [Word of the Day API](https://api.wotd.site).
- **Look Up a Word** — search any word using the free [Datamuse](https://www.datamuse.com/api/) API.
- **Word Games** — "Match the Meaning" (multiple choice) and "Word Scramble" (tap-to-spell), with room to add more games later.
- **My Word Jar** — save favorite words for later, stored locally on the device.
- **My Progress** — daily streaks, stars, words learned, and unlockable badges.

## Setup

1. Copy `.env.example` to `.env` (already gitignored) and adjust values if needed:
   ```
   cp .env.example .env
   ```
2. Install dependencies:
   ```
   flutter pub get
   ```
3. Run the app:
   ```
   flutter run
   ```

Configuration (API base URL, app name, request timeout) lives in `.env`,
read at startup via `flutter_dotenv` — see `lib/core/config/app_config.dart`.