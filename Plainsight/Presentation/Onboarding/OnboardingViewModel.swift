import Foundation
import SwiftUI

@MainActor
@Observable
final class OnboardingViewModel {
    enum Page: Int, CaseIterable {
        case breathe
        case swipe
        case schedule
    }

    var currentPage: Page = .breathe
    var demoCircleScale: Double = 0.6
    var isRequestingNotifications = false

    func advance() {
        switch currentPage {
        case .breathe: currentPage = .swipe
        case .swipe: currentPage = .schedule
        case .schedule: break
        }
    }

    func startDemoBreathing() {
        guard !isAnimatingDemo else { return }
        isAnimatingDemo = true
        animateDemoCycle()
    }

    private var isAnimatingDemo = false

    private func animateDemoCycle() {
        Task { [weak self] in
            guard let self else { return }
            while self.currentPage == .breathe {
                withAnimation(.easeInOut(duration: 2.6)) {
                    self.demoCircleScale = self.demoCircleScale == 0.6 ? 1.0 : 0.6
                }
                try? await Task.sleep(nanoseconds: 2_600_000_000)
            }
            self.isAnimatingDemo = false
        }
    }

    func requestNotificationsAndFinish(completion: @escaping () -> Void) {
        guard !isRequestingNotifications else { return }
        isRequestingNotifications = true
        Task { [weak self] in
            _ = await NotificationService.requestAuthorization()
            self?.isRequestingNotifications = false
            completion()
        }
    }
}
