//
//  CSHButtonStyle.swift
//  CSH Drink
//
//  Created by Campbell on 10/8/25.
//

import SwiftUI

struct CSHButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        Group {
            configuration.label
                .font(.headline)
                .foregroundColor(isEnabled ? Color.white : Color.secondary)
                .padding(.all, 10)
                .background(isEnabled ? Color.accentColor : Color.gray.opacity(0.3))
                .overlay(configuration.isPressed ? Color.black.opacity(0.1) : nil)
                .cornerRadius(28)
        }
    }
}

struct XLButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .frame(height: 64)
    }
}

// These two view modifiers let me use the fancy glass buttons on iOS 26+ while still maintaining
// compatibly with iOS 17/18, where it'll just use the bordered button styles instead.
struct AdaptiveProminentButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .buttonStyle(.glassProminent)
        } else {
            content
                .buttonStyle(.borderedProminent)
        }
    }
}

struct AdaptiveBorderedButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .buttonStyle(.glass)
        } else {
            content
                .buttonStyle(.bordered)
        }
    }
}

extension View {
    func adaptiveProminentButtonStyle() -> some View {
        modifier(AdaptiveProminentButtonStyle())
    }

    func adaptiveBorderedButtonStyle() -> some View {
        modifier(AdaptiveBorderedButtonStyle())
    }
}

struct CustomSpacedLabel: LabelStyle {
    var spacing: Double = 0.0
    
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: spacing) {
            configuration.icon
            configuration.title
        }
    }
}
