import WidgetKit
import SwiftUI


struct Provider: TimelineProvider {
    
    static let mockTotal = 1234567.89.toString
    static let mockBalancesByBank = ["N26": 1000.0, "Revolut": 2000.0, "Trade Republic": 3000.0]
    static let mockbalancesByCategory: [String: Double] = ["Current": 2378, "Savings": 500.0, "Crypto": 300.0, "Stocks": 200.0, "Loan": -1000]
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), balance: Provider.mockTotal, balancesByBank: Provider.mockBalancesByBank, balancesByCategory: Provider.mockbalancesByCategory)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let balanceValue = BalanceReader.totalBalance()
        let balancesByBank = BalanceReader.balancesByBank()
        let balancesByCategory = BalanceReader.balancesByCategory()
        let entry = SimpleEntry(date: Date(), balance: balanceValue.toString, balancesByBank: balancesByBank, balancesByCategory: balancesByCategory)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let balanceValue = BalanceReader.totalBalance()
        let balancesByBank = BalanceReader.balancesByBank()
        let balancesByCategory = BalanceReader.balancesByCategory()
        let entry = SimpleEntry(date: currentDate, balance: balanceValue.toString, balancesByBank: balancesByBank, balancesByCategory: balancesByCategory)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let balance: String
    let balancesByBank: [String: Double]
    let balancesByCategory: [String: Double]
}

struct TotalBalanceWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) private var family
    
    
    var body: some View {
        switch family {
        case .systemSmall:
            VStack(alignment: .center, spacing: 10) {
                HStack(alignment: .center, spacing: 8) {
                    
                    Image(systemName: "\(Locale.current.currency?.identifier ?? "dollar")sign.bank.building")
                    Text("Patfi")
                        .font(.headline)
                }
                Text(entry.balance)
                    .font(.largeTitle)
                    .bold()
                    .minimumScaleFactor(0.2)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .padding()
        case .systemMedium:
            VStack(alignment: .leading) {
                Spacer()
                ForEach(entry.balancesByBank.sorted(by: { $0.key < $1.key }), id: \.key) { bank, total in
                    HStack {
                        Text(bank)
                            .minimumScaleFactor(0.5)
                        Spacer()
                        Text(total.toString)
                            .minimumScaleFactor(0.5)
                    }
                }
                Spacer()
                HStack {
                    Text("Balance")
                        .font(.headline)
                    Spacer()
                    Text(entry.balance)
                        .font(.headline)
                }
                Spacer()
            }
            .padding()
        case .systemLarge:
            VStack(alignment: .leading) {
                Spacer()
                ForEach(entry.balancesByCategory.sorted(by: { $0.key < $1.key }), id: \.key) { category, total in
                    HStack {
                        let category = Category(rawValue: category) ?? .other
                        HStack(spacing: 8) {
                            Circle().fill(category.color).frame(width: 10, height: 10)
                            Text(category.localizedName).minimumScaleFactor(0.5)
                        }
                        Spacer()
                        Text(total.toString)
                            .minimumScaleFactor(0.5)
                    }
                }
                Spacer()
                HStack {
                    Text("Balance")
                        .font(.headline)
                    Spacer()
                    Text(entry.balance)
                        .font(.headline)
                }
                Spacer()
            }
            .padding()
        case .systemExtraLarge:
            HStack {
                VStack(alignment: .leading) {
                    Spacer()
                    Text("Patfi")
                        .font(.largeTitle)
                        .bold()
                    Spacer()
                    ForEach(entry.balancesByBank.sorted(by: { $0.key < $1.key }), id: \.key) { bank, total in
                        HStack {
                            Text(bank)
                                .minimumScaleFactor(0.5)
                            Spacer()
                            Text(total.toString)
                                .minimumScaleFactor(0.5)
                        }
                    }
                    Spacer()
                }
                Divider()
                VStack(alignment: .leading) {
                    Spacer()
                    ForEach(entry.balancesByCategory.sorted(by: { $0.key < $1.key }), id: \.key) { category, total in
                        HStack {
                            let category = Category(rawValue: category) ?? .other
                            HStack(spacing: 8) {
                                Circle().fill(category.color).frame(width: 10, height: 10)
                                Text(category.localizedName).minimumScaleFactor(0.5)
                            }
                            Spacer()
                            Text(total.toString)
                                .minimumScaleFactor(0.5)
                        }
                    }
                    Spacer()
                    HStack {
                        Text("Balance")
                            .font(.headline)
                        Spacer()
                        Text(entry.balance)
                            .font(.headline)
                    }
                    Spacer()
                }
                .padding()
            }
        default:
            Text(entry.balance)
                .font(.title)
                .bold()
                .padding()
        }
    }
}

struct TotalBalanceWidget: Widget {
    let kind: String = "TotalBalanceWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TotalBalanceWidgetEntryView(entry: entry)
                .containerBackground(
                    LinearGradient(colors: [.blue.opacity(0.3), .blue.opacity(0.7)],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing),
                    for: .widget
                )
        }
        .configurationDisplayName("Total Balance")
        .description("Total balance of my accounts")
    }
}

#Preview(as: .systemSmall) {
    TotalBalanceWidget()
} timeline: {
    SimpleEntry(date: .now, balance: Provider.mockTotal, balancesByBank: Provider.mockBalancesByBank, balancesByCategory: Provider.mockbalancesByCategory)
}
