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
        ExpenseItem(amount: 5.20, date: calendar.date(from: DateComponents(year: 2025, month: 7, day: 8))!, note: "Coffee at Starbucks", category: foodCategory),
        ExpenseItem(amount: 12.99, date: calendar.date(from: DateComponents(year: 2025, month: 7, day: 7))!, note: "Netflix Subscription", category: subscriptionsCategory),
        ExpenseItem(amount: 58.75, date: calendar.date(from: DateComponents(year: 2025, month: 7, day: 6))!, note: "Weekly Groceries", category: groceriesCategory),
        ExpenseItem(amount: 89.60, date: calendar.date(from: DateComponents(year: 2025, month: 7, day: 3))!, note: "Electric Bill Payment", category: billsCategory),
        ExpenseItem(amount: 22.99, date: calendar.date(from: DateComponents(year: 2025, month: 6, day: 30))!, note: "New Book Purchase", category: booksCategory),
        ExpenseItem(amount: 40.10, date: calendar.date(from: DateComponents(year: 2025, month: 6, day: 29))!, note: "Fuel for Car", category: fuelCategory),
        ExpenseItem(amount: 14.50, date: calendar.date(from: DateComponents(year: 2025, month: 6, day: 27))!, note: "Medicine from Pharmacy", category: medicineCategory),
        ExpenseItem(amount: 9.99, date: calendar.date(from: DateComponents(year: 2025, month: 6, day: 20))!, note: "Spotify Subscription", category: subscriptionsCategory),
        ExpenseItem(amount: 35.00, date: calendar.date(from: DateComponents(year: 2025, month: 6, day: 18))!, note: "Miscellaneous Supplies", category: miscCategory),
        ExpenseItem(amount: 11.00, date: calendar.date(from: DateComponents(year: 2025, month: 6, day: 15))!, note: "Movie Ticket", category: entertainmentCategory),

        // Larger dataset with notes:
        ExpenseItem(amount: 18.25, date: calendar.date(from: DateComponents(year: 2025, month: 7, day: 10))!, note: "Lunch at Cafe", category: foodCategory),
        ExpenseItem(amount: 23.00, date: calendar.date(from: DateComponents(year: 2025, month: 7, day: 11))!, note: "Grocery Store Visit", category: groceriesCategory),
        ExpenseItem(amount: 100.00, date: calendar.date(from: DateComponents(year: 2025, month: 7, day: 12))!, note: "Water Bill", category: billsCategory),
        ExpenseItem(amount: 7.75, date: calendar.date(from: DateComponents(year: 2025, month: 7, day: 13))!, note: "Snack Purchase", category: foodCategory),
        ExpenseItem(amount: 16.50, date: calendar.date(from: DateComponents(year: 2025, month: 7, day: 14))!, note: "Cold Medicine", category: medicineCategory),
        ExpenseItem(amount: 54.99, date: calendar.date(from: DateComponents(year: 2025, month: 7, day: 15))!, note: "Concert Tickets", category: entertainmentCategory),

        // Additional entries:
        ExpenseItem(amount: 45.00, date: calendar.date(from: DateComponents(year: 2025, month: 7, day: 16))!, note: "Dinner at Italian Restaurant", category: foodCategory),
        ExpenseItem(amount: 80.00, date: calendar.date(from: DateComponents(year: 2025, month: 7, day: 17))!, note: "Monthly Gym Membership", category: subscriptionsCategory),
        ExpenseItem(amount: 27.30, date: calendar.date(from: DateComponents(year: 2025, month: 7, day: 18))!, note: "Grocery Essentials", category: groceriesCategory),
        ExpenseItem(amount: 120.00, date: calendar.date(from: DateComponents(year: 2025, month: 7, day: 19))!, note: "Internet Bill", category: billsCategory),
        ExpenseItem(amount: 15.99, date: calendar.date(from: DateComponents(year: 2025, month: 7, day: 20))!, note: "Bookstore Purchase", category: booksCategory),
        ExpenseItem(amount: 50.00, date: calendar.date(from: DateComponents(year: 2025, month: 7, day: 21))!, note: "Gas Station", category: fuelCategory),
        ExpenseItem(amount: 18.20, date: calendar.date(from: DateComponents(year: 2025, month: 7, day: 22))!, note: "Pharmacy Refill", category: medicineCategory),
        ExpenseItem(amount: 12.99, date: calendar.date(from: DateComponents(year: 2025, month: 7, day: 23))!, note: "Streaming Service", category: subscriptionsCategory),
        ExpenseItem(amount: 30.00, date: calendar.date(from: DateComponents(year: 2025, month: 7, day: 24))!, note: "Office Supplies", category: miscCategory),
        ExpenseItem(amount: 20.00, date: calendar.date(from: DateComponents(year: 2025, month: 7, day: 25))!, note: "Movie Night Snacks", category: entertainmentCategory)
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

