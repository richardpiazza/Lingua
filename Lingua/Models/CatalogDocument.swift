import SwiftUI
import TranslationCatalog
import TranslationCatalogCoreData
import TranslationCatalogFilesystem
import TranslationCatalogSQLite
import UniformTypeIdentifiers

nonisolated struct CatalogDocument: FileDocument {
    
    enum State {
        case new
        case notReady
        case ready
    }
    
    static var readableContentTypes: [UTType] { [.linguaCatalog] }
    
    let descriptor: CatalogDescriptor
    
    init() {
        descriptor = CatalogDescriptor()
    }
    
    init(configuration: ReadConfiguration) throws {
        guard configuration.contentType == .linguaCatalog else {
            throw CocoaError(.fileReadUnknown)
        }

        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        descriptor = try JSONDecoder().decode(CatalogDescriptor.self, from: data)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(descriptor)
        return FileWrapper(regularFileWithContents: data)
    }
    
    var state: State {
        guard descriptor.kind != nil else {
            return .new
        }
        
        guard descriptor.url != nil else {
            return .notReady
        }
        
        return .ready
    }
    
    var catalog: (any Catalog) {
        get throws {
            guard let kind = descriptor.kind else {
                throw LinguaError.storageBookmark
            }
            
            guard let url = descriptor.url else {
                throw LinguaError.storageBookmark
            }
            
            return switch kind {
            case .directory:
                try FilesystemCatalog(url: url)
            case .file:
                try SQLiteCatalog(url: url)
            case .package:
                try CoreDataCatalog(url: url)
            }
        }
    }
}
