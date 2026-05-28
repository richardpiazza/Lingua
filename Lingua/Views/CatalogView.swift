import SwiftUI
import TranslationCatalog

struct CatalogView: View {

    @Binding var showCreate: Bool
    @Binding var showImport: Bool
    @Binding var showExport: Bool

    @State private var contentScheme: ContentScheme = .catalog
    @State private var expression: TranslationCatalog.Expression?

    var body: some View {
        NavigationSplitView {
            #if os(macOS)
            MacOSSidebarView(
                contentScheme: $contentScheme,
            )
            .navigationSplitViewColumnWidth(ideal: 245)
            #else
            SidebarView(
                contentScheme: $contentScheme,
            )
            .navigationSplitViewColumnWidth(ideal: 245)
            #endif
        } content: {
            ExpressionListView(
                selectedExpression: $expression,
                showCreate: $showCreate,
                showImport: $showImport,
                showExport: $showExport,
                contentScheme: contentScheme,
            )
            .navigationSplitViewColumnWidth(ideal: 305)
        } detail: {
            if let expression {
                ExpressionView(
                    expression: expression,
                    contentScheme: contentScheme,
                ) {
                    self.expression = nil
                }
            } else {
                ContentUnavailableView(
                    "",
                    systemImage: "rectangle.and.text.magnifyingglass",
                    description: Text(.catalogViewContentUnavailableDescription),
                )
            }
        }
    }
}

#Preview {
    CatalogView(
        showCreate: .constant(false),
        showImport: .constant(false),
        showExport: .constant(false),
    )
    .frame(width: 800)
}
