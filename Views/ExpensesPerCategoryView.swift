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

    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(categories, id: \.self) { category in
                    CategoryCard(
                        systemImage: category.symbol,
                        categoryName: category.name,
                        categoryExpense: category.expenses.reduce(0) { $0 + $1.amount },
                        accentColourName: Color(category.systemColorName)
                    )
                }

            }
            .navigationTitle("Category Expenses")
            .navigationBarTitleDisplayMode(.inline)
            .padding()
        }
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
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    let container = try! ModelContainer(for: ExpenseCategory.self, ExpenseItem.self)
    let context = ModelContext(container)
    seedSampleData(context: context)
    return ExpensesPerCategoryView().environment(\.modelContext, context)
}
