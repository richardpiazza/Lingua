import SwiftUI

struct StorageDescriptorView: View {
    
    var storageDescriptor: StorageDescriptor
    
    private var imageName: String {
        switch storageDescriptor.medium {
        case .sqlite:
            "cylinder"
        case .json:
            "folder"
        }
    }
    
    private var title: String {
        storageDescriptor.file
    }
    
    private var description: String {
        switch storageDescriptor.path {
        case .directory(let url):
            url.relativePath
        case .file(let url):
            url.relativePath
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(1.0, contentMode: .fit)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.caption)
                    .truncationMode(.head)
                    .lineLimit(1)
            }
        }
    }
}

#Preview {
    StorageDescriptorView(
        storageDescriptor: try! StorageDescriptor(
            storageMode: .sqlite(.applicationSupportDirectory)
        )
    )
}
