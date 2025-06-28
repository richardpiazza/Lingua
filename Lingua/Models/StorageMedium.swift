enum StorageMedium: Identifiable, CaseIterable {
    case sqlite
    case json
    
    var id: String { String(describing: self) }
}
