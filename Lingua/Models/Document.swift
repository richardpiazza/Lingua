import Foundation
import SwiftUI
import Synchronization
import TranslationCatalog
import TranslationCatalogFilesystem
import TranslationCatalogSQLite
import UniformTypeIdentifiers

class Document: ReferenceFileDocument {
    
    enum State: Equatable {
        case new
        case notReady
        case ready(any Catalog)
        
        static func == (lhs: Document.State, rhs: Document.State) -> Bool {
            switch (lhs, rhs) {
            case (.new, .new): return true
            case (.notReady, .notReady): return true
            case (.ready, .ready): return true
            default: return false
            }
        }
    }
    
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
        var catalog: FileWrapperCatalog?
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
    var fileWrapper: FileWrapper?
    
    init() {
        storage = Mutex(Storage())
    }
    
    required init(configuration: ReadConfiguration) throws {
        guard configuration.contentType == .linguaCatalog else {
            throw CocoaError(.fileReadUnknown)
        }
        
        let version = try Version(from: configuration.file, using: Self.decoder)
        let kind = try Kind(from: configuration.file, using: Self.decoder)
        let bookmarks: [UUID: Data]?
        let catalog: FileWrapperCatalog?
        
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
            catalog = try FileWrapperCatalog(fileWrapper: configuration.file)
        }
        
        let state = Storage(
            version: version,
            kind: kind,
            bookmarks: bookmarks,
            catalog: catalog
        )
        
        storage = Mutex(state)
        fileWrapper = configuration.file
    }
    
    func snapshot(contentType: UTType) throws -> Storage {
        storage.withLock { $0 }
    }
    
    func fileWrapper(snapshot: Storage, configuration: WriteConfiguration) throws -> FileWrapper {
        let wrapper = fileWrapper ?? FileWrapper(directoryWithFileWrappers: [:])
        try snapshot.version.encode(to: wrapper, using: Self.encoder)
        try snapshot.kind.encode(to: wrapper, using: Self.encoder)
        if let bookmarks = snapshot.bookmarks {
            let data = try Self.encoder.encode(bookmarks)
            wrapper.addRegularFile(withContents: data, preferredFilename: "bookmarks.json")
        }
        return wrapper
    }
    
    func setup(with kind: Kind, url: URL?) throws {
        switch kind {
        case .directory, .file:
            guard let url else {
                throw URLError(.badURL)
            }
            
            try setURL(url)
            storage.withLock {
                $0.kind = kind
            }
        case .wrappers:
            let wrapper = FileWrapper(directoryWithFileWrappers: [:])
            let catalog = try FileWrapperCatalog(fileWrapper: wrapper)
            fileWrapper = wrapper
            
            storage.withLock {
                $0.kind = kind
                $0.catalog = catalog
            }
        }
    }
    
    func setURL(_ url: URL) throws {
        let (bookmarks) = storage.withLock { ($0.bookmarks) }
        #if os(macOS)
        let data = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: [.isDirectoryKey])
        #else
        let data = try url.bookmarkData(includingResourceValuesForKeys: [.isDirectoryKey])
        #endif
        var marks = bookmarks ?? [:]
        marks[Self.deviceId] = data
        storage.withLock {
            $0.bookmarks = marks
        }
    }
    
    func urlForDevice(from bookmarks: [UUID: Data]) throws -> URL? {
        guard let bookmark = bookmarks[Self.deviceId] else {
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
        
        guard url.startAccessingSecurityScopedResource() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        return url
    }
    
    var state: State {
        let (kind, bookmarks, catalog) = storage.withLock {
            ($0.kind, $0.bookmarks, $0.catalog)
        }
        
        guard bookmarks != nil || catalog != nil else {
            return .new
        }
        
        if kind == .wrappers {
            if let catalog {
                return .ready(catalog)
            } else {
                return .notReady
            }
        }
        
        guard let bookmarks else {
            return .notReady
        }
        
        guard let url = try? urlForDevice(from: bookmarks) else {
            return .notReady
        }
        
        do {
            switch kind {
            case .directory:
                let catalog = try DirectoryCatalog(url: url)
                return .ready(catalog)
            case .file:
                let catalog = try SQLiteCatalog(url: url)
                return .ready(catalog)
            case .wrappers:
                return .notReady
            }
        } catch {
            return .notReady
        }
    }
}
