//
//  MachineList.swift
//  CSH Drink
//
//  Created by Campbell on 4/15/26.
//

import SwiftUI

struct MachineList: View {
    @Environment(DrinkModel.self) var model
    @State var machine: DrinkMachine
    
    var body: some View {
        Section(header: Text(machine.display_name)) {
            ForEach(machine.slots, id: \.self) { slot in
                MachineListItem(
                    slot: slot,
                    creditCount: model.creditCount,
                    dropInProgress: model.dropInProgress
                ) {
                    model.dropItem(selectedItem: SelectedItem(
                        machine: machine.name,
                        slot: slot.number,
                        cost: slot.item.price
                    ))
                }
            }
        }
        .disabled(model.dropInProgress)
        .disabled(!machine.is_online)
    }
}

struct MachineListItem: View {
    let slot: Slot
    let creditCount: Int
    let dropInProgress: Bool
    let onDrop: () -> Void
    
    @State private var isDropping: Bool = false
    @State private var useCompletionIcon: Bool = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(slot.item.name)
                    .foregroundStyle(slot.empty || !slot.active ? Color.secondary : Color.primary)
                
                Text("\(slot.item.price) Credits")
                    .foregroundStyle(.secondary)
                    .opacity(slot.empty || !slot.active ? 0.5 : 1.0)
                
                if let remaining = slot.count {
                    Text("\(slot.count ?? 0) Remaining")
                        .foregroundStyle(remaining > 0 ? Color.secondary : Color.red)
                        .opacity(slot.empty || !slot.active ? 0.5 : 1.0)
                }
            }
            
            Spacer()
            
            Button(action: {
                print("user requested to drop \(slot.item.name)")
                isDropping = true
                onDrop()
            }) {
                Group {
                    if isDropping {
                        Text("Dropping...")
                    } else {
                        Image(systemName: "circle")
                            .opacity(0)
                            .overlay {
                                if #available(iOS 18.0, *) {
                                    Image(systemName: useCompletionIcon ? "checkmark" : "arrow.down")
                                        .contentTransition(
                                            .symbolEffect(
                                                .replace.downUp.magic(fallback: .replace.downUp)
                                            )
                                        )
                                } else {
                                    Image(systemName: useCompletionIcon ? "checkmark" : "arrow.down")
                                }
                            }
                    }
                }
            }
            .disabled(creditCount < slot.item.price || slot.empty || !slot.active)
            .adaptiveProminentButtonStyle()
            .tint(useCompletionIcon ? Color.green : Color.accent)
            .animation(
                .spring(response: 0.3, dampingFraction: 0.6),
                value: isDropping
            )
            .onChange(of: dropInProgress) {
                if dropInProgress == false && isDropping == true {
                    useCompletionIcon = true
                    isDropping = false
                    
                    Task { @MainActor in
                        try? await Task.sleep(for: .milliseconds(1000))
                        withAnimation(.easeInOut) {
                            useCompletionIcon = false
                        }
                    }
                }
            }
        }
    }
}
