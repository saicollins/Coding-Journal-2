//
//  WishSaveApp.swift
//  WishSave
//
//  Created by Sai Col on 4/20/25.
//

import SwiftUI

@main
struct WishSaveApp: App {
    @StateObject private var model = BudgetModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
        }
    }
}
