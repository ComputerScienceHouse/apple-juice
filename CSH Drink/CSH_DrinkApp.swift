//
//  CSH_DrinkApp.swift
//  CSH Drink
//
//  Created by Campbell on 9/30/25.
//

import SwiftUI
import SignInWithCSH

@main
struct CSH_DrinkApp: App {
    @State private var model = DrinkModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    print("got a url: \(url)")
                }
                .environment(model)
        }
    }
}
