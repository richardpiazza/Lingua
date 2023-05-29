import Foundation
import TranslationCatalog
import TranslationCatalogFilesystem
import TranslationCatalogSQLite
import Logging
import CodeQuickKit

class CatalogService: ObservableObject {
    
    @Published var catalog: Catalog?
    @Published var contentMode: ContentMode?
    
    @Dependency private var logger: Logger
    
    @Persisted("STORAGE_BOOKMARK", defaultValue: nil) private var bookmark: Data?
    
    init() {
        postInit()
    }
    
    private func postInit() {
        if let data = bookmark {
            initializeStorageWithBookmark(data)
        }
    }
    
    private func initializeStorageWithBookmark(_ data: Data) {
        var isStale: Bool = false
        do {
            let url = try URL(resolvingBookmarkData: data, options: .withSecurityScope, bookmarkDataIsStale: &isStale)
            guard url.startAccessingSecurityScopedResource() else {
                return
            }
            
            let resourceValues = try url.resourceValues(forKeys: [.isDirectoryKey])
            
            if resourceValues.isDirectory == true {
                setStorageMode(.json(url))
            } else if url.path.contains("sqlite") {
                setStorageMode(.sqlite(url))
            } else {
                setStorageMode(.json(url))
            }
        } catch {
            logger.error("Failed to resolve bookmark data.", error: error)
            bookmark = nil
        }
    }
    
    func setStorageMode(_ mode: StorageMode) {
        switch mode {
        case .sqlite(let url):
            do {
                let fileUrl = URL(fileURLWithPath: url.path)
                catalog = try SQLiteCatalog(url: fileUrl)
                if bookmark == nil {
                    bookmark = try fileUrl.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: [.isDirectoryKey])
                }
            } catch {
                logger.error("Failed to set SQLite Storage Mode using URL '\(url)'.", error: error)
                return
            }
        case .json(let url):
            do {
                let fileUrl = URL(fileURLWithPath: url.path)
                catalog = try FilesystemCatalog(url: fileUrl)
                if bookmark == nil {
                    bookmark = try fileUrl.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: [.isDirectoryKey])
                }
            } catch {
                logger.error("Failed to set JSON Storage Mode using URL '\(url)'.", error: error)
                return
            }
        }
        
        contentMode = .catalog
    }
    
    func resetStorage() {
        catalog = nil
        bookmark = nil
    }
}

extension URL {
    static var defaultCatalogURL: URL {
        guard let supportDirectory = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
            preconditionFailure("Unable to get Application Support directory.")
        }
        
        return supportDirectory.appendingPathComponent("Lingua.sqlite")
    }
}
