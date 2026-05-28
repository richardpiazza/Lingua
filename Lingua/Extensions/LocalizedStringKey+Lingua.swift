import SwiftUI

extension LocalizedStringKey {
    /// Select an Expression
    static let catalogViewContentUnavailableDescription: LocalizedStringKey = "CATALOG_VIEW_CONTENT_UNAVAILABLE_DESCRIPTION"

    enum ButtonTitle {
        /// Cancel
        static let cancel: LocalizedStringKey = "BUTTON_TITLE_CANCEL"
        /// Create
        static let create: LocalizedStringKey = "BUTTON_TITLE_CREATE"
        /// Delete
        static let delete: LocalizedStringKey = "BUTTON_TITLE_DELETE"
        /// Edit
        static let edit: LocalizedStringKey = "BUTTON_TITLE_EDIT"
        /// Export
        static let export: LocalizedStringKey = "BUTTON_TITLE_EXPORT"
        /// Import
        static let `import`: LocalizedStringKey = "BUTTON_TITLE_IMPORT"
        /// OK
        static let ok: LocalizedStringKey = "BUTTON_TITLE_OK"
        /// Remove
        static let remove: LocalizedStringKey = "BUTTON_TITLE_REMOVE"
        /// Save
        static let save: LocalizedStringKey = "BUTTON_TITLE_SAVE"
        /// Select
        static let select: LocalizedStringKey = "BUTTON_TITLE_SELECT"
    }

    enum Create {

        enum ExpressionView {
            /// Localization Key
            static let key: LocalizedStringKey = "CREATE_EXPRESSION_VIEW_KEY"
            /// Add a new expression to the catalog associated to a unique key
            static let message: LocalizedStringKey = "CREATE_EXPRESSION_VIEW_MESSAGE"
            /// Create Expression
            static let title: LocalizedStringKey = "CREATE_EXPRESSION_VIEW_TITLE"
            /// Default Value
            static let value: LocalizedStringKey = "CREATE_EXPRESSION_VIEW_VALUE"
        }

        enum ProjectView {
            /// What would you like to name your new project?
            static let message: LocalizedStringKey = "CREATE_PROJECT_VIEW_MESSAGE"
            /// Name
            static let name: LocalizedStringKey = "CREATE_PROJECT_VIEW_NAME"
            /// Create Project
            static let title: LocalizedStringKey = "CREATE_PROJECT_VIEW_TITLE"
        }
    }

    enum Delete {

        enum ExpressionView {
            /// Are you sure you want to remove this expression and all its related translations?
            static let message: LocalizedStringKey = "DELETE_EXPRESSION_VIEW_MESSAGE"
            /// Delete Expression
            static let title: LocalizedStringKey = "DELETE_EXPRESSION_VIEW_TITLE"
        }

        enum ProjectView {
            /// Are you sure you want to delete project '%1$@' from the catalog? Expressions and Translations will not be affected.
            static let message: LocalizedStringKey = "DELETE_PROJECT_VIEW_MESSAGE"
            /// Delete Project
            static let title: LocalizedStringKey = "DELETE_PROJECT_VIEW_TITLE"
        }
    }

    enum Document {

        enum Kind {

            enum Directory {
                /// Provide a directory where JSON files will be created.\nBest for teams using source control.
                static let description: LocalizedStringKey = "DOCUMENT_KIND_DIRECTORY_DESCRIPTION"
                /// Directory Reference
                static let title: LocalizedStringKey = "DOCUMENT_KIND_DIRECTORY_TITLE"
            }

            enum File {
                /// Choose your own SQLite file on your filesystem.\nGreat for accessing with CLI tools.
                static let description: LocalizedStringKey = "DOCUMENT_KIND_FILE_DESCRIPTION"
                /// External Database
                static let title: LocalizedStringKey = "DOCUMENT_KIND_FILE_TITLE"
            }

            enum Wrappers {
                /// Store data in the file package.\nEverything in one place; ready for iCloud.
                static let description: LocalizedStringKey = "DOCUMENT_KIND_WRAPPERS_DESCRIPTION"
                /// Internal Package
                static let title: LocalizedStringKey = "DOCUMENT_KIND_WRAPPERS_TITLE"
            }
        }

