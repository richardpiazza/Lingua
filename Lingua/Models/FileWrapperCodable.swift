import Foundation

protocol FileWrapperCodable: Codable {
    init(from file: FileWrapper, using decoder: JSONDecoder) throws
    func encode(to file: FileWrapper, using encoder: JSONEncoder) throws
}

protocol PreferredNameExpressible {
    static var preferredFilename: String { get }
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
