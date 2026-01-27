import SwiftUI

#if os(iOS) || os(iPadOS) || targetEnvironment(macCatalyst)
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

struct ColorPickerSheetContent: View {
    let currentCentre: Color
    let submitColorChange: (Color) -> Void
    let showAlpha: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Optional: a small grabber to visually confirm detents
            Capsule().fill(.secondary.opacity(0.4))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 8)

            UIColorPickerPanel(
                currentCentre: currentCentre,
                submitColorChange: submitColorChange,
                showAlpha: showAlpha
            )
        }
        // Avoid .ignoresSafeArea() here
    }
}

#endif
