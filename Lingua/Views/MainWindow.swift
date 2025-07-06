import SwiftUI
import TranslationCatalog

struct MainWindow: View {

    @Binding var storageContainer: StorageContainer?
    
    @State private var contentScheme: ContentScheme = .catalog
    @State private var expression: TranslationCatalog.Expression?
    
    var body: some View {
        if let storageContainer {
            NavigationSplitView {
                #if os(macOS)
                MacOSSidebarView(
                    contentScheme: $contentScheme
                )
                .navigationSplitViewColumnWidth(ideal: 245)
                #else
                SidebarView(
                    contentScheme: $contentScheme
                )
                .navigationSplitViewColumnWidth(ideal: 245)
                #endif
            } content: {
                ExpressionListView(
                    selectedExpression: $expression,
                    contentScheme: contentScheme
                )
                .navigationSplitViewColumnWidth(ideal: 305)
            } detail: {
                if let expression {
                    ExpressionView(
                        expression: expression,
                        contentScheme: contentScheme
                    ) {
                        self.expression = nil
                    }
                } else {
                    ContentUnavailableView(
                        "",
                        systemImage: "rectangle.and.text.magnifyingglass",
                        description: Text("Select an Expression")
                    )
                }
            }
            .environment(\.storageContainer, storageContainer)
        } else {
            StorageSelectorView { storageMode in
                storageContainer = try StorageContainer.make(storageMode: storageMode, bookmark: true)
            }
        }
    }
}

#Preview {
    MainWindow(
        storageContainer: .constant(.inMemoryContainer)
    )
    .frame(width: 800)
}

#Preview("No Catalog") {
    MainWindow(
        storageContainer: .constant(nil)
    )
    .frame(width: 800)
}
