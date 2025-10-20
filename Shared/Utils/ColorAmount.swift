import SwiftUI

struct ColorAmount: View {
    
    var amount: Double
    
    var body: some View {
        Group {
            switch amount {
            case ..<0:
                Text(amount.toString).foregroundStyle(.red)
            case 0:
                Text(amount.toString)
            default:
                Text("+\(amount.toString)").foregroundStyle(.green)
            }
        }
        .lineLimit(1)
        #if os(watchOS)
        .minimumScaleFactor(0.5)
        #endif
    }
}

#Preview {
    VStack {
        ColorAmount(amount: 2344.9999)
        ColorAmount(amount: 2344.99)
        ColorAmount(amount: 0)
        ColorAmount(amount: -2344.9999)
    }
}
