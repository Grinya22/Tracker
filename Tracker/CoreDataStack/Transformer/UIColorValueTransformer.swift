import UIKit

@objc
final class UIColorValueTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass { NSData.self }
    override class func allowsReverseTransformation() -> Bool { true }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let color = value as? UIColor else { return nil }
        return try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor
    }

    static func register() {
        let transformer = UIColorValueTransformer()
        ValueTransformer.setValueTransformer(
            transformer,
            forName: NSValueTransformerName(String(describing: UIColorValueTransformer.self))
        )
    }
}
