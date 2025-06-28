import Foundation
import Combine
import TranslationCatalog
import TranslationCatalogFilesystem
import TranslationCatalogSQLite
import Logging
import Infuse

class LinguaCatalogService: CatalogService {
    
    var catalog: Catalog? { catalogSubject.value }
    var contentScheme: ContentScheme? { contentSchemeSubject.value }
    
    var catalogPublisher: AnyPublisher<Catalog?, Never> { catalogSubject.eraseToAnyPublisher() }
    var contentSchemePublisher: AnyPublisher<ContentScheme?, Never> { contentSchemeSubject.eraseToAnyPublisher() }
    
    private var catalogSubject = CurrentValueSubject<Catalog?, Never>(nil)
    private var contentSchemeSubject = CurrentValueSubject<ContentScheme?, Never>(nil)
    
    @Resource private var logger: Logger
    
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
            #if os(macOS)
            let url = try URL(resolvingBookmarkData: data, options: .withSecurityScope, bookmarkDataIsStale: &isStale)
            #else
            let url = try URL(resolvingBookmarkData: data, bookmarkDataIsStale: &isStale)
            #endif
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
            logger.error(
                "Failed to resolve bookmark data.",
                error: LinguaError.storageBookmark,
                redacting: []
            )
            bookmark = nil
        }
    }
    
    func setStorageMode(_ mode: StorageMode) {
        logger.info("Setting Storage Mode", metadata: [
            "Storage Mode": .stringConvertible(mode)
        ])
        
        switch mode {
        case .sqlite(let url):
            do {
                let fileUrl = URL(fileURLWithPath: url.path)
                catalogSubject.value = try SQLiteCatalog(url: fileUrl)
                if bookmark == nil {
                    #if os(macOS)
                    bookmark = try fileUrl.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: [.isDirectoryKey])
                    #else
                    bookmark = try fileUrl.bookmarkData(includingResourceValuesForKeys: [.isDirectoryKey])
                    #endif
                }
            } catch {
                logger.error(
                    "Failed to set SQLite Storage Mode using URL '\(url)'.",
                    error: LinguaError.storageSQLite,
                    redacting: []
                )
                return
            }
        case .json(let url):
            do {
                let fileUrl = URL(fileURLWithPath: url.path)
                catalogSubject.value = try FilesystemCatalog(url: fileUrl)
                if bookmark == nil {
                    #if os(macOS)
                    bookmark = try fileUrl.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: [.isDirectoryKey])
                    #else
                    bookmark = try fileUrl.bookmarkData(includingResourceValuesForKeys: [.isDirectoryKey])
                    #endif
                }
            } catch {
                logger.error(
                    "Failed to set JSON Storage Mode using URL '\(url)'.",
                    error: LinguaError.storageJSON,
                    redacting: []
                )
                return
            }
        }
        
        contentSchemeSubject.value = .catalog
    }
    
    func setContentScheme(_ mode: ContentScheme?) {
        contentSchemeSubject.value = mode
    }
    
    func resetStorage() {
        catalogSubject.value = nil
        bookmark = nil
    }
    
    func localeIdentifiers() -> Set<Locale.Identifier> {
        guard let catalog = self.catalog else {
            return []
        }
        
        return (try? catalog.localeIdentifiers()) ?? []
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
