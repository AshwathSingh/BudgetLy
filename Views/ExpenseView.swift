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

        let grouped = Dictionary(grouping: filtered) { expense -> Date in
            calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: expense.date)) ?? expense.date
        }

        let sortedGroups = grouped.sorted { $0.key > $1.key }

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

                Spacer()

                TextField("Search expenses...", text: $searchText)
                    .padding(10)
                    .padding(.top, 0)
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

    @State private var selectedExpense: ExpenseItem? = nil

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 24) {
                ForEach(groupedExpenses, id: \.groupDate) { section in
                    ExpenseSectionView(
                        title: section.groupTitle,
                        items: section.items
                    ) { tappedExpense in
                        selectedExpense = tappedExpense
                    }
                }
            }
            .padding(.bottom, 32)
        }
        .sheet(item: $selectedExpense) { expense in
            ExpenseDetailSheet(expense: expense)
        }

    }
}

struct ExpenseDetailSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query private var allCategories: [ExpenseCategory] 

    @State var expense: ExpenseItem
    @State private var isEditing = false

    @State private var editedNote: String = ""
    @State private var editedAmount: String = ""
    @State private var editedDate: Date = Date()
    @State private var editedCategory: ExpenseCategory?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    // Icon Preview
                    ZStack {
                        Circle()
                            .fill(colorFromName((editedCategory ?? expense.category).systemColorName).opacity(0.15))
                            .frame(width: 160, height: 160)

                        Image(systemName: (editedCategory ?? expense.category).symbol)
                            .font(.system(size: 70, weight: .semibold))
                            .foregroundColor(colorFromName((editedCategory ?? expense.category).systemColorName))
                    }
                    .padding(.top)

                    // Editable Fields
                    if isEditing {
                        VStack(spacing: 20) {
                            Group {
                                TextField("Note", text: $editedNote)
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(12)

                                TextField("Amount", text: $editedAmount)
                                    .keyboardType(.decimalPad)
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(12)

                                DatePicker("Date", selection: $editedDate, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(12)
                            }

                            // Category Picker
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Category")
                                    .font(.headline)

                                Picker("Category", selection: $editedCategory) {
                                    ForEach(allCategories) { category in
                                        HStack {
                                            Image(systemName: category.symbol)
                                            Text(category.name)
                                        }.tag(Optional(category)) // Optional due to editedCategory being optional
                                    }
                                }
                                .pickerStyle(.menu)
                                .padding()
                                .background(.ultraThinMaterial)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        // Static Info View
                        VStack(spacing: 12) {
                            Text(expense.note ?? "No note")
                                .font(.title2)
                                .fontWeight(.semibold)

                            Text("Amount: $\(expense.amount, specifier: "%.2f")")
                                .font(.headline)

                            Text("Category: \(expense.category.name)")
                                .foregroundColor(.secondary)

                            Text("Date: \(expense.date.formatted(date: .long, time: .omitted))")
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    }

                    // Action Buttons
                    VStack(spacing: 14) {
                        if isEditing {
                            Button(action: {
                                guard let newAmount = Double(editedAmount),
                                      let selectedCategory = editedCategory else { return }

                                expense.note = editedNote
                                expense.amount = newAmount
                                expense.date = editedDate
                                expense.category = selectedCategory

                                try? modelContext.save()
                                isEditing = false
                            }) {
                                Text("Save Changes")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.accentColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }

                            Button("Cancel") {
                                isEditing = false
                            }
                            .foregroundColor(.red)
                        } else {
                            Button("Edit") {
                                editedNote = expense.note ?? ""
                                editedAmount = String(format: "%.2f", expense.amount)
                                editedDate = expense.date
                                editedCategory = expense.category
                                isEditing = true
                            }
                            .fontWeight(.medium)
                        }

                        Button(role: .destructive) {
                            modelContext.delete(expense)
                            try? modelContext.save()
                            dismiss()
                        } label: {
                            Text("Delete Expense")
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .navigationTitle("Expense Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}



struct ExpenseSectionView: View {
    let title: String
    let items: [ExpenseItem]
    let onTap: (ExpenseItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.horizontal)

            ForEach(items, id: \.id) { expense in
                ExpensesCard(
                    title: (expense.note?.isEmpty == false ? expense.note! : expense.category.name),
                    subtitle: "\(expense.category.name) • \(expense.date.formatted(date: .abbreviated, time: .omitted))",
                    amount: expense.amount,
                    icon: expense.category.symbol,
                    color: colorFromName(expense.category.systemColorName)
                )
                .onTapGesture {
                    onTap(expense)
                }
            }
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
