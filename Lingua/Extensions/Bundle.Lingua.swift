import Foundation
import Logging

extension Bundle {
    var metadata: Logger.Metadata {
        [
            "Name": .string((object(forInfoDictionaryKey: "CFBundleName") as? String) ?? ""),
            "Display Name": .string((object(forInfoDictionaryKey: "CFBundleDisplayName") as? String) ?? ""),
            "Identifier": .string((object(forInfoDictionaryKey: "CFBundleIdentifier") as? String) ?? ""),
            "Version": .string((object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? ""),
            "Build": .string((object(forInfoDictionaryKey: "CFBundleVersion") as? String) ?? ""),
        ]
    }
}
