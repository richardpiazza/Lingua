import SwiftUI
import TranslationCatalog
import TranslationCatalogIO

struct ExpressionExporterView: View {

    var expressions: [TranslationCatalog.Expression]
    var completion: () -> Void

    @Environment(\.storageContainer) private var storageContainer
    @State private var selectedFormats: Set<FileFormat> = [.appleStrings]
    @State private var locales: [Locale] = []
    @State private var selectedLocales: [Locale] = []
    @State private var path: String = ""
    @State private var url: URL?
    @State private var presentFolderPicker: Bool = false
    @State private var isSaving: Bool = false
    @State private var error: Error?
    @FocusState private var focused: Bool

    var body: some View {
        Form {
            Section {
                HStack {
                    TextField(text: $path) {
                        Text("Export Path")
                    }
                    .textFieldStyle(.roundedBorder)
                    .focused($focused)
                    .onChange(of: path) { _, value in
                        url = URL(filePath: value, directoryHint: .isDirectory)
                    }

                    Button {
                        selectURL()
                    } label: {
                        Image(systemName: "externaldrive")
                    }
                }
            } header: {
                Text("Location")
                    .font(.headline)
            }

            Section {
                ForEach(FileFormat.linguaFormats, id: \.self) { format in
                    Toggle(isOn: Binding {
                        selectedFormats.contains(format)
                    } set: { newValue in
                        if newValue {
                            selectedFormats.insert(format)
                        } else {
                            selectedFormats.remove(format)
                        }
                    }) {
                        Text(format.displayName)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            } header: {
                Text("Platforms")
                    .font(.headline)
            }

            Section {
                ForEach(locales, id: \.identifier) { locale in
                    Toggle(isOn: Binding {
                        selectedLocales.contains(where: { $0.identifier == locale.identifier })
                    } set: { newValue in
                        if newValue {
                            selectedLocales.append(locale)
                        } else {
                            selectedLocales.removeAll(where: { $0.identifier == locale.identifier })
                        }
                    }) {
                        Text(locale.identifier)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            } header: {
                HStack {
                    Text("Languages")
                        .font(.headline)

                    HStack {
                        Button {
                            selectedLocales = locales
                        } label: {
                            Text("All")
                        }
                        .disabled(selectedLocales == locales)

                        Button {
                            selectedLocales = []
                        } label: {
                            Text("None")
                        }
                        .disabled(selectedLocales.isEmpty)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
        .formStyle(.grouped)
        .disabled(isSaving)
        .overlay {
            if isSaving {
                ProgressView()
                    .progressViewStyle(.circular)
                    .controlSize(.small)
            }

            if let error {
                VStack {
                    Text(error.localizedDescription)
                        .foregroundStyle(.red)

                    Button {
                        self.error = nil
                    } label: {
                        Text("OK")
                    }
                }
                .background {
                    Color.white
                }
            }
        }
        .toolbar {
            ToolbarItemGroup {
                Button(role: .cancel) {
                    completion()
                } label: {
                    Text("Cancel")
                }

                Button {
                    export()
                } label: {
                    Text("Export")
                }
                .buttonStyle(.borderedProminent)
                .disabled(url == nil || selectedFormats.isEmpty || selectedLocales.isEmpty)
            }
        }
        .navigationTitle("Export Expressions")
        #if os(iOS)
            .fullScreenCover(isPresented: $presentFolderPicker) {
                FolderPickerView { result in
                    switch result {
                    case .none:
                        setURL(nil)
                    case .failure(let error):
                        print(error)
                        setURL(nil)
                    case .success(let url):
                        setURL(url)
                    }
                }
            }
        #endif
            .onAppear {
                locales = catalogLocales()
                focused = true
            }
    }

    private func catalogLocales() -> [Locale] {
        Array(storageContainer.locales()).sorted(by: { $0.identifier < $1.identifier })
    }

    private func selectURL() {
        #if os(macOS)
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false

        switch panel.runModal() {
        case .OK:
            if let url = panel.url {
                setURL(url)
            }
        default:
            setURL(nil)
        }
        #else
        presentFolderPicker = true
        #endif
    }

    private func setURL(_ url: URL?) {
        self.url = url
        path = url?.path ?? ""
    }

    private func export() {
        guard let url else {
            return
        }

        error = nil
        isSaving = true
        defer {
            isSaving = false
        }

        do {
            for locale in selectedLocales {
                let path = url.appending(path: "\(locale).lproj", directoryHint: .isDirectory)
                try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true)

                for format in selectedFormats {
                    let output = path.appendingPathComponent(format.defaultFileName)
                    let defaultOrFirst = (format == .appleStrings)
                    let data = try ExpressionEncoder.encodeTranslations(
                        for: expressions,
                        fileFormat: format,
                        locale: locale,
                        defaultOrFirst: defaultOrFirst,
                    )
                    try data.write(to: output)
                }
            }

            completion()
        } catch {
            self.error = error
        }
    }
}

#Preview {
    ExpressionExporterView(
        expressions: [],
    ) {}
        .environment(\.storageContainer, .inMemoryContainer)
}
