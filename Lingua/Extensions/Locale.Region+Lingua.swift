import Foundation

extension Locale.Region {
    var name: String {
        Locale.current.localizedString(forRegionCode: identifier) ?? identifier
    }
    
    var pickerName: String {
        "\(name) (\(identifier))"
    }
    
    var unicodeFlag: String? {
        // equivalent to UInt32 = 127397
        let base = UnicodeScalar("🇦").value - UnicodeScalar("A").value
        var symbol = ""
        identifier.unicodeScalars.forEach {
            if let scalar = UnicodeScalar(base + $0.value) {
                symbol.unicodeScalars.append(scalar)
            }
        }
        
        return symbol
    }
}
