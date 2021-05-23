import SwiftUI

extension View {
    func equalWidth(_ width: Binding<CGFloat>, padding: CGFloat = 0.0) -> some View {
        return modifier(EqualWidthModifier(width: width, padding: padding))
    }
}

fileprivate struct EqualWidthPreferenceKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: CGFloat = 0.0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

fileprivate struct EqualWidthModifier: ViewModifier {
    let width: Binding<CGFloat>
    let padding: CGFloat
    
    func body(content: Content) -> some View {
        content
            .frame(width: width.wrappedValue, alignment: .trailing)
            .background(GeometryReader { geometry in
                Color.clear.preference(key: EqualWidthPreferenceKey.self, value: geometry.size.width)
            })
            .onPreferenceChange(EqualWidthPreferenceKey.self) { value in
                self.width.wrappedValue = max(self.width.wrappedValue + padding, value + padding)
            }
    }
}
