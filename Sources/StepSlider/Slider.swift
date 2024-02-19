import SwiftUI

struct SliderTrack<Value: Hashable, TrackLabel: View>: View, Equatable {
    static func == (lhs: SliderTrack<Value, TrackLabel>, rhs: SliderTrack<Value, TrackLabel>) -> Bool {
        lhs.selected == rhs.selected && lhs.values == rhs.values
    }

    @Binding var selected: Value
    let values: [Value]

    let trackLabels: (Value) -> TrackLabel

    #if targetEnvironment(macCatalyst)
    @ScaledMetric(relativeTo: .callout) var size: CGFloat = 38
    #else
    @ScaledMetric(relativeTo: .callout) var size: CGFloat = 44
    #endif

    var body: some View {
        HStack {
            ForEach(values, id: \.self) { value in
                Button(action: {
                    self.selected = value
                }) {
                    HStack {
                        Spacer(minLength: 0)
                        self.trackLabels(value)
                            .font(.callout)
                            .foregroundColor(.trackLabel)
                            .minimumScaleFactor(0.1)
                            .lineLimit(1)
                            .padding(4)
                        Spacer(minLength: 0)
                    }
                    .frame(minHeight: size)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibility(addTraits: value == selected ? .isSelected : [])
            }
        }
    }
}

#if canImport(UIKit)
private var selectionFeedback = UISelectionFeedbackGenerator()
private var impactFeedback = UIImpactFeedbackGenerator(style: .medium)
#endif

struct Slider<Value: Hashable, TrackLabel: View, ThumbLabel: View>: View {
    public let values: [Value]

    @Binding public var selected: Value

    private let trackLabels: (Value) -> TrackLabel
    private let thumbLabels: (Value) -> ThumbLabel

    private let valueIndices: (Value, [Value]) -> (Int, Int)

    @GestureState private var dragState: CGFloat? = nil

    @Environment(\.trackBackground) var trackBackground
    @Environment(\.trackHighlight) var trackHighlight
    @Environment(\.trackSelection) var trackSelectionColor
    
    @Environment(\.accessibilityReduceMotion) var accessibilityReduceMotion
    @Environment(\.layoutDirection) var layoutDirection

    init(selected: Binding<Value>,
         values: [Value],
         trackLabels: @escaping (Value) -> TrackLabel,
         thumbLabels: @escaping (Value) -> ThumbLabel,
         valueIndices: @escaping (Value, [Value]) -> (Int, Int)) {
        self._selected = selected
        self.values = values
        self.trackLabels = trackLabels
        self.thumbLabels = thumbLabels
        self.valueIndices = valueIndices
    }

    public var body: some View {
        SliderTrack(selected: $selected, values: values, trackLabels: trackLabels)
            .equatable()
            .overlay(overlay)
            .background(highlightTrack)
            .padding(6)
            .background(trackBackground.cornerRadius(10))
    }

    private var animation: Animation? {
        self.accessibilityReduceMotion ? nil : .spring()
    }

    private var overlay: some View {
        GeometryReader { proxy in
            thumb(in: proxy)
        }
        .accessibility(hidden: true)
    }

    private func dragProgress(in width: CGFloat) -> CGFloat {
        if let progress = self.dragState {
            return progress
        } else {
            let (left, right) = self.valueIndices(self.selected, self.values)
            let start = self.values.progress(for: left, in: width)
            let end = self.values.progress(for: right, in: width)
            return (start + end) / 2
        }
    }

    private var highlightTrack: some View {
        GeometryReader { proxy in
            trackHighlight
                .cornerRadius(10)
                .padding(dragState != nil && !accessibilityReduceMotion ? -6 : 0)
                .frame(width: self.values
                        .thumbOffset(for: dragProgress(in: proxy.size.width), in: proxy.size.width) + self.values
                        .elementWidth(in: proxy.size.width))
                .animation(self.animation, value: dragState != nil ? 0 : selected.hashValue)
        }
    }

    private func thumb(in proxy: GeometryProxy) -> some View {
        Rectangle()
            .foregroundColor(.clear)
            .overlay(self.thumbText)
            .background(trackSelectionColor
                            .cornerRadius(10)
                            .padding(self.dragState != nil && !self.accessibilityReduceMotion ? -6 : 0))
            .shadow(color: Color.black.opacity(0.12), radius: 4)
            .frame(width: self.values.elementWidth(in: proxy.size.width))
            .offset(x: self.values.thumbOffset(for: self.dragProgress(in: proxy.size.width), in: proxy.size.width))
            .animation(self.animation, value: self.dragState != nil ? 0 : self.selected.hashValue)
            .onChange(of: self.selected, perform: { _ in
                #if canImport(UIKit)
                selectionFeedback.selectionChanged()
                #endif
            })
            .onChange(of: self.dragState, perform: { [dragState] state in
                if let progress = state ?? dragState {
                    let selected = self.values.element(forProgress: progress)
                    if self.selected != selected {
                        self.selected = selected
                    }
                    let endProgress = values.progress(for: values.count - 1, in: proxy.size.width)
                    let startProgress = values.progress(for: 0, in: proxy.size.width)
                    #if canImport(UIKit)
                    if let previous = dragState,
                       (progress >= endProgress && previous < endProgress)
                        || (progress <= startProgress && previous > startProgress) {
                        impactFeedback.impactOccurred()
                    }
                    #endif
                }
            })
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .updating($dragState, body: { value, state, _ in

                            if self.layoutDirection == .leftToRight {
                                state = (value.location.x / proxy.size.width)
                                    .bound(by: 0 ... 1)
                            } else {
                                state = ((-value.location.x + self.values.elementWidth(in: proxy.size.width)) / proxy.size.width)
                                    .bound(by: 0 ... 1)
                            }
                        }))
    }

    private var thumbText: some View {
        self.thumbLabels(selected)
            .lineLimit(1)
            .allowsTightening(true)
            .minimumScaleFactor(0.1)
            .font(.headline)
            .foregroundColor(.primary)
            .padding(.horizontal, 4)
    }
}

struct StepSlider_Previews: PreviewProvider {
    struct Preview: View {
        @State var value: Int = 1

        @State var type: ValueType = .one

        enum ValueType: String, CaseIterable, CustomStringConvertible {
            case one, two, three, four

            var description: String { self.rawValue }
        }

        var body: some View {
            ScrollView {
                Text("\(value) min")
                    .font(.title)
                StepSlider(selected: $value,
                           values: [1, 15, 30, 45, 60, 90],
                           trackLabels: { Text("\($0)") },
                           thumbLabels: { Text("\($0) min") })
                    .trackHighlight(Color.blue)
                    .padding(20)

                StepPicker(selected: $type,
                           values: ValueType.allCases)
                    .padding(20)
                Button(action: {
                    self.value = 5
                }) {
                    Text("Reset")
                }
            }
            .transition(AnyTransition.opacity.animation(Animation.default)
                            .combined(with: .move(edge: .bottom)))
            .animation(.spring())
        }
    }

    static var previews: some View {
        Preview()
    }
}
