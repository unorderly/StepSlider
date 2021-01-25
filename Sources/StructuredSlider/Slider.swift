import SwiftUI

public struct StructuredSlider<Value: Hashable, TrackLabel: View, ThumbLabel: View>: View {

    public let values: [Value]

    @Binding public var selected: Value

    private let trackLabels: (Value) -> TrackLabel
    private let thumbLabels: (Value) -> ThumbLabel
    private let accessibilityLabels: (Value) -> Text

    private let valueIndices: (Value, [Value]) -> (Int, Int)

    @State private var dragProgress: CGFloat = 0

    @State private var isDragging = false

    @Environment(\.accentColor) var accentColor
    @Environment(\.trackBackground) var trackBackground
    @Environment(\.trackHighlight) var trackHighlight

    init(selected: Binding<Value>,
                 values: [Value],
                 trackLabels: @escaping (Value) -> TrackLabel,
                 thumbLabels: @escaping (Value) -> ThumbLabel,
                 accessibilityLabels: @escaping (Value) -> Text,
                 valueIndices: @escaping (Value, [Value]) -> (Int, Int)) {
        self._selected = selected
        self.values = values
        self.trackLabels = trackLabels
        self.thumbLabels = thumbLabels
        self.accessibilityLabels = accessibilityLabels
        self.valueIndices = valueIndices
    }

    public var body: some View {
        HStack {
            ForEach(values, id: \.self) { value in
                HStack {
                    Spacer(minLength: 0)
                    self.trackLabels(value)
                        .font(.callout)
                        .foregroundColor(.trackLabel)
                        .minimumScaleFactor(0.1)
                    Spacer(minLength: 0)
                }
                .onTapGesture {
                    self.selected = value
                }
            }
        }
        .frame(minHeight: 44)
        .overlay(overlay)
        .background(highlightTrack)
        .padding(6)
        .background(trackBackground.cornerRadius(10))
        .onChange(of: dragProgress, perform: { progress in
            if isDragging {
                self.selected = self.values.element(forProgress: progress)
            }
        })
        .accessibilityElement(children: .ignore)
        .accessibility(value: self.accessibilityLabels(selected))
        .accessibility(hint: self.values.map(self.accessibilityLabels)
                        .reduce(Text(""), { $0 + Text(", ") + $1 }))
        .accessibilityAdjustableAction({ direction in
            let (left, right) = self.valueIndices(selected, values)
            switch direction {
            case .increment:
                let next = left == right ? right + 1 : right
                if self.values.count > next {
                    self.selected = self.values[next]
                }
            case .decrement:
                let prev = left == right ? left - 1 : left
                if prev >= 0 {
                    self.selected = self.values[prev]
                }
            @unknown default:
                break
            }
        })
    }

    private var overlay: some View {
        GeometryReader { proxy in
            thumb(in: proxy)
        }
    }

    private var highlightTrack: some View {
        GeometryReader { proxy in
            trackHighlight
                .cornerRadius(10)
                .padding(isDragging ? -6 : 0)
                .frame(width: self.values.thumbOffset(for: dragProgress, in: proxy.size.width) + self.values.elementWidth(in: proxy.size.width))
                .animation(.spring(), value: isDragging)
        }
    }

    private func thumb(in proxy: GeometryProxy) -> some View {
        Rectangle()
            .foregroundColor(.clear)
            .overlay(thumbText)
            .background(
                accentColor
                    .cornerRadius(10)
                    .padding(isDragging ? -6 : 0)
            )
            .frame(width: self.values.elementWidth(in: proxy.size.width))
            .offset(x: self.values.thumbOffset(for: dragProgress, in: proxy.size.width))
            .animation(.spring(), value: isDragging)
            .onChange(of: selected, perform: { value in
                if !isDragging {
                    let (left, right) = self.valueIndices(value, values)
                    let start = values.progress(for: left, in: proxy.size.width)
                    let end = values.progress(for: right, in: proxy.size.width)
                    withAnimation(.spring()) {
                        self.dragProgress = (start + end) / 2
                    }
                }
            })
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged({ value in
                            self.isDragging = true
                            self.dragProgress = (value.location.x / proxy.size.width)
                                .bound(by: 0...1)
                        })
                        .onEnded({ value in
                            let progress = (value.location.x / proxy.size.width)
                                .bound(by: 0...1)
                            let index = self.values.index(forProgress: progress)
                            withAnimation(.spring()) {
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
                StructuredSlider(selected: $value,
                                 values: [1, 15, 30, 45, 60, 90],
                                 trackLabels: { Text("\($0)") },
                                 thumbLabels: { Text("\($0) min") })
                    .trackHighlight(Color.blue)
                    .padding(20)

                StructuredSlider(selected: $type,
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
