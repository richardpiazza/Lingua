import SwiftUI

struct DocumentView: View {
    
    var configuration: FileDocumentConfiguration<CatalogDocument>
    
    var body: some View {
        switch configuration.document.state {
        case .new:
            DescriptorKindView(
                documentUrl: configuration.fileURL
            ) { descriptor in
                configuration.document.descriptor = descriptor
            }
        case .notReady:
            Text("Not Ready")
        case .ready:
            Text("Ready")
        }
    }
}
