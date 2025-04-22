//
//  ContentView.swift
//  WishSave
//
//  Created by Sai Col on 4/20/25.
//
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeTab()
                .tabItem { Label("Home", systemImage: "house.fill") }

            ExpensesTab()
                .tabItem { Label("Expenses", systemImage: "creditcard") }

            GoalTab()
                .tabItem { Label("Goal", systemImage: "target") }

            SavingsCoachTab()
                .tabItem { Label("Coach", systemImage: "person.crop.circle.fill.badge.questionmark") }
        }
    }
}

// Home Tab

struct HomeTab: View {
    @EnvironmentObject var model: BudgetModel

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Job Title")
                TextField("Enter Job Title", text: $model.jobTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Text("Annual Income")
                TextField("Enter $", value: $model.annualIncome, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Divider()

                Text("Monthly Income (Before Tax): $\(model.monthlyIncomeBeforeTax, specifier: "%.2f")")
                Text("Tax Deducted (\(Int(model.taxRate * 100))%): -$\(model.taxAmountMonthly, specifier: "%.2f")")
                Text("Monthly Income (After Tax): $\(model.monthlyIncomeAfterTax, specifier: "%.2f")")
                Text("Adjusted Monthly Income: $\(model.adjustedMonthlyIncome, specifier: "%.2f")")
                    .fontWeight(.semibold)

                Divider()

                if model.weeksToGoal != Int.max {
                    ProgressView(value: model.goalProgress)
                    Text("Estimated Time to Reach Goal: \(model.weeksToGoal) weeks")
                } else {
                    Text("Goal not reachable with current spending.")
                        .foregroundColor(.red)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}

// MARK: - Expenses Tab

struct ExpensesTab: View {
    @EnvironmentObject var model: BudgetModel
    @State private var currentWeek = 0
    @State private var newExpenseTitle = ""
    @State private var newExpenseAmount: String = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    Text("Select Week")
                    Picker("Week", selection: $currentWeek) {
                        ForEach(0..<4) { index in
                            Text("Week \(index + 1)").tag(index)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    Text("Add Expense for Week \(currentWeek + 1)")
                        .font(.headline)

                    TextField("Expense Title", text: $newExpenseTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    TextField("Amount ($)", text: $newExpenseAmount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button("Add Expense") {
                        if let amount = Double(newExpenseAmount), !newExpenseTitle.isEmpty {
                            let expense = LabeledExpense(title: newExpenseTitle, amount: amount)
                            model.weeklyExpenses[currentWeek].append(expense)
                            newExpenseTitle = ""
                            newExpenseAmount = ""
                        }
                    }
                    .buttonStyle(.borderedProminent)

                    Divider()

                    ForEach(0..<4, id: \.self) { weekIndex in
                        let expenses = model.weeklyExpenses[weekIndex]
                        if !expenses.isEmpty {
                            Text("Week \(weekIndex + 1)").font(.headline)
                            ForEach(expenses) { expense in
                                HStack {
                                    Text(expense.title)
                                    Spacer()
                                    Text("$\(expense.amount, specifier: "%.2f")")
                                }
                            }
                        }
                    }

                    Divider()

                    Text("Monthly Income After Tax: $\(model.monthlyIncomeAfterTax, specifier: "%.2f")")
                    Text("Total Expenses: -$\(model.totalMonthlyExpenses, specifier: "%.2f")")
                    Text("Adjusted Income: $\(model.adjustedMonthlyIncome, specifier: "%.2f")")
                        .fontWeight(.bold)

                    Divider()

                    Text("Suggested Weekly Spending Limit: $\(model.recommendedWeeklyBudget, specifier: "%.2f")")
                        .foregroundColor(.blue)

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Expenses")
        }
    }
}

// MARK: - Goal Tab

struct GoalTab: View {
    @EnvironmentObject var model: BudgetModel

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Set Your Goal")
                    .font(.headline)

                TextField("Goal Name", text: $model.goalName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Goal Amount", value: $model.goalAmount, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Divider()

                if model.goalAmount > 0 && model.weeksToGoal != Int.max {
                    ProgressView(value: model.goalProgress)
                    Text("Progress: \(Int(model.goalProgress * 100))%")
                    Text("Amount Remaining: $\(model.amountRemaining, specifier: "%.2f")")
                    Text("Estimated Time Remaining: \(model.monthsToGoal) month(s)")
                    Text("Weekly Savings Rate: $\(model.weeklySavings, specifier: "%.2f")")
                    Text("Total Logged Expenses: \(model.totalExpenseCount)")
                } else {
                    Text("Set a goal and start saving!")
                        .foregroundColor(.gray)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Goal")
        }
    }
}

// MARK: - Savings Coach Tab

struct SavingsCoachTab: View {
    @EnvironmentObject var model: BudgetModel
    @State private var userQuestion: String = ""
    @State private var response: String = "Ask your savings coach anything!"
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    
    private let ollamaService = OllamaService()
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Ask the AI Coach:")
                    .font(.headline)
                
                TextEditor(text: $userQuestion)
                    .frame(height: 100)
                    .border(Color.gray)
                    .cornerRadius(8)
                
                Button(action: {
                    Task {
                        await sendQuestionToOllama()
                    }
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("Ask")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading || userQuestion.isEmpty)
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding(.top, 8)
                        .multilineTextAlignment(.leading)
                }
                
                Divider()
                
                ScrollView {
                    Text(response)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Savings Coach")
        }
    }
    
    private func sendQuestionToOllama() async {
        guard !userQuestion.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        let prompt = """
        You are a helpful savings coach for teens. Give practical budgeting advice in a friendly and encouraging tone. 
        Keep responses concise and actionable.
        
        User's financial situation:
        - Annual Income: $\(model.annualIncome)
        - Goal: Save for "\(model.goalName)" which costs $\(model.goalAmount)
        - Monthly Income After Tax: $\(model.monthlyIncomeAfterTax)
        - Current Monthly Spending: $\(model.totalMonthlyExpenses)
        
        User's question: \(userQuestion)
        """
        
        do {
            let result = try await ollamaService.sendMessage(prompt: prompt)
            response = result
        } catch let error as OllamaError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Network error: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
