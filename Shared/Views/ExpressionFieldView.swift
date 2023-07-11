import SwiftUI

struct ExpressionFieldView: View {
    
    let name: String
    let hint: String
    let value: Binding<String>
    let onCommit: () -> Void
    
    private var columns: [GridItem] {
        horizontallyCompact ?
            [GridItem(.flexible())] :
            [GridItem(.fixed(100)), .init(.flexible())]
    }
    
    private var entryFieldPadding: EdgeInsets {
        horizontallyCompact ?
            .init(top: 0, leading: 12, bottom: 0, trailing: 0) :
            .init()
    }
    
    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading) {
            Text(name)
                .font(.caption)
                .bold()
            
            Text(hint)
                .font(.caption)
                .italic()
                .foregroundColor(.gray)
            
            if !horizontallyCompact {
                Text("")
            }
            
            TextField(name, text: value, onCommit: onCommit)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(entryFieldPadding)
        }
    }
}

struct ExpressionFieldView_Previews: PreviewProvider {
    static var previews: some View {
        ExpressionFieldView(name: "Name", hint: "Your reference to this Expression", value: .constant("Welcome")) {
        }
    }
}
