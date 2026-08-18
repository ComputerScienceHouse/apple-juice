//
//  DrinkModel.swift
//  CSH Drink
//
//  Created by Campbell on 4/16/26.
//

import Combine
import SwiftUI
import SignInWithCSH

@Observable
class DrinkModel {
    var authorizer = CSHAuthorizer(
        CSHAppConfiguration(
            clientID: "applejuice",
            redirectURL: URL(string: "edu.rit.csh.applejuice://oauth2redirect")!,
            issuer: URL(string: "https://sso.csh.rit.edu/auth/realms/csh")!,
            scopes: [.openID, .profile, .email, .offlineAccess]
        )
    )
    var signInState: CSHAuthorizer.State = .unauthorized
    
    var drinkMachines: [DrinkMachine] = []
    var creditCount: Int = 0
    var dropInProgress: Bool = false
    var cancellables: Set<AnyCancellable> = Set()
    var dropFinishedTitle: String = ""
    var dropFinishedMessage: String = ""
    var isLoaded = false
    var demoMode = false
    
    init() {
        self.signInState = self.authorizer.signInState

        authorizer.$signInState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newState in
                self?.signInState = newState
            }
            .store(in: &cancellables)
    }
    
    func loadAll() {
        self.getDrinkData()
        self.getDrinkCredits()
    }
    
    func getDrinkData() {
        // Do not attempt to load real data in demo mode.
        guard !demoMode else { self.getDemoDrinkData(); return }
        
        guard let url = URL(string: "https://drink.csh.rit.edu/drinks") else { return }
        
        self.authorizer.dataTaskPublisher(for: url)
            .map{ $0.data }
            .sink(receiveCompletion: { thing in
                switch (thing) {
                case .failure(let e):
                    print("encountered error:")
                    print(e)
                    // There's not better way to handle this yet, so if auth explodes the safest
                    // option is to just force a signout and have the user log back in from scratch.
                    self.authorizer.signOut()
                case .finished:
                    print("inventory completion")
                }
            }, receiveValue: { data in
                do {
                    let decoded = try JSONDecoder().decode(DrinkMachinesParser.self, from: data)
                    self.drinkMachines = decoded.machines
                    withAnimation {
                        self.isLoaded = true
                    }
                } catch {
                    print("json error!!")
                }
            }).store(in: &cancellables)
    }
    
    func getDrinkCredits() {
        guard !demoMode else { return }
        
        switch authorizer.signInState {
        case .authorized(let signedIn):
            print("requesting credits for user \(signedIn.user.preferredUsername)")
            guard let url = URL(string: "https://drink.csh.rit.edu/users/credits?uid=\(signedIn.user.preferredUsername)") else { return }
            
            self.authorizer.dataTaskPublisher(for: url)
                .map{ $0.data }
                .sink(receiveCompletion: { _ in
                    print("credit completion")
                }, receiveValue: { data in
                    do {
                        let decoded = try JSONDecoder().decode(CreditsReponse.self, from: data)
                        print("user \(decoded.user.uid) has \(decoded.user.drinkBalance) credits")
                        withAnimation {
                            self.creditCount = Int(decoded.user.drinkBalance) ?? 0
                        }
                    } catch {
                        print("json error!!")
                    }
                }).store(in: &cancellables)
        case _:
            // Not signed in so don't try.
            return
        }
    }
    
    func dropItem(selectedItem: SelectedItem) {
        guard !demoMode else { Task { await demoDropItem(selectedItem: selectedItem) }; return }
        
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
                    // Blank these values so that we know later that if they're not blank, there
                    // was some sort of error. This is to remove the old behavior where there was
                    // an alert even for successful drops telling you they succeeded.
                    self.dropFinishedTitle = ""
                    self.dropFinishedMessage = ""

                    let decoded = try JSONDecoder().decode(DropResponse.self, from: data)
                    if decoded.drinkBalance == nil {
                        print("drop did not succeed with message: \(decoded.message)")
                        self.dropFinishedTitle = "Couldn't Drop Item"
                        self.dropFinishedMessage = "An error occurred while trying to drop the requested item. Drink replied: \(decoded.message)"
                        self.dropInProgress = false
                    }
                } catch {
                    print("json error!!")
                    guard let str = String(
                        data: data,
                        encoding: .utf8
                    ) else {
                        print("Unable to convert data")
                        self.dropFinishedTitle = "Couldn't Drop Item"
                        self.dropFinishedMessage = "An error occurred while trying to drop the requested item. No more details can be provided."
                        self.dropInProgress = false
                        return
                    }
                    print(str)
                    self.dropFinishedTitle = "Couldn't Drop Item"
                    self.dropFinishedMessage = "An error occurred while trying to drop the requested item. Raw reply from drink: \(str)"
                    self.dropInProgress = false
                }
            }).store(in: &cancellables)
    }
    
    func signOut() {
        self.authorizer.signOut()
        // "Signs out" of demo mode if we're in it.
        self.demoMode = false
        self.isLoaded = false
    }
    
    // This mildly complicated function is required because we need unauthorized + demo mode on to
    // also count as ready to display data, rather than only authorized.
    func isReadyToDisplay() -> Bool {
        if case .authorized = self.signInState {
            return true
        } else if case .unauthorized = self.signInState {
            if self.demoMode {
                return true
            }
        }
        return false
    }
    
    func getDemoDrinkData() {
        print("we are in demo mode, loading demo drink data")
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

        self.drinkMachines = decoded.machines
        // Load sample credit balance of 250.
        self.creditCount = 250
        withAnimation {
            self.isLoaded = true
        }
    }
    
    func demoDropItem(selectedItem: SelectedItem) async {
        print(selectedItem)
        self.dropInProgress = true
        withAnimation {
            creditCount -= selectedItem.cost
        }
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        print("demo drop done!")
        self.dropInProgress = false
    }
}
