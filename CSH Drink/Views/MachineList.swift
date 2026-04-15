//
//  MachineList.swift
//  CSH Drink
//
//  Created by Campbell on 4/15/26.
//

import SwiftUI

struct MachineList: View {
    @State var machine: DrinkMachine
    @Binding var creditCount: Int
    @Binding var dropInProgress: Bool
    
    let dropItem: (SelectedItem) -> Void
    
    var body: some View {
        Section(header: Text(machine.display_name)) {
            ForEach(machine.slots, id: \.self) { slot in
                HStack {
                    VStack(alignment: .leading) {
                        Text(slot.item.name)
                            .foregroundStyle(slot.empty ? Color.secondary : Color.primary)
                        Text("\(slot.item.price) Credits")
                            .foregroundStyle(.secondary)
                        if let remaining = slot.count {
                            Text("\(slot.count ?? 0) Remaining")
                                .foregroundStyle(remaining > 0 ? Color.secondary : Color.red)
                                .opacity(slot.empty ? 0.5 : 1.0)
                        }
                    }
                    Spacer()
                    Button(action: {
                        print("user requested to drop \(slot.item.name)")
                        dropItem(SelectedItem(
                            machine: machine.name,
                            slot: slot.number,
                            cost: slot.item.price
                        ))
                    }) {
                        Label("Drop", systemImage: "arrow.down")
                            .labelStyle(CustomSpacedLabel(spacing: 1))
                    }
                    .disabled(creditCount < slot.item.price || slot.empty || !slot.active)
                    .buttonStyle(CSHButtonStyle())
                }
            }
        }
        .disabled(dropInProgress)
        .disabled(!machine.is_online)
    }
}
