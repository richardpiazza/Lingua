import SwiftUI

struct DocumentKindView: View {

    var action: (Document.Kind, URL?) throws -> Void

    @State private var kind: Document.Kind? = .wrappers
    @State private var file: String = ""
    @State private var directory: String = ""

    private var ready: Bool {
        switch kind {
        case .directory:
            !directory.isEmpty
        case .file:
            !file.isEmpty
        case .wrappers:
            true
        default:
            false
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                Text(.Document.View.storagePrompt)
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                    select(.wrappers)
                } label: {
                    DescriptorKindButton(
                        kind: .wrappers,
                        selected: kind == .wrappers,
                    )
                }

                Button {
                    select(.file)
                } label: {
                    DescriptorKindButton(
                        kind: .file,
                        selected: kind == .file,
                        path: $file,
                    )
                }

                Button {
                    select(.directory)
                } label: {
                    DescriptorKindButton(
                        kind: .directory,
                        selected: kind == .directory,
                        path: $directory,
                    )
                }
            }
            .padding()
            .buttonStyle(.plain)

            Divider()

            VStack {
                Button {
                    getStarted()
                } label: {
                    Label(.Document.View.continueAction, systemImage: "arrow.forward.circle")
                }
                .disabled(!ready)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding()
            .buttonStyle(.borderedProminent)
        }
    }

    private func select(_ kind: Document.Kind) {
        if self.kind == kind {
            self.kind = nil
        } else {
            self.kind = kind
        }
    }

    private func getStarted() {
        guard let kind else {
            return
        }

        var documentUrl: URL?

        switch kind {
        case .directory:
            documentUrl = URL(filePath: directory, directoryHint: .isDirectory)
        case .file:
            documentUrl = URL(filePath: file, directoryHint: .notDirectory)
        case .wrappers:
            break
        }

        do {
            try action(kind, documentUrl)
        } catch {
            print(error)
        }
    }
}

struct DescriptorKindButton: View {

    var kind: Document.Kind
    var selected: Bool = false
    var path: Binding<String>?

    @State private var presentFolderPicker: Bool = false

    var systemImage: String {
        switch kind {
        case .directory: "folder"
        case .file: "cylinder.split.1x2"
        case .wrappers: "archivebox"
        }
    }

    var title: LocalizedStringKey {
        switch kind {
        case .directory: .Document.Kind.Directory.title
        case .file: .Document.Kind.File.title
        case .wrappers: .Document.Kind.Wrappers.title
        }
    }

    var description: LocalizedStringKey {
        switch kind {
        case .directory: .Document.Kind.Directory.description
        case .file: .Document.Kind.File.description
        case .wrappers: .Document.Kind.Wrappers.description
        }
    }

    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: systemImage)
                .font(.largeTitle)
                .frame(minWidth: 20, idealWidth: 30, maxWidth: 40)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(description)
                    .font(.caption)
                    .fixedSize()

                if let path, selected {
                    HStack {
                        TextField(text: path) {
                            Text(kind == .directory ? "JSON Directory" : "SQLite File")
                        }

                        Button {
                            selectURL()
                        } label: {
                            Image(systemName: "externaldrive")
                        }
                    }
                }
            }
        }
        .padding()
        .background(selected ? Color.gray.opacity(0.2) : Color.background)
        .border(selected ? Color.accent : Color.black, width: 1.0)
        #if os(iOS)
            .fullScreenCover(isPresented: $presentFolderPicker) {
                FolderPickerView { result in
                    switch result {
                    case .none:
                        break
                    case .failure(let error):
                        print(error)
                    case .success(let url):
                        setURL(url)
                    }
                }
            }
        #endif
    }

    private func selectURL() {
        #if os(macOS)
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false

        switch kind {
        case .file:
            panel.canChooseDirectories = true
            panel.canChooseFiles = true
        case .directory:
            panel.canChooseDirectories = true
            panel.canChooseFiles = false
        default:
            return
        }

        switch panel.runModal() {
        case .OK:
            if let url = panel.url {
                setURL(url)
            }
        default:
            break
        }
        #else
        presentFolderPicker = true
        #endif
    }

    private func setURL(_ url: URL) {
        switch kind {
        case .directory:
            path?.wrappedValue = url.path
        case .file:
            if url.hasDirectoryPath || !url.path.lowercased().hasSuffix("sqlite") {
                path?.wrappedValue = url.appendingPathComponent("Lingua.sqlite").path
            } else {
                path?.wrappedValue = url.path
            }
        default:
            break
        }
    }
}

#Preview {
    DocumentKindView { _, _ in
    }
    .frame(height: 450)
}
