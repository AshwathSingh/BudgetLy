//
//  ExpensesPerCategoryView.swift
//  BudgetLy
//
//  Created by Ashwath Singh on 08/07/25.
//

import SwiftUI
import SwiftData

struct ExpensesPerCategoryView: View {
    @Query private var categories: [ExpenseCategory]
    @Query private var expenses: [ExpenseItem]  // Fetch expenses here too

    // Compute totals per category inside this view
    var categoryTotals: [(category: ExpenseCategory, total: Double)] {
        let grouped = Dictionary(grouping: expenses) { $0.category }
        return categories.map { category in
            let total = grouped[category]?.reduce(0) { $0 + $1.amount } ?? 0
            return (category, total)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(categoryTotals, id: \.category.id) { item in
                    CategoryCard(
                        systemImage: item.category.symbol,
                        categoryName: item.category.name,
                        categoryExpense: item.total,
                        accentColourName: colorFromName(item.category.systemColorName)
                    )
                }
            }
            .navigationTitle("Category Expenses")
            .navigationBarTitleDisplayMode(.inline)
            .padding()
        }
    }
}


struct TrendsView: View {
    var body: some View {
        VStack {
            Text("Trends Analysis")
                .font(.headline)
                .padding()
            // Add charts, graphs, or stats here
            Text("Trend data goes here.")
        }
        .frame(maxWidth: .infinity)
    }
}

struct CategoryCard: View {
    var systemImage: String
    var categoryName: String
    var categoryExpense: Double
    var accentColourName: Color

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(accentColourName.opacity(0.2))
                    .frame(width: 48, height: 48)

                Image(systemName: systemImage)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(accentColourName)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(categoryName)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text("Category Total")
                    .font(.caption)
                    .foregroundColor(.primary.opacity(0.6))
            }

            Spacer()

            Text(String(format: "$%.2f", categoryExpense))
                .font(.headline)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color.secondary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    let container = try! ModelContainer(for: ExpenseCategory.self, ExpenseItem.self)
    let context = ModelContext(container)
    seedSampleData(context: context)
    return ExpensesPerCategoryView().environment(\.modelContext, context)
}
