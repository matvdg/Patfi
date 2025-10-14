import SwiftData
import SwiftUI

struct AccountPicker: View {
    
    @Binding var id: PersistentIdentifier?
    @Query(sort: \Account.name, order: .forward) private var accounts: [Account]
    private var account: Account? {
        accounts.first(where: { $0.persistentModelID == id })
    }
    
    var title: String
    
    var body: some View {
        
        Picker(title, selection: $id) {
            ForEach(accounts) { acc in
                AccountRow(account: acc, displayBalance: false)
                    .tag(acc.persistentModelID)
            }
        }
        .pickerStyle(.navigationLink)
    }
}

#Preview {
    NavigationStack {
        Form {
            AccountPicker(id: .constant(nil), title: "Account")
        }
    }
    .modelContainer(ModelContainer.shared)
}
