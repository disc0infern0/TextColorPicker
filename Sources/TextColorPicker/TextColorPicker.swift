//
//  File.swift
//  ColorPicker2
//
//  Created by Andrew on 08/01/2026.
//
import SwiftUI

/// Label wrapper around the actual icon that launches the color picker
/// LabeledContent will cause the label to be hidden if the view modifier .labelshidden  is used.
///
public struct TextColorPicker<Label: View>: View {
    var text: Binding<AttributedString>
    var textSelection: Binding<AttributedTextSelection>

    @Environment(\.colorScheme) var colorScheme

    // Store either a text key or a custom label closure, not both.
    @State private var label: LabelType = .none

    @State var colorViewModel: ColorViewModel

    private enum LabelType {
        case none, text(LocalizedStringKey), custom(() -> Label)
        @ViewBuilder var view : some View {
            switch self {
                case .none: EmptyView()
                case .text(let text): Text(text)
                case .custom(let builder): builder()
            }
        }
    }

    /// Initialisers for AttributedStrings, where the bindings to text and textSelection parameters
    /// replace the color binding used in the stock color picker.
    /// A binding for a color is not necessary in this case as the color changes will be applied directly
    /// to the attributed string.
    public init(
        _ titleKey: LocalizedStringKey? = nil,
        text: Binding<AttributedString>,
         textSelection: Binding<AttributedTextSelection>,
         supportsOpacity: Bool = true
    ) where Label == Text {
        self.label = titleKey==nil ? .none : .text(titleKey!)
        self.text = text
        self.textSelection = textSelection
        _colorViewModel =
        State( wrappedValue: ColorViewModel(supportsOpacity: supportsOpacity)
        )
    }

    public init(
        text: Binding<AttributedString>,
        textSelection: Binding<AttributedTextSelection>,
        supportsOpacity: Bool = true,
        @ViewBuilder _ labelBuilder: @escaping () -> Label
    )  {
        self.label = .custom(labelBuilder)
        self.text = text
        self.textSelection = textSelection
        _colorViewModel =
        State( wrappedValue: ColorViewModel(supportsOpacity: supportsOpacity)
        )
    }
    // The two initializers below replicate the stock ColorPicker init options

    /// Initializer for an optional text label;
    /// constrains Label to Never so the compiler can infer it
    public init( _ titleKey: LocalizedStringKey? = nil,
          selection: Binding<Color>,
          supportsOpacity: Bool = true
    ) where Label == Never {
        self.text = .constant(AttributedString(""))
        self.textSelection = .constant(AttributedTextSelection())

        self.label = titleKey==nil ? .none : .text(titleKey!)

        _colorViewModel = State( wrappedValue: ColorViewModel(
            selection: selection, supportsOpacity: supportsOpacity)
        )
    }

    /// Initializer for a custom label builder
    public init(selection: Binding<Color>,
         supportsOpacity: Bool = true,
         @ViewBuilder _ labelBuilder: @escaping () -> Label) {
        self.label = .custom(labelBuilder)
        self.text = .constant(AttributedString(""))
        self.textSelection = .constant(AttributedTextSelection())
        _colorViewModel = State( wrappedValue: ColorViewModel(
            selection: selection, supportsOpacity: supportsOpacity )
        )
    }

    public var body: some View {
        ColorPickerIcon(text: text, textSelection: textSelection)
            .environment(\.colorViewModel, colorViewModel)
            .onAppear { colorViewModel.colorScheme = colorScheme }
            .labeled(with: label.view )
    }
    //    var body: some View {
//        LabeledContent {
//            ColorPicker2Content(text: text, textSelection: textSelection)
//                .environment(\.colorViewModel, colorViewModel)
//                .onAppear { colorViewModel.colorScheme = colorScheme }
//        } label: {
//            labelType.view
//        }
//    }
}

extension View {
    func labeled<Label: View>(with label: Label) -> some View {
        LabeledContent {
            self
        } label: { label }
    }
}


#Preview("icon") {
    @Previewable @State var text: AttributedString = "The quick red fox"
    @Previewable @State var selection = AttributedTextSelection()

    @Previewable @State var color = Color.red

    VStack {
        TextEditor(text: $text, selection: $selection)
        HStack {
            TextColorPicker(text: $text, textSelection: $selection) {
                Text("Pick a color")
            }
            .font(.largeTitle)
//            .font(.title)
//            .font(.title2)
//            .font(.title3)
//            .font(.body)
            .border(.secondary.opacity(0.2))
        }
    }
    .task {
        text[text.range(of: "quick ")!].foregroundColor = .purple
        text[text.range(of: "fox")!].foregroundColor = .red
    }

    .frame(width: 300, height: 300)
}
