import SwiftUI
import TranslationCatalog

struct ExpressionView: View {
    
    @ObservedObject var viewModel: ExpressionDetailsViewModel
    
    init(viewModel: ExpressionDetailsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ExpressionFieldView(
                name: "Name",
                hint: "Your reference to this Expression",
                value: $viewModel.name,
                onCommit: viewModel.persistName
            )
            
            ExpressionFieldView(
                name: "Localization Key",
                hint: "Unique value that globally identifies this Expression",
                value: $viewModel.key,
                onCommit: viewModel.persistKey
            )
            
            ExpressionFieldView(
                name: "Context",
                hint: "Hints to translators as to how this Expression is used",
                value: $viewModel.context,
                onCommit: viewModel.persistContext
            )
            
            ExpressionFieldView(
                name: "Feature",
                hint: "Classification that groups this Expression with others in your App",
                value: $viewModel.feature,
                onCommit: viewModel.persistFeature
            )
        }
    }
}

struct ExpressionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ExpressionView(viewModel: .init(expression: .preview))
            
            ExpressionView(viewModel: .init(expression: .preview_new))
        }
    }
}
