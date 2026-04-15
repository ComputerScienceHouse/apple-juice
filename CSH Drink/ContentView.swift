//
//  ContentView.swift
//  CSH Drink
//
//  Created by Campbell on 9/30/25.
//

import Combine
import SwiftUI
import SignInWithCSH

struct ContentView: View {
    @EnvironmentObject private var authorizer: CSHAuthorizer
    @State private var drinkMachines: [DrinkMachine]?
    @State private var cancellables: Set<AnyCancellable> = Set()
    @State private var creditCount: Int = 0
    @State private var dropInProgress: Bool = false
    @State private var showDropFinishedAlert: Bool = false
    @State private var dropFinishedTitle: String = ""
    @State private var dropFinishedMessage: String = ""
    @State private var demoMode: Bool = false

    private func getDrinkData() {
        guard let url = URL(string: "https://drink.csh.rit.edu/drinks") else { return }
        
        authorizer.dataTaskPublisher(for: url)
            .map{ $0.data }
            .sink(receiveCompletion: { thing in
                switch (thing) {
                case .failure(let e):
                    print("encountered error:")
                    print(e)
                    authorizer.signOut()
                case .finished:
                    print("inventory completion")
                }
            }, receiveValue: { data in
                do {
                    let decoded = try JSONDecoder().decode(DrinkMachinesParser.self, from: data)
                    drinkMachines = decoded.machines
                } catch {
                    print("json error!!")
                }
            }).store(in: &cancellables)
    }
    
    private func getDrinkCredits() {
        switch authorizer.signInState {
        case .authorized(let signedIn):
            print("requesting credits for user \(signedIn.user.preferredUsername)")
            guard let url = URL(string: "https://drink.csh.rit.edu/users/credits?uid=\(signedIn.user.preferredUsername)") else { return }
            
            authorizer.dataTaskPublisher(for: url)
                .map{ $0.data }
                .sink(receiveCompletion: { _ in
                    print("credit completion")
                }, receiveValue: { data in
                    do {
                        let decoded = try JSONDecoder().decode(CreditsReponse.self, from: data)
                        print("user \(decoded.user.uid) has \(decoded.user.drinkBalance) credits")
                        creditCount = Int(decoded.user.drinkBalance) ?? 0
                    } catch {
                        print("json error!!")
                    }
                }).store(in: &cancellables)
        case _:
            // Not signed in so don't try.
            return
        }
    }
    
    private func dropItem(selectedItem: SelectedItem) {
        print(selectedItem)
        dropInProgress = true
        let urlString = "https://drink.csh.rit.edu/drinks/drop"
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(selectedItem)
            request.httpBody = jsonData
        } catch {
            print("json encode error")
            return
        }
        authorizer.dataTaskPublisher(for: request)
            .map{ $0.data }
            .sink(receiveCompletion: { _ in
                print("drop completion")
            }, receiveValue: { data in
                do {
                    let decoded = try JSONDecoder().decode(DropResponse.self, from: data)
                    if let drinkBalance = decoded.drinkBalance {
                        creditCount = drinkBalance
                        getDrinkData()
                        dropFinishedTitle = "Drop Successful"
                        dropFinishedMessage = "Enjoy your drink!"
                        showDropFinishedAlert = true
                    } else {
                        print("drop did not succeed with message: \(decoded.message)")
                        dropFinishedTitle = "Couldn't Drop Item"
                        dropFinishedMessage = "An error occurred while trying to drop the requested item. Drink replied: \(decoded.message)"
                        showDropFinishedAlert = true
                    }
                } catch {
                    print("json error!!")
                    guard let str = String(
                        data: data,
                        encoding: .utf8
                    ) else {
                        print("Unable to convert data")
                        dropFinishedTitle = "Couldn't Drop Item"
                        dropFinishedMessage = "An error occurred while trying to drop the requested item. No more details can be provided."
                        showDropFinishedAlert = true
                        return
                    }
                    print(str)
                    dropFinishedTitle = "Couldn't Drop Item"
                    dropFinishedMessage = "An error occurred while trying to drop the requested item. Raw reply from drink: \(str)"
                    showDropFinishedAlert = true
                }
            }).store(in: &cancellables)
    }
    
    var body: some View {
        if !demoMode {
            if case .authorized(let signedIn) = authorizer.signInState {
                NavigationStack {
                    if let drinkMachines = drinkMachines {
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
                                    Text(signedIn.user.preferredUsername)
                                        .foregroundStyle(.secondary)
                                    Divider()
                                    Button(action: {
                                        authorizer.signOut()
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
                            getDrinkCredits()
                            getDrinkData()
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
                            switch authorizer.signInState {
                            case .authorized(_):
                                getDrinkCredits()
                                getDrinkData()
                            case _:
                                print("not currently authed")
                            }
                        }
                    }
                }
            } else {
                SignInScreen(demoMode: $demoMode)
                    .environmentObject(authorizer)
            }
        } else {
            DemoView(demoMode: $demoMode)
        }
    }
}
