import Foundation

/// Owns the practice library screen: which pattern is active and selecting a new one.
@MainActor
@Observable
final class PracticesViewModel {
    private(set) var selectedPatternID: String

    let patterns: [BreathPattern] = BreathPattern.all

    private let defaults = UserDefaults.standard

    init() {
        selectedPatternID = defaults.string(forKey: "selectedPatternID") ?? BreathPattern.calm.id
    }

    var selectedPattern: BreathPattern {
        BreathPattern.pattern(forID: selectedPatternID)
    }

    func select(_ pattern: BreathPattern) {
        selectedPatternID = pattern.id
        defaults.set(pattern.id, forKey: "selectedPatternID")
    }
}
