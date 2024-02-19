import SwiftUI

struct ExpressionFieldView: View {
    
    let value: Binding<String>
    let name: String
    let hint: String
    let disabled: Bool
    
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
            
            TextField(name, text: value)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(entryFieldPadding)
                .disabled(disabled)
        }
    }
}

struct ExpressionFieldView_Previews: PreviewProvider {
    static var previews: some View {
        ExpressionFieldView(
            value: .constant("Welcome"),
            name: "Name",
            hint: "Your reference to this Expression",
            disabled: false
        )
    }
}
