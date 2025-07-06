import Foundation
import TranslationCatalog
import TranslationCatalogCoreData
import TranslationCatalogFilesystem
import TranslationCatalogSQLite

struct CatalogDescriptor: Codable {
    
    enum Version: Int, Codable {
        case v1 = 1
    }
    
    let version: Version
    let format: CatalogStorageFormat?
    let bookmark: Data?
    
    init(
        version: Version = .v1
    ) {
        self.version = version
        format = nil
        bookmark = nil
    }
    
    init(
        version: Version = .v1,
        format: CatalogStorageFormat
    ) throws {
        self.version = version
        self.format = format
        #if os(macOS)
        bookmark = try format.url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: [.isDirectoryKey])
        #else
        bookmark = try format.url.bookmarkData(includingResourceValuesForKeys: [.isDirectoryKey])
        #endif
    }
    
    var url: URL {
        get throws {
            guard let bookmark else {
                throw LinguaError.storageBookmark
            }
            
            var isStale: Bool = false
            
            #if os(macOS)
            let url = try URL(resolvingBookmarkData: bookmark, options: .withSecurityScope, bookmarkDataIsStale: &isStale)
            #else
            let url = try URL(resolvingBookmarkData: bookmark, bookmarkDataIsStale: &isStale)
            #endif
            
            guard url.startAccessingSecurityScopedResource() else {
                throw LinguaError.storageBookmark
            }
            
            return url
        }
    }
    
    var catalog: (any Catalog) {
        get throws {
            guard let format else {
                throw LinguaError.storageBookmark
            }
            
            let url = try self.url
            
            return switch format {
            case .json:
                try FilesystemCatalog(url: url)
            case .relational(let medium):
                switch medium {
                case .coreData:
                    try CoreDataCatalog(url: url)
                case .sqlite:
                    try SQLiteCatalog(url: url)
                }
            }
        }
    }
}
