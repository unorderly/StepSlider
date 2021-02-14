import SwiftUI

//MARK: - Track Background

struct TrackBackgroundKey: EnvironmentKey {
    static var defaultValue: AnyView = AnyView(Color.trackBackground)
}


extension EnvironmentValues {
    public var trackBackground: AnyView {
        get { self[TrackBackgroundKey.self] }
        set { self[TrackBackgroundKey.self] = newValue }
    }
}

struct TrackBackgroundModifier<Background: View>: ViewModifier {

    let background: Background

    func body(content: Content) -> some View {
        content
            .environment(\.trackBackground, AnyView(background))
    }
}

extension View {
    public func trackBackground<Content: View>(_ content: Content) -> some View {
        self.modifier(TrackBackgroundModifier(background: content))
    }
}

//MARK: - Track Highlight

struct TrackHighlightKey: EnvironmentKey {
    static var defaultValue: AnyView = AnyView(EmptyView())
}


extension EnvironmentValues {
    public var trackHighlight: AnyView {
        get { self[TrackHighlightKey.self] }
        set { self[TrackHighlightKey.self] = newValue }
    }
}

struct TrackHighlightModifier<Hightlight: View>: ViewModifier {

    let highlight: Hightlight

    func body(content: Content) -> some View {
        content
            .environment(\.trackHighlight, AnyView(highlight))
    }
}

extension View {
    @ViewBuilder public func trackHighlight<Content: View>(_ content: Content?) -> some View {
        if let content = content {
            self.modifier(TrackHighlightModifier(highlight: content))
        } else {
            self.modifier(TrackHighlightModifier(highlight: EmptyView()))
        }
    }
}
