import SwiftUI

public struct StructuredSlider<Value: Hashable, TrackLabel: View, ThumbLabel: View>: View {

    public let values: [Value]

    @Binding public var selected: Value

    private let trackLabels: (Value) -> TrackLabel
    private let thumbLabels: (Value) -> ThumbLabel

    typealias ValueProgress = (Value, [Value], CGFloat) -> CGFloat
    private let valueProgress: ValueProgress

    @State private var dragProgress: CGFloat = 0

    @State private var isDragging = false

    @Environment(\.accentColor) var accentColor
    @Environment(\.trackBackground) var trackBackground
    @Environment(\.trackHighlight) var trackHighlight

    init(selected: Binding<Value>,
                 values: [Value],
                 trackLabels: @escaping (Value) -> TrackLabel,
                 thumbLabels: @escaping (Value) -> ThumbLabel,
                 valueProgress: @escaping ValueProgress) {
        self._selected = selected
        self.values = values
        self.trackLabels = trackLabels
        self.thumbLabels = thumbLabels
        self.valueProgress = valueProgress
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
                    withAnimation(.spring()) {
                        self.dragProgress = self.valueProgress(value, values, proxy.size.width)
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
