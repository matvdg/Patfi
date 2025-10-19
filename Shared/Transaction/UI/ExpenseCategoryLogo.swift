import SwiftUI

struct ExpenseCategoryLogo: View {
    
    let cat: Transaction.ExpenseCategory?
    let isInternalTransfer: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(cat?.color ?? .green)
                .frame(width: 40, height: 40)
            Image(systemName: cat?.iconName ?? (isInternalTransfer ? "arrow.left.arrow.right" : "plus"))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    let columns = Array(repeating: GridItem(.flexible()), count: 4)
    LazyVGrid(columns: columns) {
        ExpenseCategoryLogo(cat: nil, isInternalTransfer: false) // Income
        ExpenseCategoryLogo(cat: nil, isInternalTransfer: true) // Internal transfer income
        ExpenseCategoryLogo(cat: .savingsInvestments, isInternalTransfer: true) // Internal transfer marked as savings
        ExpenseCategoryLogo(cat: .foodGroceries, isInternalTransfer: false)
        ExpenseCategoryLogo(cat: .diningOut, isInternalTransfer: false)
        ExpenseCategoryLogo(cat: .transportation, isInternalTransfer: false)
        ExpenseCategoryLogo(cat: .housing, isInternalTransfer: false)
        ExpenseCategoryLogo(cat: .utilities, isInternalTransfer: false)
        ExpenseCategoryLogo(cat: .insurance, isInternalTransfer: false)
        ExpenseCategoryLogo(cat: .healthcare, isInternalTransfer: false)
        ExpenseCategoryLogo(cat: .pets, isInternalTransfer: false)
        ExpenseCategoryLogo(cat: .entertainment, isInternalTransfer: false)
        ExpenseCategoryLogo(cat: .gaming, isInternalTransfer: false)
        ExpenseCategoryLogo(cat: .sportsFitness, isInternalTransfer: false)
        ExpenseCategoryLogo(cat: .shopping, isInternalTransfer: false)
        ExpenseCategoryLogo(cat: .education, isInternalTransfer: false)
        ExpenseCategoryLogo(cat: .travel, isInternalTransfer: false)
        ExpenseCategoryLogo(cat: .personalCare, isInternalTransfer: false)
        ExpenseCategoryLogo(cat: .subscriptions, isInternalTransfer: false)
        ExpenseCategoryLogo(cat: .taxes, isInternalTransfer: false)
        ExpenseCategoryLogo(cat: .debtPayment, isInternalTransfer: false)
        ExpenseCategoryLogo(cat: .giftsDonations, isInternalTransfer: false)
        ExpenseCategoryLogo(cat: .savingsInvestments, isInternalTransfer: false)
        ExpenseCategoryLogo(cat: .other, isInternalTransfer: false)
    }
    
}
