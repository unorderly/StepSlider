import StepSlider
import SwiftUI

struct ContentView: View {
    @State private var value: Int = 30

    @State private var type: ValueType = .one

    enum ValueType: String, CaseIterable, CustomStringConvertible, Identifiable {
        var id: String { self.rawValue }

        case one, two, three, four

        var description: String { self.rawValue }
    }

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("\(self.value) min")
                    Spacer()
                    Button(action: {
                        self.value = 5
                    }) {
                        Text("Reset")
                    }
                }
                .accessibility(hidden: true)

                //                ForEach(0..<5) { _ in
                StepSlider(selected: self.$value,
                           values: [1, 15, 30, 45, 60, 90],
                           trackLabels: { step in
                               Group {
                                   if step < self.value {
                                       Text("\(step)")
                                           .foregroundStyle(Color.secondary)
                                   } else {
                                       Text("\(step)")
                                   }
                               }
                           },
                           thumbLabels: {
                               Text("\($0) min").foregroundStyle(Color.white)
                           })
                           //                        .trackHighlight(Color("accent").opacity(0.2))
                           .accessibilityLabel(Text("Duration"))
                           .accessibilityAction(named: "Edit") {
                               self.value = 5
                           }
                           .accessibility(identifier: "example.slider.duration")

                StepSlider(selected: self.$value,
                           values: [1, 15, 30, 45, 60, 90],
                           trackLabels: { step in
                               Group {
                                   if step < self.value {
                                       Text("\(step)")
                                           .foregroundStyle(Color.secondary)
                                   } else {
                                       Text("\(step)")
                                   }
                               }
                           },
                           thumbLabels: {
                               Text("\($0) min").foregroundStyle(Color.white)
                           })
                           //                        .trackHighlight(Color("accent").opacity(0.2))
                           .accessibilityLabel(Text("Duration"))
                           .accessibilityAction(named: "Edit") {
                               self.value = 5
                           }
                           .accessibility(identifier: "example.slider.duration")
                           .environment(\.layoutDirection, .rightToLeft)
                //                }

                //                StepPicker(selected: $type,
                //                           values: ValueType.allCases,
                //                           trackLabels: { Text($0.description) },
                //                           thumbLabels: {
                //                               Text($0.description).foregroundStyle(Color.white)
                //                           })
                //                    .accessibilityLabel(Text("Value Types"))
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
