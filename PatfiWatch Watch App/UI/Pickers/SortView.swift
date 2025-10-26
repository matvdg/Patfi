import SwiftUI

enum Sorting: String, CaseIterable, Identifiable {
    case bank, category, amount, name
    var id: String { rawValue }
    var localized: LocalizedStringResource {
            switch self {
            case .name:      "Name"
            case .bank:      "Bank"
            case .category:  "Category"
            case .amount:    "Balance"
            }
        }
}

struct SortView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var sorting: Sorting

    var body: some View {
        NavigationView {
            List {
                ForEach(Sorting.allCases) { sort in
                    Button {
                        sorting = sort
                        dismiss()
                    } label: {
                        HStack {
                            Text(sort.localized)
                            Spacer()
                            if sorting == sort {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.primary)
                                    .bold()
                            }
                        }
                    }
                }
            }
            .navigationTitle("SortBy")
        }
    }
}

#Preview {
    @Previewable @State var mode: Sorting = .amount
    SortView(sorting: $mode)
}
