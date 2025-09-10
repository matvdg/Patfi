import SwiftUI
import SwiftData

struct BanksView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\Bank.name, order: .forward)]) private var banks: [Bank]

    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Banks")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Create") { showingAdd = true }
                    }
                }
                .sheet(isPresented: $showingAdd) {
                    AddBankView()
                }
        }
    }

    @ViewBuilder
    private var content: some View {
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
        }
    }

}

#Preview {
    BanksView()
}
