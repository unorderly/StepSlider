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

    enum ValueType: String, CaseIterable, CustomStringConvertible, Identifiable {
        var id: String { self.rawValue }

        case one, two, three, four

        var description: String { self.rawValue }
    }

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("\(value) min")
                    Spacer()
                    Button(action: {
//                        withAnimation(.spring()) {
                            self.value = 5
//                        }
                    }) {
                        Text("Reset")
                    }
                }
                .accessibility(hidden: true)

                StepSlider(selected: $value,
                           values: [1, 15, 30, 45, 60, 90],
                           trackLabels: { Text("\($0)") },
                           thumbLabels: { Text("\($0) min") })
                    .accessibilityLabel(Text("Duration"))
                    .accessibilityAction(named: "Edit", {
//                        withAnimation(.spring()) {
                            self.value = 5
//                        }
                    })
                    .accessibility(identifier: "example.slider.duration")
                    .trackHighlight(Color.blue)

                StepPicker(selected: $type,
                           values: ValueType.allCases)
                    .accessibilityLabel(Text("Value Types"))
            }
            .padding(20)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
