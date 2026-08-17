//
//  SignInScreen.swift
//  CSH Drink
//
//  Created by Campbell on 10/8/25.
//

import SwiftUI
import SignInWithCSH

struct SignInView: View {
    @Environment(DrinkModel.self) var model
    @State private var authSheetShowing: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 16) {
                Image("Icon")
                    .resizable()
                    .frame(width: 96, height: 96)
                
                Text("Sign In to Your CSH Account to Access Drink")
                    .font(.title)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text("No CSH account? You can still try the app out with demo mode.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            VStack {
                #if DEBUG
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
                #endif
                
                Button(action: {
                    authSheetShowing = false
                    authSheetShowing = true
                }) {
                    Text("Sign In...")
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                }
                .adaptiveProminentButtonStyle()

                Button(action: {
                    print("enable demo mode")
                    model.demoMode = true
                    model.getDrinkData()
                }) {
                    Text("Demo Mode")
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                }
                .adaptiveBorderedButtonStyle()
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
        .cshAuthenticationSheet(
            authorizer: model.authorizer,
            isPresented: $authSheetShowing
        )
        .onChange(of: authSheetShowing, initial: true) {
            print("sheet is being dimissed")
        }
    }
}
