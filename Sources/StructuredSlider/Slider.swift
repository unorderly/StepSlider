import SwiftUI

struct Slider<Value: Hashable, TrackLabel: View, ThumbLabel: View>: View {

    public let values: [Value]

    @Binding public var selected: Value

    private let trackLabels: (Value) -> TrackLabel
    private let thumbLabels: (Value) -> ThumbLabel

    private let valueIndices: (Value, [Value]) -> (Int, Int)

    @State private var dragProgress: CGFloat = 0
    @State private var isDragging = false
    @State private var selectionFeedback = UISelectionFeedbackGenerator()
    @State private var impactFeedback = UIImpactFeedbackGenerator(style: .medium)

    @Environment(\.accentColor) var accentColor
    @Environment(\.trackBackground) var trackBackground
    @Environment(\.trackHighlight) var trackHighlight
    @Environment(\.accessibilityReduceMotion) var accessibilityReduceMotion


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
                }
                .accessibility(addTraits: value == selected ? .isSelected : [])
            }
        }
        .frame(minHeight: 44)
        .overlay(overlay)
        .background(highlightTrack)
        .padding(6)
        .background(trackBackground.cornerRadius(10))

    }

    private var animation: Animation? {
        return self.accessibilityReduceMotion ? nil : .spring()
    }

    private var overlay: some View {
        GeometryReader { proxy in
            thumb(in: proxy)
        }
        .accessibility(hidden: true)
    }

    private var highlightTrack: some View {
        GeometryReader { proxy in
            trackHighlight
                .cornerRadius(10)
                .padding(isDragging && !accessibilityReduceMotion ? -6 : 0)
                .frame(width: self.values.thumbOffset(for: dragProgress, in: proxy.size.width) + self.values.elementWidth(in: proxy.size.width))
                .animation(self.animation, value: isDragging)
        }
    }

    private func thumb(in proxy: GeometryProxy) -> some View {
        Rectangle()
            .foregroundColor(.clear)
            .overlay(thumbText)
            .background(
                accentColor
                    .cornerRadius(10)
                    .padding(isDragging && !accessibilityReduceMotion ? -6 : 0)
            )
            .shadow(color: Color.black.opacity(0.12), radius: 4)
            .frame(width: self.values.elementWidth(in: proxy.size.width))
            .offset(x: self.values.thumbOffset(for: dragProgress, in: proxy.size.width))
            .animation(self.animation, value: isDragging)
            .onChange(of: selected, perform: { value in
                self.selectionFeedback.selectionChanged()
                if !isDragging {
                    let (left, right) = self.valueIndices(value, values)
                    let start = values.progress(for: left, in: proxy.size.width)
                    let end = values.progress(for: right, in: proxy.size.width)
                    withAnimation(self.animation) {
                        self.dragProgress = (start + end) / 2
                    }
                }
            })
            .onChange(of: dragProgress, perform: { [dragProgress] progress in
                if isDragging {
                    self.selected = self.values.element(forProgress: progress)
                    let endProgress = values.progress(for: values.count - 1, in: proxy.size.width)
                    let startProgress = values.progress(for: 0, in: proxy.size.width)
                    if (progress >= endProgress && dragProgress < endProgress)
                        || (progress <= startProgress && dragProgress > startProgress) {
                        self.impactFeedback.impactOccurred()
                    }
                }
            })
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged({ value in
                            self.isDragging = true
                            self.dragProgress = (value.location.x / proxy.size.width)
                                .bound(by: 0...1)
                            self.impactFeedback.prepare()
                            self.selectionFeedback.prepare()
                        })
                        .onEnded({ value in
                            let progress = (value.location.x / proxy.size.width)
                                .bound(by: 0...1)
                            let index = self.values.index(forProgress: progress)
                            withAnimation(self.animation) {
                                self.dragProgress = self.values.progress(for: index,
                                                                         in: proxy.size.width)
                                self.isDragging = false
                            }
                        })
            )
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

struct StructuredSlider_Previews: PreviewProvider {

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
        }
    }
    static var previews: some View {
        Preview()
    }
}
