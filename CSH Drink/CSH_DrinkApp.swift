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
    @State private var authorizer = CSHAuthorizer(
        CSHAppConfiguration(
            clientID: "applejuice",
            redirectURL: URL(string: "edu.rit.csh.applejuice://oauth2redirect")!,
            issuer: URL(string: "https://sso.csh.rit.edu/auth/realms/csh")!,
            scopes: [.openID, .profile, .email]
        )
    )
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    print("got a url: \(url)")
                }
                .environmentObject(authorizer)
        }
    }
}
