import Foundation

enum StorageMode {
    case sqlite(URL)
    case json(URL)
}
