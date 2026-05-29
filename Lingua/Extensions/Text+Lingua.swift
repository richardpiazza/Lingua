import SwiftUI

@MainActor extension Text {
    init(_ key: LocalizedStringKey, tableName: String? = nil, bundle: Bundle? = nil, comment: StaticString? = nil, _ arguments: any CVarArg...) {
        guard !arguments.isEmpty else {
            self.init(key, tableName: tableName, bundle: bundle, comment: comment)
            return
        }

        guard let rawValue = key.rawValue else {
            self.init(key, tableName: tableName, bundle: bundle, comment: comment)
            return
        }

        let formatString = (bundle ?? .main).localizedString(forKey: rawValue, value: nil, table: tableName)
        let localizedString = String(format: formatString, arguments: arguments)
        self.init(localizedString)
    }
}

@MainActor private extension LocalizedStringKey {
    var rawValue: String? {
        let mirror = Mirror(reflecting: self)
        guard let child = mirror.children.first(where: { $0.label == "key" }) else {
            return nil
        }

        guard let value = child.value as? String else {
            return nil
        }

        return value
    }
}
