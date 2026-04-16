//
//  SignInScreen.swift
//  CSH Drink
//
//  Created by Campbell on 10/8/25.
//

import SwiftUI
import SignInWithCSH

struct SignInScreen: View {
    @Environment(DrinkModel.self) var model
    @State private var authSheetShowing: Bool = false
    
    var body: some View {
        VStack {
            Image(systemName: "cup.and.saucer")
                .font(.system(size: 100))
                .foregroundStyle(.accent)
            Text("CSH Drink")
                .font(.title)
                .fontWeight(.semibold)
            Text("Sign in to your CSH account to access drink.")
                .multilineTextAlignment(.center)
            Text("No CSH account? Try demo mode.")
                .foregroundStyle(.secondary)
                .padding(.bottom, 10)
            Button(action: {
                authSheetShowing = false
                authSheetShowing = true
            }) {
                Text("Sign In")
            }
            .buttonStyle(BorderedButtonStyle())
            Button(action: {
                print("enable demo mode")
                model.demoMode = true
                model.getDrinkData()
            }) {
                Text("Demo Mode")
            }
            .buttonStyle(BorderedButtonStyle())
            switch model.signInState {
            case .authorized:
                Text("authorized")
                    .foregroundStyle(.secondary)
            case .authorizationFailed(let error):
                Text("authorization failed: \(error.localizedDescription)")
                    .foregroundStyle(.secondary)
            case .unauthorized:
                Text("unauthorized")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 10)
        .cshAuthenticationSheet(
            authorizer: model.authorizer,
            isPresented: $authSheetShowing
        )
        .onChange(of: authSheetShowing, initial: true) {
            print("sheet is being dimissed")
        }
    }
}
