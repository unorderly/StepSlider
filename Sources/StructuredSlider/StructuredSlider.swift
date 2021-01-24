import SwiftUI

public struct StructuredSlider<Value: Hashable>: View {
    public struct Step: Identifiable {
        public let value: Value
        public let label: String
        public let short: String

        public init(value: Value, label: String, short: String) {
            self.value = value
            self.label = label
            self.short = short
        }

        public var id: Value { value }
    }

    public let steps: [Step]

    @Binding public var selected: Value

    public init(selected: Binding<Value>, steps: [Step]) {
        self.steps = steps
        self._selected = selected
    }

    @State private var dragProgress: CGFloat = 0

    @State private var isDragging = false

    public var body: some View {
        HStack {
            ForEach(steps) { step in
                HStack {
                    Spacer(minLength: 0)
                    Text(step.short)
                        .font(.callout)
                        .foregroundColor(.secondary)
                    Spacer(minLength: 0)
                }
                .onTapGesture {
                    self.selected = step.value
                }
            }
        }
        .frame(minHeight: 44)
        .overlay(overlay)
        .padding(6)
        .background(Color.gray.cornerRadius(10))
        .onChange(of: dragProgress, perform: { progress in
            self.selected = self.steps.element(forProgress: progress).value
        })
    }

    private var overlay: some View {
        GeometryReader { proxy in
            thumb(in: proxy)
        }
    }

    private func thumb(in proxy: GeometryProxy) -> some View {
        Rectangle()
            .foregroundColor(.clear)
            .overlay(thumbText)
            .background(
                Color.red
                    .cornerRadius(10)
                    .padding(isDragging ? -6 : 0)
            )
            .frame(width: self.steps.elementWidth(in: proxy.size.width))
            .offset(x: self.steps.thumbOffset(for: dragProgress, in: proxy.size.width))
            .animation(.spring(), value: isDragging)
            .onChange(of: selected, perform: { value in
                if !isDragging && self.steps.element(forProgress: dragProgress).value != value,
                   let index = self.steps.firstIndex(where: { $0.value == value }){
                    withAnimation(.spring()) {
                        self.dragProgress = self.steps.progress(for: index, in: proxy.size.width)
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
                            self.isDragging = false
                            let progress = (value.predictedEndLocation.x / proxy.size.width)
                                .bound(by: 0...1)
                            let index = self.steps.index(forProgress: progress)
                            withAnimation(.spring()) {
                                self.dragProgress = self.steps.progress(for: index, in: proxy.size.width)
                            }
                        })
                        )
    }

    private var thumbText: some View {
        return Text(self.steps.element(forProgress: dragProgress).label)
            .lineLimit(1)
            .allowsTightening(true)
            .minimumScaleFactor(0.5)
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 4)
    }
}

extension Array {
    func index(for position: CGFloat, in width: CGFloat) -> Int {
        return self.index(forProgress: position / width)
    }

    func index(forProgress progress: CGFloat) -> Int {
        return Int(CGFloat(self.count) * progress).bound(by: self.indices)
    }

    func element(forProgress progress: CGFloat) -> Element {
        return self[index(forProgress: progress)]
    }

    func position(for index: Int, in width: CGFloat) -> CGFloat {
        return width * (CGFloat(index)/CGFloat(self.count)) + elementWidth(in: width) / 2
    }

    func progress(for index: Int, in width: CGFloat) -> CGFloat {
        return position(for: index, in: width) / width
    }

    func elementWidth(in width: CGFloat) -> CGFloat {
        return width / CGFloat(self.count)
    }

    func thumbOffset(for progress: CGFloat, in width: CGFloat) -> CGFloat {
        return (width * progress - elementWidth(in: width) / 2)
            .bound(by: 0..<(width - elementWidth(in: width)))
    }
}

extension FloatingPoint {
    func bound(by range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

extension Int {
    func bound(by range: Range<Self>) -> Self {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound - 1)
    }
}

extension Numeric where Self: Comparable {
    func bound(by range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }

    func bound(by range: Range<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}



struct StructuredSlider_Previews: PreviewProvider {

    struct Preview: View {
        @State var value: Int = 1

        var body: some View {
            ScrollView {
                Text("\(value) min")
                    .font(.title)
                StructuredSlider(selected: $value, steps: [
                    .init(value: 1, label: "1 min", short: "1"),
                    .init(value: 15, label: "15 min", short: "15"),
                    .init(value: 30, label: "30 min", short: "30"),
                    .init(value: 45, label: "45 min", short: "45"),
                    .init(value: 60, label: "1h", short: "1h"),
                    .init(value: 90, label: "1.5h", short: "1.5h")
                ])
                .padding(20)
                Button(action: {
                    self.value = 1
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
