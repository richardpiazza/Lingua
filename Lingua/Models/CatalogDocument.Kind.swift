extension CatalogDocument {
    enum Kind: Codable {
        /// JSON
        case directory
        /// SQLite/CoreData File
        case file(storage: Storage)
        /// FileWrappers (In-Memory / Package Directories)
        case wrappers
    }
}
