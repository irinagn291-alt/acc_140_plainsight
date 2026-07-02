import SwiftUI

/// The whole app, distilled to one screen: a single dial / gesture canvas.
/// No menu, no tab bar — long-press to start, swipe to set duration.
struct MainView: View {
    let dependencies: AppDependencies

    @State private var viewModel: BreathViewModel
    @State private var showStats = false
    @State private var showSettings = false
    @State private var showPractices = false

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _viewModel = State(initialValue: BreathViewModel(dependencies: dependencies))
    }

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                BreathingCircleView(scale: viewModel.circleScale, isFadingOut: viewModel.isFadingOut)
                    .overlay(alignment: .center) {
                        if viewModel.isSessionActive {
                            Text(viewModel.phase.label)
                                .font(AppFont.caption())
                                .foregroundStyle(AppColor.secondary)
                                .opacity(viewModel.isFadingOut ? 0 : 1)
                        }
                    }

                statusLabel

                Spacer()

                practiceChip

                oneBreathControl
                    .padding(.bottom, 32)
            }
            .padding(.horizontal, 24)

            cornerControls
        }
        .contentShape(Rectangle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 12)
                .onChanged { value in viewModel.dragChanged(translationHeight: value.translation.height) }
                .onEnded { _ in viewModel.dragEnded() }
        )
        .gesture(
            LongPressGesture(minimumDuration: 0.6)
                .onEnded { _ in viewModel.startSession() }
        )
        .onTapGesture {
            if viewModel.isSessionActive { viewModel.endSessionEarly() }
        }
        .sheet(isPresented: $showStats) {
            StatsView(dependencies: dependencies)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(dependencies: dependencies)
        }
        .sheet(isPresented: $showPractices) {
            PracticesView()
        }
    }

    private var practiceChip: some View {
        Group {
            if !viewModel.isSessionActive {
                Button {
                    showPractices = true
                } label: {
                    HStack(spacing: 6) {
                        Text(viewModel.activePatternName)
                            .font(AppFont.body(14))
                            .foregroundStyle(AppColor.text.opacity(0.85))
                        Image(systemName: "chevron.up")
                            .font(.system(size: 10, weight: .light))
                            .foregroundStyle(AppColor.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppColor.surface)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.white.opacity(0.08), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Change practice, current: \(viewModel.activePatternName)")
            }
        }
    }

    private var statusLabel: some View {
        Group {
            if viewModel.isSessionActive {
                EmptyView()
            } else {
                Text(viewModel.statusText.isEmpty ? "Long-press to begin" : viewModel.statusText)
                    .font(AppFont.body(14))
                    .foregroundStyle(AppColor.secondary)
            }
        }
    }

    private var oneBreathControl: some View {
        Group {
            if !viewModel.isSessionActive {
                Button {
                    viewModel.startOneBreath()
                } label: {
                    Text("One breath · 30s")
                        .font(AppFont.caption())
                        .foregroundStyle(AppColor.secondary.opacity(0.7))
                }
            }
        }
    }

    private var cornerControls: some View {
        VStack {
            HStack {
                Button { showSettings = true } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 16, weight: .ultraLight))
                        .foregroundStyle(AppColor.secondary.opacity(0.45))
                }

                Spacer()

                Button { showStats = true } label: {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 16, weight: .ultraLight))
                        .foregroundStyle(AppColor.secondary.opacity(0.45))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            Spacer()
        }
        .opacity(viewModel.isSessionActive ? 0 : 1)
        .animation(.easeInOut(duration: 0.3), value: viewModel.isSessionActive)
    }
}

#Preview {
    MainView(dependencies: PreviewDependenciesFactory.make())
}
