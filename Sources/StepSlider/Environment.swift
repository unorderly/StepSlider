import SwiftUI

// MARK: - Track Highlight

extension EnvironmentValues {
    @Entry public var trackHighlight: AnyView = .init(EmptyView())
}

struct TrackHighlightModifier<Hightlight: View>: ViewModifier {
    let highlight: Hightlight

    func body(content: Content) -> some View {
        content
            .environment(\.trackHighlight, AnyView(self.highlight))
    }
}

extension View {
    @ViewBuilder
    public func trackHighlight(_ content: (some View)?) -> some View {
        if let content {
            self.modifier(TrackHighlightModifier(highlight: content))
        } else {
            self.modifier(TrackHighlightModifier(highlight: EmptyView()))
        }
    }
}

// MARK: - Track Selection Background

extension EnvironmentValues {
    @Entry public var trackSelection: AnyView = .init(Color.accentColor)
}

struct TrackSelectionModifier<Hightlight: View>: ViewModifier {
    let highlight: Hightlight

    func body(content: Content) -> some View {
        content
            .environment(\.trackSelection, AnyView(self.highlight))
    }
}

extension View {
    @ViewBuilder
    public func trackSelection(_ content: (some View)?) -> some View {
        if let content {
            self.modifier(TrackSelectionModifier(highlight: content))
        } else {
            self.modifier(TrackSelectionModifier(highlight: EmptyView()))
        }
    }
}

// MARK: - Haptic

public protocol SliderHaptics {
    @MainActor
    func playUpdate()
    @MainActor
    func playEdge()
}

struct UIKitHapticAction: SliderHaptics {
#if canImport(UIKit)
    @MainActor private var selectionFeedback = UISelectionFeedbackGenerator()
    @MainActor private var impactFeedback = UIImpactFeedbackGenerator(style: .medium)
#endif
    @MainActor
    func playEdge() {
#if canImport(UIKit)
        self.impactFeedback.impactOccurred()
#endif
    }

    @MainActor
    func playUpdate() {
#if canImport(UIKit)
        self.selectionFeedback.selectionChanged()
#endif
    }
}

extension EnvironmentValues {
    @Entry public var sliderHaptics: SliderHaptics = UIKitHapticAction()
}
