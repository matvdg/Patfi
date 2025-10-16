import SwiftUI

struct PaymentMethodLogo: View {
    
    let paymentMethod: Transaction.PaymentMethod

    var body: some View {
        ZStack {
            Circle()
                .fill(paymentMethod.color)
                .frame(width: 40, height: 40)
            Image(systemName: paymentMethod.iconName)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    let columns = Array(repeating: GridItem(.flexible()), count: 4)
    LazyVGrid(columns: columns) {
        PaymentMethodLogo(paymentMethod: .cheque)
        PaymentMethodLogo(paymentMethod: .creditCard)
        PaymentMethodLogo(paymentMethod: .applePay)
        PaymentMethodLogo(paymentMethod: .directDebit)
        PaymentMethodLogo(paymentMethod: .cashWithdrawal)
        PaymentMethodLogo(paymentMethod: .bankTransfer)
        
    }
    
}
