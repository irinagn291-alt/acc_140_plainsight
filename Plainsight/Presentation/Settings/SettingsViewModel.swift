import Foundation

@MainActor
@Observable
final class SettingsViewModel {
    var notificationsEnabled: Bool {
        didSet { handleNotificationsToggle() }
    }
    var reminderTime: Date
    var ambientToneEnabled: Bool {
        didSet { UserDefaults.standard.set(ambientToneEnabled, forKey: "ambientToneEnabled") }
    }
    private(set) var didResetData = false

    private(set) var selectedPatternID: String
    private(set) var selectedToneID: String

    private let dependencies: AppDependencies
    private let defaults = UserDefaults.standard

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        self.notificationsEnabled = defaults.bool(forKey: "notificationsEnabled")
        self.ambientToneEnabled = defaults.bool(forKey: "ambientToneEnabled")
        self.selectedPatternID = defaults.string(forKey: "selectedPatternID") ?? BreathPattern.calm.id
        self.selectedToneID = defaults.string(forKey: "selectedToneID") ?? AmbientTone.calm.id
        if let stored = defaults.object(forKey: "reminderTime") as? Date {
            self.reminderTime = stored
        } else {
            self.reminderTime = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: .now) ?? .now
        }
    }

    func selectPattern(_ pattern: BreathPattern) {
        selectedPatternID = pattern.id
        defaults.set(selectedPatternID, forKey: "selectedPatternID")
    }

    func selectTone(_ tone: AmbientTone) {
        selectedToneID = tone.id
        defaults.set(selectedToneID, forKey: "selectedToneID")
    }

    func reminderTimeChanged() {
        defaults.set(reminderTime, forKey: "reminderTime")
        guard notificationsEnabled else { return }
        Task { await scheduleReminder() }
    }

    private func handleNotificationsToggle() {
        defaults.set(notificationsEnabled, forKey: "notificationsEnabled")
        if notificationsEnabled {
            Task { [weak self] in
                let granted = await NotificationService.requestAuthorization()
                guard granted else {
                    self?.notificationsEnabled = false
                    return
                }
                await self?.scheduleReminder()
            }
        } else {
            NotificationService.cancelDailyReminder()
        }
    }

    private func scheduleReminder() async {
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        await NotificationService.scheduleDailyReminder(at: components)
    }

    func resetAllData() {
        Task { [weak self] in
            guard let self else { return }
            try? await self.dependencies.resetAllDataUseCase.execute()
            self.didResetData = true
        }
    }
}
