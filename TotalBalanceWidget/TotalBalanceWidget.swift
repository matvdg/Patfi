import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), balance: 1234.toString)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let balanceValue = BalanceReader.totalBalance()
        let entry = SimpleEntry(date: Date(), balance: balanceValue.toString)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let balanceValue = BalanceReader.totalBalance()
        let entry = SimpleEntry(date: currentDate, balance: balanceValue.toString)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let balance: String
}

struct TotalBalanceWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Total Balance")
            Text(entry.balance)
                .font(.largeTitle)
                .bold()
        }
    }
}

struct TotalBalanceWidget: Widget {
    let kind: String = "TotalBalanceWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(macOS 14.0, iOS 17.0, *) {
                TotalBalanceWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                TotalBalanceWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Total Balance")
        .description("Total balance of my accounts")
    }
}

#Preview(as: .systemSmall) {
    TotalBalanceWidget()
} timeline: {
    SimpleEntry(date: .now, balance: 12345.toString)
}
