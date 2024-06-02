import SwiftUI

// MARK: - Track Background

struct TrackBackgroundKey: EnvironmentKey {
    static var defaultValue = AnyView(Color.trackBackground)
}

public extension EnvironmentValues {
    var trackBackground: AnyView {
        get { self[TrackBackgroundKey.self] }
        set { self[TrackBackgroundKey.self] = newValue }
    }
}

struct TrackBackgroundModifier<Background: View>: ViewModifier {
    let background: Background

    func body(content: Content) -> some View {
        content
            .environment(\.trackBackground, AnyView(self.background))
    }
}

public extension View {
    func trackBackground<Content: View>(_ content: Content) -> some View {
        self.modifier(TrackBackgroundModifier(background: content))
    }
}

// MARK: - Track Highlight

struct TrackHighlightKey: EnvironmentKey {
    static var defaultValue = AnyView(EmptyView())
}

public extension EnvironmentValues {
    var trackHighlight: AnyView {
        get { self[TrackHighlightKey.self] }
        set { self[TrackHighlightKey.self] = newValue }
    }
}

struct TrackHighlightModifier<Hightlight: View>: ViewModifier {
    let highlight: Hightlight

    func body(content: Content) -> some View {
        content
            .environment(\.trackHighlight, AnyView(self.highlight))
    }
}

public extension View {
    @ViewBuilder func trackHighlight<Content: View>(_ content: Content?) -> some View {
        if let content = content {
            self.modifier(TrackHighlightModifier(highlight: content))
        } else {
            self.modifier(TrackHighlightModifier(highlight: EmptyView()))
        }
    }
}

// MARK: - Track Selection Background

struct TrackSelectionKey: EnvironmentKey {
    static var defaultValue = AnyView(Color.accentColor)
}

public extension EnvironmentValues {
    var trackSelection: AnyView {
        get { self[TrackSelectionKey.self] }
        set { self[TrackSelectionKey.self] = newValue }
    }
}

struct TrackSelectionModifier<Hightlight: View>: ViewModifier {
    let highlight: Hightlight

    func body(content: Content) -> some View {
        content
            .environment(\.trackSelection, AnyView(self.highlight))
    }
}

public extension View {
    @ViewBuilder func trackSelection<Content: View>(_ content: Content?) -> some View {
        if let content = content {
            self.modifier(TrackSelectionModifier(highlight: content))
        } else {
            self.modifier(TrackSelectionModifier(highlight: EmptyView()))
        }
    }
}

// MARK: - Haptic

public protocol SliderHaptics {
    func playUpdate()
    func playEdge()
}

struct UIKitHapticAction: SliderHaptics {
#if canImport(UIKit)
private var selectionFeedback = UISelectionFeedbackGenerator()
private var impactFeedback = UIImpactFeedbackGenerator(style: .medium)
#endif

    func playEdge() {
#if canImport(UIKit)
        impactFeedback.impactOccurred()
#endif
    }

    func playUpdate() {
#if canImport(UIKit)
        selectionFeedback.selectionChanged()
#endif
    }
}

struct SliderHapticsKey: EnvironmentKey {
    static var defaultValue: SliderHaptics = UIKitHapticAction()
}

public extension EnvironmentValues {
    var sliderHaptics: SliderHaptics {
        get { self[SliderHapticsKey.self] }
        set { self[SliderHapticsKey.self] = newValue }
    }
}
