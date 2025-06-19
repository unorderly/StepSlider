import SwiftUI

public struct StepPicker<Value: Hashable, TrackLabel: View, ThumbLabel: View>: View {
    public let values: [Value]

    @Binding public var selected: Value

    private let trackLabels: (Value) -> TrackLabel
    private let thumbLabels: (Value) -> ThumbLabel

    private let cornerRadius: CGFloat
    private let padding: CGFloat
    private let roundTrackBackground: Bool
    private let updateOnDragEnd: Bool

    public init(selected: Binding<Value>,
                values: [Value],
                trackLabels: @escaping (Value) -> TrackLabel,
                thumbLabels: @escaping (Value) -> ThumbLabel,
                cornerRadius: CGFloat = 10,
                padding: CGFloat = 6,
                roundTrackBackground: Bool = true,
                updateOnDragEnd: Bool = false) {
        self._selected = selected
        self.values = values
        self.trackLabels = trackLabels
        self.thumbLabels = thumbLabels
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.roundTrackBackground = roundTrackBackground
        self.updateOnDragEnd = updateOnDragEnd
    }

    public var body: some View {
        Slider(selected: self.$selected,
               values: self.values,
               trackLabels: self.trackLabels,
               thumbLabels: self.thumbLabels,
               valueIndices: self.valueIndices,
               cornerRadius: self.cornerRadius,
               padding: self.padding,
               roundTrackBackground: self.roundTrackBackground,
               updateOnDragEnd: updateOnDragEnd)
            .accessibilityElement(children: .contain)
    }

    func valueIndices(for value: Value, values: [Value]) -> (Int, Int) {
        if let index = values.firstIndex(of: value) {
            return (index, index)
        } else {
            return (0, 0)
        }
    }
}

extension StepPicker where Value: CustomStringConvertible, TrackLabel == Text, ThumbLabel == Text {
    public init(selected: Binding<Value>,
                values: [Value]) {
        self.init(selected: selected,
                  values: values,
                  trackLabels: { Text($0.description) },
                  thumbLabels: { Text($0.description) })
    }
}

extension StepPicker where TrackLabel == ThumbLabel {
    public init(selected: Binding<Value>,
                values: [Value],
                labels: @escaping (Value) -> TrackLabel) {
        self.init(selected: selected,
                  values: values,
                  trackLabels: labels,
                  thumbLabels: labels)
    }
}
