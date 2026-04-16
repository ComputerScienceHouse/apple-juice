//
//  ContentView.swift
//  CSH Drink
//
//  Created by Campbell on 9/30/25.
//

import SwiftUI
import SignInWithCSH

struct ContentView: View {
    @Environment(DrinkModel.self) var model
    @State private var showDropCompleteAlert: Bool = false
    
    var body: some View {
        if model.isReadyToDisplay() {
            NavigationStack {
                if model.isLoaded {
                    List {
                        ForEach(model.drinkMachines, id: \.self) { machine in
                            MachineList(machine: machine)
                        }
                    }
                    .navigationTitle("CSH Drink")
                    .toolbar {
                        ToolbarItemGroup(placement: .primaryAction) {
                            Menu {
                                if case .authorized(let signedIn) = model.signInState {
                                    Text(signedIn.user.preferredUsername)
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text("DEMO USER")
                                        .foregroundStyle(.secondary)
                                }
                                Divider()
                                NavigationLink(destination: AboutView()) {
                                    Label("About", systemImage: "info.circle")
                                }
                                Button(action: {
                                    model.signOut()
                                }) {
                                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                                }
                            } label: {
                                Text("\(model.creditCount) Credits")
                                Image(systemName: "slider.horizontal.3")
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                    }
                    .onChange(of: model.dropInProgress, initial: false) {
                        if !model.dropInProgress {
                            showDropCompleteAlert = true
                        }
                    }
                    .alert(model.dropFinishedTitle, isPresented: $showDropCompleteAlert) {
                        Button("OK") {}
                    } message: {
                        Text(model.dropFinishedMessage)
                    }
                    .refreshable {
                        model.loadAll()
                    }
                } else {
                    VStack {
                        Image(systemName: "cup.and.saucer")
                            .font(.system(size: 100))
                            .foregroundStyle(.accent)
                        Text("Loading drinks...")
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .onAppear {
                        switch model.authorizer.signInState {
                        case .authorized(_):
                            model.loadAll()
                        case _:
                            print("not currently authed")
                        }
                    }
                }
            }
        } else {
            SignInScreen()
        }
    }
}
