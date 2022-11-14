import Foundation
import TranslationCatalog
import TranslationCatalogFilesystem
import TranslationCatalogSQLite

class CatalogService: ObservableObject {
    
    @Published var catalog: Catalog?
    @Published var contentMode: ContentMode? = .catalog
    
    @Persisted("SELECTED_STORAGE", defaultValue: nil) private var storage: StorageMode?
    
    init() {
        postInit()
    }
    
    private func postInit() {
        if let mode = storage {
            setStorageMode(mode)
        }
    }
    
    func setStorageMode(_ mode: StorageMode) {
        switch mode {
        case .sqlite(let url):
            do {
                catalog = try SQLiteCatalog(url: url)
            } catch {
                storage = nil
                preconditionFailure("Unable to load SQLite catalog at '\(url)'.")
            }
        case .json(let url):
            do {
                catalog = try FilesystemCatalog(url: url)
            } catch {
                storage = nil
                preconditionFailure("Unable to load Filesystem catalog at '\(url)'.")
            }
        }
        
        if storage != mode {
            storage = mode
        }
    }
    
    func resetStorage() {
        catalog = nil
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

extension CatalogService {
    private static var bundleStoreURL: URL = {
        guard let url = Bundle.main.url(forResource: "example", withExtension: "sqlite") else {
            preconditionFailure("Unable to get Bundle example database")
        }
        
        return url
    }()
    
    private static var exampleStoreURL: URL = {
        guard let supportDirectory = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
            preconditionFailure("Unable to get Application Support directory.")
        }
        
        let applicationDirectory = supportDirectory.appendingPathComponent("ExampleCatalog")
        try? FileManager.default.createDirectory(atPath: applicationDirectory.path, withIntermediateDirectories: true, attributes: nil)
        let storeURL = applicationDirectory.appendingPathComponent("example.sqlite")
        return storeURL
    }()
}
