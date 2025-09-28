extension CatalogDocument {
    enum Storage: Codable {
        case coreData
        case sqlite
    }
}
