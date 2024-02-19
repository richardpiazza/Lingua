import Foundation

enum StorageMode: Equatable, Codable {
    case sqlite(URL)
    case json(URL)
}
