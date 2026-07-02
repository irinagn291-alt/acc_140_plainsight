import SwiftUI

/// The single breathing circle — Plainsight's only illustration. Reused by
/// onboarding and the main screen so the first thing a person sees is the
/// last thing they practice with.
struct BreathingCircleView: View {
    let scale: Double
    let isFadingOut: Bool

    init(scale: Double, isFadingOut: Bool = false) {
        self.scale = scale
        self.isFadingOut = isFadingOut
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [AppColor.accent.opacity(0.55), AppColor.accent.opacity(0.0)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 160
                    )
                )
                .blur(radius: 30)

            Circle()
                .strokeBorder(AppColor.primary.opacity(0.9), lineWidth: 1)
        }
        .frame(width: 220, height: 220)
        .scaleEffect(scale)
        .opacity(isFadingOut ? 0 : 1)
        .animation(.easeOut(duration: isFadingOut ? 1.6 : 0.2), value: isFadingOut)
    }
}

#Preview {
    ZStack {
        AppColor.background.ignoresSafeArea()
        BreathingCircleView(scale: 0.8)
    }
}
