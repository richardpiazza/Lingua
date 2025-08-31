import TranslationCatalogIO

extension FileFormat {
    static let linguaFormats: [FileFormat] = [.appleStrings, .androidXML, .json]

    var defaultFileName: String {
        switch self {
        case .androidXML: "android.\(fileExtension)"
        case .appleStrings: "apple.\(fileExtension)"
        case .json: "key-value.\(fileExtension)"
        }
    }

    var displayName: String {
        switch self {
        case .androidXML: "Android (.xml)"
        case .appleStrings: "Apple (.strings)"
        case .json: "Key-Value (.json)"
        }
    }
}
