//
//  ContentView.swift
//  Patfi
//
//  Created by Mathieu Vandeginste on 04/09/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        AccountsDashboardView()
    }
}

#Preview {
    AccountsDashboardView()
        .modelContainer(for: [Account.self, BalanceSnapshot.self], inMemory: true)
}
