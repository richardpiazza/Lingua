import Foundation
import Logging
import TelemetryClient
import TranslationCatalog
import TranslationCatalogCoreData
import TranslationCatalogFilesystem
import TranslationCatalogSQLite

class StorageContainer: ObservableObject {

    static var inMemoryContainer: StorageContainer {
        do {
            let catalog = try CoreDataCatalog()
            try catalog.preload()
            return StorageContainer(catalog: catalog)
        } catch {
            preconditionFailure()
        }
    }

    @Persisted("STORAGE_BOOKMARK", defaultValue: nil) private static var bookmarkStorage: Data?

    let projectComparator = ProjectComparator()

    private let catalog: any Catalog
    private let logger: Logger = .lingua

    private var projectSubjects: [UUID: AsyncStream<[Project]>.Continuation] = [:]
    private var projectsByExpressionSubjects: [UUID: (TranslationCatalog.Expression.ID, AsyncStream<[Project]>.Continuation)] = [:]
    private var expressionSubjects: [UUID: (ContentScheme, AsyncStream<[TranslationCatalog.Expression]>.Continuation)] = [:]
    private var translationSubjects: [UUID: (TranslationCatalog.Expression.ID, AsyncStream<[TranslationCatalog.Translation]>.Continuation)] = [:]

    init(catalog: any Catalog) {
        self.catalog = catalog
    }

    static func make(storageMode: StorageMode, bookmark: Bool) throws -> StorageContainer {
        let fileUrl: URL
        let catalog: any Catalog

        switch storageMode {
        case .sqlite(let url):
            fileUrl = URL(fileURLWithPath: url.path)
            catalog = try SQLiteCatalog(url: fileUrl)
        case .json(let url):
            fileUrl = URL(fileURLWithPath: url.path)
            catalog = try FilesystemCatalog(url: fileUrl)
        }

        if bookmark {
            #if os(macOS)
            bookmarkStorage = try? fileUrl.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: [.isDirectoryKey])
            #else
            bookmarkStorage = try? fileUrl.bookmarkData(includingResourceValuesForKeys: [.isDirectoryKey])
            #endif
        }

