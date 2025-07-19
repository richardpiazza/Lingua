import TranslationCatalog

extension TranslationCatalog.Project {
    static let bakeshop = TranslationCatalog.Project(
        id: .projectBakeshop,
        name: "Bakeshop",
        expressions: [
            .add,
            .remove,
            .settings,
        ],
    )

    static let brainfog = TranslationCatalog.Project(
        id: .projectBrainfog,
        name: "Brainfog",
        expressions: [
            .settings,
        ],
    )

    static let dynumite = TranslationCatalog.Project(
        id: .projectDynumite,
        name: "Dynumite",
        expressions: [
            .update,
            .settings,
        ],
    )

    static let lingua = TranslationCatalog.Project(
        id: .projectLingua,
        name: "Lingua",
        expressions: [
            .add,
            .remove,
            .settings,
        ],
    )
}
