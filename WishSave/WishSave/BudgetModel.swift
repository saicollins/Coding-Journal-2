//
//  BudgetModel.swift
//  WishSave
//
//  Created by Sai Col on 4/20/25.
//
import Foundation

struct LabeledExpense: Identifiable, Codable {
    let id = UUID()
    var title: String
    var amount: Double
}

class BudgetModel: ObservableObject {
    @Published var jobTitle: String = ""
    @Published var annualIncome: Double = 50000
    @Published var goalName: String = ""
    @Published var goalAmount: Double = 1000

    @Published var weeklyExpenses: [[LabeledExpense]] = [[], [], [], []] // Weeks 1–4

    var taxRate: Double { 0.15 }

    var monthlyIncomeBeforeTax: Double {
        annualIncome / 12
    }

    var taxAmountMonthly: Double {
        monthlyIncomeBeforeTax * taxRate
    }

    var monthlyIncomeAfterTax: Double {
        monthlyIncomeBeforeTax - taxAmountMonthly
    }

    var totalMonthlyExpenses: Double {
        weeklyExpenses.flatMap { $0 }.reduce(0) { $0 + $1.amount }
    }

    var adjustedMonthlyIncome: Double {
        monthlyIncomeAfterTax - totalMonthlyExpenses
    }

    var averageWeeklySpending: Double {
        let allExpenses = weeklyExpenses.flatMap { $0 }
        return allExpenses.isEmpty ? 0 : totalMonthlyExpenses / 4.0
    }

    var weeklySavings: Double {
        (monthlyIncomeAfterTax / 4) - averageWeeklySpending
    }

    var weeksToGoal: Int {
        guard weeklySavings > 0 else { return Int.max }
        return Int(ceil(goalAmount / weeklySavings))
    }

    var recommendedWeeklyBudget: Double {
        (monthlyIncomeAfterTax / 4) * 0.7
    }

    var totalExpenseCount: Int {
        weeklyExpenses.flatMap { $0 }.count
    }

    var goalProgress: Double {
        let saved = Double(totalExpenseCount) * weeklySavings
        return min(saved / goalAmount, 1.0)
    }

    var amountRemaining: Double {
        max(goalAmount - (Double(totalExpenseCount) * weeklySavings), 0)
    }

    var monthsToGoal: Int {
        Int(ceil(Double(weeksToGoal) / 4.0))
    }
}