        enum View {
            /// Get Started
            static let continueAction: LocalizedStringKey = "DOCUMENT_VIEW_CONTINUE_ACTION"
            /// How would you like to store your data?
            static let storagePrompt: LocalizedStringKey = "DOCUMENT_VIEW_STORAGE_PROMPT"
        }
    }

    enum ExportView {
        /// Languages
        static let languagesLabel: LocalizedStringKey = "EXPORT_VIEW_LANGUAGES_LABEL"
        /// Location
        static let locationLabel: LocalizedStringKey = "EXPORT_VIEW_LOCATION_LABEL"
        /// Export Expressions
        static let navigationTitle: LocalizedStringKey = "EXPORT_VIEW_NAVIGATION_TITLE"
        /// Export Path
        static let pathLabel: LocalizedStringKey = "EXPORT_VIEW_PATH_LABEL"
        /// Platforms
        static let platformsLabel: LocalizedStringKey = "EXPORT_VIEW_PLATFORMS_LABEL"

        enum Action {
            /// All
            static let all: LocalizedStringKey = "EXPORT_VIEW_ACTION_ALL"
            /// None
            static let none: LocalizedStringKey = "EXPORT_VIEW_ACTION_NONE"
        }
    }

    enum Expression {
        /// Link Project
        static let actionLinkLabel: LocalizedStringKey = "EXPRESSION_ACTION_LINK_LABEL"
        /// New Expression
        static let listViewNewExpressionAction: LocalizedStringKey = "EXPRESSION_LIST_VIEW_NEW_EXPRESSION_ACTION"

        enum View {
            /// Add Translation
            static let addTranslationLabel: LocalizedStringKey = "EXPRESSION_VIEW_ADD_TRANSLATION_LABEL"
            /// Expression
            static let expressionLabel: LocalizedStringKey = "EXPRESSION_VIEW_EXPRESSION_LABEL"
            /// Language
            static let languageLabel: LocalizedStringKey = "EXPRESSION_VIEW_LANGUAGE_LABEL"
            /// Mark as Reviewed
            static let markReviewedLabel: LocalizedStringKey = "EXPRESSION_VIEW_MARK_REVIEWED_LABEL"
            /// Metadata
            static let metadataLabel: LocalizedStringKey = "EXPRESSION_VIEW_METADATA_LABEL"
            /// Mark for Review
            static let needsReviewLabel: LocalizedStringKey = "EXPRESSION_VIEW_NEEDS_REVIEW_LABEL"
            /// Search
            static let searchPrompt: LocalizedStringKey = "EXPRESSION_VIEW_SEARCH_PROMPT"
            /// Translation Options
            static let translationOptionsLabel: LocalizedStringKey = "EXPRESSION_VIEW_TRANSLATION_OPTIONS_LABEL"
            /// Translations
            static let translationsLabel: LocalizedStringKey = "EXPRESSION_VIEW_TRANSLATIONS_LABEL"

            enum Classification {
                /// Tags
                static let label: LocalizedStringKey = "EXPRESSION_VIEW_CLASSIFICATION_LABEL"
                /// Classification that groups this Expression with other in your App
                static let prompt: LocalizedStringKey = "EXPRESSION_VIEW_CLASSIFICATION_PROMPT"
            }

            enum Comments {
                /// Comments
                static let label: LocalizedStringKey = "EXPRESSION_VIEW_COMMENTS_LABEL"
                /// Hints to translators as to how this Expression is used
                static let prompt: LocalizedStringKey = "EXPRESSION_VIEW_COMMENTS_PROMPT"
            }

            enum Display {
                /// Display Name
                static let label: LocalizedStringKey = "EXPRESSION_VIEW_DISPLAY_LABEL"
                /// Optional reference to this Expression
                static let prompt: LocalizedStringKey = "EXPRESSION_VIEW_DISPLAY_PROMPT"
            }

            enum Key {
                /// Localization Key
                static let label: LocalizedStringKey = "EXPRESSION_VIEW_KEY_LABEL"
                /// Unique value that globally identifies this Expression
                static let prompt: LocalizedStringKey = "EXPRESSION_VIEW_KEY_PROMPT"
            }

