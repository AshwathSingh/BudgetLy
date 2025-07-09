//
//  showExpenses.swift
//  BudgetLy
//
//  Created by Ashwath Singh on 08/07/25.
//


struct showExpenses: View {
    var body: some View {
        VStack {
            Text("You Spent")
                .font(.largeTitle)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.indigo.opacity(0.8), Color.purple.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}