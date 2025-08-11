import SwiftUI

struct SliderTrack<Value: Hashable, TrackLabel: View>: View, Equatable {
    static func == (lhs: SliderTrack<Value, TrackLabel>, rhs: SliderTrack<Value, TrackLabel>) -> Bool {
        lhs.selected == rhs.selected && lhs.values == rhs.values
    }

    @Binding var selected: Value
    let values: [Value]

    let trackLabels: (Value) -> TrackLabel

#if targetEnvironment(macCatalyst)
    @ScaledMetric(relativeTo: .callout)
    var size: CGFloat = 38
#else
    @ScaledMetric(relativeTo: .callout)
    var size: CGFloat = 44
#endif

    @Environment(\.sliderHaptics) private var haptics

    var body: some View {
        HStack {
            ForEach(self.values, id: \.self) { value in
                Button(action: {
                    self.selected = value
                    self.haptics.playUpdate()
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
                    .frame(minHeight: self.size)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibility(addTraits: value == self.selected ? .isSelected : [])
            }
        }
    }
}

struct Slider<Value: Hashable, TrackLabel: View, ThumbLabel: View>: View {
    public let values: [Value]

    @Binding public var selected: Value

    private let trackLabels: (Value) -> TrackLabel
    private let thumbLabels: (Value) -> ThumbLabel

    private let valueIndices: (Value, [Value]) -> (Int, Int)

    private let cornerRadius: CGFloat
    private let padding: CGFloat
    private let roundTrackBackground: Bool
    private let updateOnDragEnd: Bool

    @GestureState private var dragState: CGFloat? = nil
    @State private var shadowValue: Value?

    @Environment(\.trackBackground) private var trackBackground
    @Environment(\.trackHighlight) private var trackHighlight
    @Environment(\.trackSelection) private var trackSelectionColor
    @Environment(\.sliderHaptics) private var haptics

    @Environment(\.accessibilityReduceMotion) private var accessibilityReduceMotion
    @Environment(\.layoutDirection) private var layoutDirection

    init(selected: Binding<Value>,
         values: [Value],
         trackLabels: @escaping (Value) -> TrackLabel,
         thumbLabels: @escaping (Value) -> ThumbLabel,
         valueIndices: @escaping (Value, [Value]) -> (Int, Int),
         cornerRadius: CGFloat = 10,
         padding: CGFloat = 6,
         roundTrackBackground: Bool = true,
         updateOnDragEnd: Bool = false
    ) {
        self._selected = selected
        self.values = values
        self.trackLabels = trackLabels
        self.thumbLabels = thumbLabels
        self.valueIndices = valueIndices
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.roundTrackBackground = roundTrackBackground
        self.updateOnDragEnd = updateOnDragEnd
    }

    public var body: some View {
        SliderTrack(selected: self.$selected, values: self.values, trackLabels: self.trackLabels)
            .equatable()
            .overlay(self.overlay)
            .background(self.highlightTrack)
            .padding(padding)
            .background {
                if roundTrackBackground {
                    self.trackBackground.cornerRadius(cornerRadius)
                } else {
                    self.trackBackground
                }
            }
    }

    private var animation: Animation? {
        self.accessibilityReduceMotion ? nil : .spring()
    }

    private var overlay: some View {
        GeometryReader { proxy in
            self.thumb(in: proxy)
        }
        .accessibility(hidden: true)
    }

    private var displayValue: Value {
        shadowValue ?? selected
    }
    
    private func dragProgress(in width: CGFloat) -> CGFloat {
        if let progress = self.dragState {
            return progress
        } else {
            let (left, right) = self.valueIndices(self.displayValue, self.values)
            let start = self.values.progress(for: left, in: width)
            let end = self.values.progress(for: right, in: width)
            return (start + end) / 2
        }
    }

    private var highlightTrack: some View {
        GeometryReader { proxy in
            self.trackHighlight
                .cornerRadius(cornerRadius)
                .padding(self.dragState != nil && !self.accessibilityReduceMotion ? -padding : 0)
                .frame(width: self.values
                    .thumbOffset(for: self.dragProgress(in: proxy.size.width), in: proxy.size.width) + self.values
                    .elementWidth(in: proxy.size.width))
                .animation(self.animation, value: self.dragState != nil ? 0 : self.displayValue.hashValue)
        }
    }

    private func thumb(in proxy: GeometryProxy) -> some View {
        Rectangle()
            .foregroundColor(.clear)
            .overlay(self.thumbText)
            .background(self.trackSelectionColor
                .cornerRadius(cornerRadius)
                .padding(self.dragState != nil && !self.accessibilityReduceMotion ? -padding : 0))
            .shadow(color: Color.black.opacity(0.12), radius: 4)
            .hoverEffect(.highlight)
            .frame(width: self.values.elementWidth(in: proxy.size.width))
            .offset(x: self.values.thumbOffset(for: self.dragProgress(in: proxy.size.width), in: proxy.size.width))
            .animation(self.animation, value: self.dragState != nil ? 0 : self.selected.hashValue)
            .onChange(of: self.dragState, { dragState, state in
                if let progress = state ?? dragState {
                    let selected = self.values.element(forProgress: progress)
                    if updateOnDragEnd {
                        if shadowValue == nil {
                            shadowValue = self.selected
                        }
                        if shadowValue != selected {
                            self.haptics.playUpdate()
                            shadowValue = selected
                        }
                    } else {
                        if self.selected != selected {
                            self.haptics.playUpdate()
                            self.selected = selected
                        }
                    }
                    let endProgress = self.values.progress(for: self.values.count - 1, in: proxy.size.width)
                    let startProgress = self.values.progress(for: 0, in: proxy.size.width)
#if canImport(UIKit)
                    if let previous = dragState,
                       (progress >= endProgress && previous < endProgress)
                       || (progress <= startProgress && previous > startProgress) {
                        self.haptics.playEdge()
                    }
#endif
                }
            })
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .updating(self.$dragState, body: { value, state, _ in

                    if self.layoutDirection == .leftToRight {
                        state = (value.location.x / proxy.size.width)
                            .bound(by: 0...1)
                    } else {
                        state = ((-value.location.x + self.values.elementWidth(in: proxy.size.width)) / proxy.size.width)
                            .bound(by: 0...1)
                    }
                })
                .onEnded { _ in
                    if updateOnDragEnd, let finalValue = shadowValue {
                        selected = finalValue
                        shadowValue = nil
                    }
                })
            .onChange(of: selected) {
                if dragState == nil && shadowValue != nil {
                    shadowValue = nil
                }
            }
    }

    private var thumbText: some View {
        self.thumbLabels(self.displayValue)
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
                Text("\(self.value) min")
                    .font(.title)
                StepSlider(selected: self.$value,
                           values: [1, 15, 30, 45, 60, 90],
                           trackLabels: { Text("\($0)") },
                           thumbLabels: { Text("\($0) min") })
                    .trackHighlight(Color.blue)
                    .padding(20)

                StepPicker(selected: self.$type,
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
            .animation(.spring(), value: value)
        }
    }

    static var previews: some View {
        Preview()
    }
}
