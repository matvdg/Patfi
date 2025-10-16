import SwiftUI

struct ExpenseCategoryLogo: View {
    
    let cat: Transaction.ExpenseCategory?

    var body: some View {
        ZStack {
            Circle()
                .fill(cat?.color ?? .green)
                .frame(width: 40, height: 40)
            Image(systemName: cat?.iconName ?? "plus")
                .foregroundColor(.white)
        }
    }
}

#Preview {
    let columns = Array(repeating: GridItem(.flexible()), count: 4)
    LazyVGrid(columns: columns) {
        ExpenseCategoryLogo(cat: nil)
        ExpenseCategoryLogo(cat: .foodGroceries)
        ExpenseCategoryLogo(cat: .diningOut)
        ExpenseCategoryLogo(cat: .transportation)
        ExpenseCategoryLogo(cat: .housing)
        ExpenseCategoryLogo(cat: .utilities)
        ExpenseCategoryLogo(cat: .insurance)
        ExpenseCategoryLogo(cat: .healthcare)
        ExpenseCategoryLogo(cat: .pets)
        ExpenseCategoryLogo(cat: .entertainment)
        ExpenseCategoryLogo(cat: .gaming)
        ExpenseCategoryLogo(cat: .sportsFitness)
        ExpenseCategoryLogo(cat: .shopping)
        ExpenseCategoryLogo(cat: .education)
        ExpenseCategoryLogo(cat: .travel)
        ExpenseCategoryLogo(cat: .personalCare)
        ExpenseCategoryLogo(cat: .subscriptions)
        ExpenseCategoryLogo(cat: .taxes)
        ExpenseCategoryLogo(cat: .debtPayment)
        ExpenseCategoryLogo(cat: .giftsDonations)
        ExpenseCategoryLogo(cat: .savingsInvestments)
        ExpenseCategoryLogo(cat: .other)
    }
    
}
