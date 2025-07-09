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
            .sorted(by: { $0.date > $1.date }) // ✅ Newest to oldest
    }

    var totalAmount: Double {
        filteredExpenses.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        ExpensesSheetViewContent(
            title: "This Week",
            totalAmount: totalAmount,
            expenses: filteredExpenses
        )
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
            .sorted(by: { $0.date > $1.date }) // ✅ Newest to oldest
    }

    var totalAmount: Double {
        filteredExpenses.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        ExpensesSheetViewContent(
            title: "This Month",
            totalAmount: totalAmount,
            expenses: filteredExpenses
        )
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

            VStack(spacing: 0) {
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

                    Text(title)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
                .padding(.bottom, 32)

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
