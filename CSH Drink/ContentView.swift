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
    @State private var showContent = false
    
    var body: some View {
        if model.isReadyToDisplay() {
            NavigationStack {
                ZStack {
                    if showContent || model.demoMode {
                        drinkContent
                            .transition(
                                .asymmetric(
                                    insertion: .opacity,
                                    removal: .opacity
                                )
                            )
                    } else {
                        LoadingView(
                            loadFinished: model.isLoaded,
                            onAnimationFinished: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showContent = true
                                }
                            }
                        )
                        .padding()
                        .transition(
                            .scale(scale: 0.9)
                            .combined(with: .opacity)
                        )
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: showContent)
                .task {
                    if !model.isLoaded {
                        switch model.authorizer.signInState {
                        case .authorized:
                            model.loadAll()
                        default:
                            print("not currently authed")
                        }
                    }
                }
                .onChange(of: model.isReadyToDisplay()) {
                    if !model.isReadyToDisplay() {
                        showContent = false
                    }
                }
            }
        } else {
            SignInView()
        }
    }
    
    private var drinkContent: some View {
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
                    HStack {
                        HStack(spacing: 4) {
                            Text("\(model.creditCount)")
                                .contentTransition(.numericText())
                            Text("Credits")
                        }
                        
                        Image(systemName: "slider.horizontal.3")
                            .foregroundStyle(Color.accentColor)
                    }
                }
            }
        }
        .onChange(of: model.dropInProgress, initial: false) {
            if !model.dropInProgress && model.dropFinishedTitle != "" {
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
    }
}
