//
//  SettingsView.swift
//  VINA
//
//  Created by Youssef Ahab on 18/01/2023.
//

import Foundation
import SwiftUI

struct SettingsView: View {
  private static let DEFAULT_TINT: String = Theme.purple.name
  @AppStorage(StorageStrings.NARRATE_BREAKINGNEWS) var narrateBreakingNews:
    Bool = false
  @AppStorage(StorageStrings.BACKGROUND_TINT) var backgroundTint: String = Self
    .DEFAULT_TINT
  @AppStorage(StorageStrings.HISTORY_SIZE) var historySize: Int = Constants
    .DEFAULT_BUFFER_CAPACITY
  @AppStorage(StorageStrings.AUTO_SCROLL) var autoScroll: Bool = true

  @State private var invalidHistorySizeAlert: Bool = false

  var body: some View {
    VStack(alignment: .leading) {
      colorsMenu
      HStack {
        Toggle("Auto Scroll", isOn: $autoScroll)
        Spacer()
        // TODO: remove when feature is implemented
        Toggle("Narrate Breaking News", isOn: $narrateBreakingNews)
          .disabled(true)
      }
      historySection

    }
    .alert("History cannot be <= 0", isPresented: $invalidHistorySizeAlert) {
      Button("OK", role: .cancel) {}
    }
    .padding(20)
  }
  private func validateHistorySize(newSize: Int) -> Bool {
    return (newSize > 0) ? true : false
  }

  private var historySection: some View {
    HStack {
      Text("History:")
      TextField("100...", value: $historySize, format: .number)
        .fixedSize()
        .onChange(of: historySize) { (_, newSize) in
          // note we do note need to check if the textfield contains a valid number or not since we use format: .number
          if validateHistorySize(newSize: newSize) == false {
            self.historySize = Constants.DEFAULT_BUFFER_CAPACITY
            self.invalidHistorySizeAlert = true
          }
        }
    }
  }
  private var colorsMenu: some View {
    HStack {
      Text("Background Tint")
      Menu(self.backgroundTint.capitalized) {
        ForEach(Theme.allCases) { theme in
          Button(
            theme.name,
            action: { updateBackground(themeName: theme.name) }
          )
          .onHover(perform: { _ in updateBackground(themeName: theme.name) })
        }
      }
    }
  }

  private func updateBackground(themeName: String) {
    self.backgroundTint = themeName
  }
}
struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView()
  }
}
