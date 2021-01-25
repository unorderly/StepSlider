//
//  ContentView.swift
//  Shared
//
//  Created by Leonard Mehlig on 25.01.21.
//

import SwiftUI
import StructuredSlider

struct ContentView: View {
    @State var value: Int = 1

    @State var type: ValueType = .one

    enum ValueType: String, CaseIterable, CustomStringConvertible {
        case one, two, three, four

        var description: String { self.rawValue }
    }

    var body: some View {
        ScrollView {
            HStack {
                Text("\(value) min")
                Spacer()
                Button(action: {
                    self.value = 5
                }) {
                    Text("Reset")
                }
            }
            .accessibility(hidden: true)
            StructuredSlider(selected: $value,
                             values: [1, 15, 30, 45, 60, 90],
                             trackLabels: { Text("\($0)") },
                             thumbLabels: { Text("\($0) min") })
                .accessibilityLabel(Text("Duration"))
                .accessibilityAction(named: "Edit", { self.value = 5 })
                .accessibility(identifier: "example.slider.duration")
                .trackHighlight(Color.blue)
                .padding(20)

            StructuredSlider(selected: $type,
                             values: ValueType.allCases)
                .accessibilityLabel(Text("Value Types"))
                .padding(20)

        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
