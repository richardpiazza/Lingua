import Foundation
import LocaleSupport

extension RegionCode: @retroactive Identifiable {
    public var id: String { rawValue }
    
    var name: String {
        Locale.current.localizedString(forRegionCode: rawValue) ?? rawValue
    }
}
