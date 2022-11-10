import Foundation
import TranslationCatalog
import TranslationCatalogSQLite

class CatalogService: ObservableObject {
    
    enum Source {
        case sandbox
    }
    
    private(set) var catalog: Catalog
    
    @Published var source: Source = .sandbox
    
    init() {
        let fileManager: FileManager = .default
        let url: URL = Self.exampleStoreURL
        
        if !fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.copyItem(at: Self.bundleStoreURL, to: url)
            } catch {
                preconditionFailure("Failed to copy bundle example to local directory.")
            }
        }
        
        do {
            catalog = try SQLiteCatalog(url: url)
        } catch {
            preconditionFailure("Unable to load local example database")
        }
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
