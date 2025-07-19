import SwiftUI
import TranslationCatalog
import TranslationCatalogIO

struct ExpressionImporterView: View {

    var contentScheme: ContentScheme
    var completion: () -> Void

    @Environment(\.storageContainer) private var storageContainer
    @State private var projects: [TranslationCatalog.Project] = []
    @State private var linkProject: Bool = true
    @State private var path: String = ""
    @State private var url: URL?
    @State private var fileFormat: FileFormat?
    @State private var defaultLanguage: Locale.LanguageCode = .default
    @State private var languageCode: Locale.LanguageCode?
    @State private var scriptCode: Locale.Script?
    @State private var regionCode: Locale.Region?
    @State private var presentFilePicker: Bool = false
    @State private var isSaving: Bool = false
    @State private var error: Error?
    @FocusState private var focused: Bool

    private var associatedProject: TranslationCatalog.Project? {
        guard case .project(let id) = contentScheme else {
            return nil
        }

        return projects.first(where: { $0.id == id })
    }

    var body: some View {
        Form {
            Section {
                Picker(selection: $fileFormat) {
                    Text("Select")
                        .tag(FileFormat?.none)

                    ForEach(FileFormat.linguaFormats, id: \.self) { format in
                        Text(format.displayName)
                            .tag(FileFormat?.some(format))
                    }
                } label: {
                    Text("Format")
                        .font(.headline)
                }

                HStack {
                    TextField(text: $path) {
                        Text("Path")
                    }
                    .textFieldStyle(.roundedBorder)
                    .focused($focused)
                    .onChange(of: path) { _, value in
                        url = URL(filePath: value, directoryHint: .notDirectory)
                    }

                    Button {
                        selectURL()
                    } label: {
                        Image(systemName: "externaldrive")
                    }
                }
            } header: {
                Text("File")
                    .font(.headline)
            }

            Section {
                Picker(selection: $languageCode) {
                    Text("Select")
                        .tag(Locale.LanguageCode?.none)

                    ForEach(Locale.LanguageCode.allCases, id: \.self) { code in
                        Text(code.pickerName)
                            .tag(Locale.LanguageCode?.some(code))
                    }
                } label: {
                    Text("Language")
                }

                Picker(selection: $scriptCode) {
                    Text("")
                        .tag(Locale.Script?.none)

                    ForEach(Locale.Script.allCases, id: \.self) { code in
                        Text(code.pickerName)
                            .tag(Locale.Script?.some(code))
                    }
                } label: {
                    Text("Script")
                }

                Picker(selection: $regionCode) {
                    Text("")
                        .tag(Locale.Region?.none)

                    ForEach(Locale.Region.allCases, id: \.self) { code in
                        Text(code.pickerName)
                            .tag(Locale.Region?.some(code))
                    }
                } label: {
                    Text("Region")
                }
            } header: {
                Text("Locale")
                    .font(.headline)
            }

            Section {
                Picker(selection: $defaultLanguage) {
                    ForEach(Locale.LanguageCode.allCases, id: \.self) { code in
                        Text(code.pickerName)
                            .tag(code)
                    }
                } label: {}
            } header: {
                Text("Default/Development Language")
                    .font(.headline)
            }

            if let associatedProject {
                Section {
                    Toggle(isOn: $linkProject) {
                        Text(associatedProject.name)
                    }
                } header: {
                    Text("Linking")
                        .font(.headline)
                } footer: {
                    Text("Link the imported expressions to the selected Project?")
                        .font(.caption)
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
        .task {
            for await values in storageContainer.projects() {
                projects = values
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
                    performImport()
                } label: {
                    Text("Import")
                }
                .buttonStyle(.borderedProminent)
                .disabled(url == nil || fileFormat == nil || languageCode == nil)
            }
        }
        .navigationTitle("Import Expressions")
        #if os(iOS)
            .fullScreenCover(isPresented: $presentFolderPicker) {}
        #endif
    }

    private func selectURL() {
        #if os(macOS)
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true

        switch panel.runModal() {
        case .OK:
            if let url = panel.url {
                setURL(url)
            }
        default:
            setURL(nil)
        }
        #else
        presentFilePicker = true
        #endif
    }

    private func setURL(_ url: URL?) {
        self.url = url
        path = url?.path ?? ""
    }

    private func performImport() {
        guard let url else {
            return
        }

        guard let fileFormat else {
            return
        }

        guard let languageCode else {
            return
        }

        error = nil
        isSaving = true
        defer {
            isSaving = false
        }

        do {
            let data = try Data(contentsOf: url)

            let expressions = try ExpressionDecoder.decodeExpressions(
                from: data,
                fileFormat: fileFormat,
                defaultLanguage: defaultLanguage,
                language: languageCode,
                script: scriptCode,
                region: regionCode,
            )

            var scheme: ContentScheme = .catalog
            if case .project = contentScheme, linkProject {
                scheme = contentScheme
            }

            try storageContainer.importExpressions(expressions, contentScheme: scheme)

            completion()
        } catch {
            self.error = error
        }
    }
}

#Preview {
    ExpressionImporterView(
        contentScheme: .project(.projectLingua),
    ) {}
        .environment(\.storageContainer, .inMemoryContainer)
}
