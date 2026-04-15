//
//  SignInScreen.swift
//  CSH Drink
//
//  Created by Campbell Bagley on 10/8/25.
//

import SwiftUI
import Combine
import SignInWithCSH

struct SignInScreen: View {
    @EnvironmentObject private var authorizer: CSHAuthorizer
    @Binding var demoMode: Bool
    @State private var authSheetShowing: Bool = false
    
    var body: some View {
        VStack {
            Image(systemName: "cup.and.saucer")
                .font(.system(size: 100))
                .foregroundStyle(.accent)
            Text("CSH Drink")
                .font(.title)
            Text("Sign in to your CSH account to access drink, or try demo mode.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)
            Button(action: {
                authSheetShowing = false
                authSheetShowing = true
            }) {
                Text("Sign In")
            }
            Button(action: {
                print("enable demo mode")
                demoMode = true
            }) {
                Text("Demo Mode")
            }
            switch authorizer.signInState {
            case .authorized:
                Text("authorized")
            case .authorizationFailed(let error):
                Text("authorization failed: \(error.localizedDescription)")
            case .unauthorized:
                Text("unauthorized")
            }
            //.padding(.bottom, 50)
        }
        .cshAuthenticationSheet(
            authorizer: authorizer,
            isPresented: $authSheetShowing
        )
        .onChange(of: authSheetShowing, initial: true) {
            print("sheet is being dimissed")
        }
    }
}
