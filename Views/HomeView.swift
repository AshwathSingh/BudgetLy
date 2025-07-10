//
//  HomeView.swift
//  BudgetLy
//
//  Created by Ashwath Singh on 07/07/25.
//

import SwiftUI
import SwiftData


struct HomeView: View {
    @Query var expenses: [ExpenseItem]
    @Query var categories: [ExpenseCategory]
    @State var selectedTab = 0
    @State var showExpenses = false
    @State private var showWeeklyExpenses = false
    @State private var showMonthlyExpenses = false


    var thisMonthTotal: Double {
        let calendar = Calendar.current
        let now = Date()
        return expenses
            .filter {
                calendar.isDate($0.date, equalTo: now, toGranularity: .month) &&
                calendar.isDate($0.date, equalTo: now, toGranularity: .year)
            }
            .reduce(0) { $0 + $1.amount }
    }

    var thisWeekTotal: Double {
        let calendar = Calendar.current
        let now = Date()

        // Get the start of the current week
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start else {
            return 0
        }

        // Get the end of the week (7 days from start)
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!

        return expenses
            .filter { $0.date >= weekStart && $0.date < weekEnd }
            .reduce(0) { $0 + $1.amount }
    }


    var topCategoriesWithTotals: [(category: ExpenseCategory, total: Double)] {
        let grouped = Dictionary(grouping: expenses) { $0.category }
        return grouped
            .map { (category, expenses) in
                (category: category, total: expenses.reduce(0) { $0 + $1.amount })
            }
            .sorted { $0.total > $1.total }
            .prefix(3)
            .map { $0 }
    }

    var body: some View {
        NavigationStack {
            HeaderView(textField: "Home")
            VStack(alignment: .leading, spacing: 24) {
                TabView(selection: $selectedTab) {
                    ExpenseWeeklyCardView(amount: thisWeekTotal)
                        .tag(0)
                        .frame(maxWidth: .infinity)
                        .padding(4)
                        .onTapGesture {
                            showWeeklyExpenses = true
                        }

                    ExpenseMonthCardView(amount: thisMonthTotal)
                        .tag(1)
                        .frame(maxWidth: .infinity)
                        .padding(4)
                        .onTapGesture {
                            showMonthlyExpenses = true
                        }
                }
                .padding(.top, 0)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .frame(height: 250)

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your spending per category")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("Top 3 categories this month")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    NavigationLink {
                        ExpensesPerCategoryView()
                    } label: {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color.primary.opacity(0.6))
                            .font(.title3)
                    }
                }

                VStack(spacing: 12) {
                    ForEach(topCategoriesWithTotals, id: \.category.id) { item in
                        CategoryCard(
                            systemImage: item.category.symbol,
                            categoryName: item.category.name,
                            categoryExpense: item.total,
                            accentColourName: colorFromName(item.category.systemColorName)
                        )
                    }
                }
                Spacer()
            }
            .sheet(isPresented: $showWeeklyExpenses) {
                WeeklyExpensesSheetView(expenses: expenses)
            }
            .sheet(isPresented: $showMonthlyExpenses) {
                MonthlyExpensesSheetView(expenses: expenses)
            }

            .padding(.top)
        }
    }
}


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

    var lastMonthTotal: Double {
        let calendar = Calendar.current
        let now = Date()

        guard
            let thisMonthStart = calendar.dateInterval(of: .month, for: now)?.start,
            let lastMonthStart = calendar.date(byAdding: .month, value: -1, to: thisMonthStart)
        else {
            return 0
        }
        let lastMonthEnd = calendar.date(byAdding: .month, value: 1, to: lastMonthStart)!

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

    var body: some View {
        VStack(spacing: 20) {
            Text("Monthly Spending Trends")
                .font(.title2)
                .padding(.top)

            Text("This Month: $\(String(format: "%.2f", currentMonthTotal))")
            Text("Last Month: $\(String(format: "%.2f", lastMonthTotal))")

            Text(difference >= 0
                 ? "↑ Increased by $\(String(format: "%.2f", difference)) (\(String(format: "%.1f", percentageChange))%)"
                 : "↓ Decreased by $\(String(format: "%.2f", abs(difference))) (\(String(format: "%.1f", abs(percentageChange)))%)"
            )
            .foregroundColor(difference >= 0 ? .red : .green)
            .font(.headline)

            Spacer()
        }
        .padding()
    }
}


struct WeeklyTrendsView: View {
    let currentWeekExpenses: [ExpenseItem]
    let allExpenses: [ExpenseItem]

    // Calculate last week's total
    var lastWeekTotal: Double {
        let calendar = Calendar.current
        let now = Date()

        guard
            let thisWeekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start,
            let lastWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: thisWeekStart)
        else {
            return 0
        }
        let lastWeekEnd = calendar.date(byAdding: .day, value: 7, to: lastWeekStart)!

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

    var body: some View {
        VStack(spacing: 20) {
            Text("Weekly Spending Trends")
                .font(.title2)
                .padding(.top)

            Text("This Week: $\(String(format: "%.2f", currentWeekTotal))")
            Text("Last Week: $\(String(format: "%.2f", lastWeekTotal))")

            Text(difference >= 0
                 ? "↑ Increased by $\(String(format: "%.2f", difference)) (\(String(format: "%.1f", percentageChange))%)"
                 : "↓ Decreased by $\(String(format: "%.2f", abs(difference))) (\(String(format: "%.1f", abs(percentageChange)))%)"
            )
            .foregroundColor(difference >= 0 ? .red : .green)
            .font(.headline)

            Spacer()
            // You could add charts here later
        }
        .padding()
    }
}


struct HeaderView: View {
    var textField: String
    var body: some View {
        // Custom header
        HStack {
            Text("\(textField)")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Spacer()
            
            Button {
                print("Profile Clicked")
            } label: {
                Image("charlesprofilepicture")
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            }
        }
        .padding(.horizontal, 0)
        .padding(.top)
    }
}


#Preview {
    HomeView()
}
