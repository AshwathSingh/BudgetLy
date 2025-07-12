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

        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start else {
            return 0
        }
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!

        let weekExpenses = expenses.filter { $0.date >= weekStart && $0.date < weekEnd }
        print("Expenses this week: \(weekExpenses.count)")

        return weekExpenses.reduce(0) { $0 + $1.amount }
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
