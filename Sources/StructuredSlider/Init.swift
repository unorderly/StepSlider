import SwiftUI

extension StructuredSlider {
    public init(selected: Binding<Value>,
                values: [Value],
                trackLabels: @escaping (Value) -> TrackLabel,
                thumbLabels: @escaping (Value) -> ThumbLabel,
                accessibilityLabels: @escaping (Value) -> Text) {
        self.init(selected: selected,
                  values: values,
                  trackLabels: trackLabels,
                  thumbLabels: thumbLabels,
                  accessibilityLabels: accessibilityLabels,
                  valueIndices: { current, values in
                    if let index = values.firstIndex(of: current) {
                        return (index, index)
                    } else {
                        return (0, 0)
                    }
                  })
    }
}

extension StructuredSlider where Value: Comparable {
    public init(selected: Binding<Value>,
                values: [Value],
                trackLabels: @escaping (Value) -> TrackLabel,
                thumbLabels: @escaping (Value) -> ThumbLabel,
                accessibilityLabels: @escaping (Value) -> Text) {
        self.init(selected: selected,
                  values: values,
                  trackLabels: trackLabels,
                  thumbLabels: thumbLabels,
                  accessibilityLabels: accessibilityLabels,
                  valueIndices: { value, values in
                    if let index = values.firstIndex(of: value) {
                        return (index, index)
                    } else {
                        let prev = values.lastIndex(where: { $0 < value })
                        let next = values.firstIndex(where: { $0 > value })
                        if let prev = prev, let next = next {
                            return (prev, next)
                        } else if prev == nil {
                            return (0, 0)
                        } else {
                            return (values.endIndex - 1, values.endIndex - 1)
                        }
                    }
                  })
    }
}

extension StructuredSlider where ThumbLabel == Text {
    public init(selected: Binding<Value>,
                values: [Value],
                trackLabels: @escaping (Value) -> TrackLabel,
                thumbLabels: @escaping (Value) -> ThumbLabel) {
        self.init(selected: selected,
                  values: values,
                  trackLabels: trackLabels,
                  thumbLabels: thumbLabels,
                  accessibilityLabels: thumbLabels)
    }
}

extension StructuredSlider where ThumbLabel == Text, Value: Comparable {
    public init(selected: Binding<Value>,
                values: [Value],
                trackLabels: @escaping (Value) -> TrackLabel,
                thumbLabels: @escaping (Value) -> ThumbLabel) {
        self.init(selected: selected,
                  values: values,
                  trackLabels: trackLabels,
                  thumbLabels: thumbLabels,
                  accessibilityLabels: thumbLabels)
    }
}


extension StructuredSlider where Value: CustomStringConvertible, TrackLabel == Text, ThumbLabel == Text {
    public init(selected: Binding<Value>,
                values: [Value]) {
        self.init(selected: selected,
                  values: values,
                  trackLabels: { Text($0.description) },
                  thumbLabels: { Text($0.description) })
    }
}

extension StructuredSlider where Value: CustomStringConvertible, Value: Comparable, TrackLabel == Text, ThumbLabel == Text {
    public init(selected: Binding<Value>,
                values: [Value]) {
        self.init(selected: selected,
                  values: values,
                  trackLabels: { Text($0.description) },
                  thumbLabels: { Text($0.description) })
    }
}

extension StructuredSlider where Value: CustomStringConvertible, TrackLabel == ThumbLabel {
    public init(selected: Binding<Value>,
                values: [Value],
                label: @escaping (Value) -> TrackLabel,
                accessibilityLabels: @escaping (Value) -> Text) {
        self.init(selected: selected,
                  values: values,
                  trackLabels: label,
                  thumbLabels: label,
                  accessibilityLabels: accessibilityLabels)
    }
}

extension StructuredSlider where Value: CustomStringConvertible, Value: Comparable, TrackLabel == ThumbLabel {
    public init(selected: Binding<Value>,
                values: [Value],
                label: @escaping (Value) -> TrackLabel,
                accessibilityLabels: @escaping (Value) -> Text) {
        self.init(selected: selected,
                  values: values,
                  trackLabels: label,
                  thumbLabels: label,
                  accessibilityLabels: accessibilityLabels)
    }
}
