//
//  AddExpenseView.swift
//  BudgetLy
//
//  Created by Ashwath Singh on 09/07/25.
//

import SwiftUI
import SwiftData

struct AddExpenseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var categories: [ExpenseCategory]

    @State private var selectedCategory: ExpenseCategory?
    @State private var amountText: String = ""
    @State private var date: Date = Date()
    @State private var note: String = ""

    @State private var showAddCategorySheet = false

    var isSaveDisabled: Bool {
        selectedCategory == nil || Double(amountText) == nil || (Double(amountText) ?? 0) <= 0
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Form {
                    Section(header: Text("Amount")) {
                        TextField("e.g. 12.99", text: $amountText)
                            .keyboardType(.decimalPad)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.secondarySystemGroupedBackground))
                            )
                    }
                    
                    Section(header: Text("Category")) {
                        Picker("Select Category", selection: $selectedCategory) {
                            Text("None").tag(ExpenseCategory?.none)
                            ForEach(categories, id: \.self) { category in
                                Label {
                                    Text(category.name)
                                } icon: {
                                    Image(systemName: category.symbol)
                                        .foregroundColor(colorFromName(category.systemColorName))
                                }
                                .tag(Optional(category))
                            }
                        }
                        
                        Button {
                            showAddCategorySheet = true
                        } label: {
                            Label("Add New Category", systemImage: "plus.circle")
                        }
                    }
                    
                    Section(header: Text("Date")) {
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.secondarySystemGroupedBackground))
                            )
                    }
                    
                    
                    Section(header: Text("Note (optional)")) {
                        TextField("e.g. Coffee at Starbucks", text: $note)
                    }
                    
                    Section {
                        Button(action: saveExpense) {
                            Text("Save Expense")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .disabled(isSaveDisabled)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showAddCategorySheet) {
                AddCategorySheetView(isPresented: $showAddCategorySheet, onAdd: { newCategory in
                    selectedCategory = newCategory
                })
            }
        }
    }

    private func saveExpense() {
        guard let category = selectedCategory,
              let amount = Double(amountText),
              amount > 0 else { return }

        let newExpense = ExpenseItem(amount: amount, date: date, note: note.isEmpty ? nil : note, category: category)
        modelContext.insert(newExpense)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving expense: \(error.localizedDescription)")
        }
    }
}
struct AddCategorySheetView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool
    var onAdd: (ExpenseCategory) -> Void

    @State private var name = ""
    @State private var selectedSymbol = "cart.fill"
    @State private var selectedColor = "blue"

    private let symbols = [
        // Shopping
        "cart.fill", "bag.fill", "creditcard.fill", "dollarsign.circle.fill",
        // Food
        "fork.knife", "takeoutbag.and.cup.and.straw.fill", "cup.and.saucer.fill",
        // Transport
        "car.fill", "bus.fill", "fuelpump.fill", "bicycle", "airplane",
        // Home
        "house.fill", "bed.double.fill", "sofa.fill", "lamp.floor.fill",
        // Entertainment
        "gamecontroller.fill", "film.fill", "music.note", "headphones",
        // Bills & Utilities
        "bolt.fill", "drop.fill", "wifi", "tv.fill", "lightbulb.fill",
        // Health
        "cross.case.fill", "pills.fill", "heart.fill",
        // Others
        "gift.fill", "star.fill", "globe", "doc.text.fill"
    ]

    private let colors: [(name: String, color: Color)] = [
        ("red", .red), ("orange", .orange), ("yellow", .yellow),
        ("green", .green), ("mint", .mint), ("teal", .teal),
        ("blue", .blue), ("indigo", .indigo), ("purple", .purple),
        ("pink", .pink), ("brown", .brown), ("gray", .gray)
    ]

    var isDisabled: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background to match screen
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                Form {
                    Section(header: Text("Category Name")) {
                        TextField("e.g. Groceries", text: $name)
                    }

                    Section(header: Text("Symbol")) {
                        ScrollView {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                                ForEach(symbols, id: \.self) { symbol in
                                    Image(systemName: symbol)
                                        .font(.title2)
                                        .foregroundColor(symbol == selectedSymbol ? colorFromName(selectedColor) : .gray)
                                        .padding(6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(symbol == selectedSymbol ? colorFromName(selectedColor) : .clear, lineWidth: 2)
                                        )
                                        .onTapGesture {
                                            selectedSymbol = symbol
                                        }
                                }
                            }
                            .padding(.vertical, 6)
                        }
                        .frame(minHeight: 150)
                    }

                    Section(header: Text("Color")) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(colors, id: \.name) { item in
                                    Circle()
                                        .fill(item.color)
                                        .frame(width: 30, height: 30)
                                        .overlay(
                                            Circle().stroke(item.name == selectedColor ? Color.primary : .clear, lineWidth: 2)
                                        )
                                        .onTapGesture {
                                            selectedColor = item.name
                                        }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .scrollContentBackground(.hidden) // Remove default form background
            }

            .navigationTitle("New Category")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        let category = ExpenseCategory(symbol: selectedSymbol, name: trimmed, systemColorName: selectedColor)
                        modelContext.insert(category)
                        do {
                            try modelContext.save()
                            onAdd(category)
                            isPresented = false
                        } catch {
                            print("Failed to save category: \(error.localizedDescription)")
                        }
                    }
                    .disabled(isDisabled)
                }
            }
        }
    }
}
