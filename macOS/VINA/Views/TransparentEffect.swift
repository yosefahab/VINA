//
//  TransparentEffect.swift
//  VINA
//
//  Created by Youssef Ahab on 18/01/2023.
//

import Foundation
import SwiftUI

struct TransparentEffect: NSViewRepresentable {

  func makeNSView(context: Self.Context) -> NSView {
    return NSVisualEffectView()
  }

  func updateNSView(_ nsView: NSView, context: Context) {}
}
