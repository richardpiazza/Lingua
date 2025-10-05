extension CatalogDocument {
    enum Kind: Codable {
        /// JSON
        case directory
        /// SQLite/CoreData File
        case file
        /// FileWrappers (Package Directories)
        case wrappers
    }
}
