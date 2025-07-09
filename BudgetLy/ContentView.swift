//
//  ContentView.swift
//  BudgetLy
//
//  Created by Ashwath Singh on 07/07/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var expenses: [ExpenseItem]
    @Query private var categories: [ExpenseCategory]  // fixed typo

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                }
            
            ExpenseView()
                .tabItem {
                    Image(systemName: "list.bullet.rectangle.portrait.fill")
                }
            
            HistoryView()
                .tabItem {
                    Image(systemName: "chart.bar.horizontal.page")
                }
            
            Spacer()
            
            AddExpenseView()
                .tabItem {
                    Image(systemName: "plus")
                }
        }
        .tint(.primary)
        .padding(.horizontal)
    }
}

func previewContentView() -> some View {
    do {
        let container = try ModelContainer(
            for: ExpenseCategory.self, ExpenseItem.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        seedSampleData(context: context)

        return ContentView()
            .environment(\.modelContext, context)

    } catch {
        fatalError("Failed to create model container: \(error)")
    }
}

#Preview {
    previewContentView()
}



