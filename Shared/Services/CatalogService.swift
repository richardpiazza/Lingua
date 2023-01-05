import Foundation
import TranslationCatalog
import TranslationCatalogFilesystem
import TranslationCatalogSQLite

class CatalogService: ObservableObject {
    
    @Published var catalog: Catalog?
    @Published var contentMode: ContentMode?
    
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
                let fileUrl = URL(fileURLWithPath: url.path)
                catalog = try SQLiteCatalog(url: fileUrl)
            } catch {
                print(error)
                storage = nil
                return
            }
        case .json(let url):
            do {
                let fileUrl = URL(fileURLWithPath: url.path)
                catalog = try FilesystemCatalog(url: fileUrl)
            } catch {
                print(error)
                storage = nil
                return
            }
        }
        
        if storage != mode {
            storage = mode
        }
        
        contentMode = .catalog
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
