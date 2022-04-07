//
//  Colors.swift
//
//
//  Created by Fernando Bunn on 07/04/2022.
//
#if !os(macOS)

import Foundation
import SwiftUI

public enum DuckColor {
    
    public static let red100 = Color.init(0x330B01)
    public static let red90 = Color.init(0x551605)
    public static let red80 = Color.init(0x77230C)
    public static let red70 = Color.init(0x9A3216)
    public static let red60 = Color.init(0xBC4423)
    public static let redBase = Color.init(0xDE5833)
    public static let red40 = Color.init(0xE46F4F)
    public static let red30 = Color.init(0xEB876C)
    public static let red20 = Color.init(0xF2A18A)
    public static let red10 = Color.init(0xF8BBAA)
    public static let red0 = Color.init(0xFFD7CC)
    
    public static let blue100 = Color.init(0x051133)
    public static let blue90 = Color.init(0x0B2059)
    public static let blue80 = Color.init(0x14307E)
    public static let blue70 = Color.init(0x1E42A4)
    public static let blue60 = Color.init(0x1E42A4)
    public static let blueBase = Color.init(0x3969EF)
    public static let blue40 = Color.init(0x557FF3)
    public static let blue30 = Color.init(0x7295F6)
    public static let blue20 = Color.init(0x8FABF9)
    public static let blue10 = Color.init(0xADC2FC)
    public static let blue0 = Color.init(0xADC2FC)
}

private extension Color {
  init(_ hex: UInt, alpha: Double = 1) {
    self.init(
      .sRGB,
      red: Double((hex >> 16) & 0xFF) / 255,
      green: Double((hex >> 8) & 0xFF) / 255,
      blue: Double(hex & 0xFF) / 255,
      opacity: alpha
    )
  }
}

#endif
