//
//  DemoView.swift
//  CSH Drink
//
//  Created by Campbell on 4/15/26.
//

import SwiftUI

struct DemoView: View {
    @Binding var demoMode: Bool
    
    @State private var drinkMachines: [DrinkMachine] = []
    @State private var creditCount: Int = 250
    @State private var dropInProgress: Bool = false
    @State private var dropFinishedTitle: String = ""
    @State private var dropFinishedMessage: String = ""
    @State private var showDropFinishedAlert: Bool = false
    
    private func getDrinkData() {
        guard let url = Bundle.main.url(forResource: "demo_drinks.json", withExtension: nil) else {
            print("Failed to locate demo data in bundle.")
            return
        }

        guard let data = try? Data(contentsOf: url) else {
            print("Failed to load demo data from bundle.")
            return
        }

        let decoder = JSONDecoder()

        guard let decoded = try? decoder.decode(DrinkMachinesParser.self, from: data) else {
            print("Failed to decode demo data from bundle.")
            return
        }

        drinkMachines = decoded.machines
    }
    
    private func dropItem(selectedItem: SelectedItem) {
        print(selectedItem)
        dropInProgress = true
        creditCount -= selectedItem.cost
        
        Task {
            await dummyDropComplete()
        }
    }
    
    private func dummyDropComplete() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        print("dummy drop done!")
        dropFinishedTitle = "Drop Successful"
        dropFinishedMessage = "Enjoy your drink!"
        showDropFinishedAlert = true
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(drinkMachines, id: \.self) { machine in
                    MachineList(
                        machine: machine,
                        creditCount: $creditCount,
                        dropInProgress: $dropInProgress,
                        dropItem: dropItem
                    )
                }
            }
            .navigationTitle("CSH Drink")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Menu {
                        Text("DEMO USER")
                            .foregroundStyle(.secondary)
                        Divider()
                        Button(action: {
                            demoMode = false
                        }) {
                            Text("Sign Out")
                        }
                    } label: {
                        Image(systemName: "person")
                            .foregroundStyle(Color.accentColor)
                        Text("\(creditCount) Credits")
                    }
                }
            }
            .alert(dropFinishedTitle, isPresented: $showDropFinishedAlert) {
                Button("OK") {
                    dropInProgress = false
                }
            } message: {
                Text(dropFinishedMessage)
            }
            .refreshable {
                getDrinkData()
            }
            .onAppear(perform: getDrinkData)
        }
    }
}
