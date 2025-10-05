import Foundation
import SwiftUI
import Synchronization
import UniformTypeIdentifiers

class Document: ReferenceFileDocument {
    
    enum Version: Int, FileWrapperCodable, PreferredNameExpressible {
        case v1 = 1
        
        static let preferredFilename: String = "version.json"
    }
    
    enum Kind: String, FileWrapperCodable, PreferredNameExpressible {
        /// JSON
        case directory
        /// SQLite/CoreData File
        case file
        /// FileWrappers (Package Directories)
        case wrappers
        
        static let preferredFilename: String = "kind.json"
    }
    
    struct Storage {
        var version: Version = .v1
        var kind: Kind = .wrappers
        var bookmarks: [UUID: Data]?
        var catalog: WrapperCatalog?
    }
    
    static var readableContentTypes: [UTType] { [.linguaCatalog] }
    
    private static let deviceIdentifier: Persisted<UUID>.Identifier = "device_id"
    private static let decoder = JSONDecoder()
    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        return encoder
    }()
    
    private static var deviceId: UUID {
        @Persisted(deviceIdentifier, defaultValue: .zero) var id: UUID
        if id == .zero {
            id = UUID()
        }
        return id
    }
    
    let storage: Mutex<Storage>
    var wrapper: FileWrapper?
    
    init() {
        storage = Mutex(Storage())
        wrapper = nil
    }
    
    required init(configuration: ReadConfiguration) throws {
        guard configuration.contentType == .linguaCatalog else {
            throw CocoaError(.fileReadUnknown)
        }
        
        let version = try Version(from: configuration.file, using: Self.decoder)
        let kind = try Kind(from: configuration.file, using: Self.decoder)
        let bookmarks: [UUID: Data]?
        let catalog: WrapperCatalog?
        
        switch kind {
        case .directory, .file:
            if let bookmarkWrapper = configuration.file.fileWrappers?["bookmarks.json"] {
                guard let data = bookmarkWrapper.regularFileContents else {
                    throw CocoaError(.fileReadCorruptFile)
                }
                
                bookmarks = try Self.decoder.decode([UUID: Data].self, from: data)
            } else {
                bookmarks = [:]
            }
            catalog = nil
        case .wrappers:
            bookmarks = nil
            catalog = try WrapperCatalog(from: configuration.file, using: Self.decoder)
        }
        
        let state = Storage(
            version: version,
            kind: kind,
            bookmarks: bookmarks,
            catalog: catalog
        )
        
        storage = Mutex(state)
        wrapper = configuration.file
    }
    
    func snapshot(contentType: UTType) throws -> Storage {
        storage.withLock { $0 }
    }
    
    func fileWrapper(snapshot: Storage, configuration: WriteConfiguration) throws -> FileWrapper {
        let wrapper = FileWrapper(directoryWithFileWrappers: [:])
        try snapshot.version.encode(to: wrapper, using: Self.encoder)
        try snapshot.kind.encode(to: wrapper, using: Self.encoder)
        if let bookmarks = snapshot.bookmarks {
            let data = try Self.encoder.encode(bookmarks)
            wrapper.addRegularFile(withContents: data, preferredFilename: "bookmarks.json")
        }
        if let catalog = snapshot.catalog {
            try catalog.encode(to: wrapper, using: Self.encoder)
        }
        return wrapper
    }
    
    func setURL(_ url: URL) throws {
        let (kind, bookmarks) = storage.withLock { ($0.kind, $0.bookmarks) }
        
        switch kind {
        case .directory, .file:
            let data = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: [.isDirectoryKey])
            var marks = bookmarks ?? [:]
            marks[Self.deviceId] = data
            storage.withLock { $0.bookmarks = marks }
        case .wrappers:
            throw CocoaError(.fileWriteUnsupportedScheme)
        }
    }
    
    func urlForDevice() throws -> URL? {
        let (kind, bookmarks) = storage.withLock { ($0.kind, $0.bookmarks) }
        
        switch kind {
        case .directory, .file:
            guard let marks = bookmarks else {
                throw CocoaError(.fileReadUnsupportedScheme)
            }
            
            guard let bookmark = marks[Self.deviceId] else {
                return nil
            }
            
            var isStale: Bool = false
            #if os(macOS)
            let url = try URL(resolvingBookmarkData: bookmark, options: .withSecurityScope, bookmarkDataIsStale: &isStale)
            #else
            let url = try URL(resolvingBookmarkData: bookmark, bookmarkDataIsStale: &isStale)
            #endif

            if isStale {
                try setURL(url)
            }
            
            return url
        case .wrappers:
            throw CocoaError(.featureUnsupported)
        }
    }
}
