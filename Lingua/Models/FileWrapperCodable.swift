import Foundation

protocol FileWrapperCodable: Codable {
    init(from file: FileWrapper, using decoder: JSONDecoder) throws
    func encode(to file: FileWrapper, using encoder: JSONEncoder) throws
}

protocol PreferredNameExpressible {
    static var preferredFilename: String { get }
}

protocol DocumentExpressible {
    var projectDocuments: [ProjectDocument] { get set }
    var expressionDocuments: [ExpressionDocument] { get set }
    var translationDocuments: [TranslationDocument] { get set }
}

extension FileWrapperCodable where Self: PreferredNameExpressible {
    init(from file: FileWrapper, using decoder: JSONDecoder) throws {
        guard let wrapper = file.fileWrappers?[Self.preferredFilename] else {
            throw CocoaError(.fileNoSuchFile)
        }
        
        guard let data = wrapper.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        self = try decoder.decode(Self.self, from: data)
    }
    
    func encode(to file: FileWrapper, using encoder: JSONEncoder) throws {
        let data = try encoder.encode(self)
        file.addRegularFile(withContents: data, preferredFilename: Self.preferredFilename)
    }
}

extension FileWrapperCodable where Self: Identifiable, Self.ID == UUID {
    var preferredFilename: String { "\(id.uuidString).json" }
    
    init(from file: FileWrapper, using decoder: JSONDecoder) throws {
        guard let data = file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        self = try decoder.decode(Self.self, from: data)
    }
    
    func encode(to file: FileWrapper, using encoder: JSONEncoder) throws {
        let data = try encoder.encode(self)
        file.addRegularFile(withContents: data, preferredFilename: preferredFilename)
    }
}

extension FileWrapperCodable where Self: DocumentExpressible {
    init(from file: FileWrapper, using decoder: JSONDecoder) throws {
        if let wrapper = file.fileWrappers?["Projects"], wrapper.isDirectory {
            let directory = wrapper.fileWrappers ?? [:]
            var documents: [ProjectDocument] = []
            for (key, value) in directory {
                documents.append(try ProjectDocument(from: value, using: decoder))
            }
            projectDocuments = documents
        } else {
            projectDocuments = []
        }
        
        if let wrapper = file.fileWrappers?["Expressions"], wrapper.isDirectory {
            let directory = wrapper.fileWrappers ?? [:]
            var documents: [ExpressionDocument] = []
            for (key, value) in directory {
                documents.append(try ExpressionDocument(from: value, using: decoder))
            }
            expressionDocuments = documents
        } else {
            expressionDocuments = []
        }
        
        if let wrapper = file.fileWrappers?["Translations"], wrapper.isDirectory {
            let directory = wrapper.fileWrappers ?? [:]
            var documents: [TranslationDocument] = []
            for (key, value) in directory {
                documents.append(try TranslationDocument(from: value, using: decoder))
            }
            translationDocuments = documents
        } else {
            translationDocuments = []
        }
    }
    
    func encode(to file: FileWrapper, using encoder: JSONEncoder) throws {
        var wrapper = FileWrapper(directoryWithFileWrappers: [:])
        wrapper.preferredFilename = "Projects"
        for document in projectDocuments {
            try document.encode(to: wrapper, using: encoder)
        }
        file.addFileWrapper(wrapper)
        
        wrapper = FileWrapper(directoryWithFileWrappers: [:])
        wrapper.preferredFilename = "Expressions"
        for document in expressionDocuments {
            try document.encode(to: wrapper, using: encoder)
        }
        file.addFileWrapper(wrapper)
        
        wrapper = FileWrapper(directoryWithFileWrappers: [:])
        wrapper.preferredFilename = "Translations"
        for document in translationDocuments {
            try document.encode(to: wrapper, using: encoder)
        }
        file.addFileWrapper(wrapper)
    }
}
