import SwiftData
import SwiftUI

/// Switches between onboarding and the main breathing canvas, and owns the
/// single `AppDependencies` instance for the app's lifetime.
struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(\.modelContext) private var modelContext
    @State private var dependencies: AppDependencies?

    var body: some View {
        Group {
            if let dependencies {
                if hasCompletedOnboarding {
                    MainView(dependencies: dependencies)
                } else {
                    OnboardingView(onFinish: { hasCompletedOnboarding = true })
                }
            } else {
                Color.clear
            }
        }
        .preferredColorScheme(.dark)
        .tint(AppColor.accent)
        .task {
            if dependencies == nil {
                dependencies = AppDependencies(modelContext: modelContext)
            }
        }
    }
}
