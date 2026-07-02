import SwiftUI

/// Thin, near-silent typography per the spec's light SF Pro direction.
enum AppFont {
    static func display(_ size: CGFloat) -> Font {
        .system(size: size, weight: .ultraLight, design: .default)
    }

    static func body(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .light, design: .default)
    }

    static func caption(_ size: CGFloat = 13) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }
}

enum AppMetric {
    static let cornerRadius: CGFloat = 12
}
