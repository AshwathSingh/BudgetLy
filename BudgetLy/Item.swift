//
//  Item.swift
//  BudgetLy
//
//  Created by Ashwath Singh on 07/07/25.
//

import Foundation
import SwiftData
import SwiftUICore

@Model
class ExpenseCategory: Identifiable {
    var id: UUID = UUID()
    var symbol: String
    var name: String
    var systemColorName: String  // Store color as system color name
    @Relationship(deleteRule: .cascade) var expenses: [ExpenseItem] = []

    init(symbol: String, name: String, systemColorName: String) {
        self.symbol = symbol
        self.name = name
        self.systemColorName = systemColorName
    }

    var color: Color {
        colorFromName(systemColorName)
    }
}


@Model
class ExpenseItem: Identifiable {
    var id: UUID = UUID()
    var amount: Double
    var date: Date
    var note: String?
    @Relationship var category: ExpenseCategory

    init(amount: Double, date: Date = Date(), note: String? = nil, category: ExpenseCategory) {
        self.amount = amount
        self.date = date
        self.note = note
        self.category = category
    }
}






func seedSampleData(context: ModelContext) {
    // Create categories
    let foodCategory = ExpenseCategory(symbol: "cup.and.saucer.fill", name: "Food", systemColorName: "blue")
    let subscriptionsCategory = ExpenseCategory(symbol: "tv.fill", name: "Subscriptions", systemColorName: "red")
    let groceriesCategory = ExpenseCategory(symbol: "cart.fill", name: "Groceries", systemColorName: "green")
    let billsCategory = ExpenseCategory(symbol: "bolt.fill", name: "Bills", systemColorName: "orange")
    let booksCategory = ExpenseCategory(symbol: "book.fill", name: "Books", systemColorName: "indigo")
    let fuelCategory = ExpenseCategory(symbol: "fuelpump.fill", name: "Fuel", systemColorName: "brown")
    let medicineCategory = ExpenseCategory(symbol: "pill.fill", name: "Medicine", systemColorName: "mint")
    let entertainmentCategory = ExpenseCategory(symbol: "film.fill", name: "Entertainment", systemColorName: "purple")
    let miscCategory = ExpenseCategory(symbol: "bag.fill", name: "Misc", systemColorName: "green")

    // Insert categories into context
    context.insert(foodCategory)
    context.insert(subscriptionsCategory)
    context.insert(groceriesCategory)
    context.insert(billsCategory)
    context.insert(booksCategory)
    context.insert(fuelCategory)
    context.insert(medicineCategory)
    context.insert(entertainmentCategory)
    context.insert(miscCategory)

    let calendar = Calendar.current

    let expenses = [
        ExpenseItem(amount: 4.50, date: calendar.date(from: DateComponents(year: 2025, month: 7, day: 1))!, note: "Morning coffee", category: foodCategory),
        ExpenseItem(amount: 9.99, date: calendar.date(from: DateComponents(year: 2025, month: 7, day: 2))!, note: "Netflix subscription", category: subscriptionsCategory),
        ExpenseItem(amount: 54.30, date: calendar.date(from: DateComponents(year: 2025, month: 7, day: 3))!, note: "Weekly groceries", category: groceriesCategory),
        ExpenseItem(amount: 85.00, date: calendar.date(from: DateComponents(year: 2025, month: 7, day: 3))!, note: "Electricity bill", category: billsCategory),
        ExpenseItem(amount: 20.00, date: calendar.date(from: DateComponents(year: 2025, month: 6, day: 28))!, note: "New novel", category: booksCategory),
        ExpenseItem(amount: 38.50, date: calendar.date(from: DateComponents(year: 2025, month: 6, day: 27))!, note: "Fuel refill", category: fuelCategory),
        ExpenseItem(amount: 12.75, date: calendar.date(from: DateComponents(year: 2025, month: 6, day: 25))!, note: "Pharmacy visit", category: medicineCategory),
        ExpenseItem(amount: 9.99, date: calendar.date(from: DateComponents(year: 2025, month: 6, day: 22))!, note: "Spotify subscription", category: subscriptionsCategory),
        ExpenseItem(amount: 28.00, date: calendar.date(from: DateComponents(year: 2025, month: 6, day: 21))!, note: "Office supplies", category: miscCategory),
        ExpenseItem(amount: 14.00, date: calendar.date(from: DateComponents(year: 2025, month: 6, day: 20))!, note: "Movie ticket", category: entertainmentCategory),

        // More realistic recent expenses in July up to 10th
        ExpenseItem(amount: 16.75, date: calendar.date(from: DateComponents(year: 2025, month: 7, day: 4))!, note: "Lunch at café", category: foodCategory),
        ExpenseItem(amount: 22.40, date: calendar.date(from: DateComponents(year: 2025, month: 7, day: 5))!, note: "Grocery store run", category: groceriesCategory),
        ExpenseItem(amount: 95.00, date: calendar.date(from: DateComponents(year: 2025, month: 7, day: 6))!, note: "Water bill payment", category: billsCategory),
        ExpenseItem(amount: 6.25, date: calendar.date(from: DateComponents(year: 2025, month: 7, day: 7))!, note: "Afternoon snack", category: foodCategory),
        ExpenseItem(amount: 15.00, date: calendar.date(from: DateComponents(year: 2025, month: 7, day: 8))!, note: "Cold medicine", category: medicineCategory),
        ExpenseItem(amount: 50.00, date: calendar.date(from: DateComponents(year: 2025, month: 7, day: 9))!, note: "Concert tickets", category: entertainmentCategory),
        ExpenseItem(amount: 42.00, date: calendar.date(from: DateComponents(year: 2025, month: 7, day: 10))!, note: "Dinner with friends", category: foodCategory),

        // A few subscriptions and miscellaneous
        ExpenseItem(amount: 14.99, date: calendar.date(from: DateComponents(year: 2025, month: 6, day: 30))!, note: "Streaming subscription", category: subscriptionsCategory),
        ExpenseItem(amount: 25.00, date: calendar.date(from: DateComponents(year: 2025, month: 7, day: 2))!, note: "Miscellaneous supplies", category: miscCategory)
    ]

    // Insert expenses
    for expense in expenses {
        context.insert(expense)
    }
}


func colorFromName(_ name: String) -> Color {
    switch name.lowercased() {
    case "red": return .red
    case "blue": return .blue
    case "green": return .green
    case "orange": return .orange
    case "indigo": return .indigo
    case "mint": return .mint
    case "brown": return .brown
    case "purple": return .purple
    default: return .gray // fallback
    }
}

