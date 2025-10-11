import UIKit

@objc
final class ScheduleValueTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass { NSData.self }
    override class func allowsReverseTransformation() -> Bool { true }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let days = value as? [WeekDay] else { return nil }
        return try? JSONEncoder().encode(days)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        return try? JSONDecoder().decode([WeekDay].self, from: data)
    }

    static func register() {
        let transformer = ScheduleValueTransformer()
        ValueTransformer.setValueTransformer(
            transformer,
            forName: NSValueTransformerName(String(describing: ScheduleValueTransformer.self))
        )
    }
}

//import UIKit
//
//@objc
//final class ScheduleValueTransformer: ValueTransformer {
//    override class func transformedValueClass() -> AnyClass { NSData.self }
//    override class func allowsReverseTransformation() -> Bool { true }
//
//    override func transformedValue(_ value: Any?) -> Any? {
//        guard let days = value as? [WeekDay] else { return nil }
//        let wrapper = WeekDayArrayWrapper(days: days)
//        return try? NSKeyedArchiver.archivedData(withRootObject: wrapper, requiringSecureCoding: true)
//    }
//
//    override func reverseTransformedValue(_ value: Any?) -> Any? {
//        guard let data = value as? Data else { return nil }
//        guard let wrapper = try? NSKeyedUnarchiver.unarchivedObject(ofClass: WeekDayArrayWrapper.self, from: data) else {
//            return nil
//        }
//        return wrapper.days
//    }
//
//    static func register() {
//        let transformer = ScheduleValueTransformer()
//        ValueTransformer.setValueTransformer(
//            transformer,
//            forName: NSValueTransformerName(String(describing: ScheduleValueTransformer.self))
//        )
//    }
//}
