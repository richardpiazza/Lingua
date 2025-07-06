import SwiftUI
import TranslationCatalog
import TranslationCatalogIO

struct ExportExpressionsView: View {
    
    var expressions: [TranslationCatalog.Expression]
    var completion: () -> Void
    
    @Environment(\.storageContainer) private var storageContainer
    @State private var selectedFormats: Set<FileFormat> = [.appleStrings]
    @State private var locales: [Locale.Identifier] = []
    @State private var selectedLocales: [Locale.Identifier] = []
    @State private var path: String = ""
    @State private var url: URL?
    @State private var presentFolderPicker: Bool = false
    @State private var isSaving: Bool = false
    @State private var error: Error?
    @FocusState private var focused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10.0) {
            VStack(alignment: .leading) {
                Text("Export Expressions")
                    .font(.title)
                Text("Generate translation files for multiple languages & platforms.")
                    .font(.subheadline)
            }
            
            Divider()
            
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("Platforms")
                        .font(.title3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack {
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
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Text("Languages")
                            .font(.title3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    ScrollView {
                        VStack {
                            ForEach(locales, id: \.self) { locale in
                                Toggle(isOn: Binding {
                                    selectedLocales.contains(locale)
                                } set: { newValue in
                                    if newValue {
                                        selectedLocales.append(locale)
                                    } else {
                                        selectedLocales.removeAll(where: { $0 == locale })
                                    }
                                }) {
                                    Text(locale)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                }
            }
            
            Divider()
            
            VStack(alignment: .leading) {
                Text("Location")
                    .font(.title3)
                
                HStack {
                    TextField(text: $path) {
                        Text("Export Path")
                    }
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
            }
            
            Divider()
            
            HStack {
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
                .disabled(url == nil || selectedFormats.isEmpty || selectedLocales.isEmpty)
                
                ProgressView()
                    .progressViewStyle(.circular)
                    .controlSize(.small)
                    .padding(.leading, 8)
                    .opacity(isSaving ? 1 : 0)
            }
            
            if let error {
                Text(error.localizedDescription)
                    .foregroundStyle(.red)
            }
        }
        .padding()
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
        .disabled(isSaving)
    }
    
    private func catalogLocales() -> [Locale.Identifier] {
        Array(storageContainer.localeIdentifiers()).sorted(by: { $0 < $1 })
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
                        localeIdentifier: locale,
                        defaultOrFirst: defaultOrFirst
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
    ExportExpressionsView(
        expressions: []
    ) {
    }
    .environment(\.storageContainer, .inMemoryContainer)
}
