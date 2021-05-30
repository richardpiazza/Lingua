import Foundation
import TranslationCatalog
#if canImport(UIKit)
import UIKit
#endif

class StateManager: ObservableObject {
    
    enum ContentMode: Hashable {
        case catalog
        case project(Project.ID)
        case search(String)
    }
    
    static let shared: StateManager = .init()
    
    @Published var contentMode: ContentMode? = .catalog
    
    private init() {
    }
}

extension StateManager {
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
