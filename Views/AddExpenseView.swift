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

    // New states for adding category inline
    @State private var isAddingCategory = false
    @State private var newCategoryName = ""
    @State private var newCategorySymbol = "star.fill"
    @State private var newCategoryColorName = "blue"

    // SF Symbols sample for picker (you can expand this)
    private let sfSymbols = ["star.fill", "heart.fill", "car.fill", "house.fill", "cart.fill", "flame.fill", "bolt.fill", "gift.fill"]

    // Color options (system colors)
    private let colorOptions: [(name: String, color: Color)] = [
        ("red", .red),
        ("orange", .orange),
        ("yellow", .yellow),
        ("green", .green),
        ("mint", .mint),
        ("teal", .teal),
        ("blue", .blue),
        ("indigo", .indigo),
        ("purple", .purple),
        ("pink", .pink),
        ("brown", .brown),
        ("gray", .gray)
    ]

    var isSaveDisabled: Bool {
        selectedCategory == nil || Double(amountText) == nil || (Double(amountText) ?? 0) <= 0
    }

    var isAddCategoryDisabled: Bool {
        newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Amount input
                    TextField("Amount (e.g., 12.99)", text: $amountText)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                    // Category picker or add new category button
                    if isAddingCategory {
                        addCategorySection
                    } else {
                        Picker("Category", selection: $selectedCategory) {
                            Text("Select Category").tag(ExpenseCategory?.none)
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
                        .pickerStyle(MenuPickerStyle())
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                        Button(action: {
                            isAddingCategory = true
                            newCategoryName = ""
                            newCategorySymbol = sfSymbols.first ?? "star.fill"
                            newCategoryColorName = "blue"
                        }) {
                            Label("Add New Category", systemImage: "plus.circle.fill")
                                .font(.callout)
                                .foregroundColor(.accentColor)
                        }
                        .padding(.top, -12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Date picker
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                    // Note field
                    TextField("Add a note (optional)", text: $note)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                    Spacer(minLength: 20)

                    // Save button
                    Button(action: saveExpense) {
                        Text("Save Expense")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isSaveDisabled ? Color.gray : Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                    .disabled(isSaveDisabled)
                }
                .padding()
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    var addCategorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            TextField("Category Name", text: $newCategoryName)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

            Text("Pick an Icon")
                .font(.headline)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 16) {
                ForEach(sfSymbols, id: \.self) { symbol in
                    Image(systemName: symbol)
                        .font(.title2)
                        .foregroundColor(symbol == newCategorySymbol ? colorFromName(newCategoryColorName) : .gray)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(symbol == newCategorySymbol ? colorFromName(newCategoryColorName) : .clear, lineWidth: 2)
                        )
                        .onTapGesture {
                            newCategorySymbol = symbol
                        }
                }
            }

            Text("Pick a Color")
                .font(.headline)

            HStack(spacing: 16) {
                ForEach(colorOptions, id: \.name) { colorOption in
                    Circle()
                        .fill(colorOption.color)
                        .frame(width: 30, height: 30)
                        .overlay(
                            Circle()
                                .stroke(colorOption.name == newCategoryColorName ? Color.primary : .clear, lineWidth: 2)
                        )
                        .onTapGesture {
                            newCategoryColorName = colorOption.name
                        }
                }
            }

            HStack {
                Button("Cancel") {
                    isAddingCategory = false
                }
                .foregroundColor(.red)

                Spacer()

                Button("Add Category") {
                    addCategory()
                }
                .disabled(isAddCategoryDisabled)
                .bold()
            }
            .padding(.top)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private func addCategory() {
        let trimmedName = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        let newCategory = ExpenseCategory(symbol: newCategorySymbol, name: trimmedName, systemColorName: newCategoryColorName)
        modelContext.insert(newCategory)

        do {
            try modelContext.save()
            selectedCategory = newCategory
            isAddingCategory = false
        } catch {
            print("Failed to add category: \(error.localizedDescription)")
        }
    }

    private func saveExpense() {
        guard
            let category = selectedCategory,
            let amount = Double(amountText),
            amount > 0
        else { return }

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
