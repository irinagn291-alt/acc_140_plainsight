import SwiftUI

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&rgb)
        let r = Double((rgb & 0xFF0000) >> 16) / 255
        let g = Double((rgb & 0x00FF00) >> 8) / 255
        let b = Double(rgb & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

/// Design tokens for Plainsight, sourced from the concept's Visual Direction spec.
enum AppColor {
    static let primary = Color(hex: "#FFFFFF")
    static let secondary = Color(hex: "#9AA0A6")
    static let accent = Color(hex: "#B9A7FF")
    static let background = Color(hex: "#000000")
    static let surface = Color(hex: "#0C0C0E")
    static let text = Color(hex: "#FFFFFF")
}
