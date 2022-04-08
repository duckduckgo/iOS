//
//  Button.swift
//  
//
//  Created by Fernando Bunn on 08/04/2022.
//

import SwiftUI

public struct PrimaryButtonStyle: ButtonStyle {
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Font(UIFont.boldAppFont(ofSize: Consts.fontSize)))
            .foregroundColor(configuration.isPressed ? .white.opacity(Consts.pressedOpacity) : .white.opacity(1))
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: Consts.height)
            .background(configuration.isPressed ? Color.deprecatedBlue.opacity(Consts.pressedOpacity) : Color.deprecatedBlue.opacity(1))
            .cornerRadius(Consts.cornerRadius)
    }
}

public struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    
    public init() {}
    
    private var backgoundColor: Color {
        colorScheme == .light ? Color.white : .gray70
    }
    private var foregroundColor: Color {
        colorScheme == .light ? .deprecatedBlue : .white
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Font(UIFont.boldAppFont(ofSize: Consts.fontSize)))
            .foregroundColor(configuration.isPressed ? foregroundColor.opacity(Consts.pressedOpacity) : foregroundColor.opacity(1))
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: Consts.height)
            .background(configuration.isPressed ? backgoundColor.opacity(Consts.pressedOpacity) : backgoundColor.opacity(1))
            .cornerRadius(Consts.cornerRadius)
    }
}

public struct GhostButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme

    public init() {}
    private var foregroundColor: Color {
        colorScheme == .light ? .deprecatedBlue : .white
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Font(UIFont.boldAppFont(ofSize: Consts.fontSize)))
            .foregroundColor(configuration.isPressed ? foregroundColor.opacity(Consts.pressedOpacity) : foregroundColor.opacity(1))
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: Consts.height)
            .background(Color.clear)
            .cornerRadius(Consts.cornerRadius)
    }
}

private enum Consts {
    static let cornerRadius: CGFloat = 12
    static let height: CGFloat = 50
    static let fontSize: CGFloat = 16
    static let pressedOpacity: CGFloat = 0.7
}
