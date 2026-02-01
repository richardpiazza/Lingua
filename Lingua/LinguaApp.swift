import Logging
import Occurrence
import SwiftUI
import TelemetryClient

@main
struct LinguaApp: App {

    #if os(macOS)
    @NSApplicationDelegateAdaptor private var delegate: LinguaAppDelegate
    #endif

    @State private var documentState: Document.State = .new
    @State private var showCreate: Bool = false
    @State private var showImport: Bool = false
    @State private var showExport: Bool = false

    init() {
        Occurrence.bootstrap()

        Logger.lingua.notice("Application Launched", metadata: Bundle.main.metadata)

        let config = TelemetryManagerConfiguration(appID: "A7F887D8-1C46-4A69-BAC5-632ACF4EA5AA")
        TelemetryDeck.initialize(config: config)
        TelemetryDeck.signal("Application Launched")
    }

    var body: some Scene {
        DocumentGroup(
            newDocument: {
                Document()
            },
            editor: { configuration in
                DocumentView(
                    configuration: configuration,
                    documentState: $documentState,
                    showCreate: $showCreate,
                    showImport: $showImport,
                    showExport: $showExport,
                )
                .task {
                    documentState = configuration.document.state
                }
            },
        )
        .commands {
            CatalogCommands(
                documentState: documentState,
                showCreate: $showCreate,
                showImport: $showImport,
                showExport: $showExport,
            )
        }
    }
}

#if os(macOS)
class LinguaAppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // This needs to be `false` when using the `DocumentGroup` view.
        // If true, the application will terminate after a document is selected, before the `DocumentView` is shown.
        false
    }
}
#endif
