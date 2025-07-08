import Foundation
import TranslationCatalog
import TranslationCatalogFilesystem
import TranslationCatalogSQLite

struct StorageDescriptor: Codable, Hashable, Identifiable {
    
    let medium: StorageMedium
    let path: StoragePath
    let file: String
    let bookmark: Data
    
    init(
        storageMode: StorageMode
    ) throws {
        let bookmarkURL: URL
        
        switch storageMode {
        case .sqlite(let url):
            medium = .sqlite
            
            if url.hasDirectoryPath {
                path = .directory(url)
                file = "Lingua.sqlite"
                bookmarkURL = url.appending(path: file)
                _ = try SQLiteCatalog(url: bookmarkURL)
            } else {
                path = .file(url)
                file = url.lastPathComponent
                bookmarkURL = url
            }
        case .json(let url):
            medium = .json
            path = .directory(url)
            file = ""
            bookmarkURL = url
        }
        
        #if os(macOS)
        bookmark = try bookmarkURL.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: [.isDirectoryKey])
        #else
        bookmark = try bookmarkURL.bookmarkData(includingResourceValuesForKeys: [.isDirectoryKey])
        #endif
    }
    
    var id: URL {
        switch path {
        case .directory(let url):
            url.appending(path: file)
        case .file(let url):
            url
        }
    }
    
    var catalog: any Catalog {
        get throws {
            var isStale: Bool = false
            
            #if os(macOS)
            let url = try URL(resolvingBookmarkData: bookmark, options: .withSecurityScope, bookmarkDataIsStale: &isStale)
            #else
            let url = try URL(resolvingBookmarkData: bookmark, bookmarkDataIsStale: &isStale)
            #endif
            guard url.startAccessingSecurityScopedResource() else {
                throw LinguaError.storageBookmark
            }
            
            let resourceValues = try url.resourceValues(forKeys: [.isDirectoryKey])
            
            switch (medium , resourceValues.isDirectory) {
            case (.json, true):
                return try FilesystemCatalog(url: url)
            case (.sqlite, false):
                return try SQLiteCatalog(url: url)
            default:
                throw LinguaError.storageBookmark
            }
        }
    }
}

extension StorageDescriptor {
    private static let recentsURL: URL = .applicationSupportDirectory.appendingPathComponent("Recents", conformingTo: .json)
    
    static var recents: [StorageDescriptor] {
        do {
            let data = try Data(contentsOf: recentsURL)
            let recents = try JSONDecoder().decode([StorageDescriptor].self, from: data)
            return recents
        } catch {
            return []
        }
    }
    
    static func clearRecents() {
        persistDescriptors([])
    }
    
    static func addRecent(_ descriptor: StorageDescriptor) {
        var recents = recents
        if recents.count > 7 {
            recents = recents.dropLast(recents.count - 6)
        }
        recents.insert(descriptor, at: 0)
        persistDescriptors(recents)
    }
    
    private static func persistDescriptors(_ descriptors: [StorageDescriptor]) {
        do {
            let data = try JSONEncoder().encode(descriptors)
            try data.write(to: recentsURL)
        } catch {
        }
    }
}