        return StorageContainer(catalog: catalog)
    }

    static func make() throws -> StorageContainer {
        guard let data = bookmarkStorage else {
            throw LinguaError.storageBookmark
        }

        let storageMode: StorageMode
        var isStale: Bool = false

        #if os(macOS)
        let url = try URL(resolvingBookmarkData: data, options: .withSecurityScope, bookmarkDataIsStale: &isStale)
        #else
        let url = try URL(resolvingBookmarkData: data, bookmarkDataIsStale: &isStale)
        #endif
        guard url.startAccessingSecurityScopedResource() else {
            throw LinguaError.storageBookmark
        }

        Logger.lingua.info("Restoring Bookmark", metadata: [
            "URL": .stringConvertible(url),
        ])

        let resourceValues = try url.resourceValues(forKeys: [.isDirectoryKey])

        if resourceValues.isDirectory == true {
            storageMode = .json(url)
        } else if url.path.contains("sqlite") {
            storageMode = .sqlite(url)
        } else {
            storageMode = .json(url)
        }

        return try make(storageMode: storageMode, bookmark: false)
    }

    static func clearBookmark() {
        bookmarkStorage = nil
    }

    func locales() -> Set<Locale> {
        (try? catalog.locales()) ?? []
    }

    func projects() -> AsyncStream<[Project]> {
        let id = UUID()
        logger.trace("Initializing Projects Stream", metadata: ["ID": .stringConvertible(id)])

        let stream = AsyncStream.makeStream(of: [Project].self)
        stream.continuation.onTermination = { [weak self] termination in
            self?.terminateProjectStream(id)
        }

        projectSubjects[id] = stream.continuation

        defer {
            yieldProjects()
        }

        return stream.stream
    }

    func projects(for expression: TranslationCatalog.Expression.ID) -> AsyncStream<[Project]> {
        let id = UUID()
        logger.trace("Initializing Projects (By Expression) Stream", metadata: [
            "ID": .stringConvertible(id),
            "Expression ID": .stringConvertible(expression),
        ])

        let stream = AsyncStream.makeStream(of: [Project].self)
        stream.continuation.onTermination = { [weak self] termination in
            self?.terminateProjectExpressionStream(id)
        }

        projectsByExpressionSubjects[id] = (expression, stream.continuation)

        defer {
            yieldProjects(for: expression)
        }

        return stream.stream
    }

    func createProject(_ named: String) throws -> Project {
        let query = GenericProjectQuery.named(named)
        if let _ = try? catalog.project(matching: query) {
            throw CatalogError.badQuery(query)
        }

        let id = UUID()
        let project = Project(id: id, name: named)
        try catalog.createProject(project)

        logger.trace("Project Created", metadata: [
            "ID": .stringConvertible(id),
            "Name": .string(named),
        ])
        TelemetryDeck.signal("Project Created")

        defer {
            yieldProjects()
        }

        return project
    }

    func deleteProject(_ id: Project.ID) throws {
        try catalog.deleteProject(id)

        logger.trace("Project Deleted", metadata: ["ID": .stringConvertible(id)])
        TelemetryDeck.signal("Project Deleted")

        yieldProjects()
    }

    func linkExpression(_ id: TranslationCatalog.Expression.ID, to project: Project.ID) throws {
        try catalog.updateProject(project, action: GenericProjectUpdate.linkExpression(id))

        logger.trace("Expression Linked", metadata: [
            "Expression ID": .stringConvertible(id),
            "Project ID": .stringConvertible(project),
        ])

        TelemetryDeck.signal("Expression Linked")

        yieldProjects(for: id)
        yieldExpressions(for: .project(project))
    }

    func unlinkExpression(_ id: TranslationCatalog.Expression.ID, from project: Project.ID) throws {
        try catalog.updateProject(project, action: GenericProjectUpdate.unlinkExpression(id))

        logger.trace("Expression Unlinked", metadata: [
            "Expression ID": .stringConvertible(id),
            "Project ID": .stringConvertible(project),
        ])
        TelemetryDeck.signal("Expression Unlinked")

        yieldProjects(for: id)
        yieldExpressions(for: .project(project))
    }

    private func yieldProjects() {
        do {
            let projects = try catalog.projects()
            for (_, continuation) in projectSubjects {
                continuation.yield(projects)
            }
        } catch {
            Logger.lingua.error("Failed to retrieve projects", metadata: [NSLocalizedDescriptionKey: .string(error.localizedDescription)])
        }
    }

    private func yieldProjects(for expression: TranslationCatalog.Expression.ID) {
        do {
            let projects = try catalog.projects(matching: GenericProjectQuery.expressionId(expression))
            for (_, element) in projectsByExpressionSubjects {
                if element.0 == expression {
                    element.1.yield(projects)
                }
            }
        } catch {
            Logger.lingua.error("Failed to retrieve projects", metadata: [NSLocalizedDescriptionKey: .string(error.localizedDescription)])
        }
    }

    private nonisolated func terminateProjectStream(_ id: UUID) {
        logger.trace("Terminating Projects Stream", metadata: ["ID": .stringConvertible(id)])
        Task { @MainActor [weak self] in
            self?.projectSubjects[id] = nil
        }
    }

    private nonisolated func terminateProjectExpressionStream(_ id: UUID) {
        logger.trace("Terminating Projects (By Expression) Stream", metadata: ["ID": .stringConvertible(id)])
        Task { @MainActor [weak self] in
            self?.projectsByExpressionSubjects[id] = nil
        }
    }

    func expressions(for scheme: ContentScheme) -> AsyncStream<[TranslationCatalog.Expression]> {
        let id = UUID()
        logger.trace("Initializing Expressions Stream", metadata: [
            "ID": .stringConvertible(id),
            "Scheme": .stringConvertible(scheme),
        ])

        let stream = AsyncStream.makeStream(of: [TranslationCatalog.Expression].self)
        stream.continuation.onTermination = { [weak self] termination in
            self?.terminateExpressionStream(id)
        }

        expressionSubjects[id] = (scheme, stream.continuation)

        defer {
            yieldExpressions(for: scheme)
        }

        return stream.stream
    }

    func createExpression(_ localizationKey: String, contentScheme: ContentScheme) throws -> TranslationCatalog.Expression {
        let key = localizationKey.uppercased()
        let query = GenericExpressionQuery.key(key)

        if let _ = try? catalog.expression(matching: query) {
            throw CatalogError.badQuery(query)
        }
        let language = Locale.current.language.languageCode ?? .default

        let expression = TranslationCatalog.Expression(
            key: key,
            name: localizationKey,
            defaultLanguageCode: language,
            context: nil,
            feature: nil,
            translations: [],
        )
        let expressionId = try catalog.createExpression(expression)

        let translation = TranslationCatalog.Translation(
            expressionId: expressionId,
            language: language,
            script: nil,
            region: nil,
            value: localizationKey,
        )
        let translationId = try catalog.createTranslation(translation)

        let new = TranslationCatalog.Expression(
            id: expressionId,
            key: expression.key,
            name: expression.name,
            defaultLanguageCode: expression.defaultLanguageCode,
            context: expression.context,
            feature: expression.feature,
            translations: [
                TranslationCatalog.Translation(
                    id: translationId,
                    expressionId: expressionId,
                    language: translation.language,
                    script: translation.script,
                    region: translation.region,
                    value: translation.value,
                ),
            ],
        )

        logger.trace("Expression Created", metadata: [
            "ID": .stringConvertible(expressionId),
            "Key": .string(key),
        ])
        TelemetryDeck.signal("Expression Created")

        defer {
            yieldExpressions(for: contentScheme)
        }

        return new
    }

    func importExpressions(
        _ expressions: [TranslationCatalog.Expression],
        contentScheme: ContentScheme,
    ) throws {
        for expression in expressions {
            do {
                let expressionId = try catalog.createExpression(expression)
                if case .project(let projectId) = contentScheme {
                    try catalog.updateProject(projectId, action: GenericProjectUpdate.linkExpression(expressionId))
                }
            } catch CatalogError.expressionExistingWithKey(_, let existing) {
                if case .project(let projectId) = contentScheme {
                    try catalog.updateProject(projectId, action: GenericProjectUpdate.linkExpression(existing.id))
                }

                for translation in expression.translations {
                    let expressionTranslation = Translation(translation: translation, expressionId: existing.id)
                    do {
                        try catalog.createTranslation(expressionTranslation)
                    } catch CatalogError.translationExistingWithValue {}
                }
            }
        }

        logger.trace("Expressions Imported", metadata: ["Count": .stringConvertible(expressions.count)])
        TelemetryDeck.signal("Expressions Imported")

        yieldExpressions(for: contentScheme)
    }

    func updateExpression(
        _ expression: TranslationCatalog.Expression,
        update: GenericExpressionUpdate,
        contentScheme: ContentScheme,
    ) throws {
        if case let .key(newKey) = update {
            let query = GenericExpressionQuery.key(newKey)

            if let _ = try? catalog.expression(matching: query) {
                throw CatalogError.badQuery(query)
            }
        }

        try catalog.updateExpression(expression.id, action: update)

        logger.trace("Expression Updated", metadata: ["ID": .stringConvertible(expression.id)])
        TelemetryDeck.signal("Expression Updated")

        yieldExpressions(for: contentScheme)
    }

    func deleteExpression(_ expression: TranslationCatalog.Expression) throws {
        try catalog.deleteExpression(expression.id)

        logger.trace("Expression Deleted", metadata: ["ID": .stringConvertible(expression.id)])
        TelemetryDeck.signal("Expression Deleted")

        let schemes = Set(expressionSubjects.compactMap(\.value.0))
        for scheme in schemes {
            yieldExpressions(for: scheme)
        }
    }

    private func yieldExpressions(for scheme: ContentScheme) {
        do {
            let expressions = switch scheme {
            case .catalog:
                try catalog.expressions()
            case .project(let id):
                try catalog.expressions(matching: GenericExpressionQuery.projectId(id))
            }

            for (_, element) in expressionSubjects {
                if element.0 == scheme {
                    element.1.yield(expressions)
                }
            }
        } catch {
            Logger.lingua.error("Failed to retrieve expressions", metadata: [NSLocalizedDescriptionKey: .string(error.localizedDescription)])
        }
    }

    private nonisolated func terminateExpressionStream(_ id: UUID) {
        logger.trace("Terminating Expressions Stream", metadata: ["ID": .stringConvertible(id)])
        Task { @MainActor [weak self] in
            self?.expressionSubjects[id] = nil
        }
    }

    func translations(for expressionId: TranslationCatalog.Expression.ID) -> AsyncStream<[TranslationCatalog.Translation]> {
        let id = UUID()
        logger.trace("Initializing Translations Stream", metadata: [
            "ID": .stringConvertible(id),
            "Expression ID": .stringConvertible(expressionId),
        ])

        let stream = AsyncStream.makeStream(of: [TranslationCatalog.Translation].self)
        stream.continuation.onTermination = { [weak self] termination in
            self?.terminateTranslationStream(id)
        }

        translationSubjects[id] = (expressionId, stream.continuation)

        defer {
            yieldTranslations(for: expressionId)
        }

        return stream.stream
    }

    func createTranslation(_ translation: TranslationCatalog.Translation) throws -> TranslationCatalog.Translation.ID {
        let id = try catalog.createTranslation(translation)

        let new = TranslationCatalog.Translation(
            id: id,
            expressionId: translation.expressionId,
            language: translation.language,
            script: translation.script,
            region: translation.region,
            value: translation.value,
        )

        logger.trace("Translation Created", metadata: [
            "ID": .stringConvertible(id),
            "Expression ID": .stringConvertible(translation.expressionId),
            "Value": .string(translation.value),
        ])
        TelemetryDeck.signal("Translation Created")

        defer {
            yieldTranslations(for: translation.expressionId)
        }

        return new.id
    }

    func updateTranslation(_ translation: TranslationCatalog.Translation) throws {
        let existing = try catalog.translation(translation.id)

        if existing.language != translation.language {
            try catalog.updateTranslation(translation.id, action: GenericTranslationUpdate.language(translation.language))
        }

        if existing.script != translation.script {
            try catalog.updateTranslation(translation.id, action: GenericTranslationUpdate.script(translation.script))
        }

        if existing.region != translation.region {
            try catalog.updateTranslation(translation.id, action: GenericTranslationUpdate.region(translation.region))
        }

        if existing.value != translation.value {
            try catalog.updateTranslation(translation.id, action: GenericTranslationUpdate.value(translation.value))
        }

        logger.trace("Translation Updated", metadata: ["ID": .stringConvertible(translation.id)])
        TelemetryDeck.signal("Translation Updated")

        yieldTranslations(for: existing.expressionId)
    }

    func deleteTranslation(_ id: TranslationCatalog.Translation.ID) throws {
        let existing = try catalog.translation(id)
        try catalog.deleteTranslation(id)

        logger.trace("Translation Deleted", metadata: ["ID": .stringConvertible(id)])
        TelemetryDeck.signal("Translation Deleted")

        yieldTranslations(for: existing.expressionId)
    }

    private func yieldTranslations(for expressionId: TranslationCatalog.Expression.ID) {
        do {
            let translations = try catalog.translations(matching: GenericTranslationQuery.expressionId(expressionId))
            for (_, element) in translationSubjects {
                if element.0 == expressionId {
                    element.1.yield(translations)
                }
            }
        } catch {
            Logger.lingua.error("Failed to retrieve translations", metadata: [NSLocalizedDescriptionKey: .string(error.localizedDescription)])
        }
    }

    private nonisolated func terminateTranslationStream(_ id: UUID) {
        logger.trace("Terminating Translations Stream", metadata: ["ID": .stringConvertible(id)])
        Task { @MainActor [weak self] in
            self?.translationSubjects[id] = nil
        }
    }
}
