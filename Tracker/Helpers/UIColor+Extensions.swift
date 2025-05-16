import UIKit

extension UIColor {
    // Базовые цвета (день)
    static var ypBlack: UIColor { UIColor(named: "Black [day]") ?? UIColor.black }
    static var ypGray: UIColor { UIColor(named: "Gray") ?? UIColor.gray }
    static var ypLightGray: UIColor { UIColor(named: "Light Gray") ?? UIColor.lightGray }
    static var ypWhite: UIColor { UIColor(named: "White [day]") ?? UIColor.white }
    static var ypBackground: UIColor { UIColor(named: "Background [day]") ?? UIColor.darkGray }

    // Базовые цвета (ночь)
    static var ypBlackNight: UIColor { UIColor(named: "Black [night]") ?? UIColor.black }
    static var ypWhiteNight: UIColor { UIColor(named: "White [night]") ?? UIColor.white }
    static var ypBackgroundNight: UIColor { UIColor(named: "Background [night]") ?? UIColor.darkGray }
    
    static var ypRedTracker: UIColor { UIColor(named: "Red") ?? UIColor.red }
    static var ypBlueTracker: UIColor { UIColor(named: "Blue") ?? UIColor.blue }
}
