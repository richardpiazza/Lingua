import SwiftUI

struct DocumentView: View {
    
    @Binding var document: CatalogDocument
    
    var body: some View {
        NavigationStack {
            VStack {
                switch document.state {
                case .new:
                    Text("New Document")
                case .notReady:
                    Text("Not Ready")
                case .ready:
                    Text("Ready")
                }
            }
        }
    }
}
