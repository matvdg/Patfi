import SwiftUI

struct ExpenseCategoryPicker: View {
    
    @Binding var expenseCategory: Transaction.ExpenseCategory?
    
    var body: some View {
        
        Picker("ExpenseCategory", selection: $expenseCategory) {
            ForEach(Transaction.ExpenseCategory.allCases) { cat in
                Label(cat.localized, systemImage: cat.iconName)
                    .foregroundStyle(.primary)
                    .tag(cat)
            }
        }
#if !os(macOS)
        .pickerStyle(.navigationLink)
#endif
        .foregroundStyle(.primary)
    }
}

#Preview {
    @Previewable @State var expenseCategory: Transaction.ExpenseCategory? = .education
    NavigationStack { Form { ExpenseCategoryPicker(expenseCategory: $expenseCategory) } }
}
