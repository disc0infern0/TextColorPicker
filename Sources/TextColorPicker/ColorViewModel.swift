//
//  ColorViewModel.swift
//  ColorPicker2
//
//  Created by Andrew on 06/01/2026.
//

import SwiftUI

extension EnvironmentValues {
    /// The default value will be overridden
    @Entry var colorViewModel = ColorViewModel(
        selection: .constant(.primary),
        supportsOpacity: true
    )
}


@Observable
final class ColorViewModel {
    @ObservationIgnored @Namespace var colorPickerTransition
    var selectedColor: Color = .primary
    var centerColor: [Color] = [.primary]
    var colorScheme: ColorScheme = .light
    var defaultTextColor: Color { colorScheme == .dark ? .white : .black }

    /// All varieties of init support optional display of an opacity slider
    var supportsOpacity: Bool

    /// The binding passed into the new color picker
    var selection: Binding<Color>?

    /// A boolean toggle controlling whether the UIColorPicker is shown for iOS.
    var colorPickerToggle: Bool = false

    init(supportsOpacity: Bool = true) {
        self.supportsOpacity = supportsOpacity
    }
    
    init(selection: Binding<Color>, supportsOpacity: Bool ) {
        self.selection = selection
        self.supportsOpacity = supportsOpacity
    }

    // Activation of the picker
#if os(macOS)
    /// In macOS/AppKit, we launch a custom NSColorPanel and monitor color changes
    /// through a closure (onReceiveColor) sent to a delegate function which simplty sets the
    /// selectedColor property.
    ///  The NSColor panel once initialised will initially appear, so it is necessary to close it after
    ///  instantiation. To "open" it again, or make it visible, we call the makeKeyAndOrderFront method on
    ///  the panel
    @MainActor
    func setupPanel() {
        let panel = NSColorPickerPanel.customshared
        panel.setup(with: onReceiveColor, showsAlpha: supportsOpacity)
        panel.close()
    }
#endif

    @MainActor
    func showColorPicker() {
      #if os(macOS)
        let panel = NSColorPickerPanel.customshared
        panel.color = NSColor(centerColor.first ?? .primary)
        panel.makeKeyAndOrderFront(nil)
      #else
        colorPickerToggle.toggle()
      #endif
    }
    /// Define a function to be sent to the picker so we can receive color updates.
    func onReceiveColor(_ newColor: Color) {
        selectedColor = newColor
    }

    /// update the center of the color picker to the current colour
    func updateCenterColor(text: AttributedString, textSelection: AttributedTextSelection) {

        // Get a list of the colours in the selection
        // If no colors have been set, the set will still contain one Optional(nil) value
        let colors = textSelection.attributes(in: text)[\.foregroundColor].map{ $0  ?? defaultTextColor }

        if colors.isEmpty {  // should never be the case, but lets assume things might change.
            centerColor = [defaultTextColor]
        } else { // For ranges of more than one colour, show the secondary colour
            centerColor = colors
        }
    }
    /// update the selected text to match the newly selected color
    func selectedColorChanged(text: inout AttributedString, textSelection: inout AttributedTextSelection) {
        // A new color has been selected, so update the text and the color picker centre
        centerColor = [selectedColor]
        if text != "" {
            /// Loop around all containers in the selection
            text.transformAttributes(in: &textSelection) { $0.foregroundColor = selectedColor }
        }
        // Now update the binding that could have been passed into the color picker
        if selection != nil {
            selection!.wrappedValue = selectedColor
        }

    }

    /// Create a mesh gradient for the center of the color picker icon
    /// Do our very best to represent the colours highlighted in the text with a gradient of up to 5 colours.
    func meshGradient() -> MeshGradient {
        let count = centerColor.count

        let pointOptions: [[SIMD2<Float>]] = [ // define a 2 x 2 grid and a 3 x 3 grid over which to lay our colours
                                         [ [0,0], [1,0],
                                           [0,1], [1,1] ],

                                         [ [0,0],  [0.5,0.0], [1,0],
                                           [0,0.5],[0.5,0.5], [1,0.5],
                                           [0,1],  [0.5,1],   [1,1] ]
                                         ]
        var colors: [Color]
        var size: Int = 2
        var points: [SIMD2<Float>] { size==2 ? pointOptions[0] : pointOptions[1]}

        switch count {
            case 0:
                colors = [.primary,.primary,.primary,.primary]
            case 1:
                colors = centerColor+centerColor+centerColor+centerColor
            case 2:
                colors = centerColor + centerColor // 4 colours for each point in the mesh
            case 3:
                colors = centerColor + centerColor + centerColor // 9 colours for each point in the mesh
                size = 3
            case 4:
                colors = centerColor
            case 5:
                colors = [centerColor[0],centerColor[1],centerColor[1],
                          centerColor[0],centerColor[2], centerColor[3],
                          centerColor[4],centerColor[4], centerColor[3] ]
                size = 3
            default:
                colors = [.secondary,.secondary,.secondary,.secondary]
        }
        return MeshGradient(width: size, height: size, points: points, colors: colors)
    }

    
}
