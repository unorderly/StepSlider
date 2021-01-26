//
//  SwiftUIView.swift
//  
//
//  Created by Leonard Mehlig on 26.01.21.
//

import SwiftUI

public struct StepSlider<Value: Hashable, TrackLabel: View, ThumbLabel: View>: View where Value: Comparable {

    public let values: [Value]

    @Binding public var selected: Value

    private let trackLabels: (Value) -> TrackLabel
    private let thumbLabels: (Value) -> ThumbLabel
    private let accessibilityLabels: (Value) -> Text

    public init(selected: Binding<Value>,
                values: [Value],
                 trackLabels: @escaping (Value) -> TrackLabel,
                 thumbLabels: @escaping (Value) -> ThumbLabel,
                 accessibilityLabels: @escaping (Value) -> Text) {
        self._selected = selected
        self.values = values
        self.trackLabels = trackLabels
        self.thumbLabels = thumbLabels
        self.accessibilityLabels = accessibilityLabels

    }


    public var body: some View {
        Slider(selected: $selected,
               values: values,
               trackLabels: trackLabels,
               thumbLabels: thumbLabels,
               valueIndices: self.valueIndices)
            .accessibilityElement(children: .ignore)
            .accessibility(value: self.accessibilityLabels(selected))
            .accessibility(hint: self.values.map(self.accessibilityLabels)
                            .reduce(Text(""), { $0 + Text(", ") + $1 }))
            .accessibilityAdjustableAction({ direction in
                let (left, right) = self.valueIndices(for: selected, values: values)
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

    func valueIndices(for value: Value, values: [Value]) -> (Int, Int) {
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
    }
}

extension StepSlider where ThumbLabel == Text {
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

extension StepSlider where Value: CustomStringConvertible, TrackLabel == Text, ThumbLabel == Text {
    public init(selected: Binding<Value>,
                values: [Value]) {
        self.init(selected: selected,
                  values: values,
                  trackLabels: { Text($0.description) },
                  thumbLabels: { Text($0.description) })
    }
}

extension StepSlider where Value: CustomStringConvertible, TrackLabel == ThumbLabel {
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

extension StepSlider where Value: CustomStringConvertible, TrackLabel == Text, ThumbLabel == Text {
    public init(selected: Binding<Value>,
                values: [Value],
                label: @escaping (Value) -> Text) {
        self.init(selected: selected,
                  values: values,
                  trackLabels: label,
                  thumbLabels: label,
                  accessibilityLabels: label)
    }
}
