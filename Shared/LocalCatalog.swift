import Foundation
import TranslationCatalog

class LocalCatalog {
    
    enum Query: CatalogQuery {
        case projectID(Project.ID)
    }
    
    enum Error: Swift.Error {
        case invalidProjectID(Project.ID)
        case invalidExpressionID(Expression.ID)
        case invalidTranslationID(TranslationCatalog.Translation.ID)
    }
    
    private class Store: Codable {
        var projects: [Project] = []
        var projectExpressions: [Project.ID: Expression.ID] = [:]
        var expressions: [Expression] = []
        var translations: [TranslationCatalog.Translation] = []
        var tags: [String] = []
    }
    
    private static var storeURL: URL = {
        guard let supportDirectory = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
            preconditionFailure("Unable to get Application Support directory.")
        }
        
        let applicationDirectory = supportDirectory.appendingPathComponent("LocalCatalog")
        try? FileManager.default.createDirectory(atPath: applicationDirectory.path, withIntermediateDirectories: true, attributes: nil)
        let storeURL = applicationDirectory.appendingPathComponent("store.json")
        return storeURL
    }()
    
    static let `default`: LocalCatalog = .init()
    
    private static let decoder: JSONDecoder = .init()
    private static let encoder: JSONEncoder = {
        let encoder: JSONEncoder = .init()
        encoder.outputFormatting = [.prettyPrinted]
        return encoder
    }()
    
    private let store: Store
    
    private init() {
        let storeURL = Self.storeURL
        
        if !FileManager.default.fileExists(atPath: storeURL.path) {
            if let url = Bundle.main.url(forResource: "store", withExtension: "json") {
                do {
                    try FileManager.default.copyItem(at: url, to: storeURL)
                } catch {
                    print(error)
                    store = Store()
                    return
                }
            }
        }
        
        guard let data = try? Data(contentsOf: storeURL) else {
            print("Unable to load data from 'store.json'.")
            store = Store()
            return
        }
        
        do {
            store = try Self.decoder.decode(Store.self, from: data)
        } catch {
            print(error)
            preconditionFailure("Unable to decode 'store.json'.")
        }
    }
    
    deinit {
        persist()
    }
}

extension LocalCatalog: Catalog {
    
    func projects() throws -> [Project] {
        store.projects
    }
    
    func projects(matching query: CatalogQuery) throws -> [Project] {
        preconditionFailure("Not Implemented")
    }
    
    func project(_ id: Project.ID) throws -> Project {
        guard let project = store.projects.first(where: { $0.id == id }) else {
            throw Error.invalidProjectID(id)
        }
        
        return project
    }
    
    func project(matching query: CatalogQuery) throws -> Project {
        preconditionFailure("Not Implemented")
    }
    
    func createProject(_ project: Project) throws -> Project.ID {
        preconditionFailure("Not Implemented")
    }
    
    func updateProject(_ id: Project.ID, action: CatalogUpdate) throws {
        preconditionFailure("Not Implemented")
    }
    
    func deleteProject(_ id: Project.ID) throws {
        preconditionFailure("Not Implemented")
    }
    
    func expressions() throws -> [Expression] {
        store.expressions
    }
    
    func expressions(matching query: CatalogQuery) throws -> [Expression] {
        preconditionFailure("Not Implemented")
    }
    
    func expression(_ id: Expression.ID) throws -> Expression {
        guard let expression = store.expressions.first(where: { $0.id == id }) else {
            throw Error.invalidExpressionID(id)
        }
        
        return expression
    }
    
    func expression(matching query: CatalogQuery) throws -> Expression {
        preconditionFailure("Not Implemented")
    }
    
//    func expressions(for project: Project.ID) throws -> [Expression] {
//        let expressionIDs = store.projectExpressions.filter({ $0.key == project }).map { $0.value }
//        return store.expressions.filter({ expressionIDs.contains($0.id) })
//    }
    
    func createExpression(_ expression: Expression) throws -> Expression.ID {
        preconditionFailure("Not Implemented")
    }
    
    func updateExpression(_ id: Expression.ID, action: CatalogUpdate) throws {
        preconditionFailure("Not Implemented")
    }
    
    func deleteExpression(_ id: Expression.ID) throws {
        preconditionFailure("Not Implemented")
    }
    
    func translations() throws -> [TranslationCatalog.Translation] {
        store.translations
    }
    
    func translations(matching query: CatalogQuery) throws -> [TranslationCatalog.Translation] {
        preconditionFailure("Not Implemented")
    }

    func translation(_ id: TranslationCatalog.Translation.ID) throws -> TranslationCatalog.Translation {
        guard let translation = store.translations.first(where: { $0.id == id }) else {
            throw Error.invalidTranslationID(id)
        }
        
        return translation
    }
    
    func translation(matching query: CatalogQuery) throws -> TranslationCatalog.Translation {
        preconditionFailure("Not Implemented")
    }
    
//    func translations(for expression: Expression.ID) throws -> [TranslationCatalog.Translation] {
//        store.translations.filter({ $0.expressionID == expression })
//    }
    
    func createTranslation(_ translation: TranslationCatalog.Translation) throws -> TranslationCatalog.Translation.ID {
        preconditionFailure("Not Implemented")
    }
    
    func updateTranslation(_ id: TranslationCatalog.Translation.ID, action: CatalogUpdate) throws {
        preconditionFailure("Not Implemented")
    }
    
    func deleteTranslation(_ id: TranslationCatalog.Translation.ID) throws {
        preconditionFailure("Not Implemented")
    }
}

extension LocalCatalog {
    func persist() {
        guard let data = try? Self.encoder.encode(store) else {
            preconditionFailure("Unable to encode 'store'.")
        }
        
        try? data.write(to: Self.storeURL)
    }
}
