// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI

/// Quick configuration variables for the colour picker icon
enum ColourPickerStyle {
    // Rainbow Colors from the mnemonic: Richard Of York Gave Battle In Vain (since we dont have violet, lets make that last word Pain?)
    static let rainbowColors: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo, .purple, .red]
    static let rainbowAnimationDuration = 4.2
    /// How much to shrink the central filled circle that shows the current colour. Shrinking reveals the spinning colour wheel behind it.
    static let shrinkRatio = 0.92 // the outer wheel will always be a % of the view's size.
}

/// A colour picker that indicates its function by both a circular moving pattern, and an inner circle that has an
/// outline of the background color, and is filled with the current text color,
struct ColorPickerIcon: View  {
    @Binding var text: AttributedString
    @Binding var textSelection: AttributedTextSelection

//    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorViewModel) var colorViewModel

    @State private var rotation = 0.0
    @State private var textFrame = CGRect.zero

    /// Essentially this is 3 concentric circles, but managing the proportions of each circle by setting their
    /// sizes individually, and/or by setting insets, is difficult to do for all text sizes we want to align with.
    /// *We need the outer edge of the circle to align with the size of the text, and ensure that the whole view
    /// responds to dynamic text sizing and isnt clipped by it's surroundings.*
    ///
    /// We are going to cheat a little by using Symbols inside a Text view to ensure alignment with the
    /// surrounding text;-  A Zstack of circle (an outer edge only) and circle.fill (same size, but filled in).
    /// Then if we shrink that a little, and overlay it on a spinnign colour wheel, we have the 3 concentric
    /// circles we want, and we only have to manage one number - the amount to shrink. If we set this as
    /// a proportionate value of its current size, say 80%, then it should always scale correctly, and reveal
    /// the correct amount of the colour wheel.
    ///
    var body: some View {
        @Bindable var colorViewModel = colorViewModel
        ZStack {
            Image(systemName: "circle.fill")
                .foregroundStyle(colorViewModel.meshGradient())
            Image(systemName: "circle")
                .foregroundStyle(.background)
        }
        .scaleEffect(ColourPickerStyle.shrinkRatio)
        .background(
            Circle()
                .fill(AngularGradient(colors: ColourPickerStyle.rainbowColors, center: UnitPoint(x: 0.5, y: 0.5), angle: Angle.degrees(360)))
                .rotationEffect(.degrees(rotation))
                .animation(.linear(duration: ColourPickerStyle.rainbowAnimationDuration)
                    .repeatForever(autoreverses: false), value: rotation)
                .task {
                    if !reduceMotion { rotation = 360 }
                }
        )
        .contentShape(.circle)
        .onTapGesture {
            colorViewModel.showColorPicker()
        }
        .showColorPicker()
        .task(id: textSelection ) {
            colorViewModel.updateCenterColor(text: text, textSelection: textSelection)
        }
        .task(id: colorViewModel.selectedColor) {
            colorViewModel.selectedColorChanged(text: &text, textSelection: &textSelection)
        }
    }
}



#Preview("mesh") {
    @Previewable @State var colorViewModel = ColorViewModel()
    Rectangle()
        .foregroundStyle( colorViewModel.meshGradient() )
        .clipShape(.circle)
        .task {
//            colorViewModel.centerColor = [.red, .yellow ]
//            colorViewModel.centerColor = [.red, .blue, .yellow ]
//            colorViewModel.centerColor = [.red, .blue, .green, .yellow ]
            colorViewModel.centerColor = [.red, .blue, .green, .orange, .yellow ]
            
        }
        .frame(width: 200, height: 200)
}
