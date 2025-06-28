import Foundation

enum StorageMode: Equatable, Codable {
    case sqlite(URL)
    case json(URL)
}

extension StorageMode: CustomStringConvertible {
    var description: String {
        switch self {
        case .sqlite(let url):
            "SQLite: \(url)"
        case .json(let url):
            "JSON: \(url)"
        }
    }
}
