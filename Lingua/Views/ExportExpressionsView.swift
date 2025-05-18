import SwiftUI
import TranslationCatalog
import TranslationCatalogIO
import Infuse

struct ExportExpressionsView: View {
    
    class ViewModel {
        @Resource private var catalogService: CatalogService
        
        init(catalogService: CatalogService? = nil) {
            if let service = catalogService {
                self.catalogService = service
            }
        }
        
        #if os(macOS)
        func selectURL(completion: (URL?) -> Void) {
            let panel = NSOpenPanel()
            panel.allowsMultipleSelection = false
            panel.canChooseDirectories = true
            panel.canChooseFiles = false

            switch panel.runModal() {
            case .OK:
                if let url = panel.url {
                    completion(url)
                }
            default:
                completion(nil)
                break
            }
        }
        #endif
        
        func exportExpressions(
            _ expressions: [TranslationCatalog.Expression],
            formats: Set<FileFormat>,
            locales: [Locale.Identifier],
            url: URL
        ) throws {
            for locale in locales {
                let path = url.appending(path: "\(locale).lproj", directoryHint: .isDirectory)
                try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true)
                
                for format in formats {
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
        }
        
        func catalogLocales() -> [Locale.Identifier] {
            Array(catalogService.localeIdentifiers())
                .sorted(by: { $0 < $1 })
        }
    }
    
    var viewModel: ViewModel = ViewModel()
    var expressions: [TranslationCatalog.Expression]
    var completion: () -> Void
    
    private let formats: [FileFormat] = [.appleStrings, .androidXML, .json]
    @State private var selectedFormats: Set<FileFormat> = [.appleStrings]
    @State private var locales: [Locale.Identifier] = []
    @State private var selectedLocales: [Locale.Identifier] = []
    @State private var path: String = ""
    @State private var url: URL?
    @State private var presentFolderPicker: Bool = false
    @State private var isSaving: Bool = false
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
                        ForEach(formats, id: \.self) { format in
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
                    do {
                        try viewModel.exportExpressions(
                            expressions,
                            formats: selectedFormats,
                            locales: selectedLocales,
                            url: url!
                        )
                        completion()
                    } catch {
                        print(error)
                    }
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
            locales = viewModel.catalogLocales()
            focused = true
        }
        .disabled(isSaving)
    }
    
    private func selectURL() {
        #if os(macOS)
        viewModel.selectURL { value in
            setURL(value)
        }
        #else
        presentFolderPicker = true
        #endif
    }
    
    private func setURL(_ url: URL?) {
        self.url = url
        path = url?.path ?? ""
    }
}

private extension FileFormat {
    var defaultFileName: String {
        switch self {
        case .androidXML: return "android.\(fileExtension)"
        case .appleStrings: return "apple.\(fileExtension)"
        case .json: return "web.\(fileExtension)"
        }
    }
    
    var displayName: String {
        switch self {
        case .androidXML: return "Android (.xml)"
        case .appleStrings: return "Apple (.strings)"
        case .json: return "Web (.json)"
        }
    }
}

#Preview {
    ExportExpressionsView(
        viewModel: ExportExpressionsView.ViewModel(
            catalogService: EmulatedCatalogService(
                locales: [
                    "en",
                    "es",
                    "pt_BR",
                    "zh-Hans"
                ]
            )
        ),
        expressions: []
    ) {
    }
}
