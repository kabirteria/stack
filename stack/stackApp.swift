//
//  stackApp.swift
//  stack
//
//  Created by Kabir Teria on 02/08/25.
//

import SwiftUI

@main
struct stackApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(Color.black)
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .windowBackgroundDragBehavior(.enabled)
    }
}
