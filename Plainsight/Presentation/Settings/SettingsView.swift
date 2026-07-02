import SwiftUI

struct SettingsView: View {
    let dependencies: AppDependencies

    @State private var viewModel: SettingsViewModel
    @State private var showResetConfirmation = false
    @Environment(\.dismiss) private var dismiss

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _viewModel = State(initialValue: SettingsViewModel(dependencies: dependencies))
    }

    var body: some View {
        NavigationStack {
            List {
                appearanceSection
                patternSection
                notificationsSection
                soundSection
                aboutSection
                resetSection
            }
            .scrollContentBackground(.hidden)
            .background(AppColor.background)
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Reset all data?", isPresented: $showResetConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) { viewModel.resetAllData() }
            } message: {
                Text("All practice sessions will be permanently deleted.")
            }
        }
        .preferredColorScheme(.dark)
    }

    private var appearanceSection: some View {
        Section("Appearance") {
            HStack {
                Text("Theme")
                Spacer()
                Text("Always dark")
                    .foregroundStyle(AppColor.secondary)
            }
        }
    }

    private var patternSection: some View {
        Section {
            ForEach(BreathPattern.all) { pattern in
                Button {
                    viewModel.selectPattern(pattern)
                } label: {
                    patternRow(pattern)
                }
            }
        } header: {
            Text("Breathing pattern")
        }
    }

    private func patternRow(_ pattern: BreathPattern) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(pattern.name)
                    .foregroundStyle(AppColor.text)
                Text(pattern.timingLabel)
                    .font(AppFont.caption(12))
                    .foregroundStyle(AppColor.secondary)
            }
            Spacer()
            if pattern.id == viewModel.selectedPatternID {
                Image(systemName: "checkmark")
                    .foregroundStyle(AppColor.accent)
            }
        }
    }

    private var notificationsSection: some View {
        Section("Silence on a schedule") {
            Toggle("Reminder", isOn: $viewModel.notificationsEnabled)
            if viewModel.notificationsEnabled {
                DatePicker(
                    "Time",
                    selection: $viewModel.reminderTime,
                    displayedComponents: .hourAndMinute
                )
                .onChange(of: viewModel.reminderTime) { _, _ in viewModel.reminderTimeChanged() }
            }
        }
    }

    private var soundSection: some View {
        Section {
            Toggle("Ambient tone during practice", isOn: $viewModel.ambientToneEnabled)
            ForEach(AmbientTone.all) { tone in
                Button {
                    viewModel.selectTone(tone)
                } label: {
                    toneRow(tone)
                }
            }
        } header: {
            Text("Sound")
        }
    }

    private func toneRow(_ tone: AmbientTone) -> some View {
        HStack {
            Text(tone.name)
                .foregroundStyle(AppColor.text)
            Spacer()
            if tone.id == viewModel.selectedToneID {
                Image(systemName: "checkmark")
                    .foregroundStyle(AppColor.accent)
            }
        }
    }

    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0")
                    .foregroundStyle(AppColor.secondary)
            }
            Text("Plainsight is not a substitute for therapy or medical care. If you need support, please reach out to a professional.")
                .font(AppFont.caption())
                .foregroundStyle(AppColor.secondary)
        }
    }

    private var resetSection: some View {
        Section {
            Button("Reset all data", role: .destructive) {
                showResetConfirmation = true
            }
        }
    }
}

#Preview {
    SettingsView(dependencies: PreviewDependenciesFactory.make())
}
