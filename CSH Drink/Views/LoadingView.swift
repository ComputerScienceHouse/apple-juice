//
//  LoadingView.swift
//  CSH Drink
//
//  Created by Campbell Bagley on 8/17/26.
//

import SwiftUI

struct LoadingView: View {
    let loadFinished: Bool
    let onAnimationFinished: () -> Void
    
    @State private var didFinishAnimation = false
    
    var body: some View {
        VStack {
            Image(systemName: loadFinished ? "waterbottle.fill" : "waterbottle")
                .font(.system(size: 100))
                .modifier(LoadingSymbolAnimation(loadFinished: loadFinished))
                .foregroundStyle(.accent)
        }
        .onChange(of: loadFinished) {
            guard loadFinished, !didFinishAnimation else {
                return
            }

            didFinishAnimation = true

            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(400))
                onAnimationFinished()
            }
        }
    }
}

private struct LoadingSymbolAnimation: ViewModifier {
    let loadFinished: Bool
    
    func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            content
                .symbolEffect(
                    .breathe.plain,
                    isActive: !loadFinished
                )
                .contentTransition(
                    .symbolEffect(.replace.downUp)
                )
        } else {
            content
        }
    }
}

#Preview {
    LoadingView(loadFinished: false, onAnimationFinished: {})
}
