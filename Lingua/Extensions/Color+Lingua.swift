#if canImport(AppKit)
import AppKit
#endif
import SwiftColor
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
extension Color {
    static let background: Color = Color(nsColor: .windowBackgroundColor)
}

extension Pigment {
    static let windowBackground = Pigment(NSColor.windowBackgroundColor)
}
#endif

#if canImport(UIKit)
extension Color {
    static let background: Color = Color(
        uiColor: UIColor(
            lightPigment: .white,
            darkPigment: .black,
        ),
    )
}

extension UIColor {
    convenience init(lightPigment: @escaping @autoclosure () -> Pigment, darkPigment: @escaping @autoclosure () -> Pigment) {
        self.init(dynamicProvider: { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                darkPigment().uiColor
            default:
                lightPigment().uiColor
            }
        })
    }
}

extension Pigment {
    static let white: Pigment = Pigment(.white)
    static let black: Pigment = Pigment(.black)
}
#endif
