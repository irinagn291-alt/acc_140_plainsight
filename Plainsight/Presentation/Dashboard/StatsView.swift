import SwiftUI

/// Quiet stats — no badges, no streak fire icons, just two numbers and a line.
struct StatsView: View {
    let dependencies: AppDependencies

    @State private var viewModel: StatsViewModel
    @Environment(\.dismiss) private var dismiss

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _viewModel = State(initialValue: StatsViewModel(dependencies: dependencies))
    }

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()

            if viewModel.isLoading {
                EmptyView()
            } else if !viewModel.hasAnySession {
                emptyState
            } else {
                content
            }
        }
        .task { await viewModel.load() }
        .overlay(alignment: .topTrailing) {
            Button("Done") { dismiss() }
                .font(AppFont.body(14))
                .foregroundStyle(AppColor.secondary)
                .padding()
        }
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: 40) {
                summary
                recentList
            }
            .padding(.vertical, 56)
        }
    }

    private var summary: some View {
        VStack(spacing: 40) {
            VStack(spacing: 8) {
                Text("\(viewModel.stats.totalMinutes)")
                    .font(AppFont.display(64))
                    .foregroundStyle(AppColor.text)
                Text("minutes of practice")
                    .font(AppFont.caption())
                    .foregroundStyle(AppColor.secondary)
            }

            VStack(spacing: 8) {
                Text("\(viewModel.stats.currentStreakDays)")
                    .font(AppFont.display(40))
                    .foregroundStyle(AppColor.text)
                Text("day streak")
                    .font(AppFont.caption())
                    .foregroundStyle(AppColor.secondary)
            }

            VStack(spacing: 12) {
                SparklineView(values: viewModel.stats.dailyMinutesLastMonth)
                    .padding(.horizontal, 48)

                Text("\(viewModel.stats.totalSessions) sessions · last 30 days")
                    .font(AppFont.caption())
                    .foregroundStyle(AppColor.secondary.opacity(0.6))
            }
        }
    }

    @ViewBuilder
    private var recentList: some View {
        if !viewModel.recentSessions.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Recent")
                    .font(AppFont.caption())
                    .foregroundStyle(AppColor.secondary)

                VStack(spacing: 0) {
                    ForEach(viewModel.recentSessions) { session in
                        sessionRow(session)
                        if session.id != viewModel.recentSessions.last?.id {
                            Divider().overlay(Color.white.opacity(0.06))
                        }
                    }
                }
                .background(AppColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppMetric.cornerRadius))
            }
            .padding(.horizontal, 32)
        }
    }

    private func sessionRow(_ session: BreathSession) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(session.pattern.name)
                    .font(AppFont.body(15))
                    .foregroundStyle(AppColor.text)
                Text(session.startTime.formatted(date: .abbreviated, time: .shortened))
                    .font(AppFont.caption(12))
                    .foregroundStyle(AppColor.secondary)
            }
            Spacer()
            Text(durationLabel(session.duration))
                .font(AppFont.body(14))
                .foregroundStyle(AppColor.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func durationLabel(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return minutes > 0 ? "\(minutes) min" : "\(seconds) s"
    }

    private var emptyState: some View {
        VStack {
            Spacer()
            Text("Empty here — as it should be. Take one breath.")
                .font(AppFont.body(16))
                .foregroundStyle(AppColor.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 48)
            Spacer()
        }
    }
}

#if DEBUG
#Preview {
    StatsView(dependencies: PreviewDependenciesFactory.make())
}
#endif
