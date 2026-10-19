# My Memory Box

A spaced repetition flashcard application built with Flutter. It implements a 9-level Leitner system (Box 0 to Box 8) based on powers of two (2^0 to 2^8 days). Available across mobile and web platforms, with offline-first Progressive Web App (PWA) deployment support for iOS.

---

## Features

* **Daily Review:** One review session per day with every due card. Shows the number of cards to review, an estimated duration, the next upcoming review, and today's results once done.
* **Review session:** Tap a card to flip it, then swipe right (Remembered) or left (Forgot), or use the buttons. Cards alternate between front and back prompts. Leaving the session early keeps the answers already given. A summary (promoted, demoted, time spent, success rate) ends the session.
* **Streak & Activity:** A 🔥 streak counts consecutive days with the review done; days with nothing due count as done. The Activity bar shows the last 4 days, today and the next 3 days.
* **My Boxes:** Overview of the 9 Leitner boxes with card counts and intervals. Opening a box lists its cards.
* **My Cards:** List of all flashcards with live search, filters (due cards, per box), sorting (review date, box, alphabetical, creation date, ascending or descending), and a selection mode to move or delete several cards at once.
* **Card editing:** Create, edit, move to another box, or delete a card. Duplicate cards (same front and back, ignoring case) are refused.
* **CSV import/export:** Export all cards to a CSV file and import cards from one (duplicates are skipped).
* **Theme:** 6 theme colors and System / Light / Dark mode.
* **Offline-First Storage:** Persists cards, review history, streak and preferences locally via shared_preferences (IndexedDB on Web).
* **Cross-Platform PWA:** Usable as an installable full-screen web app on iOS Safari, Android, and Desktop browsers.
* **Automated CI/CD:** Auto-deployed to GitHub Pages via GitHub Actions on push to master.

---

## Leitner Review Intervals

A remembered card moves up one box; a forgotten card goes back to Box 0. New cards start in Box 0 and are first reviewed the next day.

| Box | Power of Two | Interval |
| :--- | :--- | :--- |
| **Box 0** | 2^0 | 1 day |
| **Box 1** | 2^1 | 2 days |
| **Box 2** | 2^2 | 4 days |
| **Box 3** | 2^3 | 8 days |
| **Box 4** | 2^4 | 16 days |
| **Box 5** | 2^5 | 32 days |
| **Box 6** | 2^6 | 64 days |
| **Box 7** | 2^7 | 128 days |
| **Box 8** | 2^8 | 256 days |

---

## CSV Format

```csv
front,back,level,next_review_date,reversed
chat,cat,0,2026-10-20,false
```

* `front` and `back` are required; the other columns are optional (defaults: box 0, review tomorrow, not reversed).
* `level` is a box number from 0 to 8.
* `next_review_date` accepts `YYYY-MM-DD` or `DD/MM/YYYY`.
* Comma, semicolon and tab delimiters are detected automatically.

---

## Project Structure

```text
lib/
├── main.dart                     # Application entry point, theme state & color list
├── models/
│   └── flashcard.dart            # Flashcard data model, Leitner logic & duplicate check
├── screens/
│   ├── home_screen.dart          # Main navigation host (Daily Review, Cards, Boxes, Settings)
│   ├── review_screen.dart        # Interactive study session & summary
│   ├── card_list_screen.dart     # Searchable, filterable card list with multi-selection
│   ├── box_detail_screen.dart    # Cards of a single box
│   ├── create_card_screen.dart   # Card authoring screen
│   └── settings_screen.dart      # Theme, CSV import/export & data reset
├── services/
│   ├── storage_service.dart      # Local data persistence & streak
│   └── csv_service.dart          # CSV encoding and parsing
├── theme/
│   └── app_theme.dart            # Material 3 theme, extra colors & box colors
├── utils/
│   └── dates.dart                # Calendar-day helpers (DST-safe)
└── widgets/
    ├── daily_review_panel.dart   # Daily Review status, stats & upcoming review
    ├── streak_forecast_bar.dart  # Activity bar (past & upcoming days)
    ├── review_card.dart          # Flippable, swipeable review card
    ├── flashcard_tile.dart       # Card row with edit / move / delete actions
    ├── box_picker_dialog.dart    # Box selection dialog
    ├── level_card.dart           # Box overview card
    └── level_badge.dart          # Box number badge
```

---

## Development

```sh
flutter pub get
flutter run
flutter test
```