            enum Value {
                /// Value
                static let label: LocalizedStringKey = "EXPRESSION_VIEW_VALUE_LABEL"
                /// Your reference to this Expression
                static let prompt: LocalizedStringKey = "EXPRESSION_VIEW_VALUE_PROMPT"
            }
        }
    }

    enum ImportView {
        /// Default/Development Language
        static let defaultLanguageLabel: LocalizedStringKey = "IMPORT_VIEW_DEFAULT_LANGUAGE_LABEL"
        /// File
        static let fileLabel: LocalizedStringKey = "IMPORT_VIEW_FILE_LABEL"
        /// Format
        static let formatLabel: LocalizedStringKey = "IMPORT_VIEW_FORMAT_LABEL"
        /// Language
        static let languageLabel: LocalizedStringKey = "IMPORT_VIEW_LANGUAGE_LABEL"
        /// Locale
        static let localeLabel: LocalizedStringKey = "IMPORT_VIEW_LOCALE_LABEL"
        /// Import Expressions
        static let navigationTitle: LocalizedStringKey = "IMPORT_VIEW_NAVIGATION_TITLE"
        /// Path
        static let pathLabel: LocalizedStringKey = "IMPORT_VIEW_PATH_LABEL"
        /// Region
        static let regionLabel: LocalizedStringKey = "IMPORT_VIEW_REGION_LABEL"
        /// Script
        static let scriptLabel: LocalizedStringKey = "IMPORT_VIEW_SCRIPT_LABEL"

        enum Linking {
            /// Link the imported expressions to the selected Project?
            static let description: LocalizedStringKey = "IMPORT_VIEW_LINKING_DESCRIPTION"
            /// Linking
            static let label: LocalizedStringKey = "IMPORT_VIEW_LINKING_LABEL"
        }
    }

    enum MenuCatalog {
        /// Add Expression
        static let addExpression: LocalizedStringKey = "MENU_CATALOG_ADD_EXPRESSION"
        /// Export Translations
        static let exportTranslations: LocalizedStringKey = "MENU_CATALOG_EXPORT_TRANSLATIONS"
        /// Import Translations
        static let importTranslations: LocalizedStringKey = "MENU_CATALOG_IMPORT_TRANSLATIONS"
        /// Catalog
        static let title: LocalizedStringKey = "MENU_CATALOG_TITLE"
    }

    enum RemoveExpressionView {
        /// Are you sure you want to remove this translation from the catalog?
        static let message: LocalizedStringKey = "REMOVE_EXPRESSION_VIEW_MESSAGE"
        /// Remove Translation
        static let title: LocalizedStringKey = "REMOVE_EXPRESSION_VIEW_TITLE"
    }

    enum SidebarView {
        /// All Expressions
        static let allExpressions: LocalizedStringKey = "SIDEBAR_VIEW_ALL_EXPRESSIONS"
        /// Catalog
        static let catalog: LocalizedStringKey = "SIDEBAR_VIEW_CATALOG"
        /// Create Project
        static let createProject: LocalizedStringKey = "SIDEBAR_VIEW_CREATE_PROJECT"
        /// Projects
        static let projects: LocalizedStringKey = "SIDEBAR_VIEW_PROJECTS"
    }

    enum TranslationView {
        /// Language Code
        static let languageLabel: LocalizedStringKey = "TRANSLATION_VIEW_LANGUAGE_LABEL"
        /// Locale
        static let localeLabel: LocalizedStringKey = "TRANSLATION_VIEW_LOCALE_LABEL"
        /// Matches default language translation
        static let matchDefaultWarning: LocalizedStringKey = "TRANSLATION_VIEW_MATCH_DEFAULT_WARNING"
        /// Region Code
        static let regionLabel: LocalizedStringKey = "TRANSLATION_VIEW_REGION_LABEL"
        /// Script Code
        static let scriptLabel: LocalizedStringKey = "TRANSLATION_VIEW_SCRIPT_LABEL"
        /// Translation State
        static let stateLabel: LocalizedStringKey = "TRANSLATION_VIEW_STATE_LABEL"
        /// Translation
        static let translationLabel: LocalizedStringKey = "TRANSLATION_VIEW_TRANSLATION_LABEL"
        /// Translated Value
        static let valueLabel: LocalizedStringKey = "TRANSLATION_VIEW_VALUE_LABEL"
    }
}
