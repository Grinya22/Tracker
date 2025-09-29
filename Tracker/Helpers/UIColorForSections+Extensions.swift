import UIKit

extension UIColor {
    // Цвета выборок
    static var ypRed: UIColor { UIColor(named: "Color selection 1") ?? UIColor.red }
    static var ypOrange: UIColor { UIColor(named: "Color selection 2") ?? UIColor.orange }
    static var ypBlue: UIColor { UIColor(named: "Color selection 3") ?? UIColor.blue }
    static var ypViolet: UIColor { UIColor(named: "Color selection 4") ?? UIColor.purple }
    static var ypGreen: UIColor { UIColor(named: "Color selection 5") ?? UIColor.green }
    static var ypPink: UIColor { UIColor(named: "Color selection 6") ?? UIColor.systemPink }
    static var ypLightBlue: UIColor { UIColor(named: "Color selection 7") ?? UIColor.cyan }
    static var ypMint: UIColor { UIColor(named: "Color selection 8") ?? UIColor.systemTeal } // systemMint
    static var ypDarkViolet: UIColor { UIColor(named: "Color selection 9") ?? UIColor.purple } // systemIndigo
    static var ypCoral: UIColor { UIColor(named: "Color selection 10") ?? UIColor.orange }
    static var ypLightOrange: UIColor { UIColor(named: "Color selection 11") ?? UIColor.orange }
    static var ypSoftGreen: UIColor { UIColor(named: "Color selection 12") ?? UIColor.green }
    static var ypDeepBlue: UIColor { UIColor(named: "Color selection 13") ?? UIColor.blue }
    static var ypPurple: UIColor { UIColor(named: "Color selection 14") ?? UIColor.purple }
    static var ypStrongViolet: UIColor { UIColor(named: "Color selection 15") ?? UIColor.purple }
    static var ypLightViolet: UIColor { UIColor(named: "Color selection 16") ?? UIColor.purple }
    static var ypLightGreen: UIColor { UIColor(named: "Color selection 17") ?? UIColor.green }
    static var ypNeonGreen: UIColor { UIColor(named: "Color selection 18") ?? UIColor.green }
}

extension UIColor {
    func isEqualToColor(_ color: UIColor) -> Bool {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return r1 == r2 && g1 == g2 && b1 == b2 && a1 == a2
    }
}

