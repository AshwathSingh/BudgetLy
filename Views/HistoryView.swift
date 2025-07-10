//
//  HistoryView.swift
//  BudgetLy
//
//  Created by Ashwath Singh on 07/07/25.
//

import SwiftUI
import SwiftData
import Charts

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ExpenseItem.date, order: .reverse) var expenses: [ExpenseItem]

    @State private var selectedRange: DateRange = .thisMonth

    private var filteredExpenses: [ExpenseItem] {
        expenses.filter { selectedRange.contains($0.date) }
    }

    private var groupedByDay: [(date: Date, total: Double)] {
        let grouped = Dictionary(grouping: filteredExpenses) {
            Calendar.current.startOfDay(for: $0.date)
        }
        return grouped
            .map { (key, value) in (date: key, total: value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.date < $1.date }
    }

    private var totalSpent: Double {
        filteredExpenses.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                Text("Spending Trends")
                    .font(.largeTitle.bold())
                    .padding(.top)

                // Range Picker
                Picker("Range", selection: $selectedRange) {
                    ForEach(DateRange.allCases, id: \.self) {
                        Text($0.title).tag($0)
                    }
                }
                .pickerStyle(.segmented)

                // Bar Chart
                if !groupedByDay.isEmpty {
                    Chart {
                        ForEach(groupedByDay, id: \.date) { entry in
                            BarMark(
                                x: .value("Date", entry.date, unit: .day),
                                y: .value("Total", entry.total)
                            )
                            .foregroundStyle(.blue.gradient)
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day, count: groupedByDay.count > 10 ? 3 : 1)) { _ in AxisGridLine(); AxisTick(); AxisValueLabel(format: .dateTime.day(.defaultDigits)) }
                    }
                    .frame(height: 200)
                }

                // Category Highlights
                if !filteredExpenses.isEmpty {
                    Text("Top Categories")
                        .font(.title3.bold())
                        .padding(.top)

                    let topCategories = topCategoriesWithTotals()

                    ForEach(topCategories, id: \.category.id) { item in
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(item.category.color.opacity(0.2))
                                    .frame(width: 36, height: 36)
                                Image(systemName: item.category.symbol)
                                    .foregroundColor(item.category.color)
                            }

                            VStack(alignment: .leading) {
                                Text(item.category.name)
                                    .fontWeight(.semibold)
                                Text("Category Total")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Text("$\(item.total, specifier: "%.2f")")
                                .fontWeight(.bold)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("Trends")
    }

    private func topCategoriesWithTotals() -> [(category: ExpenseCategory, total: Double)] {
        let grouped = Dictionary(grouping: filteredExpenses) { $0.category }
        return grouped
            .map { (category, items) in
                (category: category, total: items.reduce(0) { $0 + $1.amount })
            }
            .sorted { $0.total > $1.total }
            .prefix(3)
            .map { $0 }
    }
}

enum DateRange: CaseIterable {
    case thisWeek, thisMonth

    var title: String {
        switch self {
        case .thisWeek: return "This Week"
        case .thisMonth: return "This Month"
        }
    }

    func contains(_ date: Date) -> Bool {
        let calendar = Calendar.current
        switch self {
        case .thisWeek:
            return calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
        case .thisMonth:
            return calendar.isDate(date, equalTo: Date(), toGranularity: .month)
        }
    }
}
