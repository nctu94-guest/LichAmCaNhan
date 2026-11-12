# LichAmCaNhan — Architecture

## iOS application
SwiftUI app targeting iOS 16+. Local-first, Vietnamese time zone (Asia/Ho_Chi_Minh).

## Modules
- Calendar UI: month grid with Gregorian and Vietnamese lunar dates; selected-day detail.
- LunarCalendarService: deterministic Vietnamese lunar conversion; test known dates and leap months.
- AlmanacService: ngày tốt/xấu and giờ hoàng đạo dataset/rules, clearly marked as traditional reference data.
- EventStore: Codable persistence in Application Support; migration/versioning.
- Event model: title, notes, dateKind (lunar/solar), day, month, optional year, yearlyRepeat.
- ReminderScheduler: local notifications at 08:00 one day before; rebuild pending notifications at launch/foreground; prioritize nearest notifications within iOS pending limits.
- Settings: notification permission status, reminder time, location/time zone fixed to Vietnam by default.

## Event recurrence rules
1. Default dateKind is lunar.
2. A recurring event stores month/day, not a single Gregorian date.
3. Each year resolve lunar month/day to Gregorian date, then schedule previous day at 08:00 Asia/Ho_Chi_Minh.
4. For a non-repeating event, store its year and schedule once.
5. Validate invalid lunar dates and leap-month ambiguity before saving.

## Suggested source layout
Sources/App, Sources/Models, Sources/Services, Sources/Views, Tests.

## Important accuracy note
Do not label random parity-based dates as auspicious. Good/bad-day and auspicious-hour rules need a documented Vietnamese almanac source and tests. Lunar conversion must be validated against known dates including leap months. Local notifications require user authorization and cannot be guaranteed if disabled by iOS/user.
