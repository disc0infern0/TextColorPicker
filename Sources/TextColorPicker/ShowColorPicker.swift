//
//  TogglingColorPicker.swift
//  toolbars
//
//  Created by Andrew on 19/12/2025.
//
import SwiftUI

/// The heart and soul of the color picker.
/// This controls all the updates to the selected text and the color displayed in the color picker icon
struct ShowColorPicker: ViewModifier {
    @Environment(\.colorViewModel) var colorViewModel
#if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    func panel() -> some View {
        UIColorPickerPanel(
            currentCentre: colorViewModel.centerColor.first ?? .primary,
            submitColorChange: colorViewModel.onReceiveColor,
            showAlpha: colorViewModel.supportsOpacity
        )
        .presentationDetents([.noAlpha, .withAlpha])
        .presentationDragIndicator(.visible)
        .navigationTransition(
            .zoom(sourceID: "colorpicker", in: colorViewModel.namespace)
        )
    }
#endif
    func body(content: Content) -> some View {
        @Bindable var colorViewModel: ColorViewModel = colorViewModel
#if os(macOS)
        content
            .task { colorViewModel.setupPanel() }  // On macOS, prepare a floating panel of colours
#elseif os(iOS) //including iPadOS
        // On iOS:
        // - iPhone (compact width): present the colour picker in a bottom sheet
        // - iPad (regular width): present the colour picker as a popover
        if horizontalSizeClass == .regular {
            content
                .popover( isPresented: $colorViewModel.colorPickerToggle, arrowEdge: .bottom, content: panel )
                .presentationCompactAdaptation(.none) // ensure it stays a popover on iPad
        } else {
            content
                .sheet(isPresented: $colorViewModel.colorPickerToggle, content: panel )
        }

#else
        content
            .overlay {
                Text("The Text Color Picker has not yet been implemented on this platform.")
            }
#endif
    }
}

extension View {
    func showColorPicker() -> some View {
        modifier(ShowColorPicker())
    }
}

extension PresentationDetent {
    static let noAlpha = Self.height(395)
    static let withAlpha = Self.height(590)
}
