import Foundation
import SwiftData

class BankRepository {
    
    func delete(_ bank: Bank, context: ModelContext) {
        context.delete(bank)
        do {
            try context.save()
        } catch {
            print("Failed to delete banks: \(error.localizedDescription)")
        }
    }
    
    func updateOrCreate(name: String, bank: Bank?, palette: Bank.Palette, logoAvailability: Bank.LogoAvailability, context: ModelContext) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if let bank { // Update
            if bank.name != trimmedName {
                bank.name = trimmedName
            }
            bank.color = palette
            bank.logoAvailability = logoAvailability
        } else { // Creation
            let bank = Bank(name: trimmedName, color: palette, logoAvaibility: logoAvailability)
            context.insert(bank)
        }
        do {
            try context.save()
        }
        catch {
            print("Save error:", error)
        }
    }
}
