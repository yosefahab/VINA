//
//  VINAApp.swift
//  VINA
//
//  Created by Youssef Ahab on 18/01/2023.
//

import SwiftUI

@main
struct VINAApp: App {

  var body: some Scene {
    WindowGroup {
      NewsSheetView()
        .background(TransparentEffect())
        .environmentObject(ArticleStore())
    }
    .windowStyle(.hiddenTitleBar)

    #if os(macOS)
      Settings {
        SettingsView()
      }
    #endif

  }
}
