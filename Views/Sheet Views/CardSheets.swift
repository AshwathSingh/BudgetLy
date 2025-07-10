//
//  CardSheets.swift
//  BudgetLy
//
//  Created by Ashwath Singh on 10/07/25.
//

import SwiftUI
import SwiftData

struct ExpenseWeeklyCardView: View {
    let amount: Double
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("You Spent")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
            }
            
            HStack {
                Spacer()
                let dollars = Int(amount)
                let cents = Int(round((amount - Double(dollars)) * 100))

                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("$\(dollars)")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(.white)

                    Text(".\(String(format: "%02d", cents))")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(.white.opacity(0.7))
                }
                Spacer()
            }
            HStack {
                Spacer()
                Text("this week")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.green.opacity(0.8), Color.teal.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

struct ExpenseMonthCardView: View {
    let amount: Double
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("You Spent")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
            }
            
            HStack {
                Spacer()
                
                let dollars = Int(amount)
                let cents = Int(round((amount - Double(dollars)) * 100))

                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("$\(dollars)")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(.white)

                    Text(".\(String(format: "%02d", cents))")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(.white.opacity(0.7))
                }
                
                Spacer()
            }
            HStack {
                Spacer()
                Text("this month")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.indigo.opacity(0.8), Color.purple.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

    }
}
struct WeeklyExpensesSheetView: View {
    let expenses: [ExpenseItem]

    var filteredExpenses: [ExpenseItem] {
        let calendar = Calendar.current
        let now = Date()
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start else {
            return []
        }
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!

        return expenses
            .filter { $0.date >= weekStart && $0.date < weekEnd }
            .sorted(by: { $0.date > $1.date })
    }

    var totalAmount: Double {
        filteredExpenses.reduce(0) { $0 + $1.amount }
    }

    enum Tab {
        case expenses
        case trends
    }

    @State private var selectedTab: Tab = .expenses

