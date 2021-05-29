import Foundation
import SwiftUI
import TranslationCatalog
import TranslationCatalogSQLite
#if canImport(UIKit)
import UIKit
#endif

class AppEnvironment: ObservableObject {
    
    enum State {
        case sandbox
    }
    
    enum ContentMode: Hashable {
        case catalog
        case project(Project.ID)
        case search(String)
    }
    
    static let `default`: AppEnvironment = .init()
    
    @Published var state: State = .sandbox
    @Published var contentMode: ContentMode? = .catalog
    
    let catalog: Catalog
    
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
    
    init() {
        let fileManager: FileManager = .default
        let url: URL = AppEnvironment.exampleStoreURL
        
        if !fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.copyItem(at: AppEnvironment.bundleStoreURL, to: url)
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
    
    var iPadOrMac: Bool {
        #if os(macOS)
        return true
        #elseif canImport(UIKit)
        switch UIDevice.current.userInterfaceIdiom {
        case .mac, .pad:
            return true
        default:
            return false
        }
        #else
        return false
        #endif
    }
    
    var horizontallyCompact: Bool {
        #if os(macOS)
        return false
        #elseif canImport(UIKit)
        UITraitCollection.current.horizontalSizeClass == .compact
        #else
        return false
        #endif
    }
}
