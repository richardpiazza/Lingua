import SwiftUI

struct DocumentView: View {

    var configuration: ReferenceFileDocumentConfiguration<Document>
    @Binding var documentState: Document.State
    @Binding var showCreate: Bool
    @Binding var showImport: Bool
    @Binding var showExport: Bool

    var body: some View {
        switch documentState {
        case .new:
            DocumentKindView { kind, url in
                try configuration.document.setup(with: kind, url: url)
                documentState = configuration.document.state
            }
        case .notReady:
            Text("Not Ready - Troubleshoot")
        case .ready(let catalog):
            CatalogView(
                showCreate: $showCreate,
                showImport: $showImport,
                showExport: $showExport,
            )
            .environment(\.storageContainer, StorageContainer(catalog: catalog))
        }
    }
}
