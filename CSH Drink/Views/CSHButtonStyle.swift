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

struct CustomSpacedLabel: LabelStyle {
    var spacing: Double = 0.0
    
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: spacing) {
            configuration.icon
            configuration.title
        }
    }
}
