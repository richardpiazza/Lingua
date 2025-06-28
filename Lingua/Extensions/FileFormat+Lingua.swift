import TranslationCatalogIO

extension FileFormat {
    static let linguaFormats: [FileFormat] = [.appleStrings, .androidXML, .json]
    
    var defaultFileName: String {
        switch self {
        case .androidXML: return "android.\(fileExtension)"
        case .appleStrings: return "apple.\(fileExtension)"
        case .json: return "web.\(fileExtension)"
        }
    }
    
    var displayName: String {
        switch self {
        case .androidXML: return "Android (.xml)"
        case .appleStrings: return "Apple (.strings)"
        case .json: return "Web (.json)"
        }
    }
}
