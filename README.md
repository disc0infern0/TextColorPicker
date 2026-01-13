# TextColorPicker

A lightweight, platform-adaptive text color picker designed for SwiftUI toolbars and editors for adding/updating the color in an AttributedString.
It mirrors the ergonomics of Apple's stock `ColorPicker` while providing a consistent UX for the picker icon on iPhone, iPad and macOS. The UX is similar to the iOS design, with a number of improvements highlighted below.
The color panel itself uses the platform specific panel, and on iPhone it is presented as a bottom-sheet, on iPad, it appears as a popover, and on macOS, as a floating panel.

## Usage
When used with AttributedString bindings;
```
TextColorPicker("Text Color", text: $text, textSelection: $textSelection)
```
or
```
TextColorPicker(text: $text, textSelection: $textSelection) {
    Text("Pick a color").foregroundStyle(.green)
}
```

When used with a Color binding; 
```
TextColorPicker("Text Color", selection: $color)
```
or
```
TextColorPicker(selection: $color) { 
    Text("Pick a color".foregroundStyle(.green) 
}
```

## Key Features
- Consistent picker UX across iOS, iPadOS, and macOS. (The stock picker for macOS is significantly different)
- The outer edge of the picker icon is subtly animated, showing a revolving color wheel around the outside, further emphasising its purpose
- When used with AttributedString;-
  - The picker icon center color is kept fully in sync with the color of the current insertion point
  - Whenever a range of text is highlighted that contains more than one colour, the center of the picker icon changes to show a meshed gradient of the colours (up to 5)
  - If more than 5 colours are highlighted, then the .secondary color is displayed. (gray).
- Fully compatible with the stock Apple ColorPicker api, including:
  - Labels supplied as strings and as closures.
  - Accepts a color binding as per the stock api. (if not working with AttributedString, and a consistent UX for the picker is desired)
  - Hiding labels with the `.labelsHidden()` view modifier.
  - Respect whether opacity/alpha is supported


## Design Overview
`TextColorPicker` is written in modern SwiftUI and compiles against Swift 6.2 with all concurrency checks enabled.
The invocation point, `TextColorPicker(...)` initally opens a view that labels it's content with whatever label (or none) has been supplied, then displays the picker icon, which has a view modifier  `ShowColorPicker` attached, and wires the view to a shared `ColorViewModel`. The view modifier controls when and how the color picker is presented and ensures the selected color is applied to your text model while keeping the toolbar icon in sync.
### Separation of concerns
   • TextColorPicker exposes the public API and label handling.
   • ColorPickerIcon owns presentation triggers and visual state.
   • ShowColorPicker handles platform-appropriate presentation and detents.
   • ColorViewModel centralizes state and logic for selection, mesh gradients, and panel wiring.
   • UIColorPickerPanel / NSColorPickerPanel keep platform specifics localized.

## UX / API
- Platform-adaptive presentation:
  - iPhone (compact width): bottom sheet with custom detents
  - iPad (regular width): popover anchored to the invoking control
  - macOS: floating color panel prepared on demand
- Model-driven updates using an environment-injected `ColorViewModel`
- Fully compatible with Apple ColorPicker api.
- Centralized color state, including a `centerColor` used to seed the picker UI


## Platform behavior
### iOS (including iPadOS)
- Uses size class to determine presentation style
  - Regular width (typically iPad): `.popover` with `.presentationCompactAdaptation(.none)` to remain a popover
  - Compact width (typically iPhone): `.sheet` with custom detents
- Custom detents:
  - `.noAlpha` = height 395
  - `.withAlpha` = height 590
- Drag indicator hidden for a cleaner, tool-like appearance

### macOS
- Prepares a floating panel on task start: `colorViewModel.setupPanel()`
- Integrates with the system color experience while remaining focused on text color selection

### Other platforms
- Displays a placeholder overlay noting that the picker is not yet implemented

## Similarities to Apple's stock ColorPicker
- System-native look and feel per platform
- Integration with SwiftUI state via bindings or observable models
- Optional support for opacity/alpha sliders
- Popover/sheet-style presentation that matches platform conventions
- Control over whether opacity is exposed to the user
- Supports the both stock ColorPicker initializers for adding a label.
- Icon scales with text, and supports the ```.labelsHidden()``` modifier


## Differences and enhancements
- Purpose-built for text styling workflows (toolbar/editor integration)
- The icon is subtly animated, showing a revolving color wheel around the outside.
- Improved centre icon on the color picker; 
  - Dynamically changes color whenever the text selection is changed
  - When text is highlilghted containing multiple colors, it will always attempts to show the range of colors highlighted in a mesh. (up to 5)
  
- Deterministic presentation behavior:
  - iPad: always remains a popover (no compact adaptation)
  - iPhone: consistent bottom-sheet UX with fixed detents
  - Extensible hook (`onReceiveColor`) to apply color changes immediately to your text model

## TO-DO: Screenshots
Place screenshots in an `Assets/` folder at the project root and name them as follows. Update the paths below if you choose different names.

- iPhone (sheet): `Assets/iphone-sheet.png`
- iPad (popover): `Assets/ipad-popover.png`
- macOS (floating panel): `Assets/macos-panel.png`

```md
![iPhone - Sheet](Assets/iphone-sheet.png)

![iPad - Popover](Assets/ipad-popover.png)

![macOS - Floating Panel](Assets/macos-panel.png)
