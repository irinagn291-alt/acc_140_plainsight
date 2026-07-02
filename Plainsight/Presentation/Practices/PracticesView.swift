import SwiftUI

/// The practice library: every breathing pattern with its timing and a one-line
/// description. Selecting one makes it the active practice on the main canvas.
struct PracticesView: View {
    @State private var viewModel = PracticesViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 12) {
                    Text("Practices")
                        .font(AppFont.display(30))
                        .foregroundStyle(AppColor.text)
                        .padding(.top, 32)
                        .padding(.bottom, 12)

                    ForEach(viewModel.patterns) { pattern in
                        practiceCard(pattern)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .overlay(alignment: .topTrailing) {
            Button("Done") { dismiss() }
                .font(AppFont.body(14))
                .foregroundStyle(AppColor.secondary)
                .padding()
        }
        .preferredColorScheme(.dark)
    }

    private func practiceCard(_ pattern: BreathPattern) -> some View {
        let isSelected = pattern.id == viewModel.selectedPatternID
        return Button {
            viewModel.select(pattern)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(pattern.name)
                        .font(AppFont.body(18))
                        .foregroundStyle(AppColor.text)
                    Spacer()
                    Text(pattern.timingLabel)
                        .font(AppFont.caption())
                        .foregroundStyle(isSelected ? AppColor.accent : AppColor.secondary)
                }
                Text(pattern.about)
                    .font(AppFont.caption())
                    .foregroundStyle(AppColor.secondary)
                    .multilineTextAlignment(.leading)
                phaseBar(pattern)
            }
            .padding(16)
            .background(AppColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppMetric.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: AppMetric.cornerRadius)
                    .stroke(isSelected ? AppColor.accent.opacity(0.7) : Color.white.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(pattern.name), \(pattern.timingLabel)\(isSelected ? ", selected" : "")")
    }

    /// A proportional inhale / hold / exhale bar so the rhythm is visible at a glance.
    private func phaseBar(_ pattern: BreathPattern) -> some View {
        GeometryReader { geometry in
            let total = max(pattern.cycleDuration, 1)
            HStack(spacing: 2) {
                Capsule()
                    .fill(AppColor.accent.opacity(0.8))
                    .frame(width: geometry.size.width * pattern.inhaleSeconds / total)
                if pattern.holdSeconds > 0 {
                    Capsule()
                        .fill(AppColor.secondary.opacity(0.5))
                        .frame(width: geometry.size.width * pattern.holdSeconds / total)
                }
                Capsule()
                    .fill(AppColor.accent.opacity(0.35))
            }
        }
        .frame(height: 4)
        .padding(.top, 4)
    }
}

#Preview {
    PracticesView()
}
