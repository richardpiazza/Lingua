import SwiftUI
import TranslationCatalog
import UniformTypeIdentifiers

struct CatalogDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.linguaCatalog] }
    
    let descriptor: CatalogDescriptor
    let catalog: (any Catalog)?
    
    init() {
        descriptor = CatalogDescriptor()
        catalog = try? descriptor.catalog
    }
    
    init(format: CatalogStorageFormat) throws {
        descriptor = try CatalogDescriptor(format: format)
        catalog = try descriptor.catalog
    }
    
    init(configuration: ReadConfiguration) throws {
        guard configuration.contentType == .linguaCatalog else {
            throw CocoaError(.fileReadUnknown)
        }
        
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        descriptor = try JSONDecoder().decode(CatalogDescriptor.self, from: data)
        catalog = try descriptor.catalog
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(descriptor)
        return FileWrapper(regularFileWithContents: data)
    }
}
