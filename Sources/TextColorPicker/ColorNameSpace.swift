//
//  ColorNameSpace.swift
//  TextColorPicker
//
//  Created by Andrew on 28/01/2026.
//
import SwiftUI

/// Define a global here to store a namespace to be used by the calling routine
/// for transition effects.
/// e.g.
/// ```swift
/// ToolbarItem(placement: .bottomBar) {
///    Button("Color", systemImage: "info") {
///      showColorPicker = true
///    }
/// }
/// .matchedTransitionSource( id: "colorpicker", in: colorNameSpace.transition )
/// ```

public struct ColorNameSpace: Sendable {
    @Namespace var transition
}
public let colorNameSpace = ColorNameSpace()
