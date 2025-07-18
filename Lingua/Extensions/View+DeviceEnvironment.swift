import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

extension View {
    var iPadOrMac: Bool {
        #if os(macOS)
        return true
        #elseif canImport(UIKit)
        switch UIDevice.current.userInterfaceIdiom {
        case .mac, .pad:
            return true
        default:
            return false
        }
        #else
        return false
        #endif
    }

    var horizontallyCompact: Bool {
        #if os(macOS)
        return false
        #elseif canImport(UIKit)
        UITraitCollection.current.horizontalSizeClass == .compact
        #else
        return false
        #endif
    }
}
