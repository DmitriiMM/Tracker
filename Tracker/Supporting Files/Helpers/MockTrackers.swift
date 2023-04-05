import UIKit

let mockTrackers: [TrackerCategory] = [
    TrackerCategory(
        title: "11111",
        trackers: [Tracker(
            trackerId: UUID(uuidString: "94E3C0C2-EE00-49EA-B117-8AC36ACBE800")!,
            trackerText: "понедельник",
            trackerEmoji: "👑",
            trackerColor: UIColor(named: "Color1") ?? .green,
            trackerSchedule: Optional(["Пн"])
        ), Tracker(
            trackerId: UUID(uuidString: "F323F0BF-D4FF-4156-A853-1EE65B71B4FC")!,
            trackerText: "без расписания",
            trackerEmoji: "❤️",
            trackerColor: UIColor(named: "Color2") ?? .green,
            trackerSchedule: nil)]
    ), TrackerCategory(
        title: "22222",
        trackers: [Tracker(
            trackerId: UUID(uuidString: "CC4CE49C-3F66-437C-D4FF-ECA55DCCA758")!,
            trackerText: "вторник",
            trackerEmoji: "🌎",
            trackerColor: UIColor(named: "Color13") ?? .green,
            trackerSchedule: Optional(["Вт"])
        ), Tracker(
            trackerId: UUID(uuidString: "F523F0BF-D4FF-4156-3F66-1EE65B71B4FC")!,
            trackerText: "среда",
            trackerEmoji: "☘️",
            trackerColor: UIColor(named: "Color7") ?? .green,
            trackerSchedule: Optional(["Ср"])
        ), Tracker(
            trackerId: UUID(uuidString: "F523F0BF-D4FF-4456-B117-1EE65B71B4FC")!,
            trackerText: "четверг",
            trackerEmoji: "🍄",
            trackerColor: UIColor(named: "Color18") ?? .green,
            trackerSchedule: Optional(["Пн", "Чт"])
        )
        ]
    ), TrackerCategory(
        title: "Категория номер 3",
        trackers: [Tracker(
            trackerId: UUID(uuidString: "CC4CE49C-3F66-137C-D4FF-ECA55DCCA758")!,
            trackerText: "порт",
            trackerEmoji: "🌺",
            trackerColor: UIColor(named: "Color12") ?? .green,
            trackerSchedule: Optional(["Сб"])
        ), Tracker(
            trackerId: UUID(uuidString: "F523F0BF-D4FF-4556-137C-1EE65B71B4FC")!,
            trackerText: "безысходность",
            trackerEmoji: "🌞",
            trackerColor: UIColor(named: "Color8") ?? .green,
            trackerSchedule: nil
        ), Tracker(
            trackerId: UUID(uuidString: "F523F0BF-D4FF-4156-D5FF-1EE65B71B4FC")!,
            trackerText: "четверг",
            trackerEmoji: "🌈",
            trackerColor: UIColor(named: "Color17") ?? .green,
            trackerSchedule: Optional(["Пн", "Чт"])
        )
        ]
    )
]
