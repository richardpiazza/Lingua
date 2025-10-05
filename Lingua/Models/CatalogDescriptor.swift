import Foundation

nonisolated struct CatalogDescriptor: Codable {
    
    enum Version: Int, Codable {
        case v1 = 1
    }
    
    enum Kind: Codable {
        /// JSON
        case directory
        /// SQLite
        case file
        /// CoreData
        case package
    }
    
    var version: Version = .v1
    var kind: Kind?
    var url: URL?
    var bookmark: Data?
    
    init(
        version: Version = .v1,
        kind: Kind? = nil,
        url: URL? = nil,
        bookmark: Data? = nil
    ) {
        self.version = version
        self.kind = kind
        self.url = url
        self.bookmark = bookmark
    }
    
    init(
        version: Version = .v1,
        kind: Kind,
        url: URL
    ) throws {
        self.version = version
        self.kind = kind
        self.url = url
        #if os(macOS)
        self.bookmark = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: [.isDirectoryKey])
        #else
        self.bookmark = try url.bookmarkData(includingResourceValuesForKeys: [.isDirectoryKey])
        #endif
    }
    
    init(
        version: Version = .v1,
        kind: Kind,
        bookmark: Data
    ) throws {
        self.version = version
        self.kind = kind
        
        var isStale: Bool = false
        
        #if os(macOS)
        let url = try URL(resolvingBookmarkData: bookmark, options: .withSecurityScope, bookmarkDataIsStale: &isStale)
        #else
        let url = try URL(resolvingBookmarkData: bookmark, bookmarkDataIsStale: &isStale)
        #endif
        
        if isStale {
            #if os(macOS)
            self.bookmark = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: [.isDirectoryKey])
            #else
            self.bookmark = try url.bookmarkData(includingResourceValuesForKeys: [.isDirectoryKey])
            #endif
        } else {
            self.bookmark = bookmark
        }
        
        guard url.startAccessingSecurityScopedResource() else {
            throw LinguaError.storageBookmark
        }
        
        self.url = url
    }
    
    init(from file: FileWrapper, decoder: JSONDecoder) throws {
        guard let wrapper = file.fileWrappers?["descriptor.json"] else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        guard let data = wrapper.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        self = try decoder.decode(Self.self, from: data)
    }
    
    func encode(to file: FileWrapper, encoder: JSONEncoder) throws {
        let data = try encoder.encode(self)
        file.addRegularFile(withContents: data, preferredFilename: "descriptor.json")
    }
}
