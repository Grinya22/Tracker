import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    //let schedule: [String] // расписание
    let schedule: [WeekDay] // расписание
    let creationDate: Date
}

enum WeekDay: Int, Codable, CaseIterable {
    case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday
}

