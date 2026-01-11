import SwiftUI

struct ContentSchemeButton: View {

    var contentScheme: ContentScheme
    var selected: Bool = false
    var action: () -> Void

    @Environment(\.storageContainer) private var storageContainer
    @Environment(\.colorScheme) private var colorScheme
    @State private var count: String = ""

    private var systemImage: String {
        switch contentScheme {
        case .catalog:
            "list.bullet.rectangle"
        case .needsReview:
            "checklist"
        case .missingLocales:
            "exclamationmark.bubble"
        default:
            ""
        }
    }

    private var color: Color {
        switch contentScheme {
        case .catalog:
            .yellow
        case .needsReview:
            .orange
        case .missingLocales:
            .indigo
        default:
            .gray
        }
    }

    var body: some View {
        Button {
            action()
        } label: {
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: systemImage)
                        .padding(6)
                        .background(
                            color.clipShape(Circle()),
                        )

                    Text(count)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }

                Text(contentScheme.description)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
        .task {
            for await values in storageContainer.expressions(for: contentScheme) {
                count = values.count.formatted(.number.grouping(.never))
            }
        }
    }
}

#Preview {
    VStack(spacing: 10) {
        ContentSchemeButton(
            contentScheme: .catalog,
            selected: true,
        ) {}

        ContentSchemeButton(
            contentScheme: .needsReview,
            selected: false,
        ) {}
    }
    .padding()
    .frame(width: 200)
    .environment(\.storageContainer, .inMemoryContainer)
}
