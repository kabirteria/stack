//
//  stackApp.swift
//  stack
//
//  Created by Kabir Teria on 02/08/25.
//

import SwiftUI

@main
struct stackApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var ideaStore = IdeaStore.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ideaStore)
                .background(Color.black)
                .frame(minWidth: 250, minHeight: 350)
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .windowBackgroundDragBehavior(.enabled)
        .defaultSize(width: 500, height: 700)
    }
}