    var body: some View {
        VStack(spacing: 16) {
            // Total spent header
            VStack(spacing: 8) {
                Text("Total Spent")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                let dollars = Int(totalAmount)
                let cents = Int(round((totalAmount - Double(dollars)) * 100))

                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("$\(dollars)")
                        .font(.system(size: 56, weight: .bold))
                        .foregroundStyle(.primary)
                    Text(".\(String(format: "%02d", cents))")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(.primary.opacity(0.7))
                }

                Text("This Week")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 40)

            Picker("View", selection: $selectedTab) {
                Text("Expenses").tag(Tab.expenses)
                Text("Trends").tag(Tab.trends)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .frame(maxWidth: 300)

            Divider()

            switch selectedTab {
            case .expenses:
                ExpensesSheetViewContent(
                    title: "",
                    totalAmount: 0,
                    expenses: filteredExpenses
                )
            case .trends:
                WeeklyTrendsView(currentWeekExpenses: filteredExpenses, allExpenses: expenses)
            }

            Spacer()
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}

struct MonthlyExpensesSheetView: View {
    let expenses: [ExpenseItem]

    var filteredExpenses: [ExpenseItem] {
        let calendar = Calendar.current
        let now = Date()

        return expenses
            .filter {
                calendar.isDate($0.date, equalTo: now, toGranularity: .month) &&
                calendar.isDate($0.date, equalTo: now, toGranularity: .year)
            }
            .sorted(by: { $0.date > $1.date })
    }

    var totalAmount: Double {
        filteredExpenses.reduce(0) { $0 + $1.amount }
    }

    enum Tab {
        case expenses
        case trends
    }

    @State private var selectedTab: Tab = .expenses

    var body: some View {
        VStack(spacing: 16) {
            // Total spent header
            VStack(spacing: 8) {
                Text("Total Spent")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                let dollars = Int(totalAmount)
                let cents = Int(round((totalAmount - Double(dollars)) * 100))

                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("$\(dollars)")
                        .font(.system(size: 56, weight: .bold))
                        .foregroundStyle(.primary)
                    Text(".\(String(format: "%02d", cents))")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(.primary.opacity(0.7))
                }

                Text("This Month")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 40)

            Picker("View", selection: $selectedTab) {
                Text("Expenses").tag(Tab.expenses)
                Text("Trends").tag(Tab.trends)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .frame(maxWidth: 300)

            Divider()

            switch selectedTab {
            case .expenses:
                ExpensesSheetViewContent(
                    title: "",
                    totalAmount: 0,
                    expenses: filteredExpenses
                )
            case .trends:
                MonthlyTrendsView(currentMonthExpenses: filteredExpenses, allExpenses: expenses)
            }

            Spacer()
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}

struct ExpenseCardView: View {
    let amount: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("You spent")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
            }

            HStack {
                Spacer()
                let dollars = Int(amount)
                let cents = Int(round((amount - Double(dollars)) * 100))

                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("$\(dollars)")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(.white)

                    Text(".\(String(format: "%02d", cents))")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(.white.opacity(0.7))
                }

                Spacer()
            }

            HStack {
                Spacer()
                Text("this month")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.indigo.opacity(0.8), Color.purple.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

struct ExpensesSheetViewContent: View {
    let title: String
    let totalAmount: Double
    let expenses: [ExpenseItem]

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        ForEach(expenses, id: \.id) { expense in  // Use id instead of self for Identifiable
                            ExpensesCard(
                                title: expense.note ?? expense.category.name,
                                subtitle: "\(expense.category.name) • \(expense.date.formatted(date: .abbreviated, time: .omitted))",
                                amount: expense.amount,
                                icon: expense.category.symbol,
                                color: colorFromName(expense.category.systemColorName)
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }

                Spacer()
            }
        }
}

struct MonthlyTrendsView: View {
    let currentMonthExpenses: [ExpenseItem]
    let allExpenses: [ExpenseItem]

    var calendar: Calendar { Calendar.current }
    var now: Date { Date() }

    var thisMonthStart: Date? {
        calendar.dateInterval(of: .month, for: now)?.start
    }

    var lastMonthStart: Date? {
        guard let thisMonthStart = thisMonthStart else { return nil }
        return calendar.date(byAdding: .month, value: -1, to: thisMonthStart)
    }

    var lastMonthTotal: Double {
        guard
            let lastMonthStart = lastMonthStart,
            let lastMonthEnd = calendar.date(byAdding: .month, value: 1, to: lastMonthStart)
        else { return 0 }

        let lastMonthExpenses = allExpenses.filter { $0.date >= lastMonthStart && $0.date < lastMonthEnd }
        return lastMonthExpenses.reduce(0) { $0 + $1.amount }
    }

    var currentMonthTotal: Double {
        currentMonthExpenses.reduce(0) { $0 + $1.amount }
    }

    var difference: Double {
        currentMonthTotal - lastMonthTotal
    }

    var percentageChange: Double {
        guard lastMonthTotal != 0 else { return 0 }
        return (difference / lastMonthTotal) * 100
    }

    // Helper: Calculate total per category for a given month
    func totalsPerCategory(for expenses: [ExpenseItem]) -> [ExpenseCategory: Double] {
        Dictionary(grouping: expenses, by: { $0.category })
            .mapValues { items in items.reduce(0) { $0 + $1.amount } }
    }

    var top3IncreasedCategories: [(category: ExpenseCategory, increase: Double)] {
        guard
            let lastMonthStart = lastMonthStart,
            let lastMonthEnd = calendar.date(byAdding: .month, value: 1, to: lastMonthStart)
        else { return [] }

        let lastMonthExpenses = allExpenses.filter { $0.date >= lastMonthStart && $0.date < lastMonthEnd }
        let lastMonthTotals = totalsPerCategory(for: lastMonthExpenses)
        let currentMonthTotals = totalsPerCategory(for: currentMonthExpenses)

        // Calculate difference per category
        var increases: [(ExpenseCategory, Double)] = []

        for (category, currentTotal) in currentMonthTotals {
            let lastTotal = lastMonthTotals[category] ?? 0
            let diff = currentTotal - lastTotal
            if diff > 0 {
                increases.append((category, diff))
            }
        }

        // Sort by biggest increase and take top 3
        return increases.sorted { $0.1 > $1.1 }.prefix(3).map { $0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Summary text with icon
            HStack(spacing: 16) {
                Image(systemName: difference >= 0 ? "arrow.up.right" : "arrow.down.right")
                    .font(.title3)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(difference >= 0 ? Color.red : Color.green)
                    )
                    .scaleEffect(1)

                Text(difference >= 0
                     ? "You spent $\(String(format: "%.2f", difference)) more than last month"
                     : "You spent $\(String(format: "%.2f", abs(difference))) less than last month"
                )
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(difference >= 0 ? Color.red : Color.green)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill((difference >= 0 ? Color.red : Color.green).opacity(0.15))
            )
            .frame(maxWidth: .infinity)

            // Top 3 categories with increases
            if top3IncreasedCategories.isEmpty {
                Text("No categories increased in spending compared to last month.")
                    .foregroundColor(.secondary)
                    .italic()
                    .padding(.horizontal)
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Top 3 categories with increased spending")
                        .font(.headline)
                        .padding(.horizontal)

                    ForEach(top3IncreasedCategories, id: \.category.id) { item in
                        HStack {
                            Image(systemName: item.category.symbol)
                                .font(.title2)
                                .foregroundColor(colorFromName(item.category.systemColorName))
                                .frame(width: 30)

                            VStack(alignment: .leading) {
                                Text(item.category.name)
                                    .fontWeight(.bold)
                                Text("+$\(String(format: "%.2f", item.increase)) vs last month")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(colorFromName(item.category.systemColorName).opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .circular))
                        .padding(.horizontal)
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 20)
        .padding()
    }
}

struct WeeklyTrendsView: View {
    let currentWeekExpenses: [ExpenseItem]
    let allExpenses: [ExpenseItem]

    var calendar: Calendar { Calendar.current }
    var now: Date { Date() }


    var thisWeekStart: Date? {
        calendar.dateInterval(of: .weekOfYear, for: now)?.start
    }

    var lastWeekStart: Date? {
        guard let thisWeekStart = thisWeekStart else { return nil }
        return calendar.date(byAdding: .weekOfYear, value: -1, to: thisWeekStart)
    }


    var lastWeekTotal: Double {
        guard
            let lastWeekStart = lastWeekStart,
            let lastWeekEnd = calendar.date(byAdding: .day, value: 7, to: lastWeekStart)
        else { return 0 }

        let lastWeekExpenses = allExpenses.filter { $0.date >= lastWeekStart && $0.date < lastWeekEnd }
        return lastWeekExpenses.reduce(0) { $0 + $1.amount }
    }

    var currentWeekTotal: Double {
        currentWeekExpenses.reduce(0) { $0 + $1.amount }
    }

    var difference: Double {
        currentWeekTotal - lastWeekTotal
    }

    var percentageChange: Double {
        guard lastWeekTotal != 0 else { return 0 }
        return (difference / lastWeekTotal) * 100
    }



    // Helper: Calculate total per category for a given week
    func totalsPerCategory(for expenses: [ExpenseItem]) -> [ExpenseCategory: Double] {
        Dictionary(grouping: expenses, by: { $0.category })
            .mapValues { items in items.reduce(0) { $0 + $1.amount } }
    }

    var top3IncreasedCategories: [(category: ExpenseCategory, increase: Double)] {
        guard
            let lastWeekStart = lastWeekStart,
            let lastWeekEnd = calendar.date(byAdding: .day, value: 7, to: lastWeekStart)
        else { return [] }

        let lastWeekExpenses = allExpenses.filter { $0.date >= lastWeekStart && $0.date < lastWeekEnd }
        let lastWeekTotals = totalsPerCategory(for: lastWeekExpenses)
        let currentWeekTotals = totalsPerCategory(for: currentWeekExpenses)

        // Calculate difference per category
        var increases: [(ExpenseCategory, Double)] = []

        for (category, currentTotal) in currentWeekTotals {
            let lastTotal = lastWeekTotals[category] ?? 0
            let diff = currentTotal - lastTotal
            if diff > 0 {
                increases.append((category, diff))
            }
        }

        // Sort by biggest increase and take top 3
        return increases.sorted { $0.1 > $1.1 }.prefix(3).map { $0 }
    }


    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Summary text with icon
            HStack(spacing: 16) {
               Image(systemName: difference >= 0 ? "arrow.up.right" : "arrow.down.right")
                   .font(.title3)
                   .fontWeight(.heavy)
                   .foregroundColor(.white)
                   .padding()
                   .background(
                       RoundedRectangle(cornerRadius: 16)
                           .fill(difference >= 0 ? Color.red : Color.green)
                   )
                   .scaleEffect(1)

               Text(difference >= 0
                    ? "You spent $\(String(format: "%.2f", difference)) more than last week"
                    : "You spent $\(String(format: "%.2f", abs(difference))) less than last week"
               )
               .font(.headline)
               .fontWeight(.bold)
               .foregroundColor(difference >= 0 ? Color.red : Color.green)
               .lineLimit(2)
               .multilineTextAlignment(.leading)
           }
           .padding()
           .background(
               RoundedRectangle(cornerRadius: 20)
                   .fill((difference >= 0 ? Color.red : Color.green).opacity(0.15))
           )
           .frame(maxWidth: .infinity)
            // Top 3 categories with increases
            if top3IncreasedCategories.isEmpty {
                Text("No categories increased in spending compared to last week.")
                    .foregroundColor(.secondary)
                    .italic()
                    .padding(.horizontal)
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Top 3 categories with increased spending")
                        .font(.headline)
                        .padding(.horizontal)

                    ForEach(top3IncreasedCategories, id: \.category.id) { item in
                        HStack {
                            Image(systemName: item.category.symbol)
                                .font(.title2)
                                .foregroundColor(colorFromName(item.category.systemColorName))
                                .frame(width: 30)

                            VStack(alignment: .leading) {
                                Text(item.category.name)
                                    .fontWeight(.bold)
                                Text("+$\(String(format: "%.2f", item.increase)) vs last week")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(colorFromName(item.category.systemColorName).opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .circular))
                        .padding(.horizontal)
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 20)
        .padding()
    }
}
