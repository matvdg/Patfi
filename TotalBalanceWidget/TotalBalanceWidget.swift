import WidgetKit
import SwiftUI
import Charts


struct Provider: TimelineProvider {
    
    static let mockTotal = 1234567.89.toString
    static let mockBalancesByBank: [(bankName: String, total: Double, colorPalette: String)] = [
        (bankName: "N26", total: 1000.0, colorPalette: "blue"),
        (bankName: "Revolut", total: 2000.0, colorPalette: "green"),
        (bankName: "Trade Republic", total: 3000.0, colorPalette: "yellow")
    ]
    static let mockbalancesByCategory: [String: Double] = ["Current": 2378, "Savings": 500.0, "Crypto": 300.0, "Stocks": 200.0, "Loan": -1000]
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), balance: Provider.mockTotal, balancesByBank: Provider.mockBalancesByBank, balancesByCategory: Provider.mockbalancesByCategory)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let balanceValue = BalanceReader.totalBalance
        let balancesByBankDicts = BalanceReader.balancesByBank
        let balancesByBank: [(bankName: String, total: Double, colorPalette: String)] = balancesByBankDicts.compactMap { dict in
            let bankName = dict["bankName"] as? String ?? "Unknown"
            let total = dict["total"] as? Double ?? 0
            let colorPalette = dict["colorPalette"] as? String ?? "gray"
            return (bankName: bankName, total: total, colorPalette: colorPalette)
        }
        let balancesByCategory = BalanceReader.balancesByCategory
        let entry = SimpleEntry(date: Date(), balance: balanceValue.toString, balancesByBank: balancesByBank, balancesByCategory: balancesByCategory)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let balanceValue = BalanceReader.totalBalance
        let balancesByBankDicts = BalanceReader.balancesByBank
        let balancesByBank: [(bankName: String, total: Double, colorPalette: String)] = balancesByBankDicts.compactMap { dict in
            let bankName = dict["bankName"] as? String ?? "Unknown"
            let total = dict["total"] as? Double ?? 0
            let colorPalette = dict["colorPalette"] as? String ?? "gray"
            return (bankName: bankName, total: total, colorPalette: colorPalette)
        }
        let balancesByCategory = BalanceReader.balancesByCategory
        let entry = SimpleEntry(date: currentDate, balance: balanceValue.toString, balancesByBank: balancesByBank, balancesByCategory: balancesByCategory)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let balance: String
    let balancesByBank: [(bankName: String, total: Double, colorPalette: String)]
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
                    Bank.sfSymbol
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
            VStack(alignment: .leading, spacing: 4) {
                Spacer()
                let rows = entry.balancesByBank.sorted { $0.bankName < $1.bankName }
                ForEach(Array(rows.enumerated()), id: \.offset) { _, item in
                    let bank = Bank(name: item.bankName, color: Bank.Palette(rawValue: item.colorPalette) ?? .gray)
                    let logo = bank.getLogoFromCache()
                    let total = item.total
                    HStack {
                        if let logoImage = logo {
                            logoImage
                                .resizable()
                                .scaledToFill()
                                .frame(width: 14, height: 14)
                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        } else {
                            ZStack {
                                Circle()
                                    .fill(bank.swiftUIColor)
                                    .frame(width: 14, height: 14)
                                Text(bank.initialLetter)
                                    .font(.caption2.bold())
                                    .foregroundStyle(.white)
                            }
                        }
                        Text(bank.name.isEmpty ? "No bank" : bank.name)
                            .foregroundColor(.primary)
                            .minimumScaleFactor(0.1)
                        Spacer()
                        Text(total.toString)
                            .minimumScaleFactor(0.3)
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
            VStack(alignment: .center, spacing: 4) {
                ZStack {
                    Chart {
                        ForEach(entry.balancesByCategory.sorted(by: { $0.key < $1.key }), id: \.key) { categoryKey, total in
                            let category = Category(rawValue: categoryKey) ?? .other
                            SectorMark(
                                angle: .value("Total", total),
                                innerRadius: .ratio(0.6),
                                angularInset: 1.0
                            )
                            .foregroundStyle(category.color)
                        }
                    }
                    .frame(height: 200)
                    .chartLegend(.hidden)
                    .frame(maxWidth: .infinity)
                    
                    VStack {
                        Text("Total")
                            .font(.caption)
                        Text(entry.balance)
                            .font(.headline)
                            .bold()
                            .minimumScaleFactor(0.5)
                            .frame(maxWidth: 100)
                            .multilineTextAlignment(.center)
                    }
                }
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
            }
            .padding()
        case .systemExtraLarge:
            HStack {
                VStack(alignment: .leading) {
                    Spacer()
                    let rows = entry.balancesByBank.sorted { $0.bankName < $1.bankName }
                    ForEach(Array(rows.enumerated()), id: \.offset) { _, item in
                        let bank = Bank(name: item.bankName, color: Bank.Palette(rawValue: item.colorPalette) ?? .gray)
                        let logo = bank.getLogoFromCache()
                        let total = item.total
                        HStack {
                            if let logoImage = logo {
                                logoImage
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 14, height: 14)
                                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                            } else {
                                ZStack {
                                    Circle()
                                        .fill(bank.swiftUIColor)
                                        .frame(width: 14, height: 14)
                                    Text(bank.initialLetter)
                                        .font(.caption2.bold())
                                        .foregroundStyle(.white)
                                }
                            }
                            Text(bank.name.isEmpty ? "No bank" : bank.name)
                                .foregroundColor(.primary)
                                .minimumScaleFactor(0.1)
                            Spacer()
                            Text(total.toString)
                                .minimumScaleFactor(0.3)
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
