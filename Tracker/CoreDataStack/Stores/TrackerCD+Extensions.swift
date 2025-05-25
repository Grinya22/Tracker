//import Foundation
//
//extension TrackerCoreData {
//    var scheduleArray: [WeekDay]? {
//        get {
//            guard let data = self.schedule else { return nil }
//            return ScheduleValueTransformer().reverseTransformedValue(data) as? [WeekDay]
//        }
//        set {
//            self.schedule = ScheduleValueTransformer().transformedValue(newValue) as? NSObject
//        }
//    }
//}
