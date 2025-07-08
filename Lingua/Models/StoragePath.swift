import Foundation

enum StoragePath: Codable, Hashable {
    case directory(URL)
    case file(URL)
}
