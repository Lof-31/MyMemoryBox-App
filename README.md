# My Memory Box 🧠📦

A spaced repetition flashcard application built with Flutter. It implements a 9-level Leitner system (Level 0 to Level 8) based on powers of two ($2^0$ to $2^8$ days). Available across mobile and web platforms, with offline-first Progressive Web App (PWA) deployment support for iOS.

---

## Features

* **9-Level Leitner Box System:** Cards start at Level 0, promote up to Level 8 upon successful recall, and demote back to Level 0 on mistakes.
* **Powers-of-Two Review Schedule:** Review intervals scale from 1 day up to 256 days ($2^{\text{level}}$).
* **Daily Review Queue:** Identifies cards that have surpassed their scheduled `nextReviewDate`.
* **Card Management:** Author, browse, search, and delete cards across all levels.
* **Offline-First Storage:** Persists flashcard data and review timestamps locally via `shared_preferences` (`IndexedDB` on Web).
* **Cross-Platform PWA:** Usable as an installable, standalone full-screen web app on iOS Safari, Android, and Desktop browsers.
* **Automated CI/CD:** Auto-deployed to GitHub Pages via GitHub Actions on push to `master`.

---

## Leitner Review Intervals

| Level | Power of Two | Interval | Description |
| :--- | :--- | :--- | :--- |
| **Level 0** | $2^0$ | 1 day | Daily review for new and missed cards |
| **Level 1** | $2^1$ | 2 days | Early retention check |
| **Level 2** | $2^2$ | 4 days | Intermediate recall |
| **Level 3** | $2^3$ | 8 days | Weekly reinforcement |
| **Level 4** | $2^4$ | 16 days | Long-term retention |
| **Level 5** | $2^5$ | 32 days | Intermediate recall |
| **Level 6** | $2^6$ | 64 days | Weekly reinforcement |
| **Level 7** | $2^7$ | 128 days | Long-term retention |
| **Level 8** | $2^8$ | 256 days | Long-term retention |

---

## Project Structure

```text
lib/
├── main.dart               # Application entry point & theme configuration
├── models/
│   └── flashcard.dart      # Immutable flashcard model with promote/demote Leitner logic
├── screens/
│   ├── home_screen.dart    # Dashboard displaying 9 levels and review queues
│   ├── review_screen.dart  # Interactive flip & review session
│   ├── create_card_screen.dart # Card authoring screen
│   └── card_list_screen.dart   # Searchable inventory of all cards
├── services/
│   ├── storage_service.dart     # Persistence handler (IndexedDB / SharedPreferences)
│   └── notification_service.dart# Daily notification scheduler
└── widgets/
    └── level_card.dart     # Dashboard level indicator card