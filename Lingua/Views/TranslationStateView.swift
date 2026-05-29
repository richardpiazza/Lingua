import SwiftUI
import TranslationCatalog

struct TranslationStateView: View {

    var state: TranslationState
    var matchesDefault: Bool = false

    private var color: Color {
        switch state {
        case .needsReview:
            Color.green
        case .new:
            Color.blue
        case .translated:
            Color.orange
        default:
            Color.clear
        }
    }

    var body: some View {
        switch state {
        case .translated:
            if matchesDefault {
                Image(systemName: "rectangle.on.rectangle")
                    .symbolVariant(.fill)
                    .foregroundStyle(Color.orange)
                    .help(.TranslationView.matchDefaultWarning)
            } else {
                EmptyView()
            }
        default:
            Text(state.name)
                .font(.caption2)
                .foregroundStyle(Color.white)
                .padding(.vertical, 1.5)
                .padding(.horizontal, 5)
                .background(
                    color.clipShape(Capsule()),
                )
        }
    }
}

#Preview {
    VStack {
        ForEach(TranslationState.allCases) { state in
            TranslationStateView(state: state)
            TranslationStateView(state: state, matchesDefault: true)
        }
    }
}
