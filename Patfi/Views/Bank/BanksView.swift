import SwiftUI
import SwiftData

struct BanksView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\Bank.name, order: .forward)]) private var banks: [Bank]
        
    var body: some View {
        NavigationStack {
            if banks.isEmpty {
                ContentUnavailableView(
                    "No banks",
                    systemImage: "building.columns",
                    description: Text("Create your first bank")
                )
                .padding()
            } else {
                List {
                    ForEach(banks) { bank in
                        NavigationLink {
                            AddBankView(bank: bank)
                        } label: {
                            BankRow(bank: bank)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 0)
                }
            }
        }
        .navigationTitle("Banks")
    }
}

#Preview {
    BanksView()
}
