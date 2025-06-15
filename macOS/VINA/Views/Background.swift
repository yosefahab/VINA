//
//  Background.swift
//  VINA
//
//  Created by Youssef Ahab on 29/01/2024.
//

import SwiftUI

struct Background: View {
  private static let BLUR_RADIUS: CGFloat = 150
  private static let BACKGROUND_OPACITY: Double = 0.2

  @AppStorage(StorageStrings.BACKGROUND_TINT) var backgroundTint: String = Theme
    .clear.name
  var body: some View {
    LinearGradient(
      colors: [
        Color(self.backgroundTint).opacity(Self.BACKGROUND_OPACITY)

      ],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
    .blur(radius: Self.BLUR_RADIUS)
  }
}

#Preview {
  Background(backgroundTint: StorageStrings.BACKGROUND_TINT)
}
