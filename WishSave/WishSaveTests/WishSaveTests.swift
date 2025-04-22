//
//  WishSaveTests.swift
//  WishSaveTests
//
//  Created by Sai Col on 4/20/25.
//
import XCTest
@testable import WishSave

final class WishSaveTests: XCTestCase {

    func testIncomeCalculations() {
        let model = BudgetModel()
        model.annualIncome = 60000

        XCTAssertEqual(model.monthlyIncomeBeforeTax, 5000, accuracy: 0.01)
        XCTAssertEqual(model.taxAmountMonthly, 750, accuracy: 0.01)
        XCTAssertEqual(model.monthlyIncomeAfterTax, 4250, accuracy: 0.01)
    }

    func testWeeksToGoalForecast() {
        let model = BudgetModel()
        model.annualIncome = 60000
        model.goalAmount = 500

        // Simulate 4 weeks of expenses
        model.expenses = [100, 100, 100, 100]  // average = 100
        // monthly income after tax = 4250 → weekly income = ~1062.50 → savings = ~962.50

        let expectedWeeks = Int(ceil(500 / 962.50))
        XCTAssertEqual(model.weeksToGoal, expectedWeeks)
    }

    func testNoSavingsReturnsMaxWeeks() {
        let model = BudgetModel()
        model.annualIncome = 60000
        model.goalAmount = 500
        model.expenses = [1200, 1200, 1200, 1200] // more than weekly income

        XCTAssertEqual(model.weeksToGoal, Int.max)
    }
}
