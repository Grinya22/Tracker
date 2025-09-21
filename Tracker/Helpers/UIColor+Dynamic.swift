import UIKit

extension UIColor {
    static var dynamicBackground: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .light ? .ypWhite : .ypWhiteNight
        }
    }
    
    static var dynamicButtonBackground: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .light ? .ypBlack : .ypBlackNight
        }
    }
    
    static var dynamicButtonTitle: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .light ? .ypWhite : .ypWhiteNight
        }
    }
    
    static var dynamicTextFieldOrTableViewBackgroundColor: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .light ? .ypBackground : .ypBackgroundNight
        }
    }
    
    static var dynamicTitleColor: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .light ? .ypBlack : .ypBlackNight
        }
    }
    
    static var dynamicSubtitleColor: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .light ? .ypGray : .ypLightGray
        }
    }
    
    static var dynamicSelectItemAtEmojiCollectionColor: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .light ? .ypLightGray : .ypGray
        }
    }
}
