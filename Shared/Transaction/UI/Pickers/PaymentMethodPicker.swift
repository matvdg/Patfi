import SwiftUI

struct PaymentMethodPicker: View {
    
    @Binding var paymentMethod: Transaction.PaymentMethod
    
    var body: some View {
        
        Picker("PaymentMethod", selection: $paymentMethod) {
            ForEach(Transaction.PaymentMethod.allCases) { p in
                Label(p.localized, systemImage: p.iconName)
                    .foregroundStyle(.primary)
                    .tag(p)
            }
        }
#if !os(macOS)
        .pickerStyle(.navigationLink)
#endif
        .foregroundStyle(.primary)
    }
}

#Preview {
    @Previewable @State var paymentMethod: Transaction.PaymentMethod = .applePay
    NavigationStack { Form { PaymentMethodPicker(paymentMethod: $paymentMethod) } }
}
