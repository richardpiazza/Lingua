import SwiftUI

struct StorageSelectorView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10.0) {
            VStack(alignment: .leading) {
                Text("Catalog Storage")
                    .font(.title)
                Text("Select how and where the information in the catalog is stored.")
                    .font(.subheadline)
            }
            
            Divider()
            
            Text("Storage Options")
            
            
        }
    }
}

struct StorageSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        StorageSelectorView()
    }
}
