import EventKit
import Foundation

final class CalendarManager {
    private let store = EKEventStore()
    private static let targetCalendarTitle = "日程安排"

    func requestAccessIfNeeded(completion: ((Bool) -> Void)? = nil) {
        let status = EKEventStore.authorizationStatus(for: .event)
        if #available(macOS 14.0, *) {
            switch status {
            case .notDetermined:
                store.requestFullAccessToEvents { granted, _ in
                    completion?(granted)
                }
            case .fullAccess:
                completion?(true)
            default:
                completion?(false)
            }
        } else {
            switch status {
            case .notDetermined:
                store.requestAccess(to: .event) { granted, _ in
                    completion?(granted)
                }
            case .authorized:
                completion?(true)
            default:
                completion?(false)
            }
        }
    }

    func fetchCurrentEvents(completion: @escaping ([EKEvent]) -> Void) {
        let status = EKEventStore.authorizationStatus(for: .event)
        let isAuthorized: Bool
        if #available(macOS 14.0, *) {
            isAuthorized = status == .fullAccess
        } else {
            isAuthorized = status == .authorized
        }

        guard isAuthorized else {
            Log.info("Calendar auth not granted. status=\(status.rawValue)")
            completion([])
            return
        }

        let now = Date()
        let start = Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now.addingTimeInterval(-86400)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: now) ?? now.addingTimeInterval(86400)

        let allCalendars = store.calendars(for: .event)
        let calendars = allCalendars.filter { $0.title == Self.targetCalendarTitle }
        if calendars.isEmpty {
            Log.info("Calendar fetch: target calendar not found title=\(Self.targetCalendarTitle) all=\(allCalendars.map { $0.title })")
            completion([])
            return
        }
        Log.info("Calendar fetch: using calendars=\(calendars.map { $0.title })")
        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: calendars)
        let matched = store.events(matching: predicate)
        let events = matched.filter {
            $0.startDate <= now && $0.endDate > now
        }

        if !events.isEmpty {
            let titles = events.prefix(5).map { ($0.title ?? "(nil)") }
            Log.info("Calendar current events sample=\(titles)")
        } else {
            let formatter = ISO8601DateFormatter()
            let nearby = matched
                .sorted { $0.startDate < $1.startDate }
                .filter { abs($0.startDate.timeIntervalSince(now)) < 3 * 3600 || abs($0.endDate.timeIntervalSince(now)) < 3 * 3600 }
                .prefix(5)
                .map { "\($0.title ?? "(nil)") [\(formatter.string(from: $0.startDate)) - \(formatter.string(from: $0.endDate))]" }
            Log.info("Calendar current events none. Nearby=\(nearby)")
        }

        completion(events.sorted { $0.startDate < $1.startDate })
    }
}
