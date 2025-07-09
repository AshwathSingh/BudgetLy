//
//  BudgetLyApp.swift
//  BudgetLy
//
//  Created by Ashwath Singh on 07/07/25.
//

import SwiftUI
import SwiftData

@main
struct BudgetLyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [ExpenseCategory.self, ExpenseItem.self])
        }
    }
}

