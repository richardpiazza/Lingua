import SwiftUI
import TranslationCatalog

private struct StorageContainerEnvironmentKey: EnvironmentKey {
    static let defaultValue: StorageContainer = .inMemoryContainer
}

extension EnvironmentValues {
    var storageContainer: StorageContainer {
        get { self[StorageContainerEnvironmentKey.self] }
        set { self[StorageContainerEnvironmentKey.self] = newValue }
    }
}
