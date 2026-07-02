import SwiftUI

/// Interactive single-CTA, 3-screen onboarding, per spec.
struct OnboardingView: View {
    let onFinish: () -> Void

    @State private var viewModel = OnboardingViewModel()

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Group {
                    switch viewModel.currentPage {
                    case .breathe: breathePage
                    case .swipe: swipePage
                    case .schedule: schedulePage
                    }
                }
                .transition(.opacity)
                .id(viewModel.currentPage)

                Spacer()

                pageIndicator
                    .padding(.bottom, 24)
            }
            .padding(.horizontal, 32)
        }
        .animation(.easeInOut(duration: 0.4), value: viewModel.currentPage)
        .onAppear { viewModel.startDemoBreathing() }
    }

    private var breathePage: some View {
        VStack(spacing: 40) {
            BreathingCircleView(scale: viewModel.demoCircleScale)

            Text("Breathe with me")
                .font(AppFont.display(28))
                .foregroundStyle(AppColor.text)

            ctaButton(title: "Try it") { viewModel.advance() }
        }
    }

    private var swipePage: some View {
        VStack(spacing: 40) {
            VStack(spacing: 16) {
                Image(systemName: "arrow.up.and.down")
                    .font(.system(size: 32, weight: .thin))
                    .foregroundStyle(AppColor.accent)
                Text("Swipe = duration")
                    .font(AppFont.display(28))
                    .foregroundStyle(AppColor.text)
                    .multilineTextAlignment(.center)
            }

            ctaButton(title: "Got it") { viewModel.advance() }
        }
    }

    private var schedulePage: some View {
        VStack(spacing: 40) {
            VStack(spacing: 16) {
                Image(systemName: "bell")
                    .font(.system(size: 32, weight: .thin))
                    .foregroundStyle(AppColor.accent)
                Text("Silence on a schedule?")
                    .font(AppFont.display(26))
                    .foregroundStyle(AppColor.text)
                    .multilineTextAlignment(.center)
            }

            ctaButton(title: "Begin", isLoading: viewModel.isRequestingNotifications) {
                viewModel.requestNotificationsAndFinish(completion: onFinish)
            }
        }
    }

    private func ctaButton(title: String, isLoading: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.body(17))
                .foregroundStyle(AppColor.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: AppMetric.cornerRadius)
                        .fill(AppColor.primary.opacity(isLoading ? 0.6 : 1))
                )
        }
        .disabled(isLoading)
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(OnboardingViewModel.Page.allCases, id: \.self) { page in
                Rectangle()
                    .fill(page == viewModel.currentPage ? AppColor.primary : AppColor.secondary.opacity(0.3))
                    .frame(width: page == viewModel.currentPage ? 18 : 6, height: 1.5)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.currentPage)
            }
        }
    }
}

#Preview {
    OnboardingView(onFinish: {})
}
