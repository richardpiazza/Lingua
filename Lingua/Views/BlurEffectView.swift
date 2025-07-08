import SwiftUI

#if os(macOS)
public struct BlurEffectView: NSViewRepresentable {

    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode

    public init(
        material: NSVisualEffectView.Material = .contentBackground,
        blendingMode: NSVisualEffectView.BlendingMode = .withinWindow
    ) {
        self.material = material
        self.blendingMode = blendingMode
    }

    public func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        return view
    }

    public func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
#else
public struct BlurEffectView: UIViewRepresentable {

    var style: UIBlurEffect.Style

    public init(style: UIBlurEffect.Style = .light) {
        self.style = style
    }

    public func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    public func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
#endif

#Preview {
    ZStack {
        LinearGradient(
            colors: [.red, .orange, .yellow, .green, .blue, .purple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .frame(width: 200, height: 100)

        Text("Here's an example.")
            .font(.headline)
            .padding()
            .background(
                BlurEffectView()
            )
    }
}
