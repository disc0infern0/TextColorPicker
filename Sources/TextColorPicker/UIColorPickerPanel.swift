#if os(iOS) || os(iPadOS) || targetEnvironment(macCatalyst)
import SwiftUI
import UIKit

/// Fairly standard SwiftUI bridge to the color panel used in UIKit, the UIColorPickerViewController
/// A closure is passed to the initialiser that the co-ordinator uses to submit color changes to the view model.
struct UIColorPickerPanel: UIViewControllerRepresentable {
    let currentCentre: Color
    typealias ColorChanger = ((Color)->Void)
    var submitColorChange: ColorChanger = { _ in }

    var showAlpha: Bool = true

    func makeUIViewController(context: Context) -> UIColorPickerViewController {
        let colorPicker = UIColorPickerViewController()
        colorPicker.selectedColor = UIColor(currentCentre)
        colorPicker.supportsAlpha = showAlpha
        colorPicker.title = ""
        colorPicker.delegate = context.coordinator
        return colorPicker
    }
    /// It is not necessary to communicate changes in SwiftUI to the color picker
    func updateUIViewController(_ uiViewController: UIColorPickerViewController, context: Context) { }
    
    func makeCoordinator() -> Coordinator { Coordinator(submitColorChange) }

    class Coordinator: NSObject, UIColorPickerViewControllerDelegate {
        let submitColorChange: ColorChanger
        init(_ submitColorChange: @escaping ColorChanger) {
            self.submitColorChange = submitColorChange
        }
        func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
            // User has chosen a color, so submit the new color to the viewModel
            // (which will trigger an update in the view modifier)
            submitColorChange( Color(viewController.selectedColor) )
        }
    }
}

struct ColorPickerPanel: View {
    let currentCentre: Color
    let submitColorChange: (Color)->Void = { _ in }
    let showAlpha: Bool = true
    let namespace: Namespace.ID
    
    var body: some View {
        UIColorPickerPanel(currentCentre: currentCentre, submitColorChange: submitColorChange, showAlpha: showAlpha)
            .matchedTransitionSource( id: "colorpicker", in: namespace )
    }
}
#Preview {
    @Previewable @State var text: AttributedString = ""
    @Previewable @State var selection = AttributedTextSelection()
    NavigationStack {
        Color.blue
            .overlay {
                Text("A poor representation.\nThe real color panel has nice rounded edges that the preview doesn't")
                    .foregroundColor(.white)
                    .padding()
            }
        UIColorPickerPanel(currentCentre: .blue, showAlpha: false)
            .presentationDetents([.noAlpha, .withAlpha])
    }
}

#endif
