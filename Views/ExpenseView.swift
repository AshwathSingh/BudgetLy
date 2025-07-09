//
//  ExpenseView.swift
//  BudgetLy
//
//  Created by Ashwath Singh on 07/07/25.
//

import SwiftUI
import SwiftData

struct ExpenseView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var expenses: [ExpenseItem]
    @Query private var categories: [ExpenseCategory]

    @State private var searchText = ""
    @State private var selectedFilter = "All"

    var allFilters: [String] {
        ["All"] + categories.map { $0.name }
    }
    
    private func groupedFilteredExpenses() -> [(groupDate: Date, groupTitle: String, items: [ExpenseItem])] {
        let filtered = expenses.filter { expense in
            let matchesSearch = searchText.isEmpty ||
                (expense.note?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                expense.category.name.localizedCaseInsensitiveContains(searchText)
            let matchesFilter = selectedFilter == "All" || expense.category.name == selectedFilter
            return matchesSearch && matchesFilter
        }

        let calendar = Calendar.current

        // Group expenses by start of week date
        let grouped = Dictionary(grouping: filtered) { expense -> Date in
            calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: expense.date)) ?? expense.date
        }

        // Sort weeks descending (recent first)
        let sortedGroups = grouped.sorted { $0.key > $1.key }

        // Map each group to (date, formatted title, sorted expenses ascending by day)
        return sortedGroups.map { (groupDate, items) in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            let title = "Week of \(formatter.string(from: groupDate))"
            let sortedItems = items.sorted { $0.date > $1.date }
            return (groupDate, title, sortedItems)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                HeaderView(textField: "Your Expenses")

                TextField("Search expenses...", text: $searchText)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                FilterScrollView(filters: allFilters, selectedFilter: $selectedFilter)

                ExpensesGroupedView(
                    groupedExpenses: groupedFilteredExpenses()
                )
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .background(Color(.systemBackground))
        }
    }
}

struct FilterScrollView: View {
    let filters: [String]
    @Binding var selectedFilter: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(filters, id: \.self) { filter in
                    Text(filter)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            selectedFilter == filter ? Color.accentColor.opacity(0.2) : Color(.systemGray5)
                        )
                        .foregroundStyle(selectedFilter == filter ? .primary : .secondary)
                        .clipShape(Capsule())
                        .onTapGesture {
                            selectedFilter = filter
                        }
                }
            }
        }
    }
}

struct ExpensesGroupedView: View {
    let groupedExpenses: [(groupDate: Date, groupTitle: String, items: [ExpenseItem])]

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 24) {
                ForEach(groupedExpenses, id: \.groupDate) { section in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(section.groupTitle)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.horizontal)

                        ForEach(section.items, id: \.id) { expense in
                            ExpensesCard(
                                title: (expense.note?.isEmpty == false ? expense.note! : expense.category.name),
                                subtitle: "\(expense.category.name) • \(expense.date.formatted(date: .abbreviated, time: .omitted))",
                                amount: expense.amount,
                                icon: expense.category.symbol,
                                color: colorFromName(expense.category.systemColorName) // <-- fixed here
                            )
                        }
                    }
                }
            }
            .padding(.bottom, 32)
        }
    }
}


struct ExpensesCard: View {
    var title: String
    var subtitle: String
    var amount: Double
    var icon: String
    var color: Color

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 48, height: 48)

                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(String(format: "-$%.2f", amount))
                .font(.headline)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
