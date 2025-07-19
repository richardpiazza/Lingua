import SwiftUI
import TranslationCatalog

struct StorageSelectorView: View {

    var storageModeAction: (StorageMode) throws -> Void

    @State private var presentFolderPicker: Bool = false
    @State private var selectedMedium: StorageMedium = .sqlite
    @State private var path: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .center) {
                Text("Lingua: Localization Catalog")
                    .font(.largeTitle)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()

            Divider()

            VStack(alignment: .leading) {
                Text("Specify how and where you would like to store your catalog data?")
                    .font(.subheadline)
                    .italic()

                Picker(selection: $selectedMedium) {
                    ForEach(StorageMedium.allCases) { medium in
                        Text(medium.id)
                    }
                } label: {
                    Text("Storage Medium")
                }
                .fixedSize()

                HStack {
                    Text("Path")

                    TextField(text: $path) {
                        Text(selectedMedium == .sqlite ? "SQLite File" : "JSON Directory")
                    }

                    Button {
                        selectURL()
                    } label: {
                        Image(systemName: "externaldrive")
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding()

            Divider()

            VStack(alignment: .trailing) {
                Button {
                    setStorageMode()
                } label: {
                    Text("Save")
                }
                .buttonStyle(.borderedProminent)
                .disabled(path.isEmpty)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding()
        }
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

        switch selectedMedium {
        case .sqlite:
            panel.canChooseDirectories = true
            panel.canChooseFiles = true
        case .json:
            panel.canChooseDirectories = true
            panel.canChooseFiles = false
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
        switch selectedMedium {
        case .json:
            path = url.path
        case .sqlite:
            if url.hasDirectoryPath || !url.path.lowercased().hasSuffix("sqlite") {
                path = url.appendingPathComponent("Lingua.sqlite").path
            } else {
                path = url.path
            }
        }
    }

    private func setStorageMode() {
        guard let url = URL(string: path) else {
            return
        }

        let storageMode: StorageMode
        switch selectedMedium {
        case .sqlite:
            storageMode = .sqlite(url)
        case .json:
            if url.absoluteString.hasSuffix("/") {
                storageMode = .json(url)
            } else if let newURL = URL(string: url.absoluteString.appending("/")) {
                storageMode = .json(newURL)
            } else {
                return
            }
        }

        do {
            try storageModeAction(storageMode)
        } catch {}
    }
}

#Preview {
    StorageSelectorView { _ in
    }
}
