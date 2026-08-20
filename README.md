# My Memory Box 

A spaced repetition flashcard application built with Flutter. It implements a 9-level Leitner system (Level 0 to Level 8) based on powers of two (2^0 to 2^8 days). Available across mobile and web platforms, with offline-first Progressive Web App (PWA) deployment support for iOS.

---

## Navigation & Features

* **My Boxes:** Dashboard displaying the 9 Leitner level boxes, total/due card counts, and the daily review queue (limited to 1 session per day).
* **My Cards:** Complete inventory of author cards with live text search, interval information, next review dates, in-line card edition, and deletion.
* **Settings:** Application metadata and spaced repetition configuration.
* **Offline-First Storage:** Persists flashcard data and daily review completion timestamps locally via `shared_preferences` (`IndexedDB` on Web).
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

## Tech Stack

* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **Storage:** `shared_preferences`
* **Identities:** `uuid`
* **Timezone & Notifications:** `timezone`, `flutter_timezone`, `flutter_local_notifications`
* **Hosting & CI/CD:** GitHub Pages & GitHub Actions