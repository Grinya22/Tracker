//import Foundation
//
//final class WeekDayArrayWrapper: NSObject, NSSecureCoding {
//    static var supportsSecureCoding: Bool = true
//
//    let days: [WeekDay]
//
//    init(days: [WeekDay]) {
//        self.days = days
//    }
//
//    func encode(with coder: NSCoder) {
//        let rawValues = days.map { $0.rawValue }
//        coder.encode(rawValues, forKey: "days")
//    }
//
//    required init?(coder: NSCoder) {
//        let rawValues = coder.decodeObject(forKey: "days") as? [Int] ?? []
//        self.days = rawValues.compactMap { WeekDay(rawValue: $0) }
//    }
//}
//
//
