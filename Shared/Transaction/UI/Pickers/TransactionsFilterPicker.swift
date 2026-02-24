import SwiftUI

struct TransactionsFilterPicker: View {
    
    @Binding var activeFilter: TransactionsFilter
    
    var body: some View {
        
        Picker("FilterTransactions", selection: $activeFilter) {
            ForEach(TransactionsFilter.allCases) { filter in
                Label(filter.localized, systemImage: filter.iconName)
                    .tag(filter)
            }
        }
#if !os(macOS)
        .pickerStyle(.navigationLink)
#endif
        .foregroundStyle(.primary)
    }
}

#Preview {
    @Previewable @State var activeFilter: TransactionsFilter = .all
    NavigationStack { Form { TransactionsFilterPicker(activeFilter: $activeFilter) } }
}

enum TransactionsFilter: String, Codable, CaseIterable, Identifiable {
    case all
    case hideIncomes
    case hideExpenses
    case hideInternalTransfers
    
    var id: String { rawValue }
    
    var localized: String {
        switch self {
        case .all: String(localized: "All")
        case .hideIncomes: String(localized: "HideIncomes")
        case .hideExpenses: String(localized: "HideExpenses")
        case .hideInternalTransfers: String(localized: "HideInternalTransfers")
        }
    }
    
    var iconName: String {
        switch self {
        case .all: "infinity.circle"
        case .hideIncomes: "plus.circle"
        case .hideExpenses: "minus.circle"
        case .hideInternalTransfers: "arrow.left.arrow.right.circle"
        }
    }
    
   
}
