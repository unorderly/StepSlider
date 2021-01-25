import SwiftUI

extension StructuredSlider {
    public init(selected: Binding<Value>,
                values: [Value],
                trackLabels: @escaping (Value) -> TrackLabel,
                thumbLabels: @escaping (Value) -> ThumbLabel) {
        self.init(selected: selected,
                  values: values,
                  trackLabels: trackLabels,
                  thumbLabels: thumbLabels, valueProgress: { current, values, width in
                    if let index = values.firstIndex(of: current) {
                        return values.progress(for: index, in: width)
                    } else {
                        return 0
                    }
                  })
    }
}

extension StructuredSlider where Value: Comparable {
    public init(selected: Binding<Value>,
                values: [Value],
                trackLabels: @escaping (Value) -> TrackLabel,
                thumbLabels: @escaping (Value) -> ThumbLabel) {
        self.init(selected: selected,
                  values: values,
                  trackLabels: trackLabels,
                  thumbLabels: thumbLabels,
                  valueProgress: { value, values, width in
                    if let index = values.firstIndex(of: value) {
                        return values.progress(for: index, in: width)
                    } else {
                        let prev = values.lastIndex(where: { $0 < value })
                        let next = values.firstIndex(where: { $0 > value })
                        if let prev = prev, let next = next {
                            let start = values.progress(for: prev, in: width)
                            let end = values.progress(for: next, in: width)
                            return (start + end) / 2
                        } else if prev == nil {
                            return values.progress(for: 0, in: width)
                        } else {
                            return values.progress(for: values.endIndex - 1,
                                                   in: width)
                        }
                    }
                  })
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
                label: @escaping (Value) -> TrackLabel) {
        self.init(selected: selected,
                  values: values,
                  trackLabels: label,
                  thumbLabels: label)
    }
}

extension StructuredSlider where Value: CustomStringConvertible, Value: Comparable, TrackLabel == ThumbLabel {
    public init(selected: Binding<Value>,
                values: [Value],
                label: @escaping (Value) -> TrackLabel) {
        self.init(selected: selected,
                  values: values,
                  trackLabels: label,
                  thumbLabels: label)
    }
}
