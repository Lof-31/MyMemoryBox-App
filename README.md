# My Memory Box

A spaced repetition flashcard application built with Flutter. It implements a 9-level Leitner system (Level 0 to Level 8) based on powers of two (2^0 to 2^8 days). Available across mobile and web platforms, with offline-first Progressive Web App (PWA) deployment support for iOS.

---

## Navigation and Menus

* **My Boxes:** Dashboard displaying the 9 Leitner level boxes, total/due card counts, and the daily review queue (limited to 1 session per day).
* **My Cards:** Complete inventory of flashcards with live search, interval information, next review dates, in-line card edition, and deletion.
* **Settings:** Customizable daily reminder notification time (interactive time picker) and app information.
* **Offline-First Storage:** Persists flashcard data, daily review completion dates, and notification preferences locally via `shared_preferences` (`IndexedDB` on Web).
* **Cross-Platform PWA:** Usable as an installable full-screen web app on iOS Safari, Android, and Desktop browsers.
* **Automated CI/CD:** Auto-deployed to GitHub Pages via GitHub Actions on push to `master`.

---

## Leitner Review Intervals

| Level | Power of Two | Interval | Description |
| :--- | :--- | :--- | :--- |
| **Level 0** | 2^0 | 1 day | Daily review for new and missed cards |
| **Level 1** | 2^1 | 2 days | Early retention check |
| **Level 2** | 2^2 | 4 days | Intermediate recall |
| **Level 3** | 2^3 | 8 days | Weekly reinforcement |
| **Level 4** | 2^4 | 16 days | Long-term retention |
| **Level 5** | 2^5 | 32 days | Intermediate recall |
| **Level 6** | 2^6 | 64 days | Weekly reinforcement |
| **Level 7** | 2^7 | 128 days | Long-term retention |
| **Level 8** | 2^8 | 256 days | Long-term retention |

---

## Project Structure

```text
lib/
├── main.dart               # Application entry point & theme configuration
├── models/
│   └── flashcard.dart      # Flashcard data model & Leitner logic
├── screens/
│   ├── home_screen.dart    # Main navigation host (Bottom Navigation Bar)
│   ├── card_list_screen.dart # Searchable card inventory with edit/delete
│   ├── review_screen.dart  # Interactive study session
│   ├── create_card_screen.dart # Card authoring screen
│   └── settings_screen.dart # Daily reminder time configuration
├── services/
│   ├── storage_service.dart     # Local data persistence handler
│   └── notification_service.dart# Local notification scheduling logic
└── widgets/
    └── level_card.dart     # Dashboard level card component