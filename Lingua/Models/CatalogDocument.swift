import SwiftUI
import TranslationCatalog
import TranslationCatalogCoreData
import TranslationCatalogFilesystem
import TranslationCatalogSQLite
import UniformTypeIdentifiers

/// https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileWrappers/FileWrappers.html
/// https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileWrappers/FileWrappers.html#//apple_ref/doc/uid/TP40010672-CH13-SW1
struct CatalogDocument: FileDocument {
    
    enum State {
        case new
        case notReady
        case ready
    }
    
    static var readableContentTypes: [UTType] { [.linguaCatalog] }
    
    var descriptor: CatalogDescriptor
    
    init(descriptor: CatalogDescriptor = CatalogDescriptor()) {
        self.descriptor = descriptor
    }
    
    init(configuration: ReadConfiguration) throws {
        guard configuration.contentType == .linguaCatalog else {
            throw CocoaError(.fileReadUnknown)
        }
        
        guard let descriptorWrapper = configuration.file.fileWrappers?["descriptor"] else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        guard let descriptorData = descriptorWrapper.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }

        descriptor = try JSONDecoder().decode(CatalogDescriptor.self, from: descriptorData)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let wrapper = FileWrapper(directoryWithFileWrappers: [:])
        
        let descriptorData = try JSONEncoder().encode(descriptor)
        wrapper.addRegularFile(withContents: descriptorData, preferredFilename: "descriptor")
        
        return wrapper
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
