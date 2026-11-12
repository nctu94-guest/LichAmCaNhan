# Lịch Âm Việt Nam — iOS

SwiftUI starter project for an offline-first Vietnamese lunar calendar.

## Open and run
Requirements: macOS + Xcode 15+.

1. Clone this repository.
2. Install XcodeGen: `brew install xcodegen`.
3. In the repository folder run `xcodegen generate`.
4. Open `LichAmCaNhan.xcodeproj` in Xcode.
5. Select an iPhone Simulator and press Run. For a physical iPhone, select your Apple development Team under Signing & Capabilities.

## Current repository status
The original `ContentView.swift` is a proof-of-concept showing lunar event entry, local persistence and local notifications. `ARCHITECTURE.md` records the modular target design and correctness requirements. This is not yet a complete production calendar: full month-grid browsing, verified Vietnamese lunar conversion, accurate almanac/hoàng đạo calculations, and recurring annual notification rescheduling still need implementation and tests.

## Intended modules
- Calendar UI: solar/lunar month grid and selected-day detail.
- LunarCalendarService: Vietnam timezone conversion, leap-month validation.
- AlmanacService: documented traditional day/hour rules.
- EventStore: versioned local persistence.
- ReminderScheduler: previous-day 08:00 local notifications for lunar/solar recurring events, rescheduled on launch/foreground.
- EventEditor: defaults to lunar date, supports solar date and yearly recurrence.

## Notification limitations
The app must request notification permission. iOS may limit pending local notifications; schedule the nearest events and refresh them when the app becomes active. Notifications cannot appear if the user disables them or removes the app.
