enum StorageMedium: CaseIterable, Codable, Hashable, Identifiable {
    case sqlite
    case json

    var id: String { String(describing: self) }
}
