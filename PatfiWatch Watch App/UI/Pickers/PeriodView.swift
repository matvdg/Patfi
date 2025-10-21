import SwiftUI

struct PeriodView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Binding var period: Period

    var body: some View {
        NavigationView {
            List {
                ForEach(Period.allCases) { p in
                    Button {
                        period = p
                        dismiss()
                    } label: {
                        HStack {
                            Text(p.localized)
                            Spacer()
                            if period == p {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.primary)
                                    .bold()
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var period: Period = .months
    PeriodView(period: $period)
}
